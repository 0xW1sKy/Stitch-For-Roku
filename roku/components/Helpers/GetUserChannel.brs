'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getGameNameFromId(id as string)
    game_info = getjsondata("https://api.twitch.tv/helix/games?id=" + id)
    if game_info <> invalid and game_info.data <> invalid and game_info.data[0] <> invalid
        return game_info.data[0].name
    end if
    return id
end function

function convertToTimeFormat(timestamp as string) as string
    secondsSincePublished = createObject("roDateTime")
    secondsSincePublished.FromISO8601String(timestamp)
    currentTime = createObject("roDateTime").AsSeconds()
    elapsedTime = currentTime - secondsSincePublished.AsSeconds()
    m.top.streamDurationSeconds = elapsedTime
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

function getSearchResults() as object
    userdata = getTokenFromRegistry()
    req = HttpRequest({
        url: "https://gql.twitch.tv/gql"
        headers: {
            "Accept": "*/*"
            "Authorization": "OAuth " + userdata.access_token
            "Client-Id": "ue6666qo983tsx6so1t0vnawi233wa"
            "Device-ID": userdata.device_id
            "Origin": "https://switch.tv.twitch.tv"
            "Referer": "https://switch.tv.twitch.tv/"
        }
        method: "POST"
        data: {
            query: "query ChannelInterstitial_Query(" + chr(10) + "  $login: String!" + chr(10) + "  $platform: String!" + chr(10) + "  $playerType: String!" + chr(10) + "  $skipPlayToken: Boolean!" + chr(10) + ") {" + chr(10) + "  channel: user(login: $login) {" + chr(10) + "    ...InterstitialLayout_channel" + chr(10) + "    ...StreamDetails_channel" + chr(10) + "    ...StreamPlayer_channel" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    displayName" + chr(10) + "    broadcastSettings {" + chr(10) + "      isMature" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    stream {" + chr(10) + "      restrictionType" + chr(10) + "      self {" + chr(10) + "        canWatch" + chr(10) + "      }" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      type" + chr(10) + "    }" + chr(10) + "    hosting {" + chr(10) + "      displayName" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "      login" + chr(10) + "      stream {" + chr(10) + "        id" + chr(10) + "        __typename" + chr(10) + "        type" + chr(10) + "      }" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  currentUser {" + chr(10) + "    ...StreamPlayer_currentUser" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    login" + chr(10) + "    roles {" + chr(10) + "      isStaff" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  ...StreamPlayer_token" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment BroadcasterOverview_channel on User {" + chr(10) + "  login" + chr(10) + "  displayName" + chr(10) + "  followers {" + chr(10) + "    totalCount" + chr(10) + "  }" + chr(10) + "  primaryColorHex" + chr(10) + "  primaryTeam {" + chr(10) + "    displayName" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  profileImageURL(width: 70)" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment ChannelDescription_channel on User {" + chr(10) + "  description" + chr(10) + "  displayName" + chr(10) + "  login" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment FocusableFollowButton_channel on User {" + chr(10) + "  login" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  self {" + chr(10) + "    follower {" + chr(10) + "      followedAt" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment InterstitialButtonRow_channel on User {" + chr(10) + "  ...FocusableFollowButton_channel" + chr(10) + "  login" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment InterstitialLayout_channel on User {" + chr(10) + "  ...BroadcasterOverview_channel" + chr(10) + "  ...ChannelDescription_channel" + chr(10) + "  ...InterstitialButtonRow_channel" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamDetails_channel on User {" + chr(10) + "  broadcastSettings {" + chr(10) + "    game {" + chr(10) + "      boxArtURL" + chr(10) + "      displayName" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    title" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "  stream {" + chr(10) + "    viewersCount" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_channel on User {" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "  login" + chr(10) + "  roles {" + chr(10) + "    isPartner" + chr(10) + "  }" + chr(10) + "  self {" + chr(10) + "    subscriptionBenefit {" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "  }" + chr(10) + "  stream {" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "    game {" + chr(10) + "      name" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    previewImageURL" + chr(10) + "  }" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_currentUser on User {" + chr(10) + "  hasTurbo" + chr(10) + "  id" + chr(10) + "  __typename" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment StreamPlayer_token on Query {" + chr(10) + "  user(login: $login) {" + chr(10) + "    login" + chr(10) + "    stream @skip(if: $skipPlayToken) {" + chr(10) + "      playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "        signature" + chr(10) + "        value" + chr(10) + "      }" + chr(10) + "      id" + chr(10) + "      __typename" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
            variables: {
                "login": m.top.loginRequested
                "platform": "switch_web_tv"
                "playerType": "pulsar"
                "skipPlayToken": true
            }
    } })
    channelData = ParseJSON(req.send())
    ? "DATA"
    ? channelData
    testvar = m.top.loginRequested
    ? testvar

    result = {}
    result.display_name = channelData.data.channel.login
    result.profile_image_url = channelData.data.channel.profileImageUrl
    result.description = channelData.data.channel.broadcastSettings.title
    result.live_duration = ""
    result.offline_image_url = ""
    result.title = channelData.data.channel.description
    result.followers = channelData.data.channel.followers.totalCount
    result.login = channelData.data.channel.login
    result.id = channelData.data.channel.id
    if channelData.data.channel.stream <> invalid
        result.is_live = true
        result.thumbnail_url = channelData.data.channel.stream.previewImageURL
        result.game = channelData.data.channel.stream.game.name
        result.viewer_count = channelData.data.channel.stream.viewersCount
    else
        result.is_live = false
        result.thumbnail_url = ""
        result.game = ""
        result.viewer_count = ""
    end if
    search_results_url = "https://api.twitch.tv/helix/users?login=" + m.top.loginRequested
    url = createUrl()
    url.SetUrl(search_results_url.EncodeUri())

    response_string = url.GetToString()
    search = ParseJson(response_string)

    ' if search.status <> invalid and search.status = 401
    '     ? "401"
    '     refreshToken()
    '     return getSearchResults()
    ' end if

    if search <> invalid and search.data <> invalid
        stream = search.data[0]
        last = Right(stream.profile_image_url, 2)
        if last = "eg"
            result.profile_image_url = Left(stream.profile_image_url, Len(stream.profile_image_url) - 12) + "50x50.jpeg"
        else if last = "pg"
            result.profile_image_url = Left(stream.profile_image_url, Len(stream.profile_image_url) - 11) + "50x50.jpg"
        else
            result.profile_image_url = Left(stream.profile_image_url, Len(stream.profile_image_url) - 11) + "50x50.png"
        end if

        last = Right(stream.offline_image_url, 2)
        if last = "eg"
            result.offline_image_url = Left(stream.offline_image_url, Len(stream.offline_image_url) - 14) + "896x504.jpeg"
        else if last = "pg"
            result.offline_image_url = Left(stream.offline_image_url, Len(stream.offline_image_url) - 13) + "896x504.jpg"
        else
            result.offline_image_url = Left(stream.offline_image_url, Len(stream.offline_image_url) - 13) + "896x504.png"
        end if
    end if

    search_results_url = "https://api.twitch.tv/helix/streams?user_login=" + m.top.loginRequested

    url = createUrl()
    url.SetUrl(search_results_url.EncodeUri())

    response_string = url.GetToString()
    search = ParseJson(response_string)

    if search <> invalid and search.data <> invalid and search.data[0] <> invalid
        stream = search.data[0]
        result.title = stream.title
        result.thumbnail_url = Left(stream.thumbnail_url, Len(stream.thumbnail_url) - 20) + "896x504.jpg"
        ' result.game = getGameNameFromId(stream.game_id)
        result.live_duration = convertToTimeFormat(stream.started_at)
        ? "get viewer count > " stream.viewer_count
        result.viewer_count = numberToText(stream.viewer_count) + " viewers"
        m.top.isLive = true
        result.is_live = true
    else
        m.top.isLive = false
        result.is_live = false
    end if

    ' search_results_url = "https://api.twitch.tv/helix/users/follows?first=1&to_id=" + result.id

    ' url = createUrl()
    ' url.SetUrl(search_results_url.EncodeUri())

    ' response_string = url.GetToString()
    ' search = ParseJson(response_string)

    ' if search <> invalid and search.total <> invalid
    '     result.followers = numberToText(search.total) + " followers"
    ' else
    '     result.followers = "0 followers"
    ' end if

    return result
end function