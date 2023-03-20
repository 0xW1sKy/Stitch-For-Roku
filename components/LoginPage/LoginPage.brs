sub init()
    m.code = m.top.findNode("code")
    RunContentTask()
end sub

sub handleOauthToken()
    ? m.OauthTask.response
    m.global.access_token = m.OauthTask.response.access_token
    m.global.refresh_token = m.OauthTask.response.access_token
end sub

sub handleRendezvouzToken()
    response = m.RendezvouzTask.response
    m.code.text = response.user_code
    m.OauthTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
    m.OauthTask.observeField("response", "handleOauthToken")
    m.OauthTask.request = {
        type: "getOauthToken"
        params: response
    }
end sub
' m.top.finished = true
sub RunContentTask()
    ? "Running Content Task"
    m.RendezvouzTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.RendezvouzTask.observeField("response", "handleRendezvouzToken")
    m.RendezvouzTask.request = {
        type: "getRendezvouzToken"
    }
end sub
