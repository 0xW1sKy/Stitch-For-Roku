function init()
    m.top.functionName = "onInit"
end function

function onInit()
    m.top.code = ""
    getOauthToken()
    m.top.finished = true
end function

function getOauthToken() as object
    m.top.finished = false
    enter_code_url = "https://id.twitch.tv/oauth2/device?scopes=channel_read%20chat%3Aread%20user_blocks_edit%20user_blocks_read%20user_follows_edit%20user_read&client_id=ue6666qo983tsx6so1t0vnawi233wa"
    req = HttpRequest({
        url: enter_code_url
        headers: {
            "content-type": "application/x-www-form-urlencoded"
            "origin": "https://switch.tv.twitch.tv"
            "referer": "https://switch.tv.twitch.tv/"
        }
        method: "POST"
    })
    data = req.send()
    response = ParseJSON(data)
    ? "getAuth enter code: "; response
    m.top.code = response.user_code


    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl("https://id.twitch.tv/oauth2/token")
    url.AddHeader("content-type", "application/x-www-form-urlencoded")
    url.AddHeader("origin", "https://switch.tv.twitch.tv")
    url.AddHeader("referer", "https://switch.tv.twitch.tv/")
    url.AddHeader("accept", "application/json")
    port = CreateObject("roMessagePort")
    url.SetMessagePort(port)
    queryString = "client_id=ue6666qo983tsx6so1t0vnawi233wa&device_code=" + response.device_code + "&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code"
    while true
        print url.AsyncPostFromString(queryString)
        msg = port.WaitMessage(0)
        res = ParseJson(msg.GetString())
        if res <> invalid and res.DoesExist("access_token")
            exit while
        end if
        print msg.GetString()
        sleep(response.interval * 1000)
    end while

    print msg.GetString()

    oauth_token = ParseJson(msg.GetString())

    ' url = CreateObject("roUrlTransfer")
    ' url.EnableEncodings(true)
    ' url.RetainBodyOnError(true)
    ' url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    ' url.InitClientCertificates()
    ' url.SetUrl("https://id.twitch.tv/oauth2/validate")
    ' url.AddHeader("Authorization", "OAuth " + oauth_token.access_token)
    ' url.AddHeader("Client-ID", "ue6666qo983tsx6so1t0vnawi233wa")
    ' response_string = ParseJson(url.GetToString())
    m.top.access_token = oauth_token.access_token
    m.global.switchUserToken = oauth_token.access_token
    m.top.refresh_token = oauth_token.refresh_token
    m.global.switchRefreshToken = oauth_token.refresh_token
    m.top.device_id = response.device_code
    m.global.switchDeviceId = response.device_code
    login = getUserLogin()
    saveSwitchLogin(oauth_token.access_token, oauth_token.refresh_token, login, response.device_code)
    saveLogin(oauth_token.access_token, oauth_token.refresh_token, login)
end function


function getUserLogin()
    userToken = m.top.access_token
    req = HttpRequest({
        url: "https://gql.twitch.tv/gql"
        headers: {
            "Accept": "*/*"
            ' "Accept-Encoding": "gzip, deflate, br"
            ' "Accept-Language": "en-US"
            "Authorization": "OAuth " + userToken
            ' "Cache-Control": "no-cache"
            "Client-Id": "ue6666qo983tsx6so1t0vnawi233wa"
            ' "Content-Type": "text/plain; charset=UTF-8"
            "Device-ID": m.top.device_id
            ' "Host": "gql.twitch.tv"
            "Origin": "https://switch.tv.twitch.tv"
            ' "Pragma": "no-cache"
            "Referer": "https://switch.tv.twitch.tv/"
            ' "Sec-Fetch-Site": "same-site"
            ' "Sec-Fetch-Mode": "cors"
            ' "Sec-Fetch-Dest": "empty"
            ' "User-Agent": "Mozilla/5.0 (Linux; Android 5.1; AFTS Build/LMY47O) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/41.99900.2250.0242 Safari/537.36"
        }
        method: "POST"
        data: {
            query: "query Homepage_Query {" + chr(10) + "  currentUser {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  }" + chr(10) + ""
        }
    })
    data = req.send()
    ? "RESPONSE: "; data
    response = ParseJSON(data)
    m.top.login = response.data.currentUser.login
    m.global.loggedInUser = response.data.currentUser.login
    return response.data.currentUser.login
end function




function saveSwitchLogin(access_token, refresh_token, login, device_id) as void
    sec = createObject("roRegistrySection", "StitchUserData")
    if access_token <> invalid and access_token <> ""
        sec.Write("UserToken", access_token)
        m.global.setField("UserToken", access_token)
    end if
    if access_token <> invalid and access_token <> ""
        sec.Write("RefreshToken", refresh_token)
        m.global.setField("RefreshToken", refresh_token)
    end if
    if access_token <> invalid and access_token <> ""
        sec.Write("LoggedInUser", login)
        m.global.setField("LoggedInUser", login)
    end if
    if access_token <> invalid and access_token <> ""
        sec.Write("DeviceId", device_id)
        m.global.setField("DeviceId", device_id)
    end if
    sec.Flush()
end function
