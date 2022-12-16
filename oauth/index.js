const BASIC_USER = '';
const BASIC_PASS = '';
const client_id = 'cf9fbjz6j9i6k6guz3dwh6qff5dluz';
const client_secret = '';
const redirect_uri = "https://oauth.k10labs.workers.dev/activate"

async function handleRequest(request) {
    const url = new URL(request.url);
    //   Step 1: Roku Device registers an activation code.
    if (url.pathname.includes("/register")) { // API for Stich Client
        if (request.headers.has('Authorization')) {
            const { user, pass } = basicAuthentication(request);
            if (verifyCredentials(user, pass)) {
                return await register();
            } else {
                return unauthorizedException();
            }
        } else {
            return unauthorizedException();
        }

    }

    // Step 2: User goes to activation page
    if (url.pathname === "/") { // Default Home Page where user types code and clicks 'go'
        return giveLoginPage(request);
    }

    if ((url.pathname === '/favicon.ico') || (url.pathname === '/robots.txt')) {
        return nullResponse();
    }
    // Step 3: User clicks 'submit after typing in code, and that info is posted here, this redirects to have the user authorize the app.
    if (url.pathname.includes("/callback")) { // API. Where user sent when clicked 'go', stores code / user link, and sends to twitch.
        return await sendtoAuthorize(request);
    }
    // Step 4 Successful activation sends the user here:
    if (url.pathname.includes("/activate")) { // API. After user completes twich login, we land here.
        var code = getParameterByName("code", request.url)
        var state = getParameterByName("state", request.url)
        await STITCH.put(state, code)
        return giveGetResultsPage(request);
    }


    if (url.pathname.includes("/unregister")) { // API for Stich Client
        if (request.headers.has('Authorization')) {
            const { user, pass } = basicAuthentication(request);
            if (verifyCredentials(user, pass)) {
                return unregister(request)
            } else {
                return unauthorizedException();
            }
        } else {
            return unauthorizedException();
        }

    }
}

function getParameterByName(name, url) {
    name = name.replace(/[\[\]]/g, '\\$&')
    name = name.replace(/\//g, '')
    var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url)

    if (!results) return null
    else if (!results[2]) return ''
    else if (results[2]) {
        results[2] = results[2].replace(/\//g, '')
    }

    return decodeURIComponent(results[2].replace(/\+/g, ' '));
}


function requestCredentials() {
    return new Response('You need to login.', {
        status: 401,
        headers: {
            // Prompts the user for credentials.
            'WWW-Authenticate': 'Basic realm="my scope", charset="UTF-8"',
        }
    });
}

function makeid(length) {
    var result = '';
    var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    var charactersLength = characters.length;
    for (var i = 0; i < length; i++) {
        result += characters.charAt(Math.floor(Math.random() * charactersLength));
    }
    return result;
}

async function register() {
    var code = makeid(4)
    let registration = await STITCH.put(code, "pending", { expirationTtl: 120 })
    return new Response(code, {
        status: 200
    });
}




async function unregister(request) {
    var code = getParameterByName("code", request.url)
    var auth_code = await STITCH.get(code)
    if (auth_code && auth_code !== "pending") {
        let authorizationUri = new URL(`https://id.twitch.tv/oauth2/token?client_id=${client_id}&client_secret=${client_secret}&code=${auth_code}&grant_type=authorization_code&redirect_uri=${redirect_uri}`);
        let access_token = fetch(authorizationUri, {
            method: "POST",
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
                accept: "*/*"
            }
        })
        return access_token
    }
    return new Response(JSON.stringify({ "status": "Still Waiting", "AuthCode": auth_code }), { status: 200 })
}

function nullResponse() {
    return new Response(null, { status: 204 });
}

function handleError(err) {
    const message = err.reason || err.stack || 'Unknown Error';

    return new Response(message, {
        status: err.status || 500,
        statusText: err.statusText || null,
        headers: {
            'Content-Type': 'text/plain;charset=UTF-8',
            // Disables caching by default.
            'Cache-Control': 'no-store',
            // Returns the "Content-Length" header for HTTP HEAD requests.
            'Content-Length': message.length
        }
    });
}

function giveRegisterPage(request) {
    return new Response(request)
}

function isExpired(token) {
    // check expiration
    if (token.exp - Math.round(Date.now() / 1000) < 0)
        return true
    return false
}

function cors() {
    return new Response(null, {
        headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type",
        },
    });
}


function giveAcceptPage(request) {
    let req_url = new URL(request.url);
    let params = req_url.search
    let fetchCodeURL = ""
    return `<!DOCTYPE html>
  <html>
    <body>
      <a href="${fetchCodeURL}"> Accept</button>
    </body>
  </html>
    `;
}
async function readRequestBody(request) {
    const { headers } = request;
    const contentType = headers.get('content-type') || '';

    if (contentType.includes('application/json')) {
        return JSON.stringify(await request.json());
    } else if (contentType.includes('application/text')) {
        return request.text();
    } else if (contentType.includes('text/html')) {
        return request.text();
    } else if (contentType.includes('form')) {
        const formData = await request.formData();
        const body = {};
        for (const entry of formData.entries()) {
            if (entry[0].includes("[]")) {
                entry[0] = entry[0].replace("[]", "")
                body[(entry[0] || '')] = (body[entry[0]] || '') + `${entry[1]}`.toUpperCase()
            } else {
                body[entry[0]] = entry[1];
            }
        }
        return body;
    } else {
        // Perhaps some other type of data was submitted in the form
        // like an image, or some other binary data.
        return None;
    }
}
// sendtoAuthorize generates a URL to request for a code
// then responds with a redirect to this URL
async function sendtoAuthorize(request) {
    let scopes = [
        "analytics:read:games",
        "bits:read",
        "channel:edit:commercial",
        "channel:read:hype_train",
        "user:read:broadcast",
        "chat:read",
        "chat:edit"
    ]
    var encoded_scopes = []
    for (var scope of scopes) {
        encoded_scopes.push(encodeURIComponent(scope))
    }
    const formData = await readRequestBody(request)
    const state = formData["state"]
    let authorizationUri = new URL(`https://id.twitch.tv/oauth2/authorize?scope=${encoded_scopes.join("+")}`);
    authorizationUri.searchParams.set("response_type", "code");
    authorizationUri.searchParams.set("state", state)
    authorizationUri.searchParams.set("nonce", state)
    authorizationUri.searchParams.set("force_verify", true)
    authorizationUri.searchParams.set("client_id", client_id);
    authorizationUri.searchParams.set("redirect_uri", redirect_uri);
    authorizationUri.searchParams.set("claims", { "userinfo": { "email": null, "email_verified": null, "picture": null, "preferred_username": null, "updated_at": null } })
    console.log(authorizationUri.href);
    //http://<auth server> /oauth/authorize?response_type=code&client_id=vicsecret&redirect_uri=https%3A%2F%2Fmissv.info%2Foauth%2Fapp%2Fcallback&scope=user.read&state=someState
    return Response.redirect(authorizationUri.href, 302);
}



async function giveResource(request) {
    var respBody = factoryHookResponse({})
    let token = ""
    let decodedJWT = factoryJWTPayload()
    try { //validate request is who they claim
        token = getCookie(request.headers.get("cookie"), "token")
        if (!token) token = request.headers.get("Authorization").substring(7)
        decodedJWT = jwt.verify(token, credentials.storage.secret)
            // @ts-ignore
        let storedToken = await TOKENS.get(decodedJWT.sub)
        if (isExpired(storedToken)) throw new Error("token is expired") /* TODO instead of throwing error send to refresh */
        if (storedToken != token) throw new Error("token does not match what is stored")
    } catch (e) {
        respBody.errors.push(factoryIError({ message: e.message, type: "oauth" }))
        return new Response(JSON.stringify(respBody), init)
    }
    respBody.body = getUsersPersonalBody(decodedJWT.sub)
    return new Response(JSON.stringify(respBody), init)
}

function giveLoginPage(request) {
    // let req_url = new URL(request.url);
    // let redirect_url = encodeURI(req_url.searchParams.get("redirect_uri"));
    pagedata = `<!DOCTYPE html>
    <html><head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.0/css/bootstrap.min.css" crossorigin="anonymous">
    <style type="text/css">
  body {
  background: #f6f6f9;
  padding: 4vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
}

form {
  padding: 2rem;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  max-width: 400px;
  background: #fff;
}
form .form-control {
  text-transform: uppercase;
  display: block;
  height: 4rem;
  margin-right: 0.5rem;
  text-align: center;
  font-size: 1.25rem;
  min-width: 0;
}
form .form-control:last-child {
  margin-right: 0;
}
    </style>
    </head>

    <body>
    <form action="callback" method="post">
        <h4 class="text-center mb-4">Enter your code</h4>
        <div class="d-flex mb-3">
            <input name="state[]" type="tel" maxlength="1" pattern="[0-9A-z]" class="form-control">
            <input name="state[]" type="tel" maxlength="1" pattern="[0-9A-z]" class="form-control">
            <input name="state[]" type="tel" maxlength="1" pattern="[0-9A-z]" class="form-control">
            <input name="state[]" type="tel" maxlength="1" pattern="[0-9A-z]" class="form-control">
        </div>
        <button type="submit" class="w-100 btn btn-primary">Link</button>
    </form>
            <script>
const form = document.querySelector('form')
const inputs = form.querySelectorAll('input')
const KEYBOARDS = {
  backspace: 8,
  arrowLeft: 37,
  arrowRight: 39,
}

function handleInput(e) {
  const input = e.target
  const nextInput = input.nextElementSibling
  if (nextInput && input.value) {
    nextInput.focus()
    if (nextInput.value) {
      nextInput.select()
    }
  }
}

function handlePaste(e) {
  e.preventDefault()
  const paste = e.clipboardData.getData('text')
  inputs.forEach((input, i) => {
    input.value = paste[i] || ''
  })
}

function handleBackspace(e) {
  const input = e.target
  if (input.value) {
    input.value = ''
    return
  }

  input.previousElementSibling.focus()
}

function handleArrowLeft(e) {
  const previousInput = e.target.previousElementSibling
  if (!previousInput) return
  previousInput.focus()
}

function handleArrowRight(e) {
  const nextInput = e.target.nextElementSibling
  if (!nextInput) return
  nextInput.focus()
}

form.addEventListener('input', handleInput)
inputs[0].addEventListener('paste', handlePaste)

inputs.forEach(input => {
  input.addEventListener('focus', e => {
    setTimeout(() => {
      e.target.select()
    }, 0)
  })

  input.addEventListener('keydown', e => {
    switch(e.keyCode) {
      case KEYBOARDS.backspace:
        handleBackspace(e)
        break
      case KEYBOARDS.arrowLeft:
        handleArrowLeft(e)
        break
      case KEYBOARDS.arrowRight:
        handleArrowRight(e)
        break
      default:
    }
  })
})

        </script>
    </body>
</html>
`
    return new Response(pagedata, {
        status: 200,
        headers: {
            'Content-Type': 'text/html',
            'Cache-Control': 'no-store',
            'Content-Length': pagedata.length
        }
    });
}



function giveGetResultsPage(request) {
    pagedata = `<!DOCTYPE html>
    <html><head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.0/css/bootstrap.min.css" crossorigin="anonymous">
    <style type="text/css">
  body {
  background: #f6f6f9;
  padding: 4vw;
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
}

form {
  padding: 2rem;
  border-radius: 4px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  max-width: 400px;
  background: #fff;
}
form .form-control {
  text-transform: uppercase;
  display: block;
  height: 4rem;
  margin-right: 0.5rem;
  text-align: center;
  font-size: 1.25rem;
  min-width: 0;
}
form .form-control:last-child {
  margin-right: 0;
}
    </style>
    </head>

    <body>
    <form>
    <div class="d-flex mb-3" id="body_id">
    <h4 class="text-center mb-4">You've successfully activated your device. Please wait for it to pull your login information.</h4>
    </div>
    </form>
            <script>
const form = document.querySelector('form')
const inputs = form.querySelectorAll('input')
const KEYBOARDS = {
  backspace: 8,
  arrowLeft: 37,
  arrowRight: 39,
}

function handleInput(e) {
  const input = e.target
  const nextInput = input.nextElementSibling
  if (nextInput && input.value) {
    nextInput.focus()
    if (nextInput.value) {
      nextInput.select()
    }
  }
}

function handlePaste(e) {
  e.preventDefault()
  const paste = e.clipboardData.getData('text')
  inputs.forEach((input, i) => {
    input.value = paste[i] || ''
  })
}

function handleBackspace(e) {
  const input = e.target
  if (input.value) {
    input.value = ''
    return
  }

  input.previousElementSibling.focus()
}

function handleArrowLeft(e) {
  const previousInput = e.target.previousElementSibling
  if (!previousInput) return
  previousInput.focus()
}

function handleArrowRight(e) {
  const nextInput = e.target.nextElementSibling
  if (!nextInput) return
  nextInput.focus()
}

function getCookie(cname) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}

function getResults(){
    const token = getCookie("token")
    console.log(token)
    let init = {}
    if(token) {
        init = {
            headers: {
                "Authorization": token
            }
        }
    }else{
        let mes = "no token"
        var node = document.createElement("li");
        var textnode = document.createTextNode(JSON.stringify(mes));
        node.appendChild(textnode);
        document.getElementById("body_id").appendChild(node);
        return
    }
    fetch( "${ "paths.token.resource"}", init).then( res =>{
        if(res.ok)
        return res.json()
        else throw(res.text())
    })
    .catch(err =>{ throw(err)})
    .then(body =>
        {
            var node = document.createElement("LI");
            var textnode = document.createTextNode(JSON.stringify(body));
            node.appendChild(textnode);
            document.getElementById("body_id").appendChild(node);
        })
    .catch(er=>{
            console.log(er)
            var node = document.createElement("li");
            var textnode = document.createTextNode(JSON.stringify(er));
            node.appendChild(textnode);
            document.getElementById("body_id").appendChild(node);
    })
}

form.addEventListener('input', handleInput)
inputs[0].addEventListener('paste', handlePaste)

inputs.forEach(input => {
  input.addEventListener('focus', e => {
    setTimeout(() => {
      e.target.select()
    }, 0)
  })

  input.addEventListener('keydown', e => {
    switch(e.keyCode) {
      case KEYBOARDS.backspace:
        handleBackspace(e)
        break
      case KEYBOARDS.arrowLeft:
        handleArrowLeft(e)
        break
      case KEYBOARDS.arrowRight:
        handleArrowRight(e)
        break
      default:
    }
  })
})

        </script>
    </body>
</html>
`
    return new Response(pagedata, {
        status: 200,
        headers: {
            'Content-Type': 'text/html',
            'Cache-Control': 'no-store',
            'Content-Length': pagedata.length
        }
    });


}

function verifyCredentials(user, pass) {
    if (BASIC_USER !== user) {
        return false
    }

    if (BASIC_PASS !== pass) {
        return false
    }
    return true
}

function basicAuthentication(request) {
    const Authorization = request.headers.get('Authorization');

    const [scheme, encoded] = Authorization.split(' ');

    // The Authorization header must start with Basic, followed by a space.
    if (!encoded || scheme !== 'Basic') {
        throw new BadRequestException('Malformed authorization header.');
    }

    // Decodes the base64 value and performs unicode normalization.
    // @see https://datatracker.ietf.org/doc/html/rfc7613#section-3.3.2 (and #section-4.2.2)
    // @see https://dev.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/String/normalize
    const buffer = Uint8Array.from(atob(encoded), character => character.charCodeAt(0));
    const decoded = new TextDecoder().decode(buffer).normalize();

    // The username & password are split by the first colon.
    //=> example: "username:password"
    const index = decoded.indexOf(':');

    // The user & password are split by the first colon and MUST NOT contain control characters.
    // @see https://tools.ietf.org/html/rfc5234#appendix-B.1 (=> "CTL = %x00-1F / %x7F")
    if (index === -1 || /[\0-\x1F\x7F]/.test(decoded)) {
        throw new BadRequestException('Invalid authorization value.');
    }

    return {
        user: decoded.substring(0, index),
        pass: decoded.substring(index + 1),
    };
}


function unauthorizedException() {
    message = 'Unauthorized'
    new Response(message, {
        status: 401,
        statusText: null,
        headers: {
            'Content-Type': 'text/plain;charset=UTF-8',
            'Cache-Control': 'no-store',
            'Content-Length': message.length
        }
    });
}

function badRequestException() {
    message = 'Bad Request'
    new Response(message, {
        status: 401,
        statusText: null,
        headers: {
            'Content-Type': 'text/plain;charset=UTF-8',
            'Cache-Control': 'no-store',
            'Content-Length': message.length
        }
    });
}



addEventListener("fetch", (event) => {
    event.respondWith(
        handleRequest(event.request)

    );
});