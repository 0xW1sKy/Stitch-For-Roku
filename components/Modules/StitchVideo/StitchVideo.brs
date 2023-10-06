function init()
    ' bump
    m.top.enableUI = "false"
    m.top.enableTrickPlay = "false"
    m.progressBar = m.top.findNode("progressBar")
    m.progressBar.visible = false
    m.progressBarBase = m.top.findNode("progressBarBase")
    m.progressBarProgress = m.top.findNode("progressBarProgress")
    m.progressDot = m.top.findNode("progressDot")
    m.timeProgress = m.top.findNode("timeProgress")
    m.timeDuration = m.top.findNode("timeDuration")
    m.controlButton = m.top.findNode("controlButton")

    m.messagesButton = m.top.findNode("messagesButton")
    m.qualitySelectButton = m.top.findNode("qualitySelectButton")
    m.QualityDialog = m.top.findNode("QualityDialog")
    m.glow = m.top.findNode("bg-glow")

    m.currentProgressBarState = 0
    m.currentPositionSeconds = 0
    m.currentPositionUpdated = false
    m.thumbnails = m.top.findNode("thumbnails")
    m.thumbnailImage = m.top.findNode("thumbnailImage")


    m.videoTitle = m.top.findNode("videoTitle")
    m.channelUsername = m.top.findNode("channelUsername")
    m.avatar = m.top.findNode("avatar")

    m.focusedTimeSlot = 0

    m.focusedTimeButton = 0

    m.progressBarFocused = false

    m.top.observeField("position", "watcher")
    m.top.observeField("state", "onvideoStateChange")
    ' m.top.observeField("channelAvatar", "onChannelInfoChange")
    ' m.top.observeField("videoTitle", "onChannelInfoChange")
    ' m.top.observeField("channelUsername", "onChannelInfoChange")
    m.top.observeField("chatIsVisible", "onChatVisibilityChange")
    m.uiResolution = createObject("roDeviceInfo").GetUIResolution()
    m.uiResolutionWidth = m.uiResolution.width
    if m.uiResolutionWidth = 1920
        m.thumbnails.clippingRect = [0, 0, 146.66, 82.66]
    end if

    deviceInfo = CreateObject("roDeviceInfo")
    uiResolutionWidth = deviceInfo.GetUIResolution().width
    m.sec = createObject("roRegistrySection", "VideoSettings")

    m.fadeAwayTimer = createObject("roSGNode", "Timer")
    m.fadeAwayTimer.observeField("fire", "onFadeAway")
    m.fadeAwayTimer.repeat = false
    m.fadeAwayTimer.duration = "8"
    m.fadeAwayTimer.control = "stop"

    m.buttonHoldTimer = createObject("roSGNode", "Timer")
    m.buttonHoldTimer.observeField("fire", "onButtonHold")
    m.buttonHoldTimer.repeat = true
    m.buttonHoldTimer.duration = "0.070"
    m.buttonHoldTimer.control = "stop"

    m.buttonHeld = invalid
    m.scrollInterval = 10
    m.top.streamLayoutMode = 0
    m.buttonFocused = "controlButton"
    ? "Check the bookmark"
end function


function watcher()
    m.timeProgress.text = convertToReadableTimeFormat(m.currentPositionSeconds)
    m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
    m.currentPositionSeconds = m.top.position
    if m.top.duration <> 0
        m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
        m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
    end if

    checker = m.top.position mod 20
    if checker = 0
        saveVideoBookmark()
    end if
end function

function resetProgressBar()
    m.controlButton.blendColor = "0xFFFFFFFF"
    m.messagesButton.blendColor = "0xFFFFFFFF"
    m.qualitySelectButton.blendColor = "0xFFFFFFFF"
    m.currentProgressBarState = 0
    m.thumbnailImage.visible = false
    m.progressBar.visible = false
end function

sub onQualityButtonSelect()
    ? "QualityButtonSelect"
    m.QualityDialog.visible = false
    m.QualityDialog.setFocus(false)
    resetProgressBar()
    m.progressBar.getParent().setFocus(true)
    m.top.qualityChangeRequest = m.QualityDialog.buttonSelected
    m.top.qualityChangeRequestFlag = true
end sub

sub onQualitySelectButtonPressed()
    if m.top.qualityOptions <> invalid
        m.QualityDialog.title = "Please Choose Your Video Quality"
        m.QualityDialog.buttons = m.top.qualityOptions
        m.QualityDialog.observeFieldScoped("buttonSelected", "onQualityButtonSelect")
        m.QualityDialog.visible = true
        m.lastFocusedchild = m.top.focusedChild
        m.QualityDialog.setFocus(true)
    end if
end sub

sub onChatVisibilityChange()
    m.progressBarBase.width = 1200
    m.glow.translation = [692, 32]
    m.qualitySelectButton.translation = [548, 51]
    m.controlButton.translation = [634, 53]
    m.messagesButton.translation = [710, 52]
    m.timeDuration.translation = [1198, 61]
end sub

sub onVideoStateChange()
    if m.top.state = "playing"
        m.top.setFocus(true)
        m.controlButton.uri = "pkg:/images/pause.png"
    else
        m.controlButton.uri = "pkg:/images/play.png"
    end if
end sub

function hideOverlay()
    m.controlButton.blendColor = "0xFFFFFFFF"
    m.messagesButton.blendColor = "0xFFFFFFFF"
    m.qualitySelectButton.blendColor = "0xFFFFFFFF"
    m.currentProgressBarState = 0
    m.thumbnailImage.visible = false
    m.progressBar.visible = false
end function

function showOverlay()
    focusButton(m.controlButton)
    m.thumbnailImage.visible = true
    m.progressBar.visible = true
    m.currentProgressBarState = 1
end function

sub onFadeAway()
    if not m.QualityDialog.visible
        hideOverlay()
    end if
end sub

sub onButtonHold()
    if m.buttonHeld <> invalid
        if m.buttonHeld = "right"
            m.currentPositionSeconds += m.scrollInterval
            m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
            m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
            if m.currentPositionSeconds > m.top.duration
                m.currentPositionSeconds = m.top.duration
            end if
            if m.top.thumbnailInfo <> invalid
                if m.top.thumbnailInfo.width <> invalid
                    if m.progressBarProgress.width + m.top.thumbnailInfo.width / 2 <= m.progressBarBase.width
                        if m.progressBarProgress.width - m.top.thumbnailInfo.width / 2 >= 0
                            m.thumbnails.translation = [m.progressBarProgress.width - m.top.thumbnailInfo.width / 2, -150]
                        else
                            m.thumbnails.translation = [0, -150]
                        end if
                    else
                        m.thumbnails.translation = [m.progressBarBase.width - m.top.thumbnailInfo.width, -150]
                    end if
                end if
            end if
        else if m.buttonHeld = "left"
            m.currentPositionSeconds -= m.scrollInterval
            m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
            m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
            if m.currentPositionSeconds < 0
                m.currentPositionSeconds = 0
            end if
            if m.top.thumbnailInfo <> invalid
                if m.top.thumbnailInfo.width <> invalid
                    if m.progressBarProgress.width - m.top.thumbnailInfo.width / 2 >= 0
                        if m.progressBarProgress.width + m.top.thumbnailInfo.width / 2 <= m.progressBarBase.width
                            m.thumbnails.translation = [m.progressBarProgress.width - m.top.thumbnailInfo.width / 2, -150]
                        else
                            m.thumbnails.translation = [m.progressBarBase.width - m.top.thumbnailInfo.width, -150]
                        end if
                    else
                        m.thumbnails.translation = [0, -150]
                    end if
                end if
                if m.top.thumbnailInfo.width <> invalid
                    showThumbnail()
                end if
            end if
        end if
    end if
    m.timeProgress.text = convertToReadableTimeFormat(m.currentPositionSeconds)
    m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
    m.scrollInterval += 10
end sub

function convertToReadableTimeFormat(time) as string
    time = Int(time)
    if time < 3600
        seconds = Int((time mod 60))
        if seconds < 10
            seconds = "0" + Int((time mod 60)).ToStr()
        else
            seconds = seconds.ToStr()
        end if
        return Int((time / 60)).ToStr() + ":" + seconds
    else
        hours = Int(time / 3600)
        minutes = Int((time mod 3600) / 60)
        seconds = Int((time mod 3600) mod 60)
        if seconds < 10
            seconds = "0" + seconds.ToStr()
        else
            seconds = seconds.ToStr()
        end if
        if minutes < 10
            minutes = "0" + minutes.ToStr()
        else
            minutes = minutes.ToStr()
        end if
        return hours.ToStr() + ":" + minutes + ":" + seconds
    end if
end function

sub onVideoPositionChange()
    if m.top.duration > 0
        m.progressBarProgress.width = m.progressBarBase.width * (m.top.position / m.top.duration)
        m.progressDot.translation = [m.progressBarBase.width * (m.top.position / m.top.duration) + 33, 77]
        m.timeProgress.text = convertToReadableTimeFormat(m.top.position)
        m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
    end if
end sub

sub showThumbnail()
    if m.top.thumbnailInfo <> invalid and m.top.thumbnailInfo.width <> invalid
        thumbnailsPerPart = Int(m.top.thumbnailInfo.count / m.top.thumbnailInfo.thumbnail_parts.Count())
        thumbnailPosOverall = Int(m.currentPositionSeconds / m.top.thumbnailInfo.interval)
        thumbnailPosCurrent = thumbnailPosOverall mod thumbnailsPerPart
        thumbnailRow = Int(thumbnailPosCurrent / m.top.thumbnailInfo.cols)
        thumbnailCol = Int(thumbnailPosCurrent mod m.top.thumbnailInfo.cols)
        if m.uiResolutionWidth = 1280
            m.thumbnailImage.translation = [-thumbnailCol * m.top.thumbnailInfo.width, -thumbnailRow * m.top.thumbnailInfo.height]
        else
            m.thumbnailImage.translation = [(-thumbnailCol * m.top.thumbnailInfo.width) * 0.66, (-thumbnailRow * m.top.thumbnailInfo.height) * 0.66]
        end if
        if m.top.thumbnailInfo.info_url <> invalid and m.top.thumbnailInfo.thumbnail_parts[Int(thumbnailPosOverall / thumbnailsPerPart)] <> invalid
            m.thumbnailImage.uri = m.top.thumbnailInfo.info_url + m.top.thumbnailInfo.thumbnail_parts[Int(thumbnailPosOverall / thumbnailsPerPart)]
        end if
        m.thumbnailImage.visible = true
    end if
end sub

function saveVideoBookmark() as void
    if m.top.video_type = "LIVE" or m.top.video_type = "VOD"
        bookmarkPosition = Int(m.top.position)
        if m.top.video_type = "LIVE" and m.top?.content?.createdAt <> invalid
            secondsSincePublished = createObject("roDateTime")
            secondsSincePublished.FromISO8601String(m.top.content.createdAt.toStr())
            currentTime = createObject("roDateTime").AsSeconds()
            bookmarkPosition = currentTime - secondsSincePublished.AsSeconds()
        end if
        if get_user_setting("id", invalid) <> invalid
            if m.bookmarkTask <> invalid
                m.bookmarkTask = invalid
            end if
            m.bookmarkTask = createObject("roSGNode", "TwitchApiTask")
            m.bookmarkTask.functionname = "updateUserViewedVideo"
            m.bookmarkTask.request = {
                "userId": get_user_setting("id")
                "position": bookmarkPosition
                "videoId": m.top.video_id
                "videoType": m.top.video_type 'LIVE or VOD
            }
            m.bookmarkTask.control = "run"
        else
            if m.top.duration >= 900
                videoBookmarks = "{"

                tempBookmarks = m.top.videoBookmarks
                if m.top.video_id <> invalid
                    bookmarkAlreadyExists = tempBookmarks.DoesExist(m.top.video_id)
                    tempBookmarks[m.top.video_id] = Int(m.top.position).ToStr()
                else
                    bookmarkAlreadyExists = false
                end if

                if tempBookmarks.Count() < 100
                    first = true
                    for each item in tempBookmarks.Items()
                        if not first
                            videoBookmarks += ","
                        end if
                        videoBookmarks += chr(34) + item.key + chr(34) + " : " + chr(34) + item.value + chr(34)
                        first = false
                    end for
                else
                    skip = true
                    first = true
                    for each item in tempBookmarks.Items()
                        if not skip
                            if not first
                                videoBookmarks += ","
                            end if
                            videoBookmarks += chr(34) + item.key + chr(34) + " : " + chr(34) + item.value + chr(34)
                            first = false
                        end if
                        skip = false
                    end for
                end if

                if m.top.thumbnailInfo <> invalid and bookmarkAlreadyExists = false
                    videoBookmarks += "," + chr(34) + m.top.video_id.ToStr() + chr(34) + " : " + chr(34) + Int(m.top.position).ToStr() + chr(34) + "}"
                else
                    videoBookmarks += "}"
                end if

                m.top.videoBookmarks = tempBookmarks
                set_user_setting("VideoBookmarks", videoBookmarks)
            end if
        end if
    end if
end function

' function getTimeTravelTime()
'     hour0 = Int(Val(m.timeTravelTimeSlot[0].getChild(0).text)) * 36000
'     hour1 = Int(Val(m.timeTravelTimeSlot[1].getChild(0).text)) * 3600
'     minute0 = Int(Val(m.timeTravelTimeSlot[2].getChild(0).text)) * 600
'     minute1 = Int(Val(m.timeTravelTimeSlot[3].getChild(0).text)) * 60
'     second0 = Int(Val(m.timeTravelTimeSlot[4].getChild(0).text)) * 10
'     second1 = Int(Val(m.timeTravelTimeSlot[5].getChild(0).text))
'     return hour0 + hour1 + minute0 + minute1 + second0 + second1
' end function

function resetButtonState()
    m.messagesButton.blendColor = "0xFFFFFFFF"
    m.qualitySelectButton.blendColor = "0xFFFFFFFF"
    m.controlButton.blendColor = "0xFFFFFFFF"
end function

function focusButton(button)
    resetButtonState()
    w = button.width
    h = button.height
    m.glow.translation = [button.translation[0] - 30 + w / 2, button.translation[1] - 30 + h / 2]
    button.blendColor = "0xBD00FFFF"
    m.buttonFocused = button.id
    m.currentProgressBarState = 1
    return true
end function

function selectButton()
    if m.buttonFocused = "controlButton"
        togglePlayPause()
        return true
    end if
    if m.buttonFocused = "messagesButton"
        m.top.toggleChat = true
        m.top.streamLayoutMode = (m.top.streamLayoutMode + 1) mod 3
        return true
    end if
    if m.buttonFocused = "qualitySelectButton"
        onQualitySelectButtonPressed()
        return true
    end if
end function

function togglePlayPause()
    if m.currentProgressBarState = 2
        m.top.seek = m.currentPositionSeconds
        m.currentPositionUpdated = false
        m.currentProgressBarState = 1
    else
        if m.top.state = "paused"
            m.top.control = "resume"
            m.currentPositionUpdated = false
        else
            m.top.control = "pause"
        end if
    end if
end function


function onKeyEvent(key, press) as boolean
    ? "[StichVideo] KeyEvent: "; key press
    if press
        if key <> "back"
            if m.progressBar.visible = false
                ? "show called"
                showOverlay()
            end if
        end if
        m.fadeAwayTimer.control = "stop"
        m.fadeAwayTimer.control = "start"
        if key = "right"
            ? "focused button: "; m.buttonFocused
            if m.buttonFocused = "controlButton"
                focusButton(m.messagesButton)
            else if m.buttonFocused = "qualitySelectButton"
                focusButton(m.controlButton)
            else if m.buttonFocused = "messagesButton"
                focusButton(m.qualitySelectButton)
            end if
            return true
        else if key = "left"
            if m.buttonFocused = "controlButton"
                focusButton(m.qualitySelectButton)
            else if m.buttonFocused = "qualitySelectButton"
                focusButton(m.messagesButton)
            else if m.buttonFocused = "messagesButton"
                focusButton(m.controlButton)
            end if
            return true
        else if key = "down"
            hideOverlay()
            return true
        else if key = "back"
            if m.progressBar.visible
                hideOverlay()
                return true
            end if
        else if key = "OK"
            selectButton()
        else if key = "fastforward"
            focusButton(m.controlButton)
            m.currentProgressBarState = 2
            if m.currentPositionUpdated = false
                m.currentPositionSeconds = m.top.position
                m.currentPositionUpdated = true
                m.top.control = "pause"
            end if
            m.currentPositionSeconds += 10
            if m.currentPositionSeconds > m.top.duration
                m.currentPositionSeconds = m.top.duration
            end if
            m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
            m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
            if m.top.thumbnailInfo <> invalid and m.top.thumbnailInfo.width <> invalid
                if m.progressBarProgress.width + m.top.thumbnailInfo.width / 2 <= m.progressBarBase.width
                    if m.progressBarProgress.width - m.top.thumbnailInfo.width / 2 >= 0
                        m.thumbnails.translation = [m.progressBarProgress.width - m.top.thumbnailInfo.width / 2, -150]
                    else
                        m.thumbnails.translation = [0, -150]
                    end if
                else
                    m.thumbnails.translation = [m.progressBarBase.width - m.top.thumbnailInfo.width, -150]
                end if

                m.timeProgress.text = convertToReadableTimeFormat(m.currentPositionSeconds)
                m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
                if m.top.thumbnailInfo.width <> invalid
                    showThumbnail()
                end if
            end if
            m.buttonHeld = "right"
            m.buttonHoldTimer.control = "start"
        else if key = "rewind"
            m.progressBar.visible = true
            focusButton(m.controlButton)
            m.currentProgressBarState = 2
            if m.currentPositionUpdated = false
                m.currentPositionSeconds = m.top.position
                m.currentPositionUpdated = true
                m.top.control = "pause"
            end if
            m.currentPositionSeconds -= 10
            if m.currentPositionSeconds < 0
                m.currentPositionSeconds = 0
            end if
            if m.top.thumbnailInfo <> invalid and m.top.thumbnailInfo.width <> invalid
                if m.progressBarProgress.width - m.top.thumbnailInfo.width / 2 >= 0
                    if m.progressBarProgress.width + m.top.thumbnailInfo.width / 2 <= m.progressBarBase.width
                        m.thumbnails.translation = [m.progressBarProgress.width - m.top.thumbnailInfo.width / 2, -150]
                    else
                        m.thumbnails.translation = [m.progressBarBase.width - m.top.thumbnailInfo.width, -150]
                    end if
                else
                    m.thumbnails.translation = [0, -150]
                end if

                m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
                m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
                m.timeProgress.text = convertToReadableTimeFormat(m.currentPositionSeconds)
                m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
                if m.top.thumbnailInfo.width <> invalid
                    showThumbnail()
                end if
            end if
            m.buttonHeld = "left"
            m.buttonHoldTimer.control = "start"
        else if key = "play"
            togglePlayPause()
            return true
        end if
    else if not press
        if key = "rewind" or key = "fastforward"
            m.scrollInterval = 10
            m.buttonHeld = invalid
            m.buttonHoldTimer.control = "stop"
        end if
    end if
end function