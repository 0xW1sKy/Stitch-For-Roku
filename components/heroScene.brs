sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0x020202FF"
    m.menu = m.top.findNode("MenuBar")
    m.menu.observeField("buttonSelected", "onMenuSelection")
    m.settingsMenu = m.top.findNode("SettingsMenu")
end sub

function gsCallback()
    twitchAsyncResponse = m.TwitchAsync.response
    ? "STOP"
end function

function onMenuSelection()
    ? "Menu Button Selected"; m.menu.buttonSelected
    if m.menu.buttonSelected = 5
        m.settingsMenu.visible = true
        m.settingsMenu.setFocus(true)
    end if
    if m.menu.buttonSelected = 6
        newItem = createObject("roSGNode", "LoginPage")
        newItem.translation = "[280, 160]"
        m.top.appendChild(newItem)
    end if
end function


function onKeyEvent(key, press) as boolean
    if not press return false
    ? "KEY EVENT: "; key press
    if press
        if key = "up"
            ? ""; m.top.focusedChild
            m.menu.setFocus(true)
            return true
        end if
    end if
end function

