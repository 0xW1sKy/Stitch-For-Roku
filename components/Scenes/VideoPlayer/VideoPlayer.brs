sub handleContent()
    m.PlayVideo = CreateObject("roSGNode", "GetTwitchContent")
    m.PlayVideo.observeField("response", "OnResponse")
    m.PlayVideo.contentRequested = m.top.contentRequested.getFields()
    m.PlayVideo.functionName = "main"
    m.PlayVideo.control = "run"
end sub

function handleItemSelected()
    selectedRow = m.rowlist.content.getchild(m.rowlist.rowItemSelected[0])
    selectedItem = selectedRow.getChild(m.rowlist.rowItemSelected[1])
    ' m.top.playContent = true
    ' m.top.contentSelected = selectedItem
    m.PlayVideo = CreateObject("roSGNode", "GetTwitchContent")
    m.PlayVideo.observeField("response", "OnResponse")
    m.PlayVideo.contentRequested = selectedItem.getFields()
    m.PlayVideo.functionName = "main"
    m.PlayVideo.control = "run"
end function

function onResponse()
    content = CreateObject("roSGNode", "TwitchContentNode")
    content.setFields(m.PlayVideo.response[0])
    ? "break"
    m.top.content = content
    playContent()
end function

sub taskStateChanged(event as object)
    print "Player: taskStateChanged(), id = "; event.getNode(); ", "; event.getField(); " = "; event.getData()
    state = event.GetData()
    if state = "done" or state = "stop"
        exitPlayer()
    end if
end sub

sub controlChanged()
    'handle orders by the parent/owner
    control = m.top.control
    if control = "play" then
        playContent()
    else if control = "stop" then
        exitPlayer()
    end if
end sub

sub initChat()
    if not m.top.chatStarted
        m.top.chatStarted = true
        m.chatWindow.channel_id = m.top.contentRequested.streamerId
        m.chatWindow.channel = m.top.contentRequested.streamerLogin
        if get_user_setting("ChatOption", "true") = "true"
            m.chatWindow.visible = true
            m.video.chatIsVisible = m.chatWindow.visible
        else
            m.chatWindow.visible = false
        end if
    end if
end sub

function getTopContent()
    topContent = m.top.content.getfields()
    content = CreateObject("roSGNode", "TwitchContentNode")
    content.setFields(topContent)
    return content
end function

sub playContent()
    ' if resolution <> invalid
    '     if resolution.ToInt() > get_user_setting("VideoQualitySetting").ToInt()
    '         ? "Res Skip: "; value
    '         continue for
    '     end if
    ' end if
    ' if fps <> invalid
    '     if fps.ToInt() > get_user_setting("VideoFramerateSetting").ToInt()
    '         ? "Fps Skip: "; value
    '         continue for
    '     end if
    ' end if
    if m.video <> invalid
        m.top.removeChild(m.video)
    end if
    m.video = m.top.CreateChild("CustomVideo")
    httpAgent = CreateObject("roHttpAgent")
    httpAgent.addheader("Accept", "*/*")
    httpAgent.addheader("Origin", "https://switch.tv.twitch.tv")
    httpAgent.addheader("Referer", "https://switch.tv.twitch.tv/")
    m.video.setHttpAgent(httpAgent)
    m.video.notificationInterval = 1
    m.video.observeField("toggleChat", "onToggleChat")
    videoBookmarks = get_user_setting("VideoBookmarks", "")
    if videoBookmarks <> ""
        m.video.videoBookmarks = ParseJSON(videoBookmarks)
    else
        m.video.videoBookmarks = {}
    end if
    ? "playContent"; m.top.content
    content = m.top.content
    if content <> invalid then
        m.video.content = content
        m.video.visible = false
        m.PlayerTask = CreateObject("roSGNode", "PlayerTask")
        m.PlayerTask.observeField("state", "taskStateChanged")
        m.PlayerTask.observeField("QualityChangeRequestFlag", "onQualitySelectButtonPressed")
        m.PlayerTask.video = m.video
        m.PlayerTask.control = "RUN"
        initChat()
    end if
end sub

sub exitPlayer()
    print "Player: exitPlayer()"
    m.video.control = "stop"
    m.video.visible = false
    m.PlayerTask = invalid
    'signal upwards that we are done
    m.top.state = "done"
end sub


function onKeyEvent(key, press) as boolean
    if press
        ? "Hero Scene Key Event: "; key
        if key = "back" then
            'handle Back button, by exiting play
            exitPlayer()
            m.top.backpressed = true
            return true
        end if
    end if
end function


sub init()
    ' m.video.observeField("back", "onvideoBack")
    m.chatWindow = m.top.findNode("chat")
    m.chatWindow.observeField("visible", "onChatVisibilityChange")
end sub

sub onQualitySelectButtonPressed()
    if m.PlayerTask.qualityChangeRequestFlag = true
        m.PlayerTask.qualityChangeRequestFlag = false
        exitPlayer()
        content = CreateObject("roSGNode", "TwitchContentNode")
        content.setFields(m.PlayVideo.response[m.video.qualityChangeRequest])
        if m.PlayVideo.response[m.video.qualityChangeRequest].stream <> invalid
            content.setFields(m.PlayVideo.response[m.video.qualityChangeRequest].stream)
        end if
        m.top.content = content
        playContent()
    end if
    ' ' m.video.ClearContent()
    ' m.video.video_id = m.top.contentRequested.contentId
    ' m.video.streamUrls = m.video.streamUrls
    ' m.video.streamQualities = m.video.streamQualities
    ' m.video.streamContentIds = m.video.streamContentIds
    ' m.video.streamBitrates = m.video.streamBitrates
    ' m.video.streamStickyHttpRedirects = m.video.streamStickyHttpRedirects
    ' m.video.channelUsername = m.top.contentRequested.streamerDisplayName
    ' m.video.channelAvatar = m.top.contentRequested.streamerProfileImageUrl
    ' m.video.videoTitle = m.top.contentRequested.contentTitle
    ' m.video.content = vidContent
    ' ' m.video.visible = true
    ' ' m.video.setFocus(true)
    ' ' m.video.enableCookies()
    ' checkBookmarks()
    ' m.video.control = "play"
    ' m.video.qualityChangeRequestFlag = false
    ' ' m.video.visible = true
    ? "break"
end sub

sub onToggleChat()
    ? "Main Scene > onToggleChat"
    if m.video.toggleChat = true
        m.chatWindow.visible = not m.chatWindow.visible
        m.video.chatIsVisible = m.chatWindow.visible
        m.video.toggleChat = false
    end if
end sub

sub onChatVisibilityChange()
    if m.chatWindow.visible
        m.video.width = 1025
        m.video.height = 720
        m.chatWindow.getchild(0).opacity = "1"
    else
        m.video.width = 0
        m.video.height = 0
    end if
end sub


' function handleContent()
'     if m.top.contentRequested.contentType = "CLIP"
'         playClip()
'     else
'         ? "Type: "; m.top.contentRequested.contentType
'         m.getTwitchDataTask = CreateObject("roSGNode", "TwitchApiTask")
'         m.getTwitchDataTask.observeField("response", "handleResponse")
'         if m.top.contentRequested.contentType = "VOD"
'             request = {
'                 type: "getVodPlayerWrapperQuery"
'                 params: {
'                     id: m.top.contentRequested.contentId
'                 }
'             }
'         end if
'         if m.top.contentRequested.contentType = "LIVE"
'             request = {
'                 type: "getStreamPlayerQuery"
'                 params: {
'                     id: m.top.contentRequested.streamerLogin
'                 }
'             }
'         end if
'         m.getTwitchDataTask.request = request
'         m.getTwitchDataTask.functionName = request.type
'         m.getTwitchDataTask.control = "run"
'     end if
' end function

' function handleResponse()
'     if m.top.contentRequested.contentType = "VOD"
'         usherUrl = "https://usher.ttvnw.net/vod/" + m.gettwitchdatatask.response.data.video.id + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&nauth=" + m.gettwitchdatatask.response.data.video.playbackAccessToken.value.EncodeUri() + "&nauthsig=" + m.gettwitchdatatask.response.data.video.playbackAccessToken.signature
'     else if m.top.contentRequested.contentType = "LIVE"
'         usherUrl = "https://usher.ttvnw.net/api/channel/hls/" + m.gettwitchdatatask.response.data.user.login + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&lr=true&token=" + m.gettwitchdatatask.response.data.user.stream.playbackaccesstoken.value.EncodeUri() + "&sig=" + m.gettwitchdatatask.response.data.user.stream.playbackaccesstoken.signature
'     end if
'     ' return usherUrl
'     m.usherRequestTask = createObject("roSGNode", "httpRequest")
'     m.usherRequestTask.observeField("response", "handleUsherResponse")
'     m.usherRequestTask.request = {
'         url: usherUrl
'         headers: {
'             "Accept": "*/*"
'             "Origin": "https://switch.tv.twitch.tv"
'             "Referer": "https://switch.tv.twitch.tv/"
'         }
'         method: "GET"
'     }
'     m.usherRequestTask.control = "RUN"
' end function

' function handleUsherResponse()
'     rsp = m.usherRequestTask.response.data
'     list = rsp.Split(chr(10))
'     first_stream_link = ""
'     last_stream_link = ""
'     link = ""
'     cnt = 0
'     ' streamitems_all = []
'     stream_objects = []
'     for line = 2 to list.Count() - 1
'         stream_info = list[line + 1].Split(",")
'         streamobject = {}
'         for info = 0 to stream_info.Count() - 1
'             info_parsed = stream_info[info].Split("=")
'             streamobject[info_parsed[0].replace("#EXT-X-STREAM-INF:", "")] = toString(info_parsed[1], true).replace(chr(34), "")
'         end for
'         streamobject["URL"] = list[line + 2]
'         stream_objects.push(streamobject)
'         line += 2
'     end for
'     stream_bitrates = []
'     stream_urls = []
'     stream_qualities = []
'     stream_content_ids = []
'     stream_sticky = []
'     for each stream_item in stream_objects
'         if stream_item["VIDEO"] = "chunked"
'             res = stream_item["RESOLUTION"].split("x")[1]
'             if stream_item["FRAME-RATE"] <> invalid
'                 fps = stream_item["FRAME-RATE"].split(".")[0]
'             end if
'             value = res + "p"
'             if fps <> invalid
'                 value = value + fps
'             end if
'         else
'             value = stream_item["VIDEO"]
'         end if
'         if Int(Val(stream_item["RESOLUTION"].split("x")[1])) >= 720
'             stream_quality = "HD"
'         else
'             stream_quality = "SD"
'         end if
'         resolution = value.split("p")[0]
'         fps = value.split("p")[1]
'         if resolution <> invalid
'             if resolution.ToInt() > get_user_setting("VideoQualitySetting").ToInt()
'                 ? "Res Skip: "; value
'                 continue for
'             end if
'         end if
'         if fps <> invalid
'             if fps.ToInt() > get_user_setting("VideoFramerateSetting").ToInt()
'                 ? "Fps Skip: "; value
'                 continue for
'             end if
'         end if
'         stream_qualities.push(stream_quality)
'         stream_content_ids.push(value)
'         stream_urls.push(stream_item["URL"])
'         stream_bitrates.push(Int(Val(stream_item["BANDWIDTH"])) / 1000)
'         stream_sticky.push("false")
'     end for
'     ' The stream needs a couple of seconds to load on AWS's server side before we display back to user.
'     ' The idea is that this will provide a better user experience by removing stuttering.
'     playVideo({
'         streamUrls: stream_urls
'         streamQualities: stream_qualities
'         streamContentIDs: stream_content_ids
'         streamBitrates: stream_bitrates
'         streamStickyHttpRedirects: stream_sticky
'     })
' end function

function playClip()
    vidContent = createObject("roSGNode", "ContentNode")
    vidContent.title = m.top.contentRequested.contentTitle
    vidContent.url = Left(m.top.contentRequested.previewImageUrl, Len(m.top.contentRequested.previewImageUrl) - 20) + ".mp4"
    vidContent.streamFormat = "mp4"
    m.video.video_id = m.top.contentRequested.contentId
    m.video.streamUrls = [vidContent.url]
    m.video.streamQualities = ["HD"]
    m.video.streamContentIds = ["Original"]
    m.video.channelUsername = m.top.contentRequested.streamerDisplayName
    m.video.channelAvatar = m.top.contentRequested.streamerProfileImageUrl
    m.video.videoTitle = m.top.contentRequested.contentTitle
    m.video.content = vidContent
    m.video.visible = true
    m.video.setFocus(true)
    m.video.enableCookies()
    m.chatWindow.visible = false
    checkBookmarks()
    m.video.control = "play"
end function

function playVideo(data)
    vidContent = createObject("roSGNode", "ContentNode")
    vidContent.title = m.top.contentRequested.contentTitle
    vidContent.url = data.streamUrls[0]
    vidContent.streamFormat = "hls"
    m.video.video_id = m.top.contentRequested.contentId
    m.video.streamUrls = data.streamUrls
    m.video.streamQualities = data.streamQualities
    m.video.streamContentIds = data.streamContentIds
    m.video.streamBitrates = data.streamBitrates
    m.video.streamStickyHttpRedirects = data.streamStickyHttpRedirects
    m.video.channelUsername = m.top.contentRequested.streamerDisplayName
    m.video.channelAvatar = m.top.contentRequested.streamerProfileImageUrl
    m.video.videoTitle = m.top.contentRequested.contentTitle
    m.video.content = vidContent
    m.video.visible = true
    m.video.setFocus(true)
    m.video.enableCookies()
    checkBookmarks()
    m.video.control = "play"
    ' I'm too tired to do this better, but channel_id needs to be set before channel
    m.chatWindow.channel_id = m.top.contentRequested.streamerId
    m.chatWindow.channel = m.top.contentRequested.streamerLogin
    if get_user_setting("ChatOption", "true") = "true"
        m.chatWindow.visible = true
        m.video.chatIsVisible = m.chatWindow.visible
    else
        m.chatWindow.visible = false
    end if
end function

function checkBookmarks()
    ' ? "Check the bookmark"
    if m.video.video_id <> invalid
        ' ?"video id is valid: "; m.video.video_id
        if m.video.videoBookmarks.DoesExist(m.video.video_id)
            ' ? "Jump To Position From Bookmarks > " m.video.videoBookmarks[m.video.video_id]
            m.video.seek = Val(m.video.videoBookmarks[m.video.video_id])
        end if
    end if
end function