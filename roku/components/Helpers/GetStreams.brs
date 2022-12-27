
function init()
    m.gameNames = CreateObject("roAssociativeArray")
    m.loginNames = CreateObject("roAssociativeArray")
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getLoginFromId(user_ids_url)
    url = createUrl()
    url.SetUrl(user_ids_url.EncodeUri())
    response_string = url.GetToString()
    search = ParseJson(response_string)
    if search.data <> invalid
        for each user in search.data
            m.loginNames[user.id] = user.login
        end for
    end if
end function

function getGameNameFromId(game_ids_url)
    url = createUrl()
    url.SetUrl(game_ids_url.EncodeUri())
    response_string = url.GetToString()
    search = ParseJson(response_string)
    if search.data <> invalid
        for each game in search.data
            m.gameNames[game.id] = game.name
        end for
    end if
end function


function formatItem(stream, first)
    ? "GetStreams > FormatItem"
    game_ids_url = "https://api.twitch.tv/helix/games?id="
    user_ids_url = "https://api.twitch.tv/helix/users?id="
    if first = false
        game_ids_url += "&id=" + stream.game_id
        user_ids_url += "&id=" + stream.user_id
    else
        game_ids_url += stream.game_id
        user_ids_url += stream.user_id
    end if
    thumbnail_url = Left(stream.thumbnail_url, Len(stream.thumbnail_url) - 21)

    ' thumbnail_url = "https://static-cdn.jtvnw.net/previews-ttv/live_user_" + stream.name + ".jpg"
    item = {
        description: stream.title
        guid: stream.user_id
        hdbackgroundimageurl: thumbnail_url + "-854x480.jpg"
        hdposterurl: thumbnail_url + "-854x480.jpg"
        link: ""
        "media:content": ""
        pubDate: ""
        stream: { url: thumbnail_url }
        streamformat: "hls"
        title: stream.user_name
        subtitle: stream.viewer_count
        typename: "stream"
        uri: [
        ]

    }
    return item
end function

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

'     return "Bearer " + response_string.access_token
' end function





' function getCategorySearchResults()
'     search_results_url = "https://api.twitch.tv/helix/games/top?first=24"
'     url = CreateObject("roUrlTransfer")
'     url.EnableEncodings(true)
'     url.RetainBodyOnError(true)
'     url.SetCertificatesFile("common:/certs/ca-bundle.crt")
'     url.InitClientCertificates()
'     url.AddHeader("Client-ID", "cf9fbjz6j9i6k6guz3dwh6qff5dluz") 'Used for API
'     ? "we using global"
'     url.AddHeader("Authorization", getBearerToken())
'     ? "getSearchResults >>> 2"
'     url.SetUrl(search_results_url.EncodeUri())
'     response_string = url.GetToString()
'     search = ParseJson(response_string)

'     result = []
'     if search.data <> invalid
'         for each category in search.data
'             item = {
'                 descrption: ""
'                 guid: category.id
'                 hdbackgroundimageurl: Left(category.box_art_url, Len(category.box_art_url) - 20) + "136x190.jpg"
'                 hdposterurl: Left(category.box_art_url, Len(category.box_art_url) - 20) + "136x190.jpg"
'                 link: ""
'                 "media:content": ""
'                 pubDate: ""
'                 stream: { url: "" }
'                 streamformat: "hls"
'                 title: category.name
'                 typename: "category"
'                 uri: [
'                     Left(category.box_art_url, Len(category.box_art_url) - 20) + "136x190.jpg"
'                 ]

'             }
'             result.push(item)
'         end for
'     end if
'     return result
' end function
