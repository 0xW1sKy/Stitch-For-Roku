sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0x020202FF"
    m.activeNode = invalid
    m.menu = m.top.findNode("MenuBar")
    m.menu.observeField("buttonSelected", "onMenuSelection")
    m.menu.setFocus(true)
    set_setting("active_user", "default")
end sub

function gsCallback()
    twitchAsyncResponse = m.TwitchAsync.response
    ? "STOP"
end function

function buildNode(id, name)
    if name <> invalid and id <> invalid
        newNode = createObject("roSGNode", name)
        newNode.id = id
        if id = 6
            newNode.translation = "[360, 80]"
        end if
        newNode.observeField("backPressed", "onBackPressed")
        m.top.appendChild(newNode)
        return newNode
    end if
end function

function onMenuSelection()
    pageMap = [0, 1, 2, 3, 4, "Settings", "LoginPage"]
    if m.activeNode <> invalid
        if m.activeNode.id.toStr() <> m.menu.buttonSelected.toStr()
            m.top.removeChild(m.activeNode)
            m.activeNode = invalid
        end if
    end if
    ? "Menu Button Selected"; m.menu.buttonSelected
    if m.activeNode = invalid
        m.activeNode = buildNode(m.menu.buttonSelected, pageMap[m.menu.buttonSelected])
    else
        ' TODO: Replace this with something more dynamic. hardcoding the .getchild(1) screams bad news to me
        m.activeNode.getchild(1).setFocus(true)
    end if
end function

sub onBackPressed()
    if m.activeNode.backPressed <> invalid and m.activeNode.backPressed
        m.menu.setFocus(true)
    end if
end sub

function onKeyEvent(key, press) as boolean
    if press
        if key = "options"
            ? "STOP"
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

