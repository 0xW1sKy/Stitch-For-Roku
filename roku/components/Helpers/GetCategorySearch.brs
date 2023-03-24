'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getSearchResults() as object
    search_results_url = "https://api.twitch.tv/helix/search/categories?query=" + m.top.searchText + "&type=suggest&first=5"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.AddHeader("Origin", "https://player.twitch.tv")
    url.AddHeader("Referer", "https://player.twitch.tv")
    url.AddHeader("Client-Id", "ue6666qo983tsx6so1t0vnawi233wa")
    userToken = get_user_setting("access_token")
    '? "(userToken) " userToken
    if userToken <> invalid and userToken <> ""
        ? "we usin " userToken
        url.AddHeader("Authorization", "Bearer " + get_user_setting("access_token"))
    else
        ? "we using global"
        url.AddHeader("Authorization", m.global.appBearerToken)
    end if
    url.AddHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36")
    url.AddHeader("Accept", "application/vnd.twitchtv.v5+json")
    url.InitClientCertificates()
    url.SetUrl(search_results_url.EncodeUri())

    response_string = url.GetToString()
    ? response_string
    search = ParseJson(response_string)

    result = []
    if search <> invalid and search.data <> invalid
        for each game in search.data
            item = {}
            item.id = game.id
            item.name = game.name
            item.logo = game.box_art_url
            result.push(item)
        end for
    end if

    return result
end function