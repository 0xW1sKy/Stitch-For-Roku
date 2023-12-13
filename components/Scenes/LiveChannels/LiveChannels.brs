sub init()
    m.top.observeField("focusedChild", "onGetfocus")
    ' m.top.observeField("itemFocused", "onGetFocus")
    m.rowlist = m.top.findNode("exampleRowList")
    m.rowlist.ObserveField("itemSelected", "handleItemSelected")
    m.rowlist.observeField("itemHasFocus", "handleItemFocus")
    m.GetContentTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.GetContentTask.observeField("response", "handleRecommendedSections")
    m.GetContentTask.request = {
        type: "getBrowsePagePopularQuery"
    }
    m.GetContentTask.functionName = m.GetContentTask.request.type
    m.GetContentTask.control = "run"
end sub

function buildContentNodeFromShelves(streams)
    contentCollection = createObject("RoSGNode", "ContentNode")
    maxPerRow = 3
    for i = 0 to (streams.count() - 1) step 1
        if i mod maxPerRow = 0
            row = createObject("RoSGNode", "ContentNode")
        end if
        row.title = ""
        try
            stream = streams[i]
            rowItem = createObject("RoSGNode", "TwitchContentNode")
            rowItem.contentId = stream.node.Id
            rowItem.createdAt = stream.node.createdAt
            rowItem.contentType = "LIVE"
            rowItem.viewersCount = stream.node.viewersCount
            rowItem.contentTitle = stream.node.title
            rowItem.gameDisplayName = stream.node.game.displayName
            rowItem.gameBoxArtUrl = Left(stream.node.game.boxArtUrl, Len(stream.node.game.boxArtUrl) - 20) + "188x250.jpg"
            rowItem.gameId = stream.node.game.Id
            rowItem.gameName = stream.node.game.name
            rowItem.previewImageURL = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", stream.node.broadcaster.login, "320", "180")
            rowItem.streamerDisplayName = stream.node.broadcaster.displayName
            rowItem.streamerLogin = stream.node.broadcaster.login
            rowItem.streamerId = stream.node.broadcaster.id
            rowItem.streamerProfileImageUrl = stream.node.broadcaster.profileImageURL
            row.appendChild(rowItem)
            if row.getChildCount() = maxPerRow
                contentCollection.appendChild(row)
            end if
        catch e
            ? "An error occured fetching live channel"
        end try
    end for
    return contentCollection
end function


sub handleRecommendedSections()
    if m.GetContentTask?.response?.data?.streams <> invalid
        contentCollection = buildContentNodeFromShelves(m.GetContentTask.response.data.streams.edges)
        if m.GetContentTask.response.data.streams.pageInfo <> invalid
            if m.GetContentTask.response.data.streams.pageInfo.hasNextPage
                if m.GetContentTask.response.data.streams.edges.peek().cursor <> invalid
                    m.top.cursor = m.GetContentTask.response.data.streams.edges.peek().cursor
                end if
            else
                m.top.maxedOut = true
            end if
        end if
        updateRowList(contentCollection)
    else
        for each error in m.GetContentTask.response.errors
            ' ? "RESP: "; error.message
        end for
    end if
    m.top.buffer = false
end sub

sub appendMoreRows()
    if m.top.maxedOut = false
        m.GetContentTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
        ' observe content so we can know when feed content will be parsed
        m.GetContentTask.observeField("response", "handleRecommendedSections")
        m.GetContentTask.request = {
            type: "getBrowsePagePopularQuery"
            cursor: m.top.cursor
        }
        m.GetContentTask.functionName = m.GetContentTask.request.type
        m.GetContentTask.control = "run"
    end if
end sub

function buildRowData(contentCollection)
    rowItemSize = []
    showRowLabel = []
    rowHeights = []
    ? "Cat CC: "; contentCollection
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
                rowHeights.push(275)
            else
                rowHeights.push(235)
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
    end for
    return {
        rowHeights: rowHeights
        showRowLabel: showRowLabel
        rowItemSize: rowItemSize
        content: contentCollection
        numRows: contentCollection.getChildCount()
    }
end function

function updateRowList(contentCollection)
    rowData = buildRowData(contentCollection)
    if m.rowlist.content <> invalid
        for i = 0 to (rowData.content.getChildCount() - 1) step 1
            m.rowlist.content.appendChild(rowData.content.getchild(i))
        end for
    else
        m.rowlist.content = rowData.content
    end if
    m.rowlist.numRows = m.rowlist.content.getChildCount()
end function

sub handleItemSelected()
    selectedRow = m.rowlist.content.getchild(m.rowlist.rowItemSelected[0])
    selectedItem = selectedRow.getChild(m.rowlist.rowItemSelected[1])
    m.top.contentSelected = selectedItem
end sub

sub onGetFocus()
    if m.rowlist.focusedChild = invalid
        m.rowlist.setFocus(true)
    else if m.rowlist.focusedchild.id = "exampleRowList"
        m.rowlist.focusedChild.setFocus(true)
        if m.rowlist.rowItemFocused[0] <> invalid
            if m.rowlist.content.getChildCount() > 0
                if (m.rowlist.content.getChildCount() - m.rowlist.rowItemFocused[0]) < 5
                    if m.top.buffer = false
                        m.top.buffer = true
                        appendMoreRows()
                    end if
                end if
            end if
        end if
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