sub init()
    m.top.observeField("itemHasFocus", "onGetfocus")
    m.code = m.top.findNode("code")
    m.loginText = m.top.findNode("topText")
    m.bottomText = m.top.findNode("bottomText")
    m.buttonGroup = m.top.findNode("buttonGroup")
    RunContentTask()
end sub

sub handleOauthToken()
    ? "[LoginPage] - handleOauthToken"
    if m.oauthtask.response.access_token <> invalid
        set_user_setting("access_token", m.OauthTask.response.access_token)
        set_user_setting("device_code", get_user_setting("temp_device_code"))
        if get_user_setting("device_code") = get_user_setting("temp_device_code")
            unset_user_setting("temp_device_code")
        end if
        getUserLogin()
    end if
end sub

sub handleUserLogin()
    ? "[LoginPage] - handleUserLogin()"
    if m.UserLoginTask.response.data.currentUser <> invalid and m.UserLoginTask.response.data.currentUser.login <> invalid
        access_token = get_user_setting("access_token")
        device_code = get_user_setting("device_code")
        unset_user_setting("access_token")
        unset_user_setting("device_code")
        set_setting("active_user", m.UserLoginTask.response.data.currentUser.login)
        set_user_setting("login", m.UserLoginTask.response.data.currentUser.login)
        set_user_setting("access_token", access_token)
        set_user_setting("device_code", device_code)
        ' TODO: Yet again with the static reference that should be fixed.
        ' Parent = heroScene, child 1 = MenuBar, child 3 = ButtonGroup, child 6 = loginIconButton
        m.top.finished = true
    end if
    RunContentTask()
end sub

function getUserLogin()
    ? "[LoginPage] - getUserLogin"
    userToken = get_user_setting("access_token")
    m.UserLoginTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
    m.UserLoginTask.observeField("response", "handleUserLogin")
    m.UserLoginTask.request = {
        type: "getHomePageQuery"
    }
    m.UserLoginTask.functionName = m.UserLoginTask.request.type
    m.UserLoginTask.control = "run"
end function


sub handleRendezvouzToken()
    ? "handle Rendezvouz token"
    if m.RendezvouzTask <> invalid
        response = m.RendezvouzTask.response
        ? "Response "; response
        set_user_setting("temp_device_code", response.device_code)
        m.code.text = response.user_code
        m.OauthTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
        m.OauthTask.observeField("response", "handleOauthToken")
        m.OauthTask.request = {
            type: "getOauthToken"
            params: response
        }
        m.OauthTask.functionName = m.Oauthtask.request.type
        m.OauthTask.control = "run"
    end if
end sub
' m.top.finished = true
sub onButtonSelected()
    ? "buttonSelected: "; m.buttonGroup.buttonSelected
    if m.buttonGroup.buttonSelected = 0
        active_user = get_setting("active_user", "default")
        if active_user <> "default"
            NukeRegistry(active_user)
            set_setting("active_user", "default")
            m.top.finished = true
            RunContentTask()
        end if
    end if
end sub

sub onGetFocus()
    ? "got focus"
    if m.top.focusedChild = invalid
        if m.buttonGroup.visible
            m.buttonGroup.setFocus(true)
        end if
        ' else if m.rowlist.focusedchild.id = "exampleRowList"
        '     m.rowlist.focusedChild.setFocus(true)
    end if

end sub

sub RunContentTask()
    ? "active User: "; get_setting("active_user", "default")
    if get_setting("active_user", "default") <> "default"
        m.buttonGroup.observeField("buttonSelected", "onButtonSelected")
        m.buttonGroup.buttons = [tr("Log Out")]
        m.code.visible = false
        m.loginText.visible = false
        m.bottomText.visible = false
        m.buttonGroup.visible = true
        m.buttonGroup.setFocus(true)
    else
        ? "[LoginPage] - RunContentTask"
        m.code.visible = true
        m.loginText.visible = true
        m.bottomText.visible = true
        m.buttonGroup.visible = false
        m.RendezvouzTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
        ' observe content so we can know when feed content will be parsed
        m.RendezvouzTask.observeField("response", "handleRendezvouzToken")
        m.RendezvouzTask.request = {
            type: "getRendezvouzToken"
        }
        m.RendezvouzTask.functionName = m.RendezvouzTask.request.type
        m.RendezvouzTask.control = "run"
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if not press return false
    m.top.backPressed = true
    return true
end function