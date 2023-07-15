sub init()
    m.top.functionName = "updateFollowBar"
end sub

sub updateFollowBar()
    access_token = ""
    device_code = ""
    di = CreateObject("roDeviceInfo")
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
                "platform": "switch_web_tv"
                "requestID": di.GetRandomUUID()
            }
        }
    })
    rsp = ParseJSON(req.send())
    contentCollection = []
    if rsp.data <> invalid and rsp.data.shelves <> invalid
        for each stream in rsp.data.shelves.edges[0].node.content.edges
            streamnode = stream.node
            ' type_name = stream.node.__typename
            try
                if stream.node.type <> invalid and stream.node.type = "live"
                    rowItem = createObject("RoSGNode", "TwitchContentNode")
                    rowItem.contentId = stream.node.Id
                    rowItem.contentType = "LIVE"
                    rowItem.previewImageURL = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", stream.node.broadcaster.login, "320", "180")
                    rowItem.contentTitle = stream.node.broadcaster.broadcastSettings.title
                    rowItem.viewersCount = stream.node.viewersCount
                    rowItem.streamerDisplayName = stream.node.broadcaster.displayName
                    rowItem.streamerLogin = stream.node.broadcaster.login
                    rowItem.streamerId = stream.node.broadcaster.id
                    rowItem.streamerProfileImageUrl = stream.node.broadcaster.profileImageURL
                    rowItem.gameDisplayName = stream.node.game.displayName
                    rowItem.gameBoxArtUrl = Left(stream.node.game.boxArtUrl, Len(stream.node.game.boxArtUrl) - 20) + "188x250.jpg"
                    rowItem.gameId = stream.node.game.Id
                    rowItem.gameName = stream.node.game.name
                    contentCollection.push(rowItem)
                end if
            catch e
                ? "Error: "; e
            end try
        end for
    end if
    if contentCollection.count() > 0
        m.top.result = contentCollection
    end if
end sub
