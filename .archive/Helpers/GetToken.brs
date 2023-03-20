function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()

    m.top.appBearerToken = getStreamLink()

end function

function getStreamLink() as object
    access_token_url = "https://oauth.k10labs.workers.dev/bearer"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.AddHeader("Authorization", "Basic YWRtaW46YWRtaW4=")
    url.SetUrl(access_token_url)

    response_string = ParseJSON(url.GetToString())

    ? "GetToken response: "; response_string

    return "Bearer " + response_string.access_token
end function