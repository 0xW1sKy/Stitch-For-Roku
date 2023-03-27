sub init()
    m.currentVideoQuality = m.top.findNode("currentVideoQuality")
    m.videoQualityDropdown = m.top.findNode("videoQualityDropdown")
    m.videoQualitySelectRect = m.top.findNode("videoQualitySelectRect")
    m.chatInfo = m.top.findNode("chatInfo")
    m.optionSelectRect = m.top.findNode("optionSelectRect")

    m.top.observeField("visible", "onBackPress")

    m.videoQualities = ["1080p60", "1080p", "720p60", "720p", "480p", "360p", "160p"]
    '? "m.videoQuality > "; get_user_setting("VideoQuality")
    m.currentVideoQuality.text = m.videoQualities[get_user_setting("VideoQuality", "0").ToInt()]
    m.currentChatOption = get_user_setting("ChatOption", "true")
    if m.currentChatOption = "true"
        m.chatInfo.text = "Enabled"
    else
        m.chatInfo.text = "Disabled"
    end if
    m.currentOption = 0
    m.currentVideoQualitySelected = 0
end sub

sub onBackPress()
    if m.top.visible = false
        m.videoQualityDropdown.visible = false
        m.currentVideoQuality.visible = true
    end if
end sub

sub saveVideoSettings() as void
    ? "old"
end sub

sub onKeyEvent(key, press) as boolean
    handled = false
    if press
        '? "options test > ";m.currentOption; " ";m.currentVideoQualitySelected; " ";m.videoQualityDropdown.hasFocus()
        if key = "OK"
            '? "options test > ";m.videoQualityDropdown.hasFocus()
            if m.videoQualityDropdown.hasFocus()
                if get_user_setting("VideoQuality", invalid) <> invalid
                    set_user_setting("VideoQuality", m.currentVideoQualitySelected.ToStr())
                    if m.currentVideoQualitySelected = 0 or m.currentVideoQualitySelected = 2
                        set_user_setting("VideoFramerate", "60")
                    else
                        set_user_setting("VideoFramerate", "30")
                    end if
                end if
                saveVideoSettings()
                m.currentVideoQuality.text = m.videoQualities[m.currentVideoQualitySelected]
                m.videoQualityDropdown.setFocus(false)
                m.top.setFocus(true)
                m.chatInfo.visible = true
                m.videoQualitySelectRect.visible = false
                m.videoQualityDropdown.visible = false
                m.currentVideoQuality.visible = true
            else if m.currentOption = 0
                '? "here?"
                m.videoQualityDropdown.setFocus(true)
                m.currentVideoQuality.visible = false
                m.videoQualityDropdown.visible = true
                m.chatInfo.visible = false
                m.videoQualitySelectRect.visible = true
            else if m.currentOption = 1
                '? "here?"
                m.currentChatOption = get_user_setting("ChatOption", "true")
                if m.currentChatOption = "false"
                    ? "Detected Current Chat Option True"
                    m.chatInfo.text = "Enabled"
                    set_user_setting("ChatOption", "true")
                else
                    ? "Detected Current Chat Option False"
                    m.chatInfo.text = "Disabled"
                    set_user_setting("ChatOption", "false")
                end if
            end if
            handled = true
        else if key = "down"
            if m.videoQualityDropdown.hasFocus()
                if m.currentVideoQualitySelected + 1 <= 6
                    m.currentVideoQualitySelected += 1
                    m.videoQualitySelectRect.translation = [m.videoQualitySelectRect.translation[0], m.videoQualitySelectRect.translation[1] + 50]
                end if
            else if m.currentOption + 1 <= 1
                m.optionSelectRect.translation = [90, 270]
                m.currentOption += 1
            end if
            handled = true
        else if key = "up"
            if m.videoQualityDropdown.hasFocus()
                if m.currentVideoQualitySelected - 1 >= 0
                    m.currentVideoQualitySelected -= 1
                    m.videoQualitySelectRect.translation = [m.videoQualitySelectRect.translation[0], m.videoQualitySelectRect.translation[1] - 50]
                end if
            else if m.currentOption - 1 >= 0
                m.optionSelectRect.translation = [90, 170]
                m.currentOption -= 1
            end if
            handled = true
        end if
    end if
    return handled
end sub