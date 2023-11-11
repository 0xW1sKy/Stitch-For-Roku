sub init()
    '*******************'
    '* Get Node List
    '*******************'
    m.headerRect = m.top.findNode("headerRect")
    m.headerRectShadow = m.top.findNode("headerRectShadow")
    m.menuOptions = m.top.findNode("MenuOptions")
    m.top.observeField("focusedChild", "onGetfocus")
    m.top.menuTextColor = m.global.constants.colors.muted.ice
    m.top.menuFocusColor = m.global.constants.colors.twitch.purple10
end sub

sub onGetfocus()
    if m.top.focusedChild <> invalid and m.top.focusedChild.id = "MenuBar"
        m.menuOptions.setFocus(true)
    end if
end sub

' function buildIcon(icon)
'     map = {}
'     if m.top.isFollowing
'         map["follow"] = "pkg:/images/heart.png"
'     else
'         map["follow"] = "pkg:/images/heart-0.png"
'     end if
'     newItem = createObject("roSGNode", "Button")
'     newItem.id = icon
'     newItem.textColor = m.top.menuTextColor
'     newItem.focusedTextColor = m.top.menuTextColor
'     newItem.iconUri = map[icon]
'     newItem.focusedIconUri = map[icon]
'     newItem.height = m.top.menuOptionsHeight
'     newItem.minWidth = 0
'     newItem.focusFootprintBitmapUri = "pkg:/images/FocusFootprint.9.png"
'     newItem.focusBitmapUri = "pkg:/images/FocusFootprint.9.png"
'     newItem.showFocusFootprint = false
'     newItem.getchild(3).blendColor = m.top.menuTextColor
'     newItem.getchild(3).width = m.top.menuFontSize * 2
'     newItem.getchild(3).height = m.top.menuFontSize * 2
'     newItem.getchild(4).blendColor = m.top.menuFocusColor
'     newItem.getchild(4).width = m.top.menuFontSize * 2
'     newItem.getchild(4).height = m.top.menuFontSize * 2
'     m.menuOptions.appendChild(newItem)
' end function

sub updateMenuOptions()
    m.addedTranslation = 0
    menuButtons = []
    for i = 0 to (m.top.menuOptionsText.count() - 1)
        if m.top.menuOptionsText[i] <> ""
            newItem = createObject("roSGNode", "Button")
            font = CreateObject("roSGNode", "Font")
            font.size = m.top.menuFontSize
            font.uri = m.top.menuFontUri
            newItem.minWidth = 220
            newItem.textFont = font
            newItem.focusedTextFont = font
            newItem.textColor = m.top.menuTextColor
            newItem.focusedTextColor = m.top.menuFocusColor
            newItem.iconUri = ""
            newItem.focusedIconUri = ""
            newItem.height = m.top.menuOptionsHeight
            newItem.focusFootprintBitmapUri = "pkg:/images/FocusFootprint.9.png"
            newItem.focusBitmapUri = "pkg:/images/FocusIndicator.9.png"
            newItem.showFocusFootprint = false
            newItem.id = m.top.menuOptionsText[i]
            if m.top.menuOptionsText[i] = "follow"
                if m.top.isFollowing
                    newItem.text = tr("Following")
                else
                    newItem.text = tr("Follow")
                end if
            else
                newItem.text = tr(m.top.menuOptionsText[i])
            end if
            menuButtons.push(newItem)
        end if
    end for
    for each menuButton in menuButtons
        m.menuOptions.appendChild(menuButton)
    end for
    width = 0
    for i = 0 to (m.menuOptions.getChildCount() - 1)
        ? "Width: " width
        width += m.menuOptions.getChild(i).localboundingrect().width
    end for
    ? "Width: " width
    m.headerRect.width = width
    m.headerRectShadow.width = width
end sub

sub handleUserLoginResponse()
    ? "[MenuBar] - handleUserLoginResponse()"
    search = m.loginIconTask.response
    result = { raw: search }
    if search <> invalid and search.data <> invalid
        for each stream in search.data
            set_user_setting("id", stream.id)
            set_user_setting("display_name", stream.display_name)
            set_user_setting("profile_image_url", stream.profile_image_url)
        end for
        for i = 0 to (m.menuOptions.getChildCount() - 1)
            if m.menuOptions.getchild(i).id = "LoginPage"
                m.menuOptions.getChild(i).iconUri = get_user_setting("profile_image_url")
                m.menuOptions.getChild(i).focusedIconUri = get_user_setting("profile_image_url")
                m.top.updateUserIcon = false
            end if
        end for
    end if

end sub

sub handleUserLogin()
    if m.top.updateUserIcon
        if get_setting("active_user", "$default$") <> "$default$"
            ? "[MenuBar] - handleUserLogin()"
            m.loginIconTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
            m.loginIconTask.observeField("response", "handleUserLoginResponse")
            m.loginIconTask.request = {
                type: "TwitchHelixApiRequest"
                params: {
                    endpoint: "users"
                    args: "login=" + get_user_setting("login")
                    method: "GET"
                }
            }
            m.loginIconTask.functionName = m.loginIconTask.request.type
            m.loginIconTask.control = "run"
        else
            for i = 0 to (m.menuOptions.getChildCount() - 1)
                if m.menuOptions.getchild(i).id = "LoginPage"
                    m.menuOptions.getChild(i).iconUri = m.global.constants.defaultIcons.login
                    m.menuOptions.getChild(i).focusedIconUri = m.global.constants.defaultIcons.login
                    m.top.updateUserIcon = false
                end if
            end for
        end if
    end if
end sub