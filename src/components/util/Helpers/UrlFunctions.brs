function createUrl()
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.AddHeader("Client-ID", "cf9fbjz6j9i6k6guz3dwh6qff5dluz") 'Used for API
    while m.global.appBearerToken = invalid
    end while
    userToken = m.global.userToken
    '? "(userToken) " userToken
    if userToken <> invalid and userToken <> ""
        ? "we usin " userToken
        url.AddHeader("Authorization", "Bearer " + m.global.userToken)
    else
        ? "we using global"
        url.AddHeader("Authorization", m.global.appBearerToken)
    end if
    return url
end function

function GETJSON(link as string) as object
    url = createUrl()
    url.SetUrl(link.EncodeUri())

    response_string = url.GetToString()

    return ParseJson(response_string)
end function

function POST(request_url as string, request_payload as string) as string
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.AddHeader("Client-Id", "cf9fbjz6j9i6k6guz3dwh6qff5dluz") 'Used in GetCategories2
    url.AddHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36")
    url.AddHeader("Origin", "https://player.twitch.tv")
    url.AddHeader("Referer", "https://player.twitch.tv")
    url.SetUrl(request_url)

    port = CreateObject("roMessagePort")
    url.SetMessagePort(port)

    url.AsyncPostFromString(request_payload)

    response = Wait(0, port)

    return response.GetString()
end function

function refreshToken()
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl("https://oauth.k10labs.workers.dev/refresh")
    port = CreateObject("roMessagePort")
    url.SetMessagePort(port)
    url.AsyncPostFromString("code=" + getRefreshToken())
    msg = port.WaitMessage(0)
    oauth_token = ParseJson(msg.GetString())
    ? oauth_token
    access_token = oauth_token.access_token
    refresh_token = oauth_token.refresh_token
    if access_token = invalid
        DeleteRegistry()
        access_token = ""
        refresh_token = ""
    else
        url = CreateObject("roUrlTransfer")
        url.EnableEncodings(true)
        url.RetainBodyOnError(true)
        url.SetCertificatesFile("common:/certs/ca-bundle.crt")
        url.InitClientCertificates()
        url.SetUrl("https://id.twitch.tv/oauth2/validate")
        url.AddHeader("Authorization", "Bearer " + access_token)
        response = ParseJson(url.GetToString())
    end if

    saveLogin(access_token, refresh_token, response.login)
end function

function getRefreshToken()
    sec = createObject("roRegistrySection", "LoggedInUserData")
    if sec.Exists("RefreshToken")
        return sec.Read("RefreshToken")
    end if
    return ""
end function

function saveLogin(access_token, refresh_token, login) as void
    sec = createObject("roRegistrySection", "LoggedInUserData")
    sec.Write("UserToken", access_token)
    sec.Write("RefreshToken", refresh_token)
    sec.Write("LoggedInUser", login)
    m.global.setField("userToken", access_token)
    sec.Flush()
end function

sub DeleteRegistry()
    print "Starting Delete Registry"
    Registry = CreateObject("roRegistry")
    i = 0
    for each section in Registry.GetSectionList()
        RegistrySection = CreateObject("roRegistrySection", section)
        for each key in RegistrySection.GetKeyList()
            i = i + 1
            print "Deleting " section + ":" key
            RegistrySection.Delete(key)
        end for
        RegistrySection.flush()
    end for
    print i.toStr() " Registry Keys Deleted"
end sub
' function getBearerToken() as object
'     access_token_url = "https://oauth.k10labs.workers.dev/bearer"

'     url = CreateObject("roUrlTransfer")
'     url.EnableEncodings(true)
'     url.RetainBodyOnError(true)
'     url.SetCertificatesFile("common:/certs/ca-bundle.crt")
'     url.InitClientCertificates()
'     url.AddHeader("Authorization", "Basic YWRtaW46YWRtaW4=")
'     url.SetUrl(access_token_url)

'     response_string = ParseJSON(url.GetToString())

'     ? "GetToken response: "; response_string
'     m.top.appBearerToken = "Bearer " + response_string.access_token
' end function