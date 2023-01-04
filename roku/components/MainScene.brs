'api.twitch.tv/api/channels/${user}/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6
'usher.ttvnw.net/api/channel/hls/${user}.m3u8?allow_source=true&allow_spectre=true&type=any&token=${token}&sig=${sig}

function init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0x020202FF"
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.keyboardGroup = m.top.findNode("keyboardGroup")
    m.homeScene = m.top.findNode("homeScene")
    m.categoryScene = m.top.findNode("categoryScene")
    m.loginPage = m.top.findNode("loginPage")

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

    if checkReset() = "false"
        sec = createObject("roRegistrySection", "StitchUserData")
        sec.Write("UserToken", "")
        sec.Write("RefreshToken", "")
        sec.Write("LoggedInUser", "")
        ? "RESETTED"
        setReset("true")
    end if

    loggedInUser = checkIfLoggedIn()
    if loggedInUser <> invalid
        m.getUser.loginRequested = loggedInUser
        m.getUser.control = "RUN"
        m.login = loggedInUser
    end if

    videoQuality = checkSavedVideoQuality()
    if videoQuality <> invalid
        m.global.addFields({ videoQuality: Int(Val(videoQuality)) })
    else
        m.global.addFields({ videoQuality: 2 })
    end if

    videoFramerate = checkSavedVideoFramerate()
    if videoQuality <> invalid
        m.global.addFields({ videoFramerate: Int(Val(videoFramerate)) })
    else
        m.global.addFields({ videoFramerate: 60 })
    end if

    chatOption = checkSavedChatOption()
    if chatOption <> invalid and chatOption = "true"
        m.global.addFields({ chatOption: true })
    else
        m.global.addFields({ chatOption: false })
    end if

    userData = getTokenFromRegistry()
    if userdata.access_token <> invalid and userdata.access_token <> ""
        m.global.addFields({ userToken: userdata.access_token })
    else
        m.global.addFields({ userToken: "" })
    end if
    ? "User Token is "; m.global.userToken

    if userdata.refresh_token <> invalid and userdata.refresh_token <> ""
        m.global.addFields({ refreshToken: userdata.refresh_token })
    else
        m.global.addFields({ refreshToken: "" })
    end if
    ? "Refresh Token is "; m.global.refreshToken
    if userdata.login <> invalid and userdata.login <> ""
        m.global.addFields({ loggedInUser: userdata.login })
    else
        m.global.addFields({ loggedInUser: "" })
    end if
    ? "LoggedInUser is "; userData



    videoBookmarks = checkVideoBookmarks()
    ? "MainScene >> videoBookmarks > " videoBookmarks
    if videoBookmarks <> ""
        'm.videoPlayer.videoBookmarks = {}
        m.videoPlayer.videoBookmarks = ParseJSON(videoBookmarks)
        ? "MainScene >> ParseJSON > " m.videoPlayer.videoBookmarks
    else
        m.videoPlayer.videoBookmarks = {}
    end if

    ? "MainScene >> registry space > " createObject("roRegistry").GetSpaceAvailable()

    m.chat = m.top.findNode("chat")
    m.chat.observeField("doneFocus", "onChatDoneFocus")

    m.options = createObject("roSGNode", "Options")
    m.options.visible = false

    m.top.appendChild(m.options)

    m.homeScene.setFocus(true)
    m.videoPlayer.notificationInterval = 1
    m.plyrTask = invalid
end function

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
' function on_open(event as object) as void
'     m.ws.send = ["Hello World"]
' end function

' function on_message(event as object) as void
'     print event.getData().message
' end function

sub onLoginFinish()
    ? "Main Scene > onLoginFinish"
    if m.loginPage.finished = true
        loggedInUser = checkIfLoggedIn()
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
    m.global.addFields({ appBearerToken: m.getToken.appBearerToken })
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
    m.homeScene.thumbnailInfo = invalid
    playVideo(m.stream)
    if m.videoPlayer.thumbnailInfo <> invalid
        if m.videoPlayer.videoBookmarks.DoesExist(m.videoPlayer.thumbnailInfo.video_id.ToStr())
            ? "MainScene >> position > " m.videoPlayer.videoBookmarks[m.videoPlayer.thumbnailInfo.video_id.ToStr()]
            m.videoPlayer.seek = Val(m.videoPlayer.videoBookmarks[m.videoPlayer.thumbnailInfo.video_id.ToStr()])
        end if
    end if
end sub

sub onStreamerSelected()
    ? "Main Scene > onStreamerSelected"
    if m.homeScene.visible
        ? "MainScene > Streamer"
        'm.channelPage.streamerSelectedName = m.homeScene.streamerSelectedName
        'm.channelPage.streamerSelectedThumbnail = m.homeScene.streamerSelectedThumbnail
        m.lastScene = "home"
    else if m.categoryScene.visible
        m.homeScene.lastScene = "category"
        m.homeScene.streamerSelectedThumbnail = m.categoryScene.streamerSelectedThumbnail
        m.homeScene.streamerSelectedName = m.categoryScene.streamerSelectedName
        m.lastLastScene = "home" 'm.lastScene
        m.lastScene = "category"
    else if m.keyboardGroup.visible
        'm.channelPage.streamerSelectedName = m.keyboardGroup.streamerSelectedName
        'm.channelPage.streamerSelectedThumbnail = ""
        m.homeScene.streamerSelectedName = m.keyboardGroup.streamerSelectedName
        m.homeScene.streamerSelectedThumbnail = ""
        m.lastLastScene = "home"
        m.lastScene = "search"
    end if
    m.homeScene.visible = false
    m.keyboardGroup.visible = false
    m.categoryScene.visible = false

    'm.channelPage.visible = true
    m.homeScene.visible = true

    m.currentScene = "channel"
end sub

function checkReset()
    ? "Main Scene > checkReset"
    sec = createObject("roRegistrySection", "StitchUserData")
    if sec.Exists("Reset")
        return sec.Read("Reset")
    end if
    return "false"
end function

function checkUserToken()
    ? "Main Scene > checkUserToken"
    sec = createObject("roRegistrySection", "StitchUserData")
    if sec.Exists("UserToken")
        return sec.Read("UserToken")
    end if
    return ""
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

function checkVideoBookmarks()
    ? "Main Scene > checkVideoBookmarks"
    sec = createObject("roRegistrySection", "VideoSettings")
    if sec.Exists("VideoBookmarks")
        return sec.Read("VideoBookmarks")
    end if
    return ""
end function

function checkSavedChatOption()
    ? "Main Scene > checkSavedChatOption"
    sec = createObject("roRegistrySection", "VideoSettings")
    if sec.Exists("ChatOption")
        return sec.Read("ChatOption")
    end if
    return invalid
end function

function checkSavedVideoFramerate()
    ? "Main Scene > checkSavedVideoFramerate"
    sec = createObject("roRegistrySection", "VideoSettings")
    if sec.Exists("VideoFramerate")
        return sec.Read("VideoFramerate")
    end if
    return invalid
end function

function checkSavedVideoQuality()
    ? "Main Scene > checkSavedVideoQuality"
    sec = createObject("roRegistrySection", "VideoSettings")
    if sec.Exists("VideoQuality")
        return sec.Read("VideoQuality")
    end if
    return invalid
end function

function checkIfLoggedIn() as dynamic
    ? "Main Scene > checkIfLoggedIn"
    sec = createObject("roRegistrySection", "StitchUserData")
    if sec.Exists("LoggedInUser")
        return sec.Read("LoggedInUser")
    end if
    return invalid
end function

function setReset(word as string) as void
    ? "Main Scene > setReset"
    sec = createObject("roRegistrySection", "StitchUserData")
    sec.Write("Reset", word)
    sec.Flush()
end function

' function saveLogin() as void
'     ? "Main Scene > saveLogin"
'     sec = createObject("roRegistrySection", "StitchUserData")
'     sec.Write("LoggedInUser", m.homeScene.loggedInUserName)
'     sec.Flush()
' end function

function onHeaderButtonPress()
    ? "Main Scene > onHeaderButtonPress"
    if m.homeScene.buttonPressed = "search"
        m.homeScene.visible = false
        m.keyboardGroup.visible = true
        m.keyboardGroup.setFocus(true)
    else if m.homeScene.buttonPressed = "login"
        'm.top.dialog = createObject("RoSGNode", "LoginPrompt")
        'm.top.dialog.observeField("buttonSelected", "onLogin")
        m.homeScene.visible = false
        m.loginPage.visible = true
        m.loginPage.setFocus(true)
    else if m.homeScene.buttonPressed = "options"
        m.homeScene.visible = false
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

function onStreamChange()
    ? "Main Scene > onStreamChange"
    m.stream["streamFormat"] = "hls"
    if m.keyboardGroup.visible
        m.currentScene = "search"
        m.chat.channel = m.keyboardGroup.streamerRequested
        m.stream["url"] = m.keyboardGroup.streamUrl
    else if m.homeScene.visible
        m.currentScene = "home"
        m.chat.channel = m.homeScene.streamerSelectedName 'm.homeScene.streamerRequested
        m.videoPlayer.videoTitle = m.homeScene.videoTitle
        m.videoPlayer.channelUsername = m.homeScene.channelUsername
        m.videoPlayer.channelAvatar = m.homeScene.channelAvatar
        m.videoPlayer.streamDurationSeconds = m.homeScene.streamDurationSeconds
        m.stream["url"] = m.homeScene.streamUrl
    else if m.categoryScene.visible
        m.currentScene = "category"
        m.chat.channel = m.categoryScene.streamerRequested
        m.stream["url"] = m.categoryScene.streamUrl
        ' else if m.channelPage.visible
        '     m.currentScene = "channel"
        '     m.channelPage.visible = false
        '     m.chat.channel = m.channelPage.streamerSelectedName
        '     m.stream["url"] = m.channelPage.streamUrl
    end if
    m.chat.visible = m.global.chatOption
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
    if invalid = m.plyrTask
        m.plyrTask = createObject("roSGNode", "playerTask")
        m.plyrTask.observeField("state", "onTaskStateUpdated")
    end if
    streamConfig = {
        title: ""
        streamformat: stream["streamFormat"]
        useStitched: true
        live: false
        url: stream["url"]
        type: "vod"
        streamtype: "vod"
        player: { sgnode: m.videoPlayer }
    }
    if stream["streamFormat"] = "hls"
        streamConfig.live = true
        streamConfig.type = "live"
        streamConfig.streamtype = "live"
    end if
    m.plyrTask.streamConfig = streamConfig
    m.plyrTask.video = m.videoPlayer
    m.plyrTask.control = "run"
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
end sub

sub onToggleChat()
    ? "Main Scene > onToggleChat"
    if m.videoPlayer.toggleChat = true
        m.chat.visible = not m.chat.visible
        m.videoPlayer.chatIsVisible = m.chat.visible
        m.videoPlayer.toggleChat = false
    end if
end sub

' This needs rework
function onKeyEvent(key, press) as boolean
    ' ? "Main Scene > onKeyEvent"
    handled = false
    if press
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
        else if m.options.visible and key = "back"
            m.options.visible = false
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
            m.chat.setKeyboardFocus = true
            handled = true
        end if
    end if

    '? "MAINSCENE > handled " handled " > (" key ", " press ")"
    return handled
end function

function saveLogin(access_token, refresh_token, login) as void
    sec = createObject("roRegistrySection", "StitchUserData")
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