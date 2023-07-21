sub init()
    m.top.focusable = true
    m.children = []
    for child = 2 to m.top.getChildCount() - 1
        m.children.push(m.top.getChild(child))
    end for
    m.currentIndex = 0
    m.min = 0
    m.max = 11
    deviceInfo = CreateObject("roDeviceInfo")
    uiResolutionWidth = deviceInfo.GetUIResolution().width
end sub

sub refreshFollowBar()
    if m.top.refreshFollowBar = true
        m.followBarJob = CreateObject("roSGNode", "followedStreamsBarJob")
        m.followBarJob.observeField("result", "onFollowedStreamsChange")
        m.followBarJob.control = "run"
    end if
    m.top.refreshFollowBar = false
end sub

sub numberToText(number) as object
    s = StrI(number)
    result = ""
    if number >= 100000 and number < 1000000
        result = Left(s, 4) + "K"
    else if number >= 10000 and number < 100000
        result = Left(s, 3) + "." + Mid(s, 4, 1) + "K"
    else if number >= 1000 and number < 10000
        result = Left(s, 2) + "." + Mid(s, 3, 1) + "K"
    else if number < 1000
        result = s
    end if
    return result
end sub

sub onFollowedStreamsChange()
    translation = 50
    '? "we got there"
    m.top.removeChildren(m.children)
    if get_user_setting("FollowBarOption", "true") = "true"
        m.currentIndex = 0
        m.min = 0
        m.max = 9
        if m.followBarJob.result <> invalid and m.followBarJob.result.Count() > 0
            for each stream in m.followBarJob.result
                group = createObject("roSGNode", "SidebarItem")
                group.twitch_id = stream.streamerLogin
                group.streamerProfileImage = stream.streamerProfileImageUrl
                group.display_name = stream.streamerDisplayName
                group.game = stream.gameDisplayName
                group.content = stream
                group.translation = "[8," + translation.ToStr() + "]"
                m.top.appendChild(group)
                translation += 60
            end for
            m.children = []
            for child = 2 to m.top.getChildCount() - 1
                m.children.push(m.top.getChild(child))
            end for
        end if
    end if
end sub

sub onGetFocus()
    ? "got focus"
    if m.top.itemHasFocus = true
        if m.children[m.currentIndex] <> invalid
            m.children[m.currentIndex].focused = true
        end if
    else if m.top.itemHasFocus = false
        if m.children[m.currentIndex] <> invalid
            m.children[m.currentIndex].focused = false
        end if
    end if
end sub

sub onKeyEvent(key, press) as boolean
    handled = false
    if press
        if key = "left"
            return true
        end if
        if key = "up"
            if m.currentIndex = 0
                return false
                'tofix: add behaviour to move to top bar'
            end if
            if m.currentIndex - 1 >= 0
                m.children[m.currentIndex].focused = false
                m.currentIndex -= 1
                if m.currentIndex < m.min
                    for each stream in m.children
                        stream.translation = "[5," + (stream.translation[1] + 60).ToStr() + "]"
                        if stream.translation[1] > 0
                            stream.visible = true
                        end if
                    end for
                    m.min -= 1
                    m.max -= 1
                end if
                m.children[m.currentIndex].focused = true
            end if
            handled = true
        else if key = "down"
            if m.currentIndex + 1 < m.top.getChildCount() - 1
                m.children[m.currentIndex].focused = false
                if m.children[m.currentIndex + 1] <> invalid
                    m.currentIndex += 1
                end if
                if m.currentIndex > m.max
                    for each stream in m.children
                        stream.translation = "[5," + (stream.translation[1] - 60).ToStr() + "]"
                        if stream.translation[1] <= 0
                            stream.visible = false
                        end if
                    end for
                    m.min += 1
                    m.max += 1
                end if
                m.children[m.currentIndex].focused = true
            end if
            handled = true
        else if key = "OK"
            if m.children[m.currentIndex] <> invalid
                m.top.streamerSelected = m.children[m.currentIndex].twitch_id
                m.top.contentSelected = m.children[m.currentIndex].content
                m.children[m.currentIndex].focused = false
                handled = true
            end if
        end if
    end if
    return handled
end sub