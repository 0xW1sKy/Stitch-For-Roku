'api.twitch.tv/api/channels/${user}/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6
'usher.ttvnw.net/api/channel/hls/${user}.m3u8?allow_source=true&allow_spectre=true&type=any&token=${token}&sig=${sig}

function init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = m.global.constants.colors.muted.black
    if get_setting("active_user", invalid) = invalid
        set_setting("active_user", "default")
    end if
    validateDeviceCode()
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.keyboardGroup = m.top.findNode("keyboardGroup")
    m.homeScene = m.top.findNode("homeScene")
    m.categoryScene = m.top.findNode("categoryScene")
    m.loginPage = m.top.findNode("loginPage")
    m.options = m.top.findNode("Options")
    m.keyboardGroup.observeField("streamUrl", "onStreamChange")
    m.keyboardGroup.observeField("streamerSelectedName", "onStreamerSelected")
    m.categoryScene.observeField("streamerSelectedThumbnail", "onStreamerSelected")
    m.homeScene.observeField("backgroundImageUri", "onBackgroundChange")
    m.homeScene.observeField("streamUrl", "onStreamChange")
    m.homeScene.observeField("streamerSelectedName", "onStreamerSelected")
    m.homeScene.observeField("categorySelected", "onCategoryItemSelect")
    m.homeScene.observeField("buttonPressed", "onHeaderButtonPress")
    m.homeScene.observeField("videoUrl", "onStreamChangeFromChannelPage")
    m.keyboardGroup.observeField("categorySelected", "onCategoryItemSelectFromSearch")
    m.categoryScene.observeField("streamUrl", "onStreamChange")
    m.categoryScene.observeField("clipUrl", "onClipChange")
    m.loginPage.observeField("finished", "onLoginFinish")
    m.videoPlayer.observeField("back", "onVideoPlayerBack")
    m.videoPlayer.observeField("toggleChat", "onToggleChat")
    m.currentScene = "home"
    m.lastScene = ""
    m.lastLastScene = ""
    m.stream = createObject("RoSGNode", "ContentNode")
    m.stream.streamFormat = "hls"
    m.getToken = createObject("roSGNode", "GetToken")
    m.getToken.observeField("appBearerToken", "onBearerTokenReceived")
    m.getToken.control = "RUN"
    m.login = ""
    m.getUser = createObject("roSGNode", "GetUser")
    m.getUser.observeField("searchResults", "onUserLogin")

    m.testtimer = m.top.findNode("testTimer")
    m.testtimer.control = "start"
    m.testtimer.ObserveField("fire", "refreshFollows")
    m.videoPlayer.observeField("streamLayoutMode", "onToggleStreamLayout")

    loggedInUser = get_user_setting("login", invalid)
    if loggedInUser <> invalid
        m.getUser.loginRequested = loggedInUser
        m.getUser.control = "RUN"
        m.login = loggedInUser
    end if

    videoBookmarks = get_user_setting("VideoBookmarks", "")
    if videoBookmarks <> ""
        m.videoPlayer.videoBookmarks = ParseJSON(videoBookmarks)
        ? "MainScene >> ParseJSON > " m.videoPlayer.videoBookmarks
    else
        m.videoPlayer.videoBookmarks = {}
    end if

    ? "MainScene >> registry space > " createObject("roRegistry").GetSpaceAvailable()

    m.chat = m.top.findNode("chat")
    m.chat.observeField("doneFocus", "onChatDoneFocus")
    m.homeScene.setFocus(true)
    m.videoPlayer.notificationInterval = 1
    m.plyrTask = invalid
    m.buttonHoldTimer = createObject("roSGNode", "Timer")
    m.buttonHoldTimer.observeField("fire", "onButtonHold")
    m.buttonHoldTimer.repeat = true
    m.buttonHoldTimer.duration = "15"
    m.buttonHoldTimer.control = "stop"
end function

sub handleDevicecode()
    set_user_setting("device_code", m.task.response.device_code)
end sub

sub validateDeviceCode()
    device_code = get_user_setting("device_code", invalid)
    if device_code = invalid
        m.Task = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
        ' observe content so we can know when feed content will be parsed
        m.Task.observeField("response", "handleDeviceCode")
        m.Task.request = {
            type: "getRendezvouzToken"
        }
        m.Task.functionName = m.task.request.type
        m.Task.control = "run"
    end if
end sub

sub onChatDoneFocus()
    ? "Main Scene > onChatDoneFocus"
    if m.chat.doneFocus
        m.videoPlayer.setFocus(true)
        m.chat.doneFocus = false
    end if
end sub

sub onBackgroundChange()
    ? "Main Scene > onBackgroundChange"
    m.top.backgroundUri = m.homeScene.backgroundImageUri

end sub

sub onLoginFinish()
    ? "Main Scene > onLoginFinish"
    if m.loginPage.finished = true
        loggedInUser = get_user_setting("login", invalid)
        if loggedInUser <> invalid
            m.getUser.loginRequested = loggedInUser
            m.getUser.control = "RUN"
            m.login = loggedInUser
        end if
        m.loginPage.visible = false
        m.homeScene.visible = false
        m.homeScene.visible = true
        m.homeScene.setFocus(true)
        m.loginPage.finished = false
    end if
end sub

sub onBearerTokenReceived()
    ? "Main Scene > onBearerTokenReceived"
    set_setting("AppBearerToken", m.getToken.appBearerToken)
end sub

sub onStreamChangeFromChannelPage()
    ? "Main Scene > onStreamChangeFromChannelPage"
    m.stream["streamFormat"] = "hls"
    m.stream["url"] = m.homeScene.videoUrl
    m.chat.visible = false
    m.videoPlayer.chatIsVisible = m.chat.visible
    m.videoPlayer.videoTitle = m.homeScene.videoTitle
    m.videoPlayer.channelUsername = m.homeScene.channelUsername
    m.videoPlayer.channelAvatar = m.homeScene.channelAvatar
    m.videoPlayer.thumbnailInfo = m.homeScene.thumbnailInfo
    if m.stream.URL.Instr("/vod/") > -1
        m.videoPlayer.video_id = m.stream.URL.split("/vod/")[1].split(".m3u8?")[0]
    else
        m.videoPlayer.video_id = invalid
    end if
    m.homeScene.thumbnailInfo = invalid
    playVideo(m.stream)
    if m.videoPlayer.video_id <> invalid
        if m.videoPlayer.videoBookmarks.DoesExist(m.videoPlayer.video_id)
            ? "MainScene >> position > " m.videoPlayer.videoBookmarks[m.videoPlayer.video_id]
            m.videoPlayer.seek = Val(m.videoPlayer.videoBookmarks[m.videoPlayer.video_id])
        end if
    end if
end sub

sub onStreamerSelected()
    ? "Main Scene > onStreamerSelected"
    if m.homeScene.visible
        ? "MainScene > Streamer"
        m.lastScene = "home"
    else if m.categoryScene.visible
        m.homeScene.lastScene = "category"
        m.homeScene.streamerSelectedThumbnail = m.categoryScene.streamerSelectedThumbnail
        m.homeScene.streamerSelectedName = m.categoryScene.streamerSelectedName
        m.lastLastScene = "home" 'm.lastScene
        m.lastScene = "category"
    else if m.keyboardGroup.visible
        m.homeScene.streamerSelectedName = m.keyboardGroup.streamerSelectedName
        m.homeScene.streamerSelectedThumbnail = ""
        m.lastLastScene = "home"
        m.lastScene = "search"
    end if
    m.homeScene.visible = false
    m.keyboardGroup.visible = false
    m.categoryScene.visible = false
    m.homeScene.visible = true
    m.currentScene = "channel"
end sub

function onHeaderButtonPress()
    ? "Main Scene > onHeaderButtonPress"
    if m.homeScene.buttonPressed = "search"
        m.homeScene.visible = false
        m.keyboardGroup.visible = true
        m.keyboardGroup.setFocus(true)
    else if m.homeScene.buttonPressed = "login"
        m.loginPage.visible = true
        m.loginPage.setFocus(true)
    else if m.homeScene.buttonPressed = "options"
        m.options.visible = true
        m.options.setFocus(true)
    end if
end function

function onUserLogin()
    userdata = getTokenFromRegistry()
    ? "Main Scene > onUserLogin"
    ?"USERDATA: "; userdata
    m.homeScene.loggedInUserName = userdata.login
    if m.getUser.searchResults.profile_image_url <> invalid
        m.homeScene.loggedInUserProfileImage = m.getUser.searchResults.profile_image_url
        m.chat.loggedInUsername = userdata.login
    else
        m.homeScene.loggedInUserProfileImage = ""
        m.homeScene.loggedInUserName = "Login"
    end if
    m.homeScene.followedStreams = m.getUser.searchResults.followed_users
    m.homeScene.currentlyLiveStreamerIds = m.getUser.currentlyLiveStreamerIds
end function

function onCategoryItemSelectFromSearch()
    ? "Main Scene > onCategoryItemSelectFromSearch"
    m.categoryScene.currentCategory = m.keyboardGroup.categorySelected
    m.homeScene.visible = false
    m.keyboardGroup.visible = false
    m.categoryScene.visible = true
    m.lastLastScene = "home"
    m.lastScene = "search"
end function

function onCategoryItemSelect()
    ? "Main Scene > onCategoryItemSelect"
    m.categoryScene.currentCategory = m.homeScene.categorySelected
    m.homeScene.visible = false
    m.keyboardGroup.visible = false
    m.categoryScene.visible = true
    m.lastScene = "home"
end function

function onClipChange()
    ? "Main Scene > onClipChange"
    m.categoryScene.fromClip = true
    m.stream["streamFormat"] = "mp4"
    if m.categoryScene.visible = true
        m.currentScene = "category"
        m.stream["url"] = m.categoryScene.clipUrl
    end if
    m.categoryScene.visible = false
    playVideo(m.stream)
end function

sub onQualityChangeRequest()

end sub


function onStreamChange()
    ? "Main Scene > onStreamChange"
    m.stream["streamFormat"] = "hls"
    if m.keyboardGroup.visible
        m.currentScene = "search"
        m.chat.channel = m.keyboardGroup.streamerRequested
        AddAndSetFields(m.stream, m.keyboardGroup.streamMetadata)
        m.stream["url"] = m.keyboardGroup.streamUrl
    else if m.homeScene.visible
        m.currentScene = "home"
        m.chat.channel = m.homeScene.streamerSelectedName 'm.homeScene.streamerRequested
        m.videoPlayer.videoTitle = m.homeScene.videoTitle
        m.videoPlayer.channelUsername = m.homeScene.channelUsername
        m.videoPlayer.channelAvatar = m.homeScene.channelAvatar
        m.videoPlayer.streamDurationSeconds = m.homeScene.streamDurationSeconds
        AddAndSetFields(m.videoPlayer, m.homeScene.streamMetadata)
        ? "STOP"
        m.stream["url"] = m.homeScene.streamUrl
    else if m.categoryScene.visible
        m.currentScene = "category"
        m.chat.channel = m.categoryScene.streamerRequested
        AddAndSetFields(m.stream, m.categoryScene.streamMetadata)
        m.stream["url"] = m.categoryScene.streamUrl
    end if
    if get_user_setting("ChatOption", "true") = "true"
        m.chat.visible = true
    else
        m.chat.visible = false
    end if
    m.videoPlayer.chatIsVisible = m.chat.visible
    playVideo(m.stream)
end function

function playVideo(stream as object)
    m.videoPlayer.width = 0
    m.videoPlayer.height = 0
    m.videoPlayer.setFocus(true)
    if m.keyboardGroup.visible
        m.keyboardGroup.visible = false
    end if
    if not m.videoPlayer.visible
        m.videoPlayer.visible = true
    end if
    m.videoPlayer.content = stream
    m.videoPlayer.control = "play"
end function

function refreshFollows()
    ? "Main Scene > refreshFollows"
    if m.login <> ""
        m.getUser.loginRequested = m.login
        m.getUser.control = "RUN"
    end if
end function

function onLogin()
    ? "Main Scene > onLogin"
    m.login = m.top.dialog.text
    '? "login > "; m.login
    m.top.dialog.close = true
    m.getUser.loginRequested = m.login
    m.getUser.control = "RUN"
end function

sub onVideoPlayerBack()
    ? "Main Scene > onVideoPlayerBack"
    if m.videoPlayer.back = true
        m.videoPlayer.control = "stop"
        m.videoPlayer.visible = false
        m.keyboardGroup.visible = false
        if m.currentScene = "home"
            m.homeScene.visible = false
            m.homeScene.visible = true
            m.homeScene.setFocus(true)
        else if m.currentScene = "category"
            m.categoryScene.visible = true
            'm.categoryScene.fromClip = false
            m.categoryScene.setFocus(true)
        else if m.currentScene = "search"
            m.keyboardGroup.visible = true
        else if m.currentScene = "channel"
            m.homeScene.visible = false
            m.homeScene.visible = true
            m.homeScene.setFocus(true)
            'm.channelPage.visible = true
            'm.channelPage.setFocus(true)
        end if
        m.chat.visible = false
        m.videoPlayer.chatIsVisible = m.chat.visible
        m.videoPlayer.back = false
    end if
    if m.videoplayer.qualityChangeRequestflag = true
        m.stream["url"] = m.videoplayer.qualityChangeRequest
        playVideo(m.stream)
        m.videoplayer.qualityChangeRequestFlag = false
    end if
end sub

sub onToggleChat()
    ? "Main Scene > onToggleChat"
    if m.videoPlayer.toggleChat = true
        m.chat.visible = not m.chat.visible
        m.videoPlayer.chatIsVisible = m.chat.visible
        m.videoPlayer.toggleChat = false
    end if
end sub


sub onToggleStreamLayout()
    ? "Layout Mode is "; m.videoPlayer.streamLayoutMode
    if m.videoPlayer.streamLayoutMode = 0 'stream is shrinked
        m.videoPlayer.width = 1030
        m.videoPlayer.height = 720
        m.chat.getchild(0).opacity = "1"
        m.chat.visible = true
        m.videoPlayer.chatIsVisible = m.chat.visible
    else if m.videoPlayer.streamLayoutMode = 1 'layout with chat on top of stream
        m.videoPlayer.width = 0
        m.videoPlayer.height = 0
        m.chat.getchild(0).opacity = "0.85"
        m.chat.visible = true
        m.videoPlayer.chatIsVisible = m.chat.visible
    else if m.videoPlayer.streamLayoutMode = 2 'no chat layout fullscreen
        m.videoPlayer.width = 0
        m.videoPlayer.height = 0
        m.chat.visible = false
        m.videoPlayer.chatIsVisible = m.chat.visible
    end if
end sub

sub onButtonHold()
    if m.buttonHeld = "replay"
        NukeRegistry()
        m.top.exitApp = true
    end if
    if m.buttonHeld = "options"
        ? "Only used for dev purposes"
    end if
end sub
' This needs rework
function onKeyEvent(key, press) as boolean
    ? "Main Scene > onKeyEvent" + key; press
    handled = false
    if press
        if key = "replay"
            m.buttonHeld = "replay"
            m.buttonHoldTimer.control = "start"
            ' ? "KONAMI"
        end if
        if key = "options"
            m.buttonHeld = "options"
            m.buttonHoldTimer.control = "start"
        end if
        if m.videoPlayer.visible = true and key = "back"
            m.videoPlayer.back = true
            handled = true
        else if m.videoPlayer.visible = true and key = "rewind"
            'm.chat.visible = not m.chat.visible
            'handled = true
        else if m.homeScene.visible = true and key = "options"
            m.homeScene.visible = false
            m.keyboardGroup.visible = true
            m.keyboardGroup.setFocus(true)
            handled = true
        else if (m.options.visible or m.loginPage.visible) and key = "back"
            m.options.visible = false
            m.loginPage.visible = false
            m.homeScene.visible = false
            m.homeScene.visible = true
            m.homeScene.setFocus(true)
            handled = true
            'else if (m.keyboardGroup.visible or m.categoryScene.visible or m.channelPage.visible) and key = "back"
        else if (m.keyboardGroup.visible or m.categoryScene.visible) and key = "back"
            m.categoryScene.visible = false
            m.keyboardGroup.visible = false
            m.options.visible = false
            'm.channelPage.visible = false
            m.homeScene.visible = false
            if m.lastScene = "home"
                m.homeScene.visible = false
                m.homeScene.visible = true
                m.homeScene.setFocus(true)
            else if m.lastScene = "category"
                m.lastScene = m.lastLastScene
                m.lastLastScene = "home"
                m.categoryScene.visible = true
                'm.categoryScene.fromClip = false
                m.categoryScene.setFocus(true)
            else if m.lastScene = "search"
                m.lastScene = m.lastLastScene
                m.lastLastScene = "home"
                m.keyboardGroup.visible = true
            else
                m.homeScene.visible = false
                m.homeScene.visible = true
                m.homeScene.setFocus(true)
            end if
            handled = true
        else if m.homeScene.visible and key = "back"
            if m.homeScene.lastScene = "category"
                m.homeScene.visible = false
                m.categoryScene.visible = true
                m.lastScene = m.lastLastScene
                m.lastLastScene = "home"
                'm.categoryScene.setFocus(true)
                handled = true
            end if
            'handled = true
        else if m.loginPage.visible and key = "back"
            m.loginPage.visible = false
            m.homeScene.visible = false
            m.homeScene.visible = true
            m.homeScene.setFocus(true)
            return true
        else if key = "OK" and m.videoPlayer.visible
            handled = true
        end if
    else if not press
        if key = "replay" or key = "options"
            ?"key: " key " press: " press
            m.buttonHoldTimer.control = "stop"
        end if
    end if

    '? "MAINSCENE > handled " handled " > (" key ", " press ")"
    return handled
end function

