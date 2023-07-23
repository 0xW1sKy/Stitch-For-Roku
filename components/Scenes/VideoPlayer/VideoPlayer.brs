sub init()
    m.videoPlayer = m.top.findNode("videoWindow")
    m.videoPlayer.observeField("QualityChangeRequest", "onQualitySelectButtonPressed")
    ' m.videoPlayer.observeField("back", "onVideoPlayerBack")
    videoBookmarks = get_user_setting("VideoBookmarks", "")
    if videoBookmarks <> ""
        m.videoPlayer.videoBookmarks = ParseJSON(videoBookmarks)
    else
        m.videoPlayer.videoBookmarks = {}
    end if
    m.videoPlayer.notificationInterval = 1
    m.videoPlayer.observeField("toggleChat", "onToggleChat")
    m.chatWindow = m.top.findNode("chat")
    m.chatWindow.observeField("visible", "onChatVisibilityChange")
end sub

sub onQualitySelectButtonPressed()
    if m.videoplayer.qualityChangeRequestflag = true
        vidContent = createObject("roSGNode", "ContentNode")
        vidContent.title = m.top.contentRequested.contentTitle
        vidContent.url = m.videoplayer.qualityChangeRequest
        vidContent.streamFormat = m.videoPlayer.content.streamFormat
        ' m.videoPlayer.ClearContent()
        m.videoPlayer.video_id = m.top.contentRequested.contentId
        m.videoPlayer.streamUrls = m.videoplayer.streamUrls
        m.videoPlayer.streamQualities = m.videoplayer.streamQualities
        m.videoPlayer.streamContentIds = m.videoplayer.streamContentIds
        m.videoPlayer.streamBitrates = m.videoplayer.streamBitrates
        m.videoPlayer.streamStickyHttpRedirects = m.videoplayer.streamStickyHttpRedirects
        m.videoPlayer.channelUsername = m.top.contentRequested.streamerDisplayName
        m.videoPlayer.channelAvatar = m.top.contentRequested.streamerProfileImageUrl
        m.videoPlayer.videoTitle = m.top.contentRequested.contentTitle
        m.videoPlayer.content = vidContent
        ' m.videoplayer.visible = true
        ' m.videoplayer.setFocus(true)
        ' m.videoplayer.enableCookies()
        checkBookmarks()
        m.videoplayer.control = "play"
        m.videoplayer.qualityChangeRequestFlag = false
        ' m.videoPlayer.visible = true
    end if
end sub

sub onToggleChat()
    ? "Main Scene > onToggleChat"
    if m.videoPlayer.toggleChat = true
        m.chatWindow.visible = not m.chatWindow.visible
        m.videoPlayer.chatIsVisible = m.chatWindow.visible
        m.videoPlayer.toggleChat = false
    end if
end sub

sub onChatVisibilityChange()
    if m.chatWindow.visible
        m.videoPlayer.width = 1025
        m.videoPlayer.height = 720
        m.chatWindow.getchild(0).opacity = "1"
    else
        m.videoPlayer.width = 0
        m.videoPlayer.height = 0
    end if
end sub


function handleContent()
    if m.top.contentRequested.contentType = "CLIP"
        playClip()
    else
        ? "Type: "; m.top.contentRequested.contentType
        m.getTwitchDataTask = CreateObject("roSGNode", "TwitchApiTask")
        m.getTwitchDataTask.observeField("response", "handleResponse")
        if m.top.contentRequested.contentType = "VOD"
            request = {
                type: "getVodPlayerWrapperQuery"
                params: {
                    id: m.top.contentRequested.contentId
                }
            }
        end if
        if m.top.contentRequested.contentType = "LIVE"
            request = {
                type: "getStreamPlayerQuery"
                params: {
                    id: m.top.contentRequested.streamerLogin
                }
            }
        end if
        m.getTwitchDataTask.request = request
        m.getTwitchDataTask.functionName = request.type
        m.getTwitchDataTask.control = "run"
    end if
end function

function handleResponse()
    if m.top.contentRequested.contentType = "VOD"
        usherUrl = "https://usher.ttvnw.net/vod/" + m.gettwitchdatatask.response.data.video.id + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&nauth=" + m.gettwitchdatatask.response.data.video.playbackAccessToken.value.EncodeUri() + "&nauthsig=" + m.gettwitchdatatask.response.data.video.playbackAccessToken.signature
    else if m.top.contentRequested.contentType = "LIVE"
        usherUrl = "https://usher.ttvnw.net/api/channel/hls/" + m.gettwitchdatatask.response.data.user.login + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&lr=true&token=" + m.gettwitchdatatask.response.data.user.stream.playbackaccesstoken.value.EncodeUri() + "&sig=" + m.gettwitchdatatask.response.data.user.stream.playbackaccesstoken.signature
    end if
    ' return usherUrl
    m.usherRequestTask = createObject("roSGNode", "httpRequest")
    m.usherRequestTask.observeField("response", "handleUsherResponse")
    m.usherRequestTask.request = {
        url: usherUrl
        headers: {
            "Accept": "*/*"
            "Origin": "https://switch.tv.twitch.tv"
            "Referer": "https://switch.tv.twitch.tv/"
        }
        method: "GET"
    }
    m.usherRequestTask.control = "RUN"
end function

function handleUsherResponse()
    rsp = m.usherRequestTask.response.data
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
        if stream_item["VIDEO"] = "chunked"
            res = stream_item["RESOLUTION"].split("x")[1]
            if stream_item["FRAME-RATE"] <> invalid
                fps = stream_item["FRAME-RATE"].split(".")[0]
            end if
            value = res + "p"
            if fps <> invalid
                value = value + fps
            end if
        else
            value = stream_item["VIDEO"]
        end if
        if Int(Val(stream_item["RESOLUTION"].split("x")[1])) >= 720
            stream_quality = "HD"
        else
            stream_quality = "SD"
        end if
        resolution = value.split("p")[0]
        fps = value.split("p")[1]
        if resolution <> invalid
            if resolution.ToInt() > get_user_setting("VideoQualitySetting").ToInt()
                ? "Res Skip: "; value
                continue for
            end if
        end if
        if fps <> invalid
            if fps.ToInt() > get_user_setting("VideoFramerateSetting").ToInt()
                ? "Fps Skip: "; value
                continue for
            end if
        end if
        stream_qualities.push(stream_quality)
        stream_content_ids.push(value)
        stream_urls.push(stream_item["URL"])
        stream_bitrates.push(Int(Val(stream_item["BANDWIDTH"])) / 1000)
        stream_sticky.push("false")
    end for
    ' The stream needs a couple of seconds to load on AWS's server side before we display back to user.
    ' The idea is that this will provide a better user experience by removing stuttering.
    playVideo({
        streamUrls: stream_urls
        streamQualities: stream_qualities
        streamContentIDs: stream_content_ids
        streamBitrates: stream_bitrates
        streamStickyHttpRedirects: stream_sticky
    })
end function

function playClip()
    vidContent = createObject("roSGNode", "ContentNode")
    vidContent.title = m.top.contentRequested.contentTitle
    vidContent.url = Left(m.top.contentRequested.previewImageUrl, Len(m.top.contentRequested.previewImageUrl) - 20) + ".mp4"
    vidContent.streamFormat = "mp4"
    m.videoPlayer.video_id = m.top.contentRequested.contentId
    m.videoPlayer.streamUrls = [vidContent.url]
    m.videoPlayer.streamQualities = ["HD"]
    m.videoPlayer.streamContentIds = ["Original"]
    m.videoPlayer.channelUsername = m.top.contentRequested.streamerDisplayName
    m.videoPlayer.channelAvatar = m.top.contentRequested.streamerProfileImageUrl
    m.videoPlayer.videoTitle = m.top.contentRequested.contentTitle
    m.videoplayer.content = vidContent
    m.videoplayer.visible = true
    m.videoplayer.setFocus(true)
    m.videoplayer.enableCookies()
    m.chatWindow.visible = false
    checkBookmarks()
    m.videoplayer.control = "play"
end function

function playVideo(data)
    vidContent = createObject("roSGNode", "ContentNode")
    vidContent.title = m.top.contentRequested.contentTitle
    vidContent.url = data.streamUrls[0]
    vidContent.streamFormat = "hls"
    m.videoPlayer.video_id = m.top.contentRequested.contentId
    m.videoPlayer.streamUrls = data.streamUrls
    m.videoPlayer.streamQualities = data.streamQualities
    m.videoPlayer.streamContentIds = data.streamContentIds
    m.videoPlayer.streamBitrates = data.streamBitrates
    m.videoPlayer.streamStickyHttpRedirects = data.streamStickyHttpRedirects
    m.videoPlayer.channelUsername = m.top.contentRequested.streamerDisplayName
    m.videoPlayer.channelAvatar = m.top.contentRequested.streamerProfileImageUrl
    m.videoPlayer.videoTitle = m.top.contentRequested.contentTitle
    m.videoplayer.content = vidContent
    m.videoplayer.visible = true
    m.videoplayer.setFocus(true)
    m.videoplayer.enableCookies()
    checkBookmarks()
    m.videoplayer.control = "play"
    ' I'm too tired to do this better, but channel_id needs to be set before channel
    m.chatWindow.channel_id = m.top.contentRequested.streamerId
    m.chatWindow.channel = m.top.contentRequested.streamerLogin
    if get_user_setting("ChatOption", "true") = "true"
        m.chatWindow.visible = true
        m.videoPlayer.chatIsVisible = m.chatWindow.visible
    else
        m.chatWindow.visible = false
    end if
end function

function checkBookmarks()
    ' ? "Check the bookmark"
    if m.videoPlayer.video_id <> invalid
        ' ?"video id is valid: "; m.videoPlayer.video_id
        if m.videoPlayer.videoBookmarks.DoesExist(m.videoPlayer.video_id)
            ' ? "Jump To Position From Bookmarks > " m.videoPlayer.videoBookmarks[m.videoPlayer.video_id]
            m.videoPlayer.seek = Val(m.videoPlayer.videoBookmarks[m.videoPlayer.video_id])
        end if
    end if
end function

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        ? "Home Scene Key Event: "; key
        if key = "back"
            m.top.backPressed = true
            return false
        end if
        if key = "OK"
            ? "selected"
        end if
    end if
end function