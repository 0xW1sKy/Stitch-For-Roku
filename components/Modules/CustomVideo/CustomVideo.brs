function init()
    ' bump
    m.progressBar = m.top.findNode("progressBar")
    m.progressBar.visible = false
    m.progressBarBase = m.top.findNode("progressBarBase")
    m.progressBarProgress = m.top.findNode("progressBarProgress")
    m.progressDot = m.top.findNode("progressDot")
    m.timeProgress = m.top.findNode("timeProgress")
    m.timeDuration = m.top.findNode("timeDuration")
    m.controlButton = m.top.findNode("controlButton")
    m.timeTravelButton = m.top.findNode("timeTravelButton")
    m.messagesButton = m.top.findNode("messagesButton")
    m.qualitySelectButton = m.top.findNode("qualitySelectButton")
    m.QualityDialog = m.top.findNode("QualityDialog")
    m.glow = m.top.findNode("bg-glow")
    m.timeTravelRect = m.top.findNode("timeTravelRect")
    m.currentProgressBarState = 0
    m.currentPositionSeconds = 0
    m.currentPositionUpdated = false
    m.thumbnails = m.top.findNode("thumbnails")
    m.thumbnailImage = m.top.findNode("thumbnailImage")
    m.arrows = m.top.findNode("arrows")

    m.videoTitle = m.top.findNode("videoTitle")
    m.channelUsername = m.top.findNode("channelUsername")
    m.avatar = m.top.findNode("avatar")

    hour0 = m.top.findNode("hour0")
    hour1 = m.top.findNode("hour1")
    minute0 = m.top.findNode("minute0")
    minute1 = m.top.findNode("minute1")
    second0 = m.top.findNode("second0")
    second1 = m.top.findNode("second1")

    m.focusedTimeSlot = 0
    m.timeTravelTimeSlot = [hour0, hour1, minute0, minute1, second0, second1]

    cancelButton = m.top.findNode("cancelButton")
    acceptButton = m.top.findNode("acceptButton")

    m.focusedTimeButton = 0
    m.timeTravelButtons = [cancelButton, acceptButton]

    m.progressBarFocused = false

    m.top.observeField("position", "watcher")
    m.top.observeField("state", "onvideoStateChange")
    m.top.observeField("channelAvatar", "onChannelInfoChange")
    m.top.observeField("videoTitle", "onChannelInfoChange")
    m.top.observeField("channelUsername", "onChannelInfoChange")
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
end function


function watcher()
    m.timeProgress.text = convertToReadableTimeFormat(m.currentPositionSeconds)
    m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
    m.currentPositionSeconds = m.top.position
    if m.top.duration <> 0
        m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
        m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
    end if

    checker = m.top.position mod 60
    if checker = 0
        saveVideoBookmark()
    end if
end function

function resetProgressBar()
    m.controlButton.blendColor = "0xFFFFFFFF"
    m.messagesButton.blendColor = "0xFFFFFFFF"
    m.timeTravelButton.blendColor = "0xFFFFFFFF"
    m.qualitySelectButton.blendColor = "0xFFFFFFFF"
    m.currentProgressBarState = 0
    m.thumbnailImage.visible = false
    m.progressBar.visible = false
end function

sub onQualityButtonSelect()
    m.QualityDialog.visible = false
    m.QualityDialog.setFocus(false)
    resetProgressBar()
    m.progressBar.getParent().setFocus(true)
    m.top.qualityChangeRequestFlag = true
    m.top.qualityChangeRequest = m.top.STREAMURLS[m.QualityDialog.buttonSelected]
end sub

sub onQualitySelectButtonPressed()
    if m.top.STREAMCONTENTIDS <> invalid and m.top.STREAMCONTENTIDS.count() > 1
        m.QualityDialog.title = "Please Choose Your Video Quality"
        m.QualityDialog.buttons = m.top.STREAMCONTENTIDS
        m.QualityDialog.observeFieldScoped("buttonSelected", "onQualityButtonSelect")
        m.QualityDialog.visible = true
        m.lastFocusedchild = m.top.focusedChild
        m.QualityDialog.setFocus(true)
    end if
end sub

sub onChatVisibilityChange()
    if m.top.chatIsVisible
        m.progressBarBase.width = 950
        m.glow.translation = [534, 32]
        m.timeTravelButton.translation = [390, 51]
        m.controlButton.translation = [476, 53]
        m.messagesButton.translation = [552, 52]
        m.timeDuration.translation = [950, 61]
    else
        m.progressBarBase.width = 1200
        m.glow.translation = [692, 32]
        m.timeTravelButton.translation = [548, 51]
        m.controlButton.translation = [634, 53]
        m.messagesButton.translation = [710, 52]
        m.timeDuration.translation = [1198, 61]
    end if
end sub

sub onVideoStateChange()
    if m.top.state = "playing"
        m.top.setFocus(true)
    end if
end sub

function hideOverlay()
    m.controlButton.blendColor = "0xFFFFFFFF"
    m.messagesButton.blendColor = "0xFFFFFFFF"
    m.timeTravelButton.blendColor = "0xFFFFFFFF"
    m.qualitySelectButton.blendColor = "0xFFFFFFFF"
    m.currentProgressBarState = 0
    m.thumbnailImage.visible = false
    m.progressBar.visible = false
end function

sub onFadeAway()
    if not m.timeTravelRect.visible and not m.QualityDialog.visible
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
end function

function getTimeTravelTime()
    hour0 = Int(Val(m.timeTravelTimeSlot[0].getChild(0).text)) * 36000
    hour1 = Int(Val(m.timeTravelTimeSlot[1].getChild(0).text)) * 3600
    minute0 = Int(Val(m.timeTravelTimeSlot[2].getChild(0).text)) * 600
    minute1 = Int(Val(m.timeTravelTimeSlot[3].getChild(0).text)) * 60
    second0 = Int(Val(m.timeTravelTimeSlot[4].getChild(0).text)) * 10
    second1 = Int(Val(m.timeTravelTimeSlot[5].getChild(0).text))
    return hour0 + hour1 + minute0 + minute1 + second0 + second1
end function

sub onChannelInfoChange()
    m.videoTitle.text = m.top.videoTitle
    m.channelUsername.text = m.top.channelUsername
    m.avatar.uri = m.top.channelAvatar
end sub

function onKeyEvent(key, press) as boolean
    handled = false
    if press
        m.fadeAwayTimer.control = "stop"
        m.fadeAwayTimer.control = "start"
        if key = "up"
            if m.currentProgressBarState = 0
                m.currentProgressBarState = 1
                m.progressBar.visible = true
                w = m.controlButton.width
                h = m.controlButton.height
                m.glow.translation = [m.controlButton.translation[0] - 30 + w / 2, m.controlButton.translation[1] - 30 + h / 2]
                m.controlButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 1
            else if m.currentProgressBarState = 2
                m.currentProgressBarState = 0
                m.progressBarBase.height = 2
                m.progressBarProgress.height = 2
                m.progressBar.visible = false
                m.thumbnailImage.visible = false
            else if m.currentProgressBarState = 3
            else if m.currentProgressBarState = 6
                number = (Int(Val(m.timeTravelTimeSlot[m.focusedTimeSlot].getChild(0).text)) + 1)
                if m.focusedTimeSlot = 2 or m.focusedTimeSlot = 4
                    number = number mod 6
                else
                    number = number mod 10
                end if
                m.timeTravelTimeSlot[m.focusedTimeSlot].getChild(0).text = number.ToStr()
            end if
            return true
        else if key = "right"
            if m.currentProgressBarState = 1
                m.currentProgressBarState = 4
                m.controlButton.blendColor = "0xFFFFFFFF"
                w = m.messagesButton.width
                h = m.messagesButton.height
                m.glow.translation = [m.messagesButton.translation[0] - 30 + w / 2, m.messagesButton.translation[1] - 30 + h / 2]
                m.messagesButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 2

            else if m.currentProgressBarState = 3
                m.currentProgressBarState = 1
                m.timeTravelButton.blendColor = "0xFFFFFFFF"
                w = m.controlButton.width
                h = m.controlButton.height
                m.glow.translation = [m.controlButton.translation[0] - 30 + w / 2, m.controlButton.translation[1] - 30 + h / 2]
                m.controlButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 8
                m.currentProgressBarState = 3
                m.qualitySelectButton.blendColor = "0xFFFFFFFF"
                w = m.timeTravelButton.width
                h = m.timeTravelButton.height
                m.glow.translation = [m.timeTravelButton.translation[0] - 30 + w / 2, m.timeTravelButton.translation[1] - 30 + h / 2]
                m.timeTravelButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 6
                if m.focusedTimeSlot <> -1 and m.focusedTimeSlot + 1 <= 5
                    m.timeTravelTimeSlot[m.focusedTimeSlot].uri = "pkg:/images/unfocusedTimeSlot.png"
                    m.timeTravelTimeSlot[m.focusedTimeSlot].getChild(0).color = "0x3F3F3FFF"
                    m.focusedTimeSlot += 1
                    m.timeTravelTimeSlot[m.focusedTimeSlot].uri = "pkg:/images/focusedTimeSlot.png"
                    m.timeTravelTimeSlot[m.focusedTimeSlot].getChild(0).color = "0xDC79FFFF"
                    m.arrows.translation = [m.timeTravelTimeSlot[m.focusedTimeSlot].translation[0] + 18, m.timeTravelTimeSlot[m.focusedTimeSlot].translation[1] - 6]
                else if m.focusedTimeSlot = -1
                    m.timeTravelButtons[m.focusedTimeButton].opacity = 0.5
                    m.focusedTimeButton += 1
                    m.focusedTimeButton = m.focusedTimeButton mod 2
                    m.timeTravelButtons[m.focusedTimeButton].opacity = 1
                end if
            else if m.currentProgressBarState = 2
                if m.currentPositionUpdated = false
                    m.currentPositionSeconds = m.top.position
                    m.currentPositionUpdated = true
                    m.top.control = "pause"
                    m.controlButton.uri = "pkg:/images/play.png"
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
            end if
            return true
        else if key = "left"
            if m.currentProgressBarState = 2

            else if m.currentProgressBarState = 4
                m.currentProgressBarState = 1
                m.messagesButton.blendColor = "0xFFFFFFFF"
                w = m.controlButton.width
                h = m.controlButton.height
                m.glow.translation = [m.controlButton.translation[0] - 30 + w / 2, m.controlButton.translation[1] - 30 + h / 2]
                m.controlButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 1
                m.currentProgressBarState = 3
                m.controlButton.blendColor = "0xFFFFFFFF"
                w = m.timeTravelButton.width
                h = m.timeTravelButton.height
                m.glow.translation = [m.timeTravelButton.translation[0] - 30 + w / 2, m.timeTravelButton.translation[1] - 30 + h / 2]
                m.timeTravelButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 3
                m.currentProgressBarState = 8
                m.timeTravelButton.blendColor = "0xFFFFFFFF"
                w = m.qualitySelectButton.width
                h = m.qualitySelectButton.height
                m.glow.translation = [m.qualitySelectButton.translation[0] - 30 + w / 2, m.qualitySelectButton.translation[1] - 30 + h / 2]
                m.qualitySelectButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 6
                if m.focusedTimeSlot <> -1 and m.focusedTimeSlot - 1 >= 0
                    m.timeTravelTimeSlot[m.focusedTimeSlot].uri = "pkg:/images/unfocusedTimeSlot.png"
                    m.timeTravelTimeSlot[m.focusedTimeSlot].getChild(0).color = "0x3F3F3FFF"
                    m.focusedTimeSlot -= 1
                    m.timeTravelTimeSlot[m.focusedTimeSlot].uri = "pkg:/images/focusedTimeSlot.png"
                    m.timeTravelTimeSlot[m.focusedTimeSlot].getChild(0).color = "0xDC79FFFF"
                    m.arrows.translation = [m.timeTravelTimeSlot[m.focusedTimeSlot].translation[0] + 18, m.timeTravelTimeSlot[m.focusedTimeSlot].translation[1] - 6]
                else if m.focusedTimeSlot = -1
                    m.timeTravelButtons[m.focusedTimeButton].opacity = 0.5
                    m.focusedTimeButton -= 1
                    if m.focusedTimeButton = -1
                        m.focusedTimeButton = 1
                    end if
                    m.timeTravelButtons[m.focusedTimeButton].opacity = 1
                end if
            end if
            return true
        else if key = "down"
            if m.currentProgressBarState = 6
                number = (Int(Val(m.timeTravelTimeSlot[m.focusedTimeSlot].getChild(0).text)) - 1)
                if number = -1
                    if m.focusedTimeSlot = 2 or m.focusedTimeSlot = 4
                        number = 5
                    else
                        number = 9
                    end if
                end if
                m.timeTravelTimeSlot[m.focusedTimeSlot].getChild(0).text = number.ToStr()
            else
                hideOverlay()
                return true
            end if
        else if key = "back"
            if m.timeTravelRect.visible
                m.timeTravelRect.visible = false
                m.currentProgressBarState = 3
            else
                m.currentPositionSeconds = 0
                m.currentProgressBarState = 0
                m.timeTravelRect.visible = false
                m.progressBar.visible = false
                m.currentPositionUpdated = false
                m.thumbnailImage.uri = ""
                saveVideoBookmark()
                m.top.thumbnailInfo = invalid
            end if
        else if key = "OK"
            if m.currentProgressBarState = 1
                if m.top.state = "paused"
                    m.top.control = "resume"
                    m.controlButton.uri = "pkg:/images/pause.png"
                    m.currentPositionUpdated = false
                else
                    m.top.control = "pause"
                    m.controlButton.uri = "pkg:/images/play.png"
                end if
                return true
            else if m.currentProgressBarState = 2
                m.top.seek = m.currentPositionSeconds
                m.controlButton.uri = "pkg:/images/pause.png"
                m.currentPositionUpdated = false
                m.currentProgressBarState = 1
                return true
            else if m.currentProgressBarState = 3
                m.currentProgressBarState = 6
                m.focusedTimeSlot = 0
                m.timeTravelTimeSlot[m.focusedTimeSlot].uri = "pkg:/images/focusedTimeSlot.png"
                m.timeTravelTimeSlot[m.focusedTimeSlot].getChild(0).color = "0xDC79FFFF"
                m.arrows.translation = [m.timeTravelTimeSlot[m.focusedTimeSlot].translation[0] + 18, m.timeTravelTimeSlot[m.focusedTimeSlot].translation[1] - 6]
                m.timeTravelRect.visible = true
                return true
            else if m.currentProgressBarState = 4
                m.top.toggleChat = true
                m.top.streamLayoutMode = (m.top.streamLayoutMode + 1) mod 3
                return true
            else if m.currentProgressBarState = 5
                m.currentPositionSeconds = 0
                m.currentProgressBarState = 0
                m.progressBar.visible = false
                m.currentPositionUpdated = false
                m.thumbnailImage.uri = ""
                saveVideoBookmark()
                m.top.thumbnailInfo = invalid
                m.top.back = true
                return true
            else if m.currentProgressBarState = 6
                if m.focusedTimeSlot <> -1
                    m.timeTravelTimeSlot[m.focusedTimeSlot].uri = "pkg:/images/unfocusedTimeSlot.png"
                    m.timeTravelTimeSlot[m.focusedTimeSlot].getChild(0).color = "0x3F3F3FFF"
                    m.timeTravelButtons[m.focusedTimeButton].opacity = 1
                    m.focusedTimeSlot = -1
                else
                    if m.focusedTimeButton = 1
                        m.top.seek = getTimeTravelTime()
                        m.controlButton.uri = "pkg:/images/pause.png"
                        m.currentPositionUpdated = false
                    end if
                    for timeSlot = 0 to 5
                        m.timeTravelTimeSlot[timeSlot].getChild(0).text = "0"
                    end for
                    m.timeTravelButtons[m.focusedTimeButton].opacity = 0.5
                    m.currentProgressBarState = 3
                    m.timeTravelRect.visible = false
                end if
                return true
            else if m.currentProgressBarState = 8
                onQualitySelectButtonPressed()
            end if
        else if key = "fastforward"
            m.progressBar.visible = true
            w = m.controlButton.width
            h = m.controlButton.height
            m.glow.translation = [m.controlButton.translation[0] - 30 + w / 2, m.controlButton.translation[1] - 30 + h / 2]
            m.controlButton.blendColor = "0xBD00FFFF"
            m.currentProgressBarState = 2
            if m.currentPositionUpdated = false
                m.currentPositionSeconds = m.top.position
                m.currentPositionUpdated = true
                m.top.control = "pause"
                m.controlButton.uri = "pkg:/images/play.png"
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
            w = m.controlButton.width
            h = m.controlButton.height
            m.glow.translation = [m.controlButton.translation[0] - 30 + w / 2, m.controlButton.translation[1] - 30 + h / 2]
            m.controlButton.blendColor = "0xBD00FFFF"
            m.currentProgressBarState = 2
            if m.currentPositionUpdated = false
                m.currentPositionSeconds = m.top.position
                m.currentPositionUpdated = true
                m.top.control = "pause"
                m.controlButton.uri = "pkg:/images/play.png"
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
            if m.currentProgressBarState = 2
                m.top.seek = m.currentPositionSeconds
                m.controlButton.uri = "pkg:/images/pause.png"
                m.currentPositionUpdated = false
                m.currentProgressBarState = 1
            else
                if m.top.state = "paused"
                    m.top.control = "resume"
                    m.controlButton.uri = "pkg:/images/pause.png"
                    m.currentPositionUpdated = false
                else
                    m.top.control = "pause"
                    m.controlButton.uri = "pkg:/images/play.png"
                end if
            end if
            return true
        end if
    else if not press
        if key = "rewind" or key = "fastforward"
            m.scrollInterval = 10
            m.buttonHeld = invalid
            m.buttonHoldTimer.control = "stop"
        end if
    end if
    return handled
end function