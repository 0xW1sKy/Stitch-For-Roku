sub init()
    m.top.backgroundUri = ""
    m.top.backgroundColor = "0x020202FF"
    m.menu = m.top.findNode("MenuBar")
    m.top.setFocus(true)
end sub

function onKeyEvent(key, press) as boolean
    ? "KEY EVENT: "; key press
    handled = false
    if press
        if key = "up"
            m.menu.setFocus(true)
            handled = true
        end if
    end if
    return handled
end function