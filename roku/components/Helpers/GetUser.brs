
function init()
    m.gameNames = CreateObject("roAssociativeArray")
    m.userProfiles = CreateObject("roAssociativeArray")
    m.userLogins = CreateObject("roAssociativeArray")
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getGameNameFromId(link)
    url = createUrl()
    'search_results_url = "https://api.twitch.tv/helix/games?id=" + id
    url.SetUrl(link.EncodeUri())
    '? "getGameNameFromId > ";link.EncodeUri()
    response_string = url.GetToString()
    search = ParseJson(response_string)
    'name = ""
    if search.data <> invalid
        'name = search.data[0].name
        for each game in search.data
            m.gameNames[game.id] = game.name
        end for
    end if
    'return name
end function

function getProfilePicture(link)
    url = createUrl()
    'search_url = "https://api.twitch.tv/helix/users?id=" + user_id.ToStr()
    url.SetUrl(link.EncodeUri())
    '? "getProfilePicture > ";link.EncodeUri()
    response_string = url.GetToString()
    search = ParseJson(response_string)

    if search.data = invalid
        return "pkg:/images/login.png"
    end if
    for each profile in search.data
        m.userLogins[profile.id] = profile.login
        'uri = search.data[0].profile_image_url
        uri = profile.profile_image_url
        last = Right(uri, 2)
        if last = "eg"
            m.userProfiles[profile.id] = Left(uri, Len(uri) - 12) + "50x50.jpeg"
        else if last = "pg"
            m.userProfiles[profile.id] = Left(uri, Len(uri) - 11) + "50x50.jpg"
        else
            m.userProfiles[profile.id] = Left(uri, Len(uri) - 11) + "50x50.png"
        end if
    end for
end function

function convertToTimeFormat(timestamp as string) as string
    secondsSincePublished = createObject("roDateTime")
    secondsSincePublished.FromISO8601String(timestamp)
    currentTime = createObject("roDateTime").AsSeconds()
    elapsedTime = currentTime - secondsSincePublished.AsSeconds()
    hours = Int(elapsedTime / 60 / 60)
    mins = elapsedTime / 60 mod 60
    secs = elapsedTime mod 60
    if mins < 10
        mins = mins.ToStr()
        mins = "0" + mins
    else
        mins = mins.ToStr()
    end if
    if secs < 10
        secs = secs.ToStr()
        secs = "0" + secs
    else
        secs = secs.ToStr()
    end if
    return hours.ToStr() + ":" + mins + ":" + secs
end function



function get_user_data()
    search_results_url = "https://api.twitch.tv/helix/users?login=" + m.top.loginRequested
    url = createUrl()
    url.SetUrl(search_results_url.EncodeUri())
    response_string = url.GetToString()
    search = ParseJson(response_string)
    result = { raw: search }
    if search <> invalid and search.data <> invalid
        for each stream in search.data
            result.id = stream.id
            result.login = stream.login
            result.display_name = stream.display_name
            last = Right(stream.profile_image_url, 2)
            result.profile_image_url = stream.profile_image_url
        end for
    end if
    return result
end function

function getSearchResults() as object
    userdata = getTokenFromRegistry()
    access_token = ""
    device_code = ""
    ' doubled up here in stead of defaulting to "" because access_token is dependent on device_code
    if get_user_setting("device_code") <> invalid
        device_code = get_user_setting("device_code")
        if get_user_setting("access_token") <> invalid
            access_token = "OAuth " + get_user_setting("access_token")
        end if
    end if
    req = HttpRequest({
        url: "https://gql.twitch.tv/gql"
        headers: {
            "Accept": "*/*"
            "Authorization": access_token
            "Client-Id": "ue6666qo983tsx6so1t0vnawi233wa"
            "Device-ID": device_code
            "Origin": "https://switch.tv.twitch.tv"
            "Referer": "https://switch.tv.twitch.tv/"
        }
        method: "POST"
        data: {
            query: "query FollowingPage_Query(" + chr(10) + "  $first: Int!" + chr(10) + "  $liveUserCursor: Cursor" + chr(10) + "  $offlineUserCursor: Cursor" + chr(10) + "  $followedGameType: FollowedGamesType" + chr(10) + "  $categoryFirst: Int!" + chr(10) + "  $itemsPerRow: Int!" + chr(10) + "  $limit: Int!" + chr(10) + "  $platform: String!" + chr(10) + "  $requestID: String!" + chr(10) + ") {" + chr(10) + "  user {" + chr(10) + "    followedLiveUsers(first: $first, after: $liveUserCursor) {" + chr(10) + "      edges {" + chr(10) + "        node {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "    follows(first: $first, after: $offlineUserCursor) {" + chr(10) + "      edges {" + chr(10) + "        node {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "          stream {" + chr(10) + "            id" + chr(10) + "            __typename" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "    followedGames(first: $categoryFirst, type: $followedGameType) {" + chr(10) + "      nodes {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "    ...LiveStreamInfiniteShelf_followedLiveUsers" + chr(10) + "    ...OfflineInfiniteShelf_followedUsers" + chr(10) + "    ...CategoryShelf_followedCategories" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  ...FollowingPageEmpty_Query" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment CategoryBannerContent_category on Game {" + chr(10) + "  streams(first: 1) {" + chr(10) + "    edges {" + chr(10) + "      node {" + chr(10) + "        ...FollowingLiveStreamBannerContent_stream" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment CategoryShelf_followedCategories on User {" + chr(10) + "  followedGames(first: $categoryFirst, type: $followedGameType) {" + chr(10) + "    nodes {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      displayName" + chr(10) + "      developers" + chr(10) + "      boxArtURL" + chr(10) + "      ...FocusableCategoryCard_category" + chr(10) + "      ...CategoryBannerContent_category" + chr(10) + "      streams(first: 1) {" + chr(10) + "        edges {" + chr(10) + "          node {" + chr(10) + "            previewImageURL" + chr(10) + "            id" + chr(10) + "            __typename" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableCategoryCard_category on Game {" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  name" + chr(10) + "  displayName" + chr(10) + "  viewersCount" + chr(10) + "  boxArtURL" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableOfflineChannelCard_channel on User {" + chr(10) + "  displayName" + chr(10) + "  followers {" + chr(10) + "    totalCount" + chr(10) + "  }" + chr(10) + "  lastBroadcast {" + chr(10) + "    startedAt" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  login" + chr(10) + "  profileImageURL(width: 300)" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableStreamCard_stream on Stream {" + chr(10) + "  broadcaster {" + chr(10) + "    displayName" + chr(10) + "    login" + chr(10) + "    broadcastSettings {" + chr(10) + "      title" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    profileImageURL(width: 50)" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  game {" + chr(10) + "    displayName" + chr(10) + "    name" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  previewImageURL" + chr(10) + "  type" + chr(10) + "  viewersCount" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FollowingLiveStreamBannerContent_stream on Stream {" + chr(10) + "  game {" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  broadcaster {" + chr(10) + "    broadcastSettings {" + chr(10) + "      title" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FollowingPageEmpty_Query on Query {" + chr(10) + "  shelves(itemsPerRow: $itemsPerRow, first: $limit, platform: $platform, requestID: $requestID) {" + chr(10) + "    edges {" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        title {" + chr(10) + "          fallbackLocalizedTitle" + chr(10) + "          localizedTitleTokens {" + chr(10) + "            node {" + chr(10) + "              __typename" + chr(10) + "              ... on Game {" + chr(10) + "                __typename" + chr(10) + "                displayName" + chr(10) + "                name" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "              ... on TextToken {" + chr(10) + "                __typename" + chr(10) + "                text" + chr(10) + "                location" + chr(10) + "              }" + chr(10) + "              ... on BrowsableCollection {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "              ... on Tag {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "              ... on User {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "            }" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "        trackingInfo {" + chr(10) + "          rowName" + chr(10) + "        }" + chr(10) + "        content {" + chr(10) + "          edges {" + chr(10) + "            trackingID" + chr(10) + "            node {" + chr(10) + "              __typename" + chr(10) + "              __isShelfContent: __typename" + chr(10) + "              ... on Stream {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "                previewImageURL" + chr(10) + "                broadcaster {" + chr(10) + "                  displayName" + chr(10) + "                  broadcastSettings {" + chr(10) + "                    title" + chr(10) + "                    id" + chr(10) + "                    __typename" + chr(10) + "                  }" + chr(10) + "                  id" + chr(10) + "                  __typename" + chr(10) + "                }" + chr(10) + "                game {" + chr(10) + "                  displayName" + chr(10) + "                  boxArtURL" + chr(10) + "                  id" + chr(10) + "                  __typename" + chr(10) + "                }" + chr(10) + "                ...FocusableStreamCard_stream" + chr(10) + "              }" + chr(10) + "              ... on Game {" + chr(10) + "                ...FocusableCategoryCard_category" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "                streams(first: 1) {" + chr(10) + "                  edges {" + chr(10) + "                    node {" + chr(10) + "                      id" + chr(10) + "                      __typename" + chr(10) + "                      previewImageURL" + chr(10) + "                      broadcaster {" + chr(10) + "                        displayName" + chr(10) + "                        broadcastSettings {" + chr(10) + "                          title" + chr(10) + "                          id" + chr(10) + "                          __typename" + chr(10) + "                        }" + chr(10) + "                        id" + chr(10) + "                        __typename" + chr(10) + "                      }" + chr(10) + "                      game {" + chr(10) + "                        displayName" + chr(10) + "                        boxArtURL" + chr(10) + "                        id" + chr(10) + "                        __typename" + chr(10) + "                      }" + chr(10) + "                    }" + chr(10) + "                  }" + chr(10) + "                }" + chr(10) + "              }" + chr(10) + "              ... on Clip {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "              ... on Tag {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "              ... on Video {" + chr(10) + "                id" + chr(10) + "                __typename" + chr(10) + "              }" + chr(10) + "            }" + chr(10) + "          }" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment LiveStreamInfiniteShelf_followedLiveUsers on User {" + chr(10) + "  followedLiveUsers(first: $first, after: $liveUserCursor) {" + chr(10) + "    edges {" + chr(10) + "      cursor" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        displayName" + chr(10) + "        stream {" + chr(10) + "          previewImageURL" + chr(10) + "          game {" + chr(10) + "            boxArtURL" + chr(10) + "            id" + chr(10) + "            __typename" + chr(10) + "          }" + chr(10) + "          ...FollowingLiveStreamBannerContent_stream" + chr(10) + "          ...FocusableStreamCard_stream" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment OfflineBannerContent_user on User {" + chr(10) + "  displayName" + chr(10) + "  lastBroadcast {" + chr(10) + "    startedAt" + chr(10) + "    game {" + chr(10) + "      displayName" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment OfflineInfiniteShelf_followedUsers on User {" + chr(10) + "  follows(first: $first, after: $offlineUserCursor) {" + chr(10) + "    edges {" + chr(10) + "      cursor" + chr(10) + "      node {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        bannerImageURL" + chr(10) + "        displayName" + chr(10) + "        lastBroadcast {" + chr(10) + "          game {" + chr(10) + "            boxArtURL" + chr(10) + "            id" + chr(10) + "            __typename" + chr(10) + "          }" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "        stream {" + chr(10) + "          id" + chr(10) + "          __typename" + chr(10) + "        }" + chr(10) + "        ...OfflineBannerContent_user" + chr(10) + "        ...FocusableOfflineChannelCard_channel" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
            variables: {
                "first": 100
                ' "liveUserCursor": ""
                ' "offlineUserCursor": ""
                "followedGameType": "ALL"
                "categoryFirst": 100
                "itemsPerRow": 25
                "limit": 8
                "platform": "web_tv"
                "requestID": "xl8ONVvbK8sBp2H9"
            }
        }
    })
    test_data = ParseJSON(req.send())
    result = {
        login: ""
        id: ""
        display_name: ""
        profile_image_url: ""
        followed_users: []
    }
    user_data = get_user_data()
    if user_data <> invalid
        result.login = user_data.login
        result.display_name = user_data.display_name
        result.id = user_data.id
        result.profile_image_url = user_data.profile_image_url
    end if
    if test_data.data.user = invalid
        return result
    end if
    ' current_user_id = test_data.data.user.id
    ? "TEST DATA: "
    ? "live"
    ? test_data.data.user.followedLiveUsers.edges[0].node
    live_streamer_ids = {}
    for each streamer in test_data.data.user.followedLiveUsers.edges
        live_streamer_ids[(streamer.node.id.ToStr())] = true
        item = {}
        item.viewer_count = streamer.node.stream.viewersCount
        item.user_name = streamer.node.displayName
        item.game_id = streamer.node.stream.game.displayName
        item.title = streamer.node.stream.broadcaster.broadcastSettings.title
        item.shortDescriptionLine1 = streamer.node.stream.broadcaster.login
        item.login = streamer.node.stream.broadcaster.login
        item.thumbnail = Left(streamer.node.stream.previewImageUrl, Len(streamer.node.stream.previewImageUrl) - 20) + "320x180.jpg"
        item.profile_image_url = streamer.node.stream.broadcaster.profileImageUrl
        result.followed_users.push(item)
        ' item.live_duration = convertToTimeFormat(streamer.started_at)ToStr()
    end for
    ' followed_streamers = test_data.data.user.follows.edges

    ' refreshToken()
    ' 'search_results_url = "https://api.twitch.tv/kraken/streams?client_id=jzkbprff40iqj646a697cyrvl0zt2m6&limit=24&offset=" + m.top.offset + "&game="


    ' if result.id = invalid
    '     return result
    ' end if

    ' url2 = createUrl()

    ' user_follows_url = "https://api.twitch.tv/helix/users/follows?first=100&from_id=" + result.id
    ' url2.SetUrl(user_follows_url.EncodeUri())
    ' response_string = url2.GetToString()
    ' search = ParseJson(response_string)
    ' live_streamer_ids = {}
    ' if search <> invalid and search.data <> invalid
    '     result.followed_users = []
    '     total = search.total
    '     first_added_game = true
    '     current_added_games = 0
    '     game_ids_url = "https://api.twitch.tv/helix/games"
    '     user_ids_url = "https://api.twitch.tv/helix/users"
    '     current = 0
    '     addedGameIds = 0
    '     addedUserIds = 0
    '     while current < total
    '         '? "cursor > ";search.pagination.cursor
    '         if current <> 0
    '             url2 = createUrl()
    '             '? "id > ";result.id
    '             if search.pagination.cursor = invalid
    '                 if addedGameIds > 0
    '                     getGameNameFromId(game_ids_url)
    '                 end if
    '                 if addedUserIds > 0
    '                     getProfilePicture(user_ids_url)
    '                 end if
    '                 for each streamer in result.followed_users
    '                     streamer.game_id = m.gameNames[streamer.game_id]
    '                     streamer.profile_image_url = m.userProfiles[streamer.profile_image_url]
    '                 end for
    '                 result.followed_users.SortBy("viewer_count", "r")
    '                 return result
    '             end if
    '             user_follows_url = "https://api.twitch.tv/helix/users/follows?first=100&from_id=" + result.id + "&after=" + search.pagination.cursor
    '             url2.SetUrl(user_follows_url.EncodeUri())
    '             response_string = url2.GetToString()
    '             search = ParseJson(response_string)
    '         end if
    '         actually_added_followed_user = false
    '         actually_streaming_url = "https://api.twitch.tv/helix/streams?first=100"
    '         for each followed_user in search.data
    '             actually_streaming_url += "&user_id=" + followed_user.to_id
    '             actually_added_followed_user = true
    '             current += 1
    '         end for

    '         if not actually_added_followed_user then exit while

    '         url3 = createUrl()
    '         url3.SetUrl(actually_streaming_url.EncodeUri())
    '         response_string = url3.GetToString()
    '         search2 = ParseJson(response_string)
    '         for each streamer in search2.data
    '             item = {}
    '             item.user_name = streamer.user_name
    '             item.viewer_count = streamer.viewer_count
    '             item.game_id = streamer.game_id
    '             item.title = streamer.title
    '             item.thumbnail = Left(streamer.thumbnail_url, Len(streamer.thumbnail_url) - 20) + "320x180.jpg"
    '             item.live_duration = convertToTimeFormat(streamer.started_at)
    '             live_streamer_ids[streamer.user_id.ToStr()] = true
    '             if addedGameIds = 0
    '                 game_ids_url += "?id=" + streamer.game_id.ToStr()
    '                 addedGameIds += 1
    '             else if addedGameIds < 100
    '                 game_ids_url += "&id=" + streamer.game_id.ToStr()
    '                 addedGameIds += 1
    '             else if addedGameIds = 100
    '                 getGameNameFromId(game_ids_url)
    '                 game_ids_url = "https://api.twitch.tv/helix/games?id=" + streamer.game_id.ToStr()
    '                 addedGameIds = 1
    '             end if
    '             item.profile_image_url = streamer.user_id
    '             if addedUserIds = 0
    '                 user_ids_url += "?id=" + streamer.user_id.ToStr()
    '                 addedUserIds += 1
    '             else if addedUserIds < 100
    '                 user_ids_url += "&id=" + streamer.user_id.ToStr()
    '                 addedUserIds += 1
    '             else if addedUserIds = 100
    '                 getProfilePicture(user_ids_url)
    '                 user_ids_url = "https://api.twitch.tv/helix/users?id=" + streamer.user_id.ToStr()
    '                 addedUserIds = 1
    '             end if
    '             result.followed_users.push(item)
    '         end for
    '     end while
    '     if addedGameIds > 0
    '         getGameNameFromId(game_ids_url)
    '     end if
    '     if addedUserIds > 0
    '         getProfilePicture(user_ids_url)
    '     end if
    ' end if

    ' for each streamer in result.followed_users
    '     streamer.game_id = m.gameNames[streamer.game_id]
    '     streamer.login = m.userLogins[streamer.profile_image_url]
    '     streamer.profile_image_url = m.userProfiles[streamer.profile_image_url]
    ' end for
    ' ? "follows"
    ' if result.followed_users <> invalid
    '     result.followed_users.SortBy("viewer_count", "r")
    ' end if

    m.top.currentlyLiveStreamerIds = live_streamer_ids
    '? "currentlyLiveStreamerIds getuser " m.top.currentlyLiveStreamerIds
    result.followed_users.SortBy("viewer_count", "r")
    return result
end function