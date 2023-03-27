function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()

    getStreamLink()

    m.top.finished = true

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

    return ""
end function