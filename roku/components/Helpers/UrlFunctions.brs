function createUrl()
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.AddHeader("Client-ID", "ue6666qo983tsx6so1t0vnawi233wa") 'Used for API
    while m.global.appBearerToken = invalid
    end while
    userToken = m.global.userToken
    '? "(userToken) " userToken
    if userToken <> invalid and userToken <> ""
        ? "we usin " userToken
        url.AddHeader("Authorization", "Bearer " + m.global.userToken)
    else
        ? "we using global"
        url.AddHeader("Authorization", m.global.appBearerToken)
    end if
    return url
end function

function createUrlNorm()
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    while m.global.appBearerToken = invalid
    end while
    userToken = m.global.userToken
    ? "(userToken) " userToken
    if userToken <> invalid and userToken <> ""
        ? "we usin " userToken
        url.AddHeader("Client-ID", "ue6666qo983tsx6so1t0vnawi233wa") 'Used for API
        url.AddHeader("Authorization", "Bearer " + m.global.userToken)
    else
        ? "we using global"
        url.AddHeader("Client-ID", "cf9fbjz6j9i6k6guz3dwh6qff5dluz") 'Used for API
        url.AddHeader("Authorization", m.global.appBearerToken)
    end if
    return url
end function

function getjsondata(link as string) as object
    url = createUrl()
    url.SetUrl(link.EncodeUri())
    response_string = url.GetToString()
    return ParseJson(response_string)
end function

function POST(request_url as string, request_payload as string) as string
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.AddHeader("Client-Id", "cf9fbjz6j9i6k6guz3dwh6qff5dluz") 'Used in GetCategories2
    url.AddHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36")
    url.AddHeader("Origin", "https://player.twitch.tv")
    url.AddHeader("Referer", "https://player.twitch.tv")
    url.SetUrl(request_url)

    port = CreateObject("roMessagePort")
    url.SetMessagePort(port)

    url.AsyncPostFromString(request_payload)

    response = Wait(0, port)

    return response.GetString()
end function


function getTokenFromRegistry()
    sec = createObject("roRegistrySection", "SavedUserData")
    if sec.Exists("RefreshToken")
        refresh_token = sec.Read("RefreshToken")
    end if
    if sec.Exists("UserToken")
        userToken = sec.Read("UserToken")
    end if
    if sec.Exists("LoggedInUser")
        userLogin = sec.Read("LoggedInUser")
    end if
    if sec.Exists("DeviceId")
        device_id = sec.Read("DeviceId")
    else
        device_id = ""
    end if
    if refresh_token = invalid or refresh_token = ""
        refresh_token = ""
    end if
    if userToken = invalid or userToken = ""
        userToken = ""
    end if
    if userLogin = invalid or userLogin = ""
        userLogin = ""
    end if
    if device_id = invalid or device_id = ""
        device_id = ""
    end if
    return {
        access_token: userToken
        refresh_token: refresh_token
        login: userLogin
        device_id: device_id
    }
end function


function refreshToken()
    userdata = getTokenFromRegistry()
    userLogin = userdata.login
    refresh_token = userdata.refresh_token
    userToken = userdata.access_token
    deviceCode = userdata.device_id

    ? "Client Asked to Refresh Token"
    ' queryString = "client_id=ue6666qo983tsx6so1t0vnawi233wa&device_code=" + response.device_code + "&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code"
    ' oauth_token = ParseJson(msg.GetString())

    ' if refresh_token <> invalid and refresh_token <> ""
    '     req = HttpRequest({
    '         url: "https://id.twitch.tv/oauth2/token?grant_type=refresh_token&refresh_token=" + refresh_token + "&client_id=ue6666qo983tsx6so1t0vnawi233wa" + "&device_code=" + deviceCode
    '         headers: {
    '             "content-type": "application/x-www-form-urlencoded"
    '             "origin": "https://switch.tv.twitch.tv"
    '             "referer": "https://switch.tv.twitch.tv/"
    '             "accept": "application/json"
    '         }
    '         method: "POST"
    '     })
    '     oauth_token = ParseJSON(req.send())
    '     ? "REFRESHED OAUTH TOKEN IS: "; oauth_token
    '     saveLogin(oauth_token.access_token, oauth_token.refresh_token, userLogin)
    ' end if
end function


function saveLogin(access_token, refresh_token, login) as void
    sec = createObject("roRegistrySection", "SavedUserData")
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
    sec.Flush()
end function

function UrlEncode(str as string) as string
    o = CreateObject("roUrlTransfer")
    return o.Escape(str)
end function

function validateUserToken(oauth_token = invalid)
    ' refreshToken()
    if oauth_token = invalid
        token = getTokenFromRegistry()
        userToken = token.access_token
        refresh_token = token.refresh_token
        userLogin = token.login
    else
        userToken = oauth_token.access_token
    end if
    req = HttpRequest({
        url: "https://id.twitch.tv/oauth2/validate"
        headers: {
            "Client-ID": "ue6666qo983tsx6so1t0vnawi233wa"
            "Authorization": "OAuth " + userToken
        }
        method: "GET"
    })
    response = ParseJSON(req.send())
    ? "Response: "; response
    if response <> invalid
        if response.status = 401 and refresh_token <> invalid and refresh_token <> ""
            ? "USED FIRST ONE!!!"
            ' refreshToken()
            return ""
        end if
        if response.login <> invalid and response.login <> ""
            ? "USED THIS ONE!!!"
            return response.login
        end if
    end if
end function

function HttpRequest(params = invalid as dynamic) as object
    url = invalid
    method = invalid
    headers = {}
    data = invalid
    timeout = 0
    retries = 1
    interval = 500
    if params <> invalid then
        if params.url <> invalid then url = params.url
        if params.method <> invalid then method = params.method
        if params.headers <> invalid then headers = params.headers
        if params.data <> invalid then data = params.data
        if params.timeout <> invalid then timeout = params.timeout
        if params.retries <> invalid then retries = params.retries
        if params.interval <> invalid then interval = params.interval
    end if

    obj = {
        _timeout: timeout
        _retries: retries
        _interval: interval
        _deviceInfo: createObject("roDeviceInfo")
        _url: url
        _method: method
        _requestHeaders: headers
        _data: data
        _http: invalid
        _isAborted: false

        _isProtocolSecure: function(url as string) as boolean
            return left(url, 6) = "https:"
        end function

        _createHttpRequest: function() as object
            request = createObject("roUrlTransfer")
            request.setPort(createObject("roMessagePort"))
            request.setUrl(m._url)
            request.retainBodyOnError(true)
            request.enableCookies()
            request.setHeaders(m._requestHeaders)
            if m._method <> invalid then request.setRequest(m._method)

            'Checks if URL protocol is secured, and adds appropriate parameters if needed
            if m._isProtocolSecure(m._url) then
                request.setCertificatesFile("common:/certs/ca-bundle.crt")
                ' request.addHeader("X-Roku-Reserved-Dev-Id", "")
                ' request.addHeader("Client-Id", "kimne78kx3ncx6brgo4mv6wki5h1ko")
                request.initClientCertificates()
            end if

            return request
        end function

        getPort: function()
            if m._http <> invalid then
                return m._http.getPort()
            else
                return invalid
            end if
        end function

        getCookies: function(domain as string, path as string) as object
            if m._http <> invalid then
                return m._http.getCookies(domain, path)
            else
                return invalid
            end if
        end function

        send: function(data = invalid as dynamic) as dynamic
            timeout = m._timeout
            retries = m._retries
            response = invalid

            if data <> invalid then m._data = data

            if m._data <> invalid and getInterface(m._data, "ifString") = invalid then
                m._data = formatJson(m._data)
            end if

            while retries > 0 and m._deviceInfo.getLinkStatus()
                if m._sendHttpRequest(m._data) then
                    event = m._http.getPort().waitMessage(timeout)

                    if m._isAborted then
                        m._isAborted = false
                        m._http.asyncCancel()
                        exit while
                    else if type(event) = "roUrlEvent" then
                        response = event
                        exit while
                    end if

                    m._http.asyncCancel()
                    timeout *= 2
                    sleep(m._interval)
                end if

                retries--
            end while

            return response
        end function

        _sendHttpRequest: function(data = invalid as dynamic) as dynamic
            m._http = m._createHttpRequest()

            if data <> invalid then
                return m._http.asyncPostFromString(data)
            else
                return m._http.asyncGetToString()
            end if
        end function

        abort: function()
            m._isAborted = true
        end function

    }

    return obj
end function

