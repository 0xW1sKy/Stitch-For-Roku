sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = m.global.constants.colors.hinted.grey1
    m.activeNode = invalid
    m.followedStreamBar = m.top.findNode("followedStreamsBar")
    m.followedStreamBar.observeField("contentSelected", "onFollowSelected")
    m.menu = m.top.findNode("MenuBar")
    m.menu.menuOptionsText = ["Home", "Categories", "Following"]
    m.menu.observeField("buttonSelected", "onMenuSelection")
    m.menu.setFocus(true)
    if get_setting("active_user") = invalid
        set_setting("active_user", "default")
    end if
    if get_user_setting("device_code") = invalid
        m.getDeviceCodeTask = CreateObject("roSGNode", "TwitchApiTask")
        m.getDeviceCodeTask.observeField("response", "handleDeviceCode")
        m.getDeviceCodeTask.request = {
            type: "getRendezvouzToken"
        }
        m.getDeviceCodeTask.functionName = m.getDeviceCodeTask.request.type
        m.getDeviceCodeTask.control = "run"
    else
        onMenuSelection()
    end if
    m.footprints = []
    refreshFollowBar()
end sub

function refreshFollowBar()
    m.followedStreamBar.refreshFollowBar = true
end function

function handleDeviceCode()
    if m.getDeviceCodeTask <> invalid
        response = m.getDeviceCodeTask.response
        set_user_setting("device_code", response.device_code)
    end if
    onMenuSelection()
end function

function buildNode(name)
    if name <> invalid
        newNode = createObject("roSGNode", name)
        newNode.id = name
        newNode.translation = "[0, 0]"
        newNode.observeField("backPressed", "onBackPressed")
        newNode.observeField("contentSelected", "onContentSelected")
        if name <> "GamePage" and name <> "ChannelPage" and name <> "VideoPlayer"
            m.top.insertChild(newNode, 1)
        else
            m.top.appendChild(newNode)
        end if
        if name = "LoginPage"
            newNode.observeField("finished", "onLoginFinished")
        end if
        return newNode
    end if
end function

sub onLoginFinished()
    m.menu.updateUserIcon = true
    if get_user_setting("device_code") = invalid
        m.getDeviceCodeTask = CreateObject("roSGNode", "TwitchApiTask")
        m.getDeviceCodeTask.observeField("response", "handleDeviceCode")
        m.getDeviceCodeTask.request = {
            type: "getRendezvouzToken"
        }
        m.getDeviceCodeTask.functionName = m.getDeviceCodeTask.request.type
        m.getDeviceCodeTask.control = "run"
    end if
end sub

function onMenuSelection()
    refreshFollowBar()
    if m.menu.focusedChild <> invalid
        if m.activeNode <> invalid
            if m.activeNode.id.toStr() <> m.menu.focusedChild.focusedChild.id.toStr()
                m.top.removeChild(m.activeNode)
                m.activeNode = invalid
            end if
        end if
    end if
    if m.activeNode = invalid
        m.activeNode = buildNode(m.menu.focusedChild.focusedChild.id)
    end if
    m.activeNode.setfocus(true)
end function

sub onFollowSelected()
    content = m.followedStreamBar.contentSelected
    if m.activeNode <> invalid
        m.footprints.push(m.activeNode)
        m.activeNode = invalid
    end if
    if m.activeNode = invalid
        m.activeNode = buildNode("ChannelPage")
    end if
    m.activeNode.contentRequested = content
    m.activeNode.setfocus(true)
end sub

sub onContentSelected()
    if m.activeNode.contentSelected.contentType = "GAME"
        id = "GamePage"
    else if m.activeNode.contentSelected.contentType = "LIVE" or m.activeNode.contentSelected.contentType = "VOD" or m.activeNode.contentSelected.contentType = "USER"
        id = "ChannelPage"
    else if m.activeNode.playContent = true
        id = "VideoPlayer"
    end if
    content = m.activeNode.contentSelected
    if m.activeNode <> invalid
        m.footprints.push(m.activeNode)
        m.activeNode = invalid
    end if
    if m.activeNode = invalid
        m.activeNode = buildNode(id)
    end if
    m.activeNode.contentRequested = content
    m.activeNode.setfocus(true)
end sub

sub onBackPressed()
    if m.activeNode.backPressed <> invalid and m.activeNode.backPressed
        if m.footprints.Count() > 0
            m.top.removeChild(m.activeNode)
            m.activeNode = m.footprints.pop()
            m.activeNode.setFocus(false)
        else
            m.menu.setFocus(true)
        end if
    end if
end sub

function onKeyEvent(key, press) as boolean
    if press
        ? "Hero Scene Key Event: "; key
        if key = "options"
            ? "BREAK"
            return true
        end if
        if key = "replay"
            ? "----------- Currently Focused Child ----------" + chr(34); m.top.focusedChild
            ? "----------- Last Focused Child ----------" + chr(34); lastFocusedChild(m.top.focusedChild)
            return true
        end if
        if key = "up"
            if m.activeNode.id <> "GamePage" and m.activeNode.id <> "ChannelPage" and m.activeNode.id <> "VideoPlayer"
                m.followedStreamBar.itemHasFocus = false
                m.menu.setFocus(true)
            end if
        end if
        if key = "down"
            m.activeNode.setFocus(true)
        end if
        if key = "left"
            if m.activeNode.id <> "GamePage" and m.activeNode.id <> "ChannelPage" and m.activeNode.id <> "VideoPlayer"
                m.activeNode.setFocus(false)
                m.followedStreamBar.setFocus(true)
                m.followedStreamBar.itemHasFocus = true
                return true
            end if
        end if
        if key = "right"
            m.followedStreamBar.itemHasFocus = false
            m.activeNode.setFocus(true)
            return true
        end if
    end if
    ' if key = "up"
    '     m.top.setFocus(true)
    '     return true
    ' end if
    if not press return false
    ? "KEY EVENT: "; key press
end function

