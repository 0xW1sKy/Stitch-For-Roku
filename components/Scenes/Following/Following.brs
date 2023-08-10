sub init()
    m.top.observeField("focusedChild", "onGetfocus")
    ? "init"; TimeStamp()
    ' m.top.observeField("itemFocused", "onGetFocus")
    m.rowlist = m.top.findNode("exampleRowList")
    ' m.allChannels = m.top.findNode("allChannels")
    ' m.allChannels.observeField("itemSelected", "handleItemSelected")
    m.rowlist.ObserveField("itemSelected", "handleItemSelected")
    m.offlineList = m.top.findNode("offlineList")
    m.GetContentTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.GetContentTask.observeField("response", "decideRoute")
    m.GetContentTask.request = {
        type: "getFollowingPageQuery"
    }
    m.getcontentTask.functionName = m.getcontenttask.request.type
    m.getcontentTask.control = "run"
end sub

sub decideRoute()
    ? "DecideRoute"; TimeStamp()
    if get_setting("active_user") <> invalid and get_setting("active_user") <> "$default$"
        ? "Route -> handleRecommendedSections"
        handleRecommendedSections()
    else
        ? "Route -> handleDefaultSections"
        handleDefaultSections()
    end if
end sub

sub handleDefaultSections()
    contentCollection = createObject("RoSGNode", "ContentNode")
    if m.GetcontentTask.response.data <> invalid and m.GetcontentTask.response.data.shelves <> invalid
        if m.GetcontentTask.response.data.shelves.count() > 0
            for each streamRow in m.GetcontentTask.response.data.shelves.edges
                row = createObject("RoSGNode", "ContentNode")
                temp_title = ""
                try
                    for each wordblock in streamRow.node.title.localizedTitleTokens
                        if wordblock.node.__typename = "TextToken"
                            temp_title = Substitute("{0}{1}", temp_title, wordblock.node.text)
                        end if
                        if wordblock.node.__typename = "Game"
                            temp_title = Substitute("{0}{1}", temp_title, wordblock.node.displayName)
                        end if
                        if wordblock.node.__typename = "BrowsableCollection"
                            temp_title = streamRow.node.title.fallbackLocalizedTitle
                        end if
                    end for
                catch e
                    ? "TITLE ERROR: "; e
                    temp_title = streamRow.node.title.fallbackLocalizedTitle
                    ? "Title With Problem: "; temp_title
                end try
                row.title = temp_title
                jsonStreams = []
                for each stream in streamRow.node.content.edges
                    if stream.node <> invalid
                        if stream.node["__typename"].toStr() <> invalid and stream.node["__typename"].toStr() = "Stream"
                            rowItem = {}
                            rowItem.contentId = stream.node.Id
                            rowItem.contentType = "LIVE"
                            rowItem.previewImageURL = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", stream.node.broadcaster.login, "320", "180")
                            rowItem.contentTitle = stream.node.broadcaster.broadcastSettings.title
                            rowItem.viewersCount = stream.node.viewersCount
                            rowItem.streamerDisplayName = stream.node.broadcaster.displayName
                            rowItem.streamerLogin = stream.node.broadcaster.login
                            rowItem.streamerId = stream.node.broadcaster.id
                            rowItem.streamerProfileImageUrl = stream.node.broadcaster.profileImageURL
                            if stream.node.game <> invalid
                                rowItem.gameDisplayName = stream.node.game.displayName
                                rowItem.gameBoxArtUrl = Left(stream.node.game.boxArtUrl, Len(stream.node.game.boxArtUrl) - 20) + "188x250.jpg"
                                rowItem.gameId = stream.node.game.Id
                                rowItem.gameName = stream.node.game.name
                            end if
                            jsonStreams.push(rowItem)
                        end if
                    end if
                end for
                for each stream in jsonStreams
                    rowItem = createObject("RoSGNode", "TwitchContentNode")
                    setTwitchContentFields(rowItem, stream)
                    row.appendChild(rowItem)
                end for
                if row.getchildcount() > 0
                    contentCollection.appendChild(row)
                end if
            end for
            updateRowList(contentCollection)
        end if
    end if
end sub



sub handleRecommendedSections()
    ? "handleRecommendedSections: "; TimeStamp()
    contentCollection = createObject("RoSGNode", "ContentNode")
    if m.GetcontentTask?.response?.data?.user <> invalid
        ? "UserSectionValid"
    else
        ? "User Section Invalid"
    end if
    try
        if m.GetcontentTask.response.data <> invalid and m.GetcontentTask.response.data.user <> invalid and m.GetcontentTask.response.data.user.followedLiveUsers <> invalid
            if m.GetcontentTask.response.data.user.followedLiveUsers.count() > 0
                row = createObject("RoSGNode", "ContentNode")
                row.title = tr("followedLiveUsers")
                first = true
                itemsPerRow = 3
                liveFollows = []
                for each liveUser in m.GetcontentTask.response.data.user.followedLiveUsers.edges
                    stream = liveUser.node.stream
                    rowItem = {}
                    rowItem.contentId = stream.Id
                    rowItem.contentType = "LIVE"
                    rowItem.previewImageURL = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", stream.broadcaster.login, "320", "180")
                    rowItem.contentTitle = stream.broadcaster.broadcastSettings.title
                    rowItem.viewersCount = stream.viewersCount
                    rowItem.streamerDisplayName = stream.broadcaster.displayName
                    rowItem.streamerLogin = stream.broadcaster.login
                    rowItem.streamerId = stream.broadcaster.id
                    rowItem.streamerProfileImageUrl = stream.broadcaster.profileImageURL
                    rowItem.gameDisplayName = stream.game.displayName
                    rowItem.gameBoxArtUrl = Left(stream.game.boxArtUrl, Len(stream.game.boxArtUrl) - 20) + "188x250.jpg"
                    rowItem.gameId = stream.game.Id
                    rowItem.gameName = stream.game.name
                    liveFollows.push(rowItem)
                end for
                appended = false
                for i = 0 to (liveFollows.count() - 1) step 1
                    if first
                        first = false
                    else if i mod itemsPerRow = 0
                        row = createObject("RoSGNode", "ContentNode")
                    end if
                    twitchContentNode = createObject("roSGNode", "TwitchContentNode")
                    setTwitchContentFields(twitchContentNode, liveFollows[i])
                    row.appendChild(twitchContentNode)
                    appended = false
                    if row.getChildCount() = itemsPerRow
                        contentCollection.appendChild(row)
                        appended = true
                    end if
                end for
                if not appended and row <> invalid and row.getchildcount() > 0
                    contentCollection.appendChild(row)
                end if
            end if
        end if
    catch e
    end try
    try
        ? "LiveStreamSection Complete: "; TimeStamp()
        if m.GetcontentTask.response.data <> invalid and m.GetcontentTask.response.data.user <> invalid and m.GetcontentTask.response.data.user.follows <> invalid
            if m.GetcontentTask.response.data.user.follows.count() > 0
                row = createObject("RoSGNode", "ContentNode")
                row.title = tr("followedOfflineUsers")
                first = true
                itemsPerRow = 6
                ? "OfflineSection Start: "; TimeStamp()
                streams = []
                ? "OfflineSection ContentStart: "; TimeStamp()
                for each stream in m.GetcontentTask.response.data.user.follows.edges
                    try
                        rowItem = {}
                        rowItem.contentId = stream.node.Id
                        rowItem.contentType = "USER"
                        rowItem.previewImageURL = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", stream.node.login, "320", "180")
                        rowItem.contentTitle = stream.node.displayName
                        rowItem.followerCount = stream.node.followers.totalCount
                        rowItem.streamerDisplayName = stream.node.displayName
                        rowItem.streamerLogin = stream.node.login
                        rowItem.streamerId = stream.node.id
                        rowItem.streamerProfileImageUrl = stream.node.profileImageURL
                        ' rowItem.gameDisplayName = stream.node.game.displayName
                        ' rowItem.gameBoxArtUrl = Left(stream.node.game.boxArtUrl, Len(stream.node.game.boxArtUrl) - 20) + "188x250.jpg"
                        ' rowItem.gameId = stream.node.game.Id
                        ' rowItem.gameName = stream.node.game.name
                        streams.push(rowItem)
                    catch e
                        ? "error: "; e
                    end try
                end for
                ? "OfflineSection ContentEnd: "; TimeStamp()
                streams.sortBy("streamerLogin")
                appended = false
                for i = 0 to (streams.count() - 1) step 1
                    if first
                        first = false
                    else if i mod itemsPerRow = 0
                        row = createObject("RoSGNode", "ContentNode")
                    end if
                    twitchContentNode = createObject("roSGNode", "TwitchContentNode")
                    setTwitchContentFields(twitchContentNode, streams[i])
                    row.appendChild(twitchContentNode)
                    appended = false
                    if row.getChildCount() = itemsPerRow
                        contentCollection.appendChild(row)
                        appended = true
                    end if
                end for
                if not appended and row <> invalid and row.getchildcount() > 0
                    contentCollection.appendChild(row)
                end if
                ? "OfflineStreamSection Complete: "; TimeStamp()
                updateRowList(contentCollection)
            end if
        end if
    catch e
    end try
end sub

function updateRowList(contentCollection)
    ? "updateRowList: "; TimeStamp()
    rowItemSize = []
    showRowLabel = []
    rowHeights = []
    for each row in contentCollection.getChildren(contentCollection.getChildCount(), 0)
        if row.title <> ""
            hasRowLabel = true
        else
            hasRowLabel = false
        end if
        showRowLabel.push(hasRowLabel)
        defaultRowHeight = 275
        if row.getchild(0).contentType = "LIVE" or row.getchild(0).contentType = "VOD"
            rowItemSize.push([320, 180])
            if hasRowLabel
                rowHeights.push(295)
            else
                rowHeights.push(255)
            end if
        end if
        if row.getchild(0).contentType = "GAME"
            rowItemSize.push([188, 250])
            if hasRowLabel
                rowHeights.push(325)
            else
                rowHeights.push(305)
            end if
        end if
        if row.getchild(0).contentType = "USER"
            rowItemSize.push([150, 150])
            if hasRowLabel
                rowHeights.push(260)
            else
                rowHeights.push(240)
            end if
        end if
    end for
    m.rowlist.rowHeights = rowHeights
    m.rowlist.showRowLabel = showRowLabel
    m.rowlist.rowItemSize = rowItemSize
    m.rowlist.content = contentCollection
    m.rowlist.numRows = m.rowlist.content.getChildCount()
    m.rowlist.rowlabelcolor = m.global.constants.colors.twitch.purple10
    ? "updateRowList Done: "; TimeStamp()
end function

sub handleItemSelected()
    if m.rowlist.focusedChild <> invalid
        item = m.rowList
    else if m.offlinelist.focusedChild <> invalid
        item = m.offlinelist
    end if
    selectedRow = item.content.getchild(item.rowItemSelected[0])
    selectedItem = selectedRow.getChild(item.rowItemSelected[1])
    m.top.contentSelected = selectedItem
end sub

sub handleLiveItemSelected()
    selectedRow = m.rowlist.content.getchild(m.rowlist.rowItemSelected[0])
    selectedItem = selectedRow.getChild(m.rowlist.rowItemSelected[1])
    m.top.playContent = true
    m.top.contentSelected = selectedItem
end sub

sub onGetFocus()
    if m.rowlist.focusedChild = invalid
        m.rowlist.setFocus(true)
    else if m.rowlist.focusedchild.id = "exampleRowList"
        m.rowlist.focusedChild.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        ? "Home Scene Key Event: "; key
        if key = "up" or key = "back"
            m.top.backPressed = true
            return true
        end if
    end if
end function