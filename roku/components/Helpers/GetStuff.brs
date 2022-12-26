function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()
    m.top.streamUrl = getStreamLink()

end function

function getStreamLink() as object
    ' access_token_url = "http://api.twitch.tv/api/channels/" + m.top.streamerRequested + "/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6&platform=_"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    userToken = m.global.userToken
    ? "(userToken) " userToken
    if userToken <> invalid and userToken <> ""
        ? "we usin " userToken
        url.AddHeader("authorization", "OAuth " + userToken)
    end if
    url.AddHeader("client-id", "cf9fbjz6j9i6k6guz3dwh6qff5dluz")
    stream_link = "https://twitch.k10labs.workers.dev/stream?streamer=" + m.top.streamerRequested
    ' url.AddHeader("Origin", "https://player.twitch.tv")
    ' url.AddHeader("Referer", "https://player.twitch.tv")
    url.SetUrl(stream_link.EncodeUri())
    rsp = url.GetToString()
    ' ? "rsp: "; rsp
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
    preloadUrl = CreateObject("roUrlTransfer")
    preloadUrl.EnableEncodings(true)
    preloadUrl.RetainBodyOnError(true)
    preloadUrl.SetCertificatesFile("common:/certs/ca-bundle.crt")
    preloadUrl.InitClientCertificates()
    preloadUrl.SetUrl(link)
    preload_string = preloadUrl.GetToString()
    ' The stream needs a couple of seconds to load on AWS's server side before we display back to user.
    ' The idea is that this will provide a better user experience by removing stuttering.
    return link
end function

'https://usher.ttvnw.net/api/channel/hls/nickmercs.m3u8?allow_source=true&fast_bread=true&p=6274977&play_session_id=587e886acefc28722ef9db20d471d9e9&player_backend=mediaplayer&playlist_include_framerate=true&reassignments_supported=true&sig=cfa200674bab75075ee0d9a5eaec941095033e24&supported_codecs=avc1&token=%7B%22adblock%22%3Atrue%2C%22authorization%22%3A%7B%22forbidden%22%3Afalse%2C%22reason%22%3A%22%22%7D%2C%22blackout_enabled%22%3Afalse%2C%22channel%22%3A%22nickmercs%22%2C%22channel_id%22%3A15564828%2C%22chansub%22%3A%7B%22restricted_bitrates%22%3A%5B%5D%2C%22view_until%22%3A1924905600%7D%2C%22ci_gb%22%3Afalse%2C%22geoblock_reason%22%3A%22%22%2C%22device_id%22%3A%22f3f26ea3cdfea02a%22%2C%22expires%22%3A1594268273%2C%22extended_history_allowed%22%3Afalse%2C%22game%22%3A%22%22%2C%22hide_ads%22%3Afalse%2C%22https_required%22%3Atrue%2C%22mature%22%3Afalse%2C%22partner%22%3Afalse%2C%22platform%22%3A%22_%22%2C%22player_type%22%3A%22site%22%2C%22private%22%3A%7B%22allowed_to_view%22%3Atrue%7D%2C%22privileged%22%3Afalse%2C%22server_ads%22%3Afalse%2C%22show_ads%22%3Atrue%2C%22subscriber%22%3Afalse%2C%22turbo%22%3Afalse%2C%22user_id%22%3A60049647%2C%22user_ip%22%3A%2272.136.77.60%22%2C%22version%22%3A2%7D&cdm=wv&player_version=0.9.80
'https://usher.ttvnw.net/vod/682807996.m3u8?allow_source=true&p=732898&playlist_include_framerate=true&reassignments_supported=true&sig=8aead6f4649e407fdd3f872c44d8d798386bdafc&supported_codecs=avc1&token=%7B%22authorization%22%3A%7B%22forbidden%22%3Afalse%2C%22reason%22%3A%22%22%7D%2C%22chansub%22%3A%7B%22restricted_bitrates%22%3A%5B%5D%7D%2C%22device_id%22%3A%22f3f26ea3cdfea02a%22%2C%22expires%22%3A1595201031%2C%22https_required%22%3Atrue%2C%22privileged%22%3Afalse%2C%22user_id%22%3A60049647%2C%22version%22%3A2%2C%22vod_id%22%3A682807996%7D&cdm=wv&player_version=1.0.0