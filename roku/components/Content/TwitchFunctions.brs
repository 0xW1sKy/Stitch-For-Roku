function getUserOauthToken()
    login = validateUserToken()
    if login <> invalid
        token = getTokenFromRegistry()
        userToken = token.access_token
        refresh_token = token.refresh_token
        userLogin = token.login
        output = "Oauth: " + userToken
        return output
    end if
    return invalid
end function

function getUserBearerToken()
    login = validateUserToken()
    if login <> invalid
        token = getTokenFromRegistry()
        userToken = token.access_token
        refresh_token = token.refresh_token
        userLogin = token.login
        output = "Oauth: " + userToken
        return output
    end if
    return invalid
end function

function getTokenFromRegistry()
    sec = createObject("roRegistrySection", "StitchUserData")
    if sec.Exists("RefreshToken")
        refresh_token = sec.Read("RefreshToken")
    end if
    if sec.Exists("UserToken")
        userToken = sec.Read("UserToken")
    end if
    if sec.Exists("LoggedInUser")
        userLogin = sec.Read("LoggedInUser")
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
    return {
        access_token: userToken
        refresh_token: refresh_token
        login: userLogin
    }

end function

function saveLogin(access_token, refresh_token, login) as void
    sec = createObject("roRegistrySection", "StitchUserData")
    sec.Write("UserToken", access_token)
    sec.Write("RefreshToken", refresh_token)
    sec.Write("LoggedInUser", login)
    m.global.setField("userToken", access_token)
    m.global.setField("refreshToken", refresh_token)
    sec.Flush()
end function

function refreshToken(userToken, refresh_token, userLogin)
    ? "Client Asked to Refresh Token"
    if userLogin <> invalid and userLogin <> "" and refresh_token <> invalid and refresh_token <> ""
        req = HttpRequest({
            url: "https://oauth.k10labs.workers.dev/refresh?code=" + refresh_token
            headers: {
                "Client-ID": "cf9fbjz6j9i6k6guz3dwh6qff5dluz"
                "Authorization": "Bearer " + userToken
            }
            method: "POST"
            data: { "code": m.global.rendezvouzToken }
        })
        oauth_token = ParseJSON(req.send())
        saveLogin(oauth_token.access_token, oauth_token.refresh_token, userLogin)
        return oauth_token
    end if
end function

function validateUserToken(oauth_token = invalid)
    login = invalid
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
            "Client-ID": "cf9fbjz6j9i6k6guz3dwh6qff5dluz"
            "Authorization": "Bearer " + userToken
        }
        method: "POST"
        data: { "code": m.global.rendezvouzToken }
    })
    response = ParseJSON(req.send())
    if response.status <> invalid
        if response_string.status = 401 and refresh_token <> invalid and refresh_token <> ""
            refreshToken(userToken, refresh_token, userLogin)
        end if
        if response.login <> invalid and response.login <> ""
            login = response.login
            return login
        end if
    end if
    return invalid
end function

function getNewUserToken() as object
    req = HttpRequest({
        url: "https://oauth.k10labs.workers.dev/register"
        headers: {
            "Client-ID": "cf9fbjz6j9i6k6guz3dwh6qff5dluz"
            "Authorization": "Basic YWRtaW46YWRtaW4="
        }
        method: "GET"
    })
    response = ParseJSON(req.send())
    m.global.setField("rendezvouzToken", response)

    req = HttpRequest({
        url: "https://oauth.k10labs.workers.dev/unregister?code=" + m.global.rendezvouzToken
        headers: {
            "Client-ID": "cf9fbjz6j9i6k6guz3dwh6qff5dluz"
            "Authorization": "Basic YWRtaW46YWRtaW4="
        }
        method: "POST"
        data: { "code": m.global.rendezvouzToken }
    })

    while true
        res = ParseJSON(req.send())
        if res <> invalid and res.DoesExist("access_token")
            exit while
        end if
        sleep(5000)
    end while
    oauth_token = res

    login = validateUserToken(oauth_token)

    if login <> invalid
        saveLogin(oauth_token.access_token, oauth_token.refresh_token, response_string.login)
    end if
    return ""
end function


function getStreamLink(streamer) as object
    req = HttpRequest({
        url: "https://twitch.k10labs.workers.dev/stream?streamer=" + streamer
        headers: {
            "Client-ID": "cf9fbjz6j9i6k6guz3dwh6qff5dluz"
            "Authorization": getUserOauthToken()
        }
        method: "GET"
    })
    response = ParseJSON(req.send())
    list = response.Split(chr(10))
    first_stream_link = ""
    last_stream_link = ""
    link = ""
    cnt = 0
    for line = 2 to list.Count() - 1
        stream_info = list[line + 1].Split(",")
        stream_quality = invalid
        stream_framerate = invalid
        for info = 0 to stream_info.Count() - 1
            info_parsed = stream_info[info].Split("=")
            if info_parsed[0] = "RESOLUTION"
                stream_quality = Int(Val(info_parsed[1].Split("x")[1]))
            else if info_parsed[0] = "VIDEO"
                if info_parsed[1] = (chr(34) + "chunked" + chr(34))
                    stream_framerate = 30
                else
                    stream_framerate = Int(Val(info_parsed[1].Split("p")[1]))
                end if
            end if
        end for

        if stream_framerate = invalid
            stream_framerate = 30
        end if

        if not stream_quality = invalid
            compatible_link = false
            last_stream_link = list[line + 2]
            if m.global.videoFramerate >= stream_framerate
                if m.global.videoQuality <= 1 and stream_quality <= 1080
                    compatible_link = true
                else if m.global.videoQuality <= 3 and stream_quality <= 720
                    compatible_link = true
                else if m.global.videoQuality = 4 and stream_quality <= 480
                    compatible_link = true
                else if m.global.videoQuality = 5 and stream_quality <= 360
                    compatible_link = true
                else if m.global.videoQuality = 6 and stream_quality <= 160
                    compatible_link = true
                end if
            end if

            if compatible_link
                link = list[line + 2]
                exit for
            end if
        end if

        line += 2
    end for

    if link = ""
        return last_stream_link
    end if
    return link
end function


function getRecommendedStreams() as object
    req = HttpRequest({
        url: "https://api.twitch.tv/helix/streams?first=21"
        headers: {
            "Client-ID": "cf9fbjz6j9i6k6guz3dwh6qff5dluz"
            "Authorization": getBearerToken()
        }
        method: "GET"
    })
    response = ParseJSON(req.send())
    first = true
    result = []
    if response <> invalid and response.data <> invalid
        for each stream in response.data
            game_ids_url = "https://api.twitch.tv/helix/games?id="
            user_ids_url = "https://api.twitch.tv/helix/users?id="
            if first = false
                game_ids_url += "&id=" + stream.game_id
                user_ids_url += "&id=" + stream.user_id
            else
                game_ids_url += stream.game_id
                user_ids_url += stream.user_id
            end if
            thumbnail_url = Left(stream.thumbnail_url, Len(stream.thumbnail_url) - 21)
            item = {
                description: stream.title
                guid: stream.user_id
                hdbackgroundimageurl: thumbnail_url + "-854x480.jpg"
                hdposterurl: thumbnail_url + "-854x480.jpg"
                link: "https://twitch.k10labs.workers.dev/stream?streamer=" + stream.user_name
                "media:content": "https://twitch.k10labs.workers.dev/stream?streamer=" + stream.user_name
                pubDate: ""
                stream: { url: "https://twitch.k10labs.workers.dev/stream?streamer=" + stream.user_name }
                streamformat: "hls"
                title: stream.user_name
                subtitle: stream.viewer_count
                uri: [
                    "https://twitch.k10labs.workers.dev/stream?streamer=" + stream.user_name
                ]
            }
            result.push(item)
            first = false
        end for
    end if
    return result
end function



function getCategorySearchResults()
    req = HttpRequest({
        url: "https://api.twitch.tv/helix/games/top?first=24"
        headers: {
            "Client-ID": "cf9fbjz6j9i6k6guz3dwh6qff5dluz"
            "Authorization": getBearerToken()
        }
        method: "GET"
    })
    response = ParseJSON(req.send())
    result = []
    if response.data <> invalid
        for each category in response.data
            item = {
                descrption: ""
                guid: category.id
                hdbackgroundimageurl: Left(category.box_art_url, Len(category.box_art_url) - 20) + "136x190.jpg"
                hdposterurl: Left(category.box_art_url, Len(category.box_art_url) - 20) + "136x190.jpg"
                link: ""
                "media:content": ""
                pubDate: ""
                stream: { url: "" }
                streamformat: "hls"
                title: category.name
                typename: "category"
                uri: [
                    Left(category.box_art_url, Len(category.box_art_url) - 20) + "136x190.jpg"
                ]

            }
            result.push(item)
        end for
    end if
    return result
end function



function getBearerToken() as object
    req = HttpRequest({
        url: "https://oauth.k10labs.workers.dev/bearer"
        headers: { "Authorization": "Basic YWRtaW46YWRtaW4=" }
        method: "GET"
    })
    response = ParseJSON(req.send())
    return "Bearer " + response.access_token
end function




' function getRecommendedStreams()
'     payload = [{
'         "operationName": "PersonalSections",
'         "variables": {
'             "input": {
'                 "sectionInputs": [
'                     "RECS_FOLLOWED_SECTION",
'                     "RECOMMENDED_SECTION"
'                 ],
'                 "recommendationContext": {
'                     "platform": "web",
'                     "clientApp": "twilight",
'                     "channelName": "",
'                     "categoryName": "",
'                     "lastChannelName": "",
'                     "lastCategoryName": "",
'                     "pageviewContent": "",
'                     "pageviewContentType": "",
'                     "pageviewLocation": "",
'                     "pageviewMedium": "",
'                     "previousPageviewContent": "",
'                     "previousPageviewContentType": "",
'                     "previousPageviewLocation": "",
'                     "previousPageviewMedium": ""
'                 }
'             },
'             "creatorAnniversariesExperimentEnabled": false,
'             "sideNavActiveGiftExperimentEnabled": false
'         },
'         "extensions": {
'             "persistedQuery": {
'                 "version": 1,
'                 "sha256Hash": "469b047f12eef51d67d3007b7c908cf002c674825969b4fa1c71c7e4d7f1bbfb"
'             }
'         }
'     }]
'     req = HttpRequest({
'         url: "https://gql.twitch.tv/gql"
'         headers: { "Client-Id": "kimne78kx3ncx6brgo4mv6wki5h1ko" }
'         method: "POST"
'         data: payload
'     })
'     return req.send()
' end function


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