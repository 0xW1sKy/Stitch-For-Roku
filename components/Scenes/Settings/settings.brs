sub init()
    m.top.observeField("focusedChild", "onGetFocus")
    m.top.overhangTitle = tr("Settings")
    m.top.optionsAvailable = false

    m.userLocation = []

    m.settingsMenu = m.top.findNode("settingsMenu")
    ' m.settingsMenu.focusBitmapUri = m.settingsMenu.focusFootprintBitmapUri
    m.settingsMenu.focusBitmapBlendColor = m.global.constants.colors.twitch.purple9
    ' m.settingsMenu.focusFootprintBlendColor = m.global.constants.colors.twitch.purple10
    m.settingsMenu.focusedColor = m.global.constants.colors.white


    m.settingDetail = m.top.findNode("settingDetail")
    m.settingDesc = m.top.findNode("settingDesc")
    m.settingTitle = m.top.findNode("settingTitle")
    m.path = m.top.findNode("path")

    m.boolSetting = m.top.findNode("boolSetting")
    m.radioSetting = m.top.findNode("radioSetting")

    m.settingsMenu.setFocus(true)
    m.settingsMenu.observeField("itemFocused", "settingFocused")
    m.settingsMenu.observeField("itemSelected", "settingSelected")

    m.boolSetting.observeField("checkedItem", "boolSettingChanged")
    m.radioSetting.observeField("checkedItem", "radioSettingChanged")

    m.settingsMenu.observeField("focusedChild", "onGetfocus")
    ' Load Configuration Tree
    m.configTree = GetConfigTree()
    LoadMenu({ children: m.configTree })
end sub

sub onGetfocus()
    if m.settingDetail.focusedChild = invalid
        if not m.radioSetting.hasFocus()
            m.settingsMenu.setFocus(true)
        end if
    end if
end sub

sub LoadMenu(configSection)
    if configSection.children = invalid
        ' Load parent menu
        m.userLocation.pop()
        configSection = m.userLocation.peek()
    else
        if m.userLocation.Count() > 0 then m.userLocation.peek().selectedIndex = m.settingsMenu.itemFocused
        m.userLocation.push(configSection)
    end if

    result = CreateObject("roSGNode", "ContentNode")

    for each item in configSection.children
        listItem = result.CreateChild("ContentNode")
        listItem.title = tr(item.title)
        listItem.Description = tr(item.description)
        listItem.id = item.id
    end for

    m.settingsMenu.content = result

    if configSection.selectedIndex <> invalid and configSection.selectedIndex > -1
        m.settingsMenu.jumpToItem = configSection.selectedIndex
    end if

    ' Set Path display
    m.path.text = ""
    for each level in m.userLocation
        if level.title <> invalid then m.path.text += " / " + tr(level.title)
    end for
end sub



sub settingFocused()
    selectedSetting = m.userLocation.peek().children[m.settingsMenu.itemFocused]
    m.settingDesc.text = tr(selectedSetting.Description)
    m.settingTitle.text = tr(selectedSetting.Title)

    ' Hide Settings
    m.boolSetting.visible = false
    m.radioSetting.visible = false

    if selectedSetting.type = invalid
        return
    else if selectedSetting.type = "bool"

        m.boolSetting.visible = true

        if get_user_setting(selectedSetting.settingName) = "true"
            m.boolSetting.checkedItem = 1
        else
            m.boolSetting.checkedItem = 0
        end if
    else if LCase(selectedSetting.type) = "radio"

        selectedValue = get_user_setting(selectedSetting.settingName)

        radioContent = CreateObject("roSGNode", "ContentNode")

        itemIndex = 0
        for each item in m.userLocation.peek().children[m.settingsMenu.itemFocused].options
            listItem = radioContent.CreateChild("ContentNode")
            listItem.title = tr(item.title)
            listItem.id = item.id
            if selectedValue = item.id
                m.radioSetting.checkedItem = itemIndex
            end if
            itemIndex++
        end for

        m.radioSetting.content = radioContent

        m.radioSetting.visible = true
    else
        print "Unknown setting type " + selectedSetting.type
    end if

end sub


sub settingSelected()
    selectedItem = m.userLocation.peek().children[m.settingsMenu.itemFocused]

    if selectedItem.type <> invalid ' Show setting
        if selectedItem.type = "bool"
            m.boolSetting.setFocus(true)
        end if
        if selectedItem.type = "radio"
            m.radioSetting.setFocus(true)
        end if
    else if selectedItem.children <> invalid and selectedItem.children.Count() > 0 ' Show sub menu
        LoadMenu(selectedItem)
        m.settingsMenu.setFocus(true)
    else
        return
    end if

    m.settingDesc.text = m.settingsMenu.content.GetChild(m.settingsMenu.itemFocused).Description

end sub


sub boolSettingChanged()
    if m.boolSetting.focusedChild = invalid then return
    selectedSetting = m.userLocation.peek().children[m.settingsMenu.itemFocused]

    if m.boolSetting.checkedItem
        set_user_setting(selectedSetting.settingName, "true")
    else
        set_user_setting(selectedSetting.settingName, "false")
    end if

end sub

sub radioSettingChanged()
    if m.radioSetting.focusedChild = invalid then return
    selectedSetting = m.userLocation.peek().children[m.settingsMenu.itemFocused]
    set_user_setting(selectedSetting.settingName, m.radioSetting.content.getChild(m.radioSetting.checkedItem).id)
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false
    ? "KeyPress in Settings: "; key
    if (key = "back" or key = "left") and m.settingsMenu.focusedChild <> invalid and m.userLocation.Count() > 1
        LoadMenu({})
        return true
    else if (key = "back" or key = "left") and m.settingDetail.focusedChild <> invalid
        m.settingsMenu.setFocus(true)
        return true
    else if (key = "back" or key = "left") and m.radioSetting.hasFocus()
        m.settingsMenu.setFocus(true)
        return true
    else if (key = "back")
        m.top.backPressed = true
        return true
    end if
    if (key = "right" or key = "OK")
        settingSelected()
    end if
    if key = "up"
        m.top.backPressed = true
        return true
    end if
    return false
end function