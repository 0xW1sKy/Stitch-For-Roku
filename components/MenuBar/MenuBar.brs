sub init()
    '*******************'
    '* Get Node List
    '*******************'
    m.logo = m.top.findNode("logo")
    m.headerRect = m.top.findNode("headerRect")
    m.menuOptions = m.top.findNode("MenuOptions")
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
        newItem = createObject("roSGNode", "JFButton")
        font = CreateObject("roSGNode", "Font")
        font.size = m.top.menuFontSize
        font.uri = m.top.menuFontUri
        newItem.textFont = font
        newItem.minChars = 30
        newItem.focusedTextFont = font
        newItem.textColor = m.top.menuTextColor
        newItem.focusedTextColor = m.top.menuTextColor
        newItem.iconUri = ""
        newItem.focusedIconUri = ""
        newItem.height = m.top.menuOptionsHeight
        newItem.focusFootprintBitmapUri = "pkg:/images/FocusFootprint.9.png"
        newItem.focusBitmapUri = "pkg:/images/FocusIndicator.9.png"
        newItem.showFocusFootprint = false
        newItem.text = tr(m.top.menuOptionsText[i])
        m.menuOptions.appendChild(newItem)
    end for
    if m.top.showSearchIcon
        newItem = createObject("roSGNode", "JFButton")
        newItem.textColor = m.top.menuTextColor
        newItem.focusedTextColor = m.top.menuTextColor
        newItem.iconUri = "pkg:/images/iconSearch.png"
        newItem.focusedIconUri = "pkg:/images/iconSearch.png"
        newItem.height = m.top.menuOptionsHeight
        newItem.focusFootprintBitmapUri = "pkg:/images/FocusFootprint.9.png"
        newItem.focusBitmapUri = "pkg:/images/null.png"
        newItem.showFocusFootprint = false
        newItem.getchild(3).blendColor = m.top.menuTextColor
        newItem.getchild(3).width = m.top.menuFontSize * 2
        newItem.getchild(3).height = m.top.menuFontSize * 2
        newItem.getchild(4).blendColor = m.top.menuFocusColor
        newItem.getchild(4).width = m.top.menuFontSize * 2
        newItem.getchild(4).height = m.top.menuFontSize * 2
        m.menuOptions.appendChild(newItem)
    end if
    if m.top.showSettingsIcon
        newItem = createObject("roSGNode", "JFButton")
        newItem.textColor = m.top.menuTextColor
        newItem.focusedTextColor = m.top.menuTextColor
        newItem.iconUri = "pkg:/images/iconSettings.png"
        newItem.focusedIconUri = "pkg:/images/iconSettings.png"
        newItem.height = m.top.menuOptionsHeight
        newItem.focusFootprintBitmapUri = "pkg:/images/FocusFootprint.9.png"
        newItem.focusBitmapUri = "pkg:/images/null.png"
        newItem.showFocusFootprint = false
        newItem.getchild(3).blendColor = m.top.menuTextColor
        newItem.getchild(3).width = m.top.menuFontSize * 2
        newItem.getchild(3).height = m.top.menuFontSize * 2
        newItem.getchild(4).blendColor = m.top.menuFocusColor
        newItem.getchild(4).width = m.top.menuFontSize * 2
        newItem.getchild(4).height = m.top.menuFontSize * 2
        m.menuOptions.appendChild(newItem)
    end if
    if m.top.showLoginIcon
        newItem = createObject("roSGNode", "JFButton")
        newItem.textColor = m.top.menuTextColor
        newItem.focusedTextColor = m.top.menuTextColor
        newItem.iconUri = "pkg:/images/iconLogin.png"
        newItem.focusedIconUri = "pkg:/images/iconLogin.png"
        newItem.height = m.top.menuOptionsHeight
        newItem.focusFootprintBitmapUri = "pkg:/images/FocusFootprint.9.png"
        newItem.focusBitmapUri = "pkg:/images/null.png"
        newItem.showFocusFootprint = false
        newItem.getchild(3).blendColor = m.top.menuTextColor
        newItem.getchild(3).width = m.top.menuFontSize * 2
        newItem.getchild(3).height = m.top.menuFontSize * 2
        newItem.getchild(4).blendColor = m.top.menuFocusColor
        newItem.getchild(4).width = m.top.menuFontSize * 2
        newItem.getchild(4).height = m.top.menuFontSize * 2
        m.menuOptions.appendChild(newItem)
    end if
end sub
