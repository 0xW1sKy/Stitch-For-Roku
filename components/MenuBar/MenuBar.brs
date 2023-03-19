sub init()
    '*******************'
    '* Get Node List
    '*******************'
    m.logo = m.top.findNode("logo")
    m.headerRect = m.top.findNode("headerRect")
    m.menuOptions = m.top.findNode("MenuOptions")
    m.searchIcon = m.top.findNode("searchIcon")
    m.settingsIcon = m.top.findNode("settingsIcon")
    m.loginIcon = m.top.findNode("loginIcon")
    '*******************'
    '* Update Visiblity
    '*******************'
    m.searchIcon.visible = m.top.showSearchIcon
    m.settingsIcon.visible = m.top.showSettingsIcon
    m.loginIcon.visible = m.top.showLoginIcon
    m.top.observeField("focusedChild", "onFocusedItem")
end sub


sub updateMenuOptions()
    '*******************'
    '* Include Width of Logo in Menu Option Offset
    '*******************'
    if m.top.MenuOptionsText.count() > 0
        xoffset = m.menuOptions.translation[0] + m.logo.width + m.logo.translation[0]
        yoffset = m.menuOptions.translation[1]
        m.menuOptions.translation = "[" + xoffset.ToStr() + "," + yoffset.ToStr() + "]"
    end if
    for i = 0 to (m.top.menuOptionsText.count() - 1)
        newItem = createObject("roSGNode", "Button")
        newItem.text = m.top.menuOptionsText[i]
        font = CreateObject("roSGNode", "Font")
        font.size = m.top.menuFontSize
        font.uri = m.top.menuFontUri
        newItem.textFont = font
        newItem.focusedTextFont = font
        newItem.textColor = m.top.menuTextColor
        newItem.focusedTextColor = m.top.menuTextColor
        newItem.iconUri = ""
        newItem.focusedIconUri = ""
        newItem.height = 80
        newItem.focusFootprintBitmapUri = "pkg:/locale/images/FocusFootprint.9.png"
        newItem.focusBitmapUri = "pkg:/locale/images/FocusIndicator.9.png"
        newItem.showFocusFootprint = false
        m.menuOptions.appendChild(newItem)
    end for
end sub

sub onFocusedItem()
    ? "CurrentlyFocusedChild: "; m.top.focusedChild.id

    print "MenuBar Focused"
end sub

sub onSelectedItemChange()
    print ""
end sub

function getLabelWidthPx(text)
    FontPixels = text.textFont.size * 0.5
    width = text.translation[0] + Len(text.text) * FontPixels
    return width
end function

sub OnChangeContent()
    print "##onChangeContent"
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ?"MenuBar KeyEvent: "; key press
    if press
        if key = "right"
            m.menuOptions.focusButton = m.menuOptions.buttonFocused + 1
            return true
        end if
        if key = "left"
            m.menuOptions.focusButton = m.menuOptions.buttonFocused - 1
            return true
        end if
    end if
    if key = "down"
        parent = m.top.getParent()
        parent.setFocus(true)
        return true
    end if
end function