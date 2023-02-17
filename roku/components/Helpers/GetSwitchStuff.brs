function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()
    m.top.streamUrl = getStreamUrl()
end function

function getStreamUrl()
    req = HttpRequest({
        url: "https://gql.twitch.tv/gql"
        headers: {
            "Accept": "*/*"
            ' "Accept-Encoding": "gzip, deflate, br"
            ' "Accept-Language": "en-US"
            "Authorization": "OAuth " + m.global.switchUserToken
            ' "Cache-Control": "no-cache"
            "Client-Id": "ue6666qo983tsx6so1t0vnawi233wa"
            ' "Content-Type": "text/plain; charset=UTF-8"
            "Device-ID": m.global.switchDeviceId
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
            query: "query StreamPlayer_Query(" + chr(10) + "  $login: String!" + chr(10) + "  $playerType: String!" + chr(10) + "  $platform: String!" + chr(10) + "  $skipPlayToken: Boolean!" + chr(10) + ") {" + chr(10) + "  ...StreamPlayer_token" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_token on Query {" + chr(10) + "  user(login: $login) {" + chr(10) + "    login" + chr(10) + "    stream @skip(if: $skipPlayToken) {" + chr(10) + "      playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "        signature" + chr(10) + "        value" + chr(10) + "      }" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
            variables: {
                "login": m.top.streamerRequested
                "platform": "switch_web_tv"
                "playerType": "pulsar"
                "skipPlayToken": false
            }
        }
    })
    data = req.send()
    ? "RESPONSE: "; data
    response = ParseJSON(data)
    usherUrl = "https://usher.ttvnw.net/api/channel/hls/" + m.top.streamerRequested + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&lr=true&token=" + UrlEncode(response.data.user.stream.playbackaccesstoken.value) + "&sig=" + response.data.user.stream.playbackaccesstoken.signature
    ? "USERURL: "; usherUrl
    ' return usherUrl
    req = HttpRequest({
        url: usherUrl
        headers: {
            "Accept": "*/*"
            "Origin": "https://switch.tv.twitch.tv"
            "Referer": "https://switch.tv.twitch.tv/"
        }
        method: "GET"
    })

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
end function

