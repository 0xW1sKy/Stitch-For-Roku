sub init()
    m.top.observeField("control", "onContentChange")
end sub

sub onContentChange()
    if m.top.content.contentType = "VOD"
        m.GetVodTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
        ' ' observe content so we can know when feed content will be parsed
        m.GetVodTask.observeField("response", "handleVodLink")
        m.GetVodTask.request = {
            type: "getVodPlayerWrapperQuery"
            params: {
                id: m.top.content.contentId
            }
        }
    end if
    if m.top.content.contentType = "STREAM"
        m.GetStreamTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
        ' ' observe content so we can know when feed content will be parsed
        m.GetStreamTask.observeField("response", "handleStreamLink")
        m.GetStreamTask.request = {
            type: "getStreamPlayerQuery"
            params: {
                id: m.top.content.streamerLogin
            }
        }
    end if
end sub

function Encode(str as string) as string
    o = CreateObject("roUrlTransfer")
    return o.Escape(str)
end function

sub handleVodLink()
    m.top.content.url = "https://usher.ttvnw.net/vod/" + m.GetVodTask.response.data.video.id + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&nauth=" + UrlEncode(m.GetVodTask.response.data.video.playbackAccessToken.value) + "&nauthsig=" + m.GetVodTask.response.data.video.playbackAccessToken.signature
end sub

sub handleStreamLink()
    ' seekpreviewurl = response.data.video.seekpreviewurl
    '"https://static-cdn.jtvnw.net/cf_vods/vod/7b652c53825567c2bb4c_kaicenat_41850780219_1676414633/storyboards/1738339385-info.json"
    usherUrl = "https://usher.ttvnw.net/api/channel/hls/" + m.GetStreamTask.response.data.user.login + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&lr=true&token=" + Encode(m.GetStreamTask.response.data.user.stream.playbackaccesstoken.value) + "&sig=" + m.GetStreamTask.response.data.user.stream.playbackaccesstoken.signature
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
    ' streamitems_all = []
    stream_objects = []
    for line = 2 to list.Count() - 1
        stream_info = list[line + 1].Split(",")
        streamobject = {}
        for info = 0 to stream_info.Count() - 1
            info_parsed = stream_info[info].Split("=")
            streamobject[info_parsed[0].replace("#EXT-X-STREAM-INF:", "")] = toString(info_parsed[1], true).replace(chr(34), "")
        end for
        streamobject["URL"] = list[line + 2]
        stream_objects.push(streamobject)
        line += 2
    end for
    stream_bitrates = []
    stream_urls = []
    stream_qualities = []
    stream_content_ids = []
    stream_sticky = []
    for each stream_item in stream_objects
        stream_bitrates.push(Int(Val(stream_item["BANDWIDTH"])) / 1000)
        if stream_item["VIDEO"] = "chunked"
            value = stream_item["RESOLUTION"].split("x")[1] + "p" + stream_item["FRAME-RATE"].split(".")[0]
        else
            value = stream_item["VIDEO"]
        end if
        stream_content_ids.push(value)
        stream_urls.push(stream_item["URL"])
        if Int(Val(stream_item["RESOLUTION"].split("x")[1])) >= 720
            stream_qualities.push("HD")
        else
            stream_qualities.push("SD")
        end if
        stream_sticky.push("false")

    end for
    ' The stream needs a couple of seconds to load on AWS's server side before we display back to user.
    ' The idea is that this will provide a better user experience by removing stuttering.

    m.top.content.streamUrls = stream_urls
    m.top.content.streamQualities = stream_qualities
    m.top.content.streamContentIDs = stream_content_ids
    m.top.content.streamBitrates = stream_bitrates
    m.top.content.streamStickyHttpRedirects = stream_sticky
    m.top.control = "prebuffer"
end sub


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