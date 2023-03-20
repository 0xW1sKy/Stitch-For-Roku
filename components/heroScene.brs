sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0x020202FF"
    m.menu = m.top.findNode("MenuBar")
    m.top.setFocus(true)
    m.menu.observeField("buttonSelected", "onMenuSelection")
end sub

function gsCallback()
    twitchAsyncResponse = m.TwitchAsync.response
    ? "STOP"
end function

function onMenuSelection()
    ? "Menu Button Selected"; m.menu.buttonSelected
    if m.menu.buttonSelected = 6
        newItem = createObject("roSGNode", "LoginPage")
        newItem.translation = "[280, 160]"
        m.top.appendChild(newItem)
    end if
end function


function onKeyEvent(key, press) as boolean
    ? "KEY EVENT: "; key press
    handled = false
    if press
        if key = "up"
            m.menu.setFocus(true)
            handled = true
        end if
    end if
end function

