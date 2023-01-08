function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()
    m.top.streamUrl = getStreamLink()

end function
' "Client-ID": "cf9fbjz6j9i6k6guz3dwh6qff5dluz"
' "Authorization": "OAuth " + userToken
' "Client-ID": "kimne78kx3ncx6brgo4mv6wki5h1ko"

function getPlaybackAccessToken()
    token = getTokenFromRegistry()
    userToken = token.access_token
    req = HttpRequest({
        url: "https://gql.twitch.tv/gql"
        headers: {
            "Accept": "*/*"
            ' "Accept-Encoding": "gzip, deflate, br"
            ' "Accept-Language": "en-US"
            ' "Authorization": "OAuth uk5seeh033g141pr69vdw7f8s1y0b7"
            ' "Cache-Control": "no-cache"
            "Client-Id": "kimne78kx3ncx6brgo4mv6wki5h1ko"
            ' "Content-Type": "text/plain; charset=UTF-8"
            ' "Device-ID": getDeviceId()
            ' "Host": "gql.twitch.tv"
            ' "Origin": "https://www.twitch.tv"
            ' "Pragma": "no-cache"
            ' "Referer": "https://www.twitch.tv/"
            ' "Sec-Fetch-Site": "same-site"
            ' "Sec-Fetch-Mode": "cors"
            ' "Sec-Fetch-Dest": "empty"
            ' "User-Agent": "Mozilla/5.0 (Linux; Android 5.1; AFTS Build/LMY47O) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/41.99900.2250.0242 Safari/537.36"
        }
        method: "POST"
        data: {
            operationName: "PlaybackAccessToken_Template"
            query: "query PlaybackAccessToken_Template($login: String!, $isLive: Boolean!, $vodID: ID!, $isVod: Boolean!, $playerType: String!) { streamPlaybackAccessToken(channelName: $login, params: { platform: " + Chr(34) + "web" + Chr(34) + ", playerBackend: " + Chr(34) + "mediaplayer" + chr(34) + ", playerType: $playerType }) @include(if: $isLive) { value signature __typename } videoPlaybackAccessToken(id: $vodID, params: { platform: " + chr(34) + "web" + chr(34) + ", playerBackend: " + chr(34) + "mediaplayer" + chr(34) + ", playerType: $playerType }) @include(if: $isVod) { value signature __typename } }"
            variables: {
                "isLive": true
                "login": m.top.streamerRequested
                "isVod": false
                "vodID": ""
                "playerType": "site"
            }
        }
    })
    data = req.send()
    ? "RESPONSE: "; data
    response = ParseJSON(data)
    isVod = false

    if isVod
        return response.data.videoPlaybackAccessToken
    else
        return response.data.streamPlaybackAccessToken
    end if
end function

function getMd5Hash(s as string)
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(s)
    digest = CreateObject("roEVPDigest")
    digest.Setup("md5")
    result = digest.Process(ba)
    return result
end function

function getDeviceId()
    di = CreateObject("roDeviceInfo")
    uniqueId = di.GetChannelClientId()
    return uniqueId
end function

function getStreamLink() as object
    userToken = m.global.userToken
    playbackAccessToken = getPlaybackAccessToken()
    baseurl = "https://usher.ttvnw.net/"
    isVod = false
    if isVod
        middle = "vod/"
    else
        middle = "api/channel/hls/"
    end if
    id = m.top.streamerRequested
    fullUrl = baseurl + middle + id + ".m3u8"
    date = CreateObject("roDateTime")
    actionid = getDeviceId() + m.top.streamerRequested + playbackAccessToken.value + date.AsSeconds().toStr()
    play_session_id = getMd5Hash(actionid)
    usherUrl = fullUrl + "?client_id=kimne78kx3ncx6brgo4mv6wki5h1ko&allow_source=true&fast_bread=true&player_backend=mediaplayer&playlist_include_framerate=true&reassignments_supported=true&supported_codecs=avc1&cdm=wv&player_version=1.16.0&token=" + UrlEncode(playbackAccessToken.value) + "&sig=" + UrlEncode(playbackAccessToken.signature) '+ "&play_session_id=" + play_session_id
    '
    req = HttpRequest({
        url: usherUrl
        headers: {
            "Client-id": "kimne78kx3ncx6brgo4mv6wki5h1ko"
            "Referer": ""
            "Accept": "application/x-mpegURL, application/vnd.apple.mpegurl, application/json, text/plain"
            "User-Agent": "Mozilla/5.0 (Linux; Android 5.1; AFTS Build/LMY47O) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/41.99900.2250.0242 Safari/537.36"
            ' "Origin": "https://www.twitch.tv"
            ' "Accept-Language": "en-US,en;q=0.9"
        }
        method: "GET"
    })
    ' ' acmb= Base64({"BrowseItemTrackingId":"1af69f74-e5a2-40a6-8226-9a8fc8040605:0"}) ' this is BS click tracking stuff
    ' ' &p=8799414 ' probably not needed? i'm guessing its another activity tracking thing for ads.
    ' ' "&play_session_id=be830c5df7b6c134c9e0eee23c82968b" I feel like this is needed. seems like an md5 hash start by trying generating my own random
    ' return usherUrl

    rsp = req.send().getString()
    list = rsp.Split(chr(10))
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
    ' The stream needs a couple of seconds to load on AWS's server side before we display back to user.
    ' The idea is that this will provide a better user experience by removing stuttering.
    return link
    ' return usherUrl
end function