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
    ' content.ignoreStreamErrors = true
    m.top.content = m.PlayVideo.response
    m.top.metadata = m.PlayVideo.metadata
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

function onQualityChangeRequested()
    ? "[Video Wrapper] - Quality Change Requested: "; m.video.qualityChangeRequest
    new_content = CreateObject("roSGNode", "TwitchContentNode")
    new_content.setFields(m.top.contentRequested.getFields())
    new_content.setFields(m.top.metadata[m.video.qualityChangeRequest])
    m.top.content = new_content
    m.allowBreak = false
    exitPlayer()
    playContent()
    m.allowBreak = true
end function

sub playContent()
    if m.video <> invalid
        m.top.removeChild(m.video)
    end if
    if m.top.contentRequested.contentType = "LIVE"
        quality_options = []
        if m.top.metadata <> invalid
            for each quality_option in m.top.metadata
                quality_options.push(quality_option.qualityID)
            end for
        end if
        m.video = m.top.CreateChild("StitchVideo")
        m.video.qualityOptions = quality_options
    else
        m.video = m.top.CreateChild("CustomVideo")
    end if
    httpAgent = CreateObject("roHttpAgent")
    httpAgent.setCertificatesFile("common:/certs/ca-bundle.crt")
    httpAgent.InitClientCertificates()
    httpAgent.enableCookies()
    httpAgent.addheader("Accept", "*/*")
    httpAgent.addHeader("content-type", "application/octet-stream")
    httpAgent.addheader("authority", "wv-keyos-twitch.licensekeyserver.com")
    httpAgent.addheader("Origin", "https://switch.tv.twitch.tv")
    httpAgent.addheader("Referer", "https://switch.tv.twitch.tv/")
    m.video.setHttpAgent(httpAgent)
    m.video.notificationInterval = 1
    m.video.observeField("toggleChat", "onToggleChat")
    m.video.observeField("QualityChangeRequestFlag", "onQualityChangeRequested")
    videoBookmarks = get_user_setting("VideoBookmarks", "")
    m.video.video_type = m.top.contentRequested.contentType
    m.video.video_id = m.top.contentRequested.contentId
    if videoBookmarks <> ""
        m.video.videoBookmarks = ParseJSON(videoBookmarks)
    else
        m.video.videoBookmarks = {}
    end if
    ? "Quality Selection: "; m.top.content
    content = m.top.content
    if content <> invalid then
        m.video.content = content
        if content.streamerProfileImageUrl <> invalid
            m.video.channelAvatar = content.streamerProfileImageUrl
        end if
        if content.streamerDisplayName <> invalid
            m.video.channelUsername = content.streamerDisplayName
        end if
        if content.contentTitle <> invalid
            m.video.videoTitle = content.contentTitle
        end if
        m.video.visible = false
        if m.video.video_id <> invalid
            ? "video id is valid: "; m.video.video_id
            if m.video.videoBookmarks.DoesExist(m.video.video_id)
                ? "Jump To Position From Bookmarks > " m.video.videoBookmarks[m.video.video_id]
                m.video.seek = Val(m.video.videoBookmarks[m.video.video_id])
            end if
        end if
        m.PlayerTask = CreateObject("roSGNode", "PlayerTask")
        m.PlayerTask.observeField("state", "taskStateChanged")
        m.PlayerTask.video = m.video
        m.PlayerTask.control = "RUN"
        initChat()
    end if
end sub

sub exitPlayer()
    print "Player: exitPlayer()"
    if m.video <> invalid
        m.video.control = "stop"
        m.video.visible = false
    end if
    m.PlayerTask = invalid
    'signal upwards that we are done
    if m.allowBreak
        m.top.state = "done"
    end if
end sub


function onKeyEvent(key, press) as boolean
    if press
        ? "[VideoPlayer] Key Event: "; key
        if key = "back" then
            'handle Back button, by exiting play
            m.chatWindow.callFunc("stopJobs")
            exitPlayer()
            m.top.backpressed = true
            return true
        end if
    end if
end function


sub init()
    ' m.video.observeField("back", "onvideoBack")
    m.chatWindow = m.top.findNode("chat")
    m.chatWindow.fontSize = get_user_setting("ChatFontSize")
    m.chatWindow.observeField("visible", "onChatVisibilityChange")
    m.allowBreak = true
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
        m.chatWindow.width = 320
        m.video.width = 960
        m.video.height = 720
    else
        m.video.width = 0
        m.video.height = 0
    end if
end sub

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