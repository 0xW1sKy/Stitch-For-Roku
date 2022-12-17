function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()

    stream_link = getStreamLink()

    m.top.finished = true

end function

function saveLogin(access_token, refresh_token, login) as void
    sec = createObject("roRegistrySection", "LoggedInUserData")
    sec.Write("UserToken", access_token)
    sec.Write("RefreshToken", refresh_token)
    sec.Write("LoggedInUser", login)
    m.global.setField("userToken", access_token)
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
        sleep(2000)
    end while

    print msg.GetString()

    oauth_token = ParseJson(msg.GetString())

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl("https://id.twitch.tv/oauth2/validate")
    url.AddHeader("Authorization", "Bearer " + oauth_token.access_token)
    response_string = ParseJson(url.GetToString())

    ? "oauth_token.refresh_token "; oauth_token.refresh_token
    saveLogin(oauth_token.access_token, oauth_token.refresh_token, response_string.login)

    return ""
end function