sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0x020202FF"
    m.menu = m.top.findNode("MenuBar")
    m.top.setFocus(true)
end sub

function gsCallback()
    twitchAsyncResponse = m.TwitchAsync.response
    ? "STOP"
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
    if key = "OK"
        ? "Menu Button Selected"; m.menu.buttonSelected
        if m.menu.buttonSelected = 6
            ? "stop"
        end if
        handled = true
    end if
    return handled
end function

