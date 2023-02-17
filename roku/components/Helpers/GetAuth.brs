function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()

    getStreamLink()

    m.top.finished = true

end function


function saveLogin(access_token, refresh_token, login) as void
    sec = createObject("roRegistrySection", "SavedUserData")
    if access_token <> invalid and access_token <> ""
        sec.Write("UserToken", access_token)
        m.global.setField("UserToken", access_token)
    end if
    if access_token <> invalid and access_token <> ""
        sec.Write("RefreshToken", refresh_token)
        m.global.setField("RefreshToken", refresh_token)
    end if
    if access_token <> invalid and access_token <> ""
        sec.Write("LoggedInUser", login)
        m.global.setField("LoggedInUser", login)
    end if
    sec.Flush()
end function

function getStreamLink() as object
    m.top.finished = false

    enter_code_url = "https://oauth.k10labs.workers.dev/register"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(enter_code_url)
    url.AddHeader("Authorization", "Basic YWRtaW46YWRtaW4=")
    response_string = url.GetToString()
    ? "getAuth enter code: "; response_string
    m.top.code = response_string

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl("https://oauth.k10labs.workers.dev/unregister?code=" + response_string)
    url.AddHeader("Authorization", "Basic YWRtaW46YWRtaW4=")
    port = CreateObject("roMessagePort")
    url.SetMessagePort(port)

    while true
        print url.AsyncPostFromString("code=" + response_string)
        msg = port.WaitMessage(0)
        res = ParseJson(msg.GetString())
        if res <> invalid and res.DoesExist("access_token")
            exit while
        end if
        print msg.GetString()
        sleep(5000)
    end while

    print msg.GetString()

    oauth_token = ParseJson(msg.GetString())

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl("https://id.twitch.tv/oauth2/validate")
    url.AddHeader("Authorization", "OAuth " + oauth_token.access_token)
    url.AddHeader("Client-ID", "ue6666qo983tsx6so1t0vnawi233wa")
    response_string = ParseJson(url.GetToString())

    ? "oauth_token.refresh_token "; oauth_token.refresh_token
    saveLogin(oauth_token.access_token, oauth_token.refresh_token, response_string.login)
    return ""
end function