sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = m.global.constants.colors.hinted.grey1
    m.activeNode = invalid
    m.menu = m.top.findNode("MenuBar")
    m.menu.observeField("buttonSelected", "onMenuSelection")
    m.menu.setFocus(true)
    if get_setting("active_user") = invalid
        set_setting("active_user", "default")
    end if
    if get_user_setting("device_code") = invalid
        m.getDeviceCodeTask = CreateObject("roSGNode", "TwitchApi")
        m.getDeviceCodeTask.observeField("response", "handleDeviceCode")
        m.getDeviceCodeTask.request = {
            type: "getRendezvouzToken"
        }
    else
        onMenuSelection()
    end if
end sub

function handleDeviceCode()
    if m.getDeviceCodeTask <> invalid
        response = m.getDeviceCodeTask.response
        set_user_setting("device_code", response.device_code)
    end if
    onMenuSelection()
end function

function buildNode(id, name)
    if name <> invalid and id <> invalid
        newNode = createObject("roSGNode", name)
        newNode.id = id
        newNode.translation = "[0, 0]"
        newNode.observeField("backPressed", "onBackPressed")
        newNode.observeField("contentSelected", "onContentSelected")
        m.top.appendChild(newNode)
        return newNode
    end if
end function

function onMenuSelection()
    if m.activeNode <> invalid
        if m.activeNode.id.toStr() <> m.menu.buttonSelected.toStr()
            m.top.removeChild(m.activeNode)
            m.activeNode = invalid
        end if
    end if
    ? "Menu Button Selected"; m.menu.buttonSelected
    if m.activeNode = invalid
        m.activeNode = buildNode(m.menu.buttonSelected, m.global.constants.menuOptions[m.menu.buttonSelected])
    end if
    m.activeNode.setfocus(true)
end function

function gamePage(content)
    if m.activeNode <> invalid
        m.top.removeChild(m.activeNode)
        m.activeNode = invalid
    end if
    if m.activeNode = invalid
        m.activeNode = buildNode("7", m.global.constants.menuOptions[7])
    end if
    m.activeNode.contentRequested = content
    m.activeNode.setfocus(true)
end function

sub onContentSelected()
    ? m.activeNode.contentSelected
    if m.activeNode.contentSelected.contentType = "GAME"
        gamePage(m.activeNode.contentSelected)
    end if
end sub

sub onBackPressed()
    if m.activeNode.backPressed <> invalid and m.activeNode.backPressed
        m.menu.setFocus(true)
    end if
end sub

function onKeyEvent(key, press) as boolean
    if press
        ? "Hero Scene Key Event: "; key
        if key = "options"
            NukeRegistry()
            return true
        end if
        if key = "replay"
            ? "----------- Currently Focused Child ----------" + chr(34); m.top.focusedChild
            ? "----------- Last Focused Child ----------" + chr(34); lastFocusedChild(m.top.focusedChild)
            return true
        end if
        if key = "down"
            onMenuSelection()
        end if
    end if
    ' if key = "up"
    '     m.top.setFocus(true)
    '     return true
    ' end if
    if not press return false
    ? "KEY EVENT: "; key press
end function

