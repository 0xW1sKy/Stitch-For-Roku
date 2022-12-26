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

function createUrlNorm()
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.AddHeader("Client-ID", "cf9fbjz6j9i6k6guz3dwh6qff5dluz") 'Used for API
    while m.global.appBearerToken = invalid
    end while
    ' userToken = m.global.userToken
    '? "(userToken) " userToken
    ' if userToken <> invalid and userToken <> ""
    '     ? "we usin " userToken
    '     url.AddHeader("Authorization", "Bearer " + m.global.userToken)
    ' else
    ? "we using global"
    url.AddHeader("Authorization", m.global.appBearerToken)
    ' end if
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
    ? "Client Asked to Refresh Token"
    sec = createObject("roRegistrySection", "StitchUserData")
    if sec.Exists("RefreshToken")
        refresh_token = sec.Read("RefreshToken")
    end if
    if sec.Exists("UserToken")
        userToken = sec.Read("UserToken")
    end if
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl("https://id.twitch.tv/oauth2/validate")
    url.AddHeader("Authorization", "Bearer " + userToken)
    response_string = ParseJson(url.GetToString())
    if response_string.status <> invalid and response_string.status = 401 and refresh_token <> invalid and refresh_token <> ""
        ? "URL Functions > refreshToken > 401"
        url = CreateObject("roUrlTransfer")
        url.EnableEncodings(true)
        url.RetainBodyOnError(true)
        url.SetCertificatesFile("common:/certs/ca-bundle.crt")
        url.InitClientCertificates()
        refresh_url = "https://oauth.k10labs.workers.dev/refresh?code=" + refresh_token
        url.SetUrl(refresh_url)
        oauth_token = ParseJson(url.GetToString())
        saveLogin(oauth_token.access_token, oauth_token.refresh_token, response_string.login)
    end if
end function

function saveLogin(access_token, refresh_token, login) as void
    sec = createObject("roRegistrySection", "StitchUserData")
    sec.Write("UserToken", access_token)
    sec.Write("RefreshToken", refresh_token)
    sec.Write("LoggedInUser", login)
    m.global.setField("userToken", access_token)
    m.global.setField("refreshToken", refresh_token)
    sec.Flush()
end function
