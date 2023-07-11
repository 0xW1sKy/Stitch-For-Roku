
function TwitchGraphQLRequest($data, $access_token = $null, $device_code = $null) {
    $headers = @{
        "Accept"          = "*/*"
        "Authorization"   = "OAuth $access_token"
        "Client-Id"       = "ue6666qo983tsx6so1t0vnawi233wa"
        "Device-ID"       = $device_code
        "Origin"          = "https://switch.tv.twitch.tv"
        "Referer"         = "https://switch.tv.twitch.tv/"
        "Accept-Language" = "en-US,en"
        "content-type"    = "application/json"
    }
    $req = Invoke-RestMethod -Uri "https://gql.twitch.tv/gql" -Method POST -Body $data -Headers $headers

    return $req
}

function get-OAuthToken($device_code) {
    $url = "https://id.twitch.tv/oauth2/token" + "?client_id=ue6666qo983tsx6so1t0vnawi233wa&device_code=" + $device_code + "&grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Adevice_code"
    $headers = @{
        "content-type" = "application/x-www-form-urlencoded"
        "origin"       = "https://switch.tv.twitch.tv"
        "referer"      = "https://switch.tv.twitch.tv/"
        "accept"       = "application/json"
    }
    $method = "POST"
    while ($true) {
        $req = Invoke-RestMethod -Uri $url -Headers $headers -Method $method -SkipHttpErrorCheck
        if ($req.access_token) {
            break
        }
        else {
            Start-Sleep 5
        }
    }
    return $req
}

function get-rendezvouztoken {
    $url = "https://id.twitch.tv/oauth2/device?scopes=channel_read%20chat%3Aread%20user_blocks_edit%20user_blocks_read%20user_follows_edit%20user_read&client_id=ue6666qo983tsx6so1t0vnawi233wa"
    $headers = @{
        "content-type" = "application/x-www-form-urlencoded"
        "origin"       = "https://switch.tv.twitch.tv"
        "referer"      = "https://switch.tv.twitch.tv/"
    }
    $method = "POST"
    $req = Invoke-RestMethod -Uri $url -Headers $headers -Method $method
    return $req
}



function TwitchHelixApiRequest($access_token = $null, $device_code = $null, $data = $null, $endpoint, $twitchargs, $method) {

    $url = "https://api.twitch.tv/helix/" + $endpoint + "?" + $twitchargs
    $headers = @{
        "Accept"        = "*/*"
        "Authorization" = "Bearer $access_token"
        "Client-Id"     = "ue6666qo983tsx6so1t0vnawi233wa"
        "Device-ID"     = $device_code
        "Origin"        = "https://switch.tv.twitch.tv"
        "Referer"       = "https://switch.tv.twitch.tv/"
    }
    if ($null -eq $data) {
        $rsp = Invoke-RestMethod -Uri $url -Headers $headers -Method $method
    }
    else {
        $rsp = Invoke-RestMethod -Uri $url -Headers $headers -Method $method -Body $data
    }
    return $rsp
}



$info = get-rendezvouztoken
$user_code = $info.user_code
$device_code = $info.device_code
Write-Host "Authenticate to https://www.twitch.tv/activate using code $user_code"
$token = get-OAuthToken -device_code $device_code
$access_token = $token.access_token

$body = "{`"query`":`"query Homepage_Query(\n  `$itemsPerRow: Int!\n  `$limit: Int!\n  `$platform: String!\n  `$requestID: String!\n) {\n  currentUser {\n    id\n    __typename\n    login\n    roles {\n      isStaff\n    }\n  }\n  shelves(itemsPerRow: `$itemsPerRow, first: `$limit, platform: `$platform, requestID: `$requestID) {\n    edges {\n      node {\n        id\n        __typename\n        title {\n          fallbackLocalizedTitle\n          localizedTitleTokens {\n            node {\n              __typename\n              ... on Game {\n                __typename\n                displayName\n                name\n              }\n              ... on TextToken {\n                __typename\n                text\n                location\n              }\n            }\n          }\n        }\n        trackingInfo {\n          reasonTarget\n          reasonTargetType\n          reasonType\n          rowName\n        }\n        content {\n          edges {\n            trackingID\n            node {\n              __typename\n              __isShelfContent: __typename\n              ... on Stream {\n                id\n                __typename\n                previewImageURL\n                broadcaster {\n                  displayName\n                  broadcastSettings {\n                    title\n                    id\n                    __typename\n                  }\n                  id\n                  __typename\n                }\n                game {\n                  displayName\n                  boxArtURL\n                  id\n                  __typename\n                }\n                ...FocusableStreamCard_stream\n              }\n              ... on Game {\n                ...FocusableCategoryCard_category\n                id\n                __typename\n                streams(first: 1) {\n                  edges {\n                    node {\n                      id\n                      __typename\n                      previewImageURL\n                      broadcaster {\n                        displayName\n                        broadcastSettings {\n                          title\n                          id\n                          __typename\n                        }\n                        id\n                        __typename\n                      }\n                      game {\n                        displayName\n                        boxArtURL\n                        id\n                        __typename\n                      }\n                    }\n                  }\n                }\n              }\n            }\n          }\n        }\n      }\n    }\n  }\n}\n\nfragment FocusableCategoryCard_category on Game {\n  name\n  id\n  __typename\n  displayName\n  viewersCount\n  boxArtURL\n}\n\nfragment FocusableStreamCard_stream on Stream {\n  broadcaster {\n    displayName\n    login\n    hosting {\n      id\n      __typename\n    }\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    profileImageURL(width: 50)\n    id\n    __typename\n  }\n  game {\n    displayName\n    name\n    id\n    __typename\n  }\n  id\n  __typename\n  previewImageURL\n  type\n  viewersCount\n}\n`",`"variables`":{`"itemsPerRow`":20,`"limit`":8,`"platform`":`"switch_web_tv`",`"requestID`":`"lwxcwatjfMfwXYPz`"}}"

$catbody = "{`"query`":`"query GamesDirectory_Query(\n  `$first: Int!\n) {\n  currentUser {\n    id\n    __typename\n    login\n    roles {\n      isStaff\n    }\n  }\n  games(first: `$first) {\n    edges {\n      node {\n        ...FocusableCategoryCard_category\n        id\n        __typename\n      }\n    }\n  }\n}\n\nfragment FocusableCategoryCard_category on Game {\n  name\n  id\n  __typename\n  displayName\n  viewersCount\n  boxArtURL\n}\n`",`"variables`":{`"first`":80}}"
$test = TwitchGraphQLRequest -data $catbody -access_token $access_token -device_code $device_code

$followBody = "{`"query`": `"query FollowingPage_Query(\n  `$first: Int!\n  `$liveUserCursor: Cursor\n  `$offlineUserCursor: Cursor\n  `$followedGameType: FollowedGamesType\n  `$categoryFirst: Int!\n  `$itemsPerRow: Int!\n  `$limit: Int!\n  `$platform: String!\n  `$requestID: String!\n) {\n  user {\n    followedLiveUsers(first: `$first, after: `$liveUserCursor) {\n      edges {\n        node {\n          id\n          __typename\n        }\n      }\n    }\n    follows(first: `$first, after: `$offlineUserCursor) {\n      edges {\n        node {\n          id\n          __typename\n          stream {\n            id\n            __typename\n          }\n        }\n      }\n    }\n    followedGames(first: `$categoryFirst, type: `$followedGameType) {\n      nodes {\n        id\n        __typename\n      }\n    }\n    ...LiveStreamInfiniteShelf_followedLiveUsers\n    ...OfflineInfiniteShelf_followedUsers\n    ...CategoryShelf_followedCategories\n    id\n    __typename\n  }\n  ...FollowingPageEmpty_Query\n}\n\nfragment CategoryBannerContent_category on Game {\n  streams(first: 1) {\n    edges {\n      node {\n        ...FollowingLiveStreamBannerContent_stream\n        id\n        __typename\n      }\n    }\n  }\n}\n\nfragment CategoryShelf_followedCategories on User {\n  followedGames(first: `$categoryFirst, type: `$followedGameType) {\n    nodes {\n      id\n      __typename\n      displayName\n      developers\n      boxArtURL\n      ...FocusableCategoryCard_category\n      ...CategoryBannerContent_category\n      streams(first: 1) {\n        edges {\n          node {\n            previewImageURL\n            id\n            __typename\n          }\n        }\n      }\n    }\n  }\n}\n\nfragment FocusableCategoryCard_category on Game {\n  id\n  __typename\n  name\n  displayName\n  viewersCount\n  boxArtURL\n}\n\nfragment FocusableOfflineChannelCard_channel on User {\n  displayName\n  followers {\n    totalCount\n  }\n  lastBroadcast {\n    startedAt\n    id\n    __typename\n  }\n  login\n  profileImageURL(width: 300)\n}\n\nfragment FocusableStreamCard_stream on Stream {\n  broadcaster {\n    displayName\n    login\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    profileImageURL(width: 50)\n    id\n    __typename\n  }\n  game {\n    displayName\n    name\n    id\n    __typename\n  }\n  id\n  __typename\n  previewImageURL\n  type\n  viewersCount\n}\n\nfragment FollowingLiveStreamBannerContent_stream on Stream {\n  game {\n    displayName\n    id\n    __typename\n  }\n  broadcaster {\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    displayName\n    id\n    __typename\n  }\n}\n\nfragment FollowingPageEmpty_Query on Query {\n  shelves(itemsPerRow: `$itemsPerRow, first: `$limit, platform: `$platform, requestID: `$requestID) {\n    edges {\n      node {\n        id\n        __typename\n        title {\n          fallbackLocalizedTitle\n          localizedTitleTokens {\n            node {\n              __typename\n              ... on Game {\n                __typename\n                displayName\n                name\n                id\n                __typename\n              }\n              ... on TextToken {\n                __typename\n                text\n                location\n              }\n              ... on BrowsableCollection {\n                id\n                __typename\n              }\n              ... on Tag {\n                id\n                __typename\n              }\n              ... on User {\n                id\n                __typename\n              }\n            }\n          }\n        }\n        trackingInfo {\n          rowName\n        }\n        content {\n          edges {\n            trackingID\n            node {\n              __typename\n              __isShelfContent: __typename\n              ... on Stream {\n                id\n                __typename\n                previewImageURL\n                broadcaster {\n                  displayName\n                  broadcastSettings {\n                    title\n                    id\n                    __typename\n                  }\n                  id\n                  __typename\n                }\n                game {\n                  displayName\n                  boxArtURL\n                  id\n                  __typename\n                }\n                ...FocusableStreamCard_stream\n              }\n              ... on Game {\n                ...FocusableCategoryCard_category\n                id\n                __typename\n                streams(first: 1) {\n                  edges {\n                    node {\n                      id\n                      __typename\n                      previewImageURL\n                      broadcaster {\n                        displayName\n                        broadcastSettings {\n                          title\n                          id\n                          __typename\n                        }\n                        id\n                        __typename\n                      }\n                      game {\n                        displayName\n                        boxArtURL\n                        id\n                        __typename\n                      }\n                    }\n                  }\n                }\n              }\n              ... on Clip {\n                id\n                __typename\n              }\n              ... on Tag {\n                id\n                __typename\n              }\n              ... on Video {\n                id\n                __typename\n              }\n            }\n          }\n        }\n      }\n    }\n  }\n}\n\nfragment LiveStreamInfiniteShelf_followedLiveUsers on User {\n  followedLiveUsers(first: `$first, after: `$liveUserCursor) {\n    edges {\n      cursor\n      node {\n        id\n        __typename\n        displayName\n        stream {\n          previewImageURL\n          game {\n            boxArtURL\n            id\n            __typename\n          }\n          ...FollowingLiveStreamBannerContent_stream\n          ...FocusableStreamCard_stream\n          id\n          __typename\n        }\n      }\n    }\n  }\n}\n\nfragment OfflineBannerContent_user on User {\n  displayName\n  lastBroadcast {\n    startedAt\n    game {\n      displayName\n      id\n      __typename\n    }\n    id\n    __typename\n  }\n  stream {\n    id\n    __typename\n  }\n}\n\nfragment OfflineInfiniteShelf_followedUsers on User {\n  follows(first: `$first, after: `$offlineUserCursor) {\n    edges {\n      cursor\n      node {\n        id\n        __typename\n        bannerImageURL\n        displayName\n        lastBroadcast {\n          game {\n            boxArtURL\n            id\n            __typename\n          }\n          id\n          __typename\n        }\n        stream {\n          id\n          __typename\n        }\n        ...OfflineBannerContent_user\n        ...FocusableOfflineChannelCard_channel\n      }\n    }\n  }\n}\n`",`"variables`": {`"first`": 100,`"followedGameType`": `"ALL`",`"categoryFirst`": 100,`"itemsPerRow`": 100,`"limit`": 8,`"platform`": `"switch_web_tv`",`"requestID`": `"$([guid]::newGuid())`"}}"

$test = TwitchGraphQLRequest -data $followbody -access_token $access_token -device_code $device_code

$gamePage = "{`"query`": `"query GameDirectory_Query(\n  `$gameAlias: String!\n  `$channelsCount: Int!\n) {\n  currentUser {\n    id\n    __typename\n    login\n    roles {\n      isStaff\n    }\n  }\n  game(name: `$gameAlias) {\n    boxArtURL\n    displayName\n    name\n    streams(first: `$channelsCount) {\n      edges {\n        node {\n          id\n          __typename\n          previewImageURL\n          ...FocusableStreamCard_stream\n        }\n      }\n    }\n    id\n    __typename\n  }\n}\n\nfragment FocusableStreamCard_stream on Stream {\n  broadcaster {\n    displayName\n    login\n    hosting {\n      id\n      __typename\n    }\n    broadcastSettings {\n      title\n      id\n      __typename\n    }\n    profileImageURL(width: 50)\n    id\n    __typename\n  }\n  game {\n    displayName\n    name\n    id\n    __typename\n  }\n  id\n  __typename\n  previewImageURL\n  type\n  viewersCount\n}\n`",`"variables`": {`"gameAlias`": `"just chatting`",`"channelsCount`": 40}}"

$test = TwitchGraphQLRequest -data $gamePage -access_token $access_token -device_code $device_code
