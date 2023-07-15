sub init()
    m.top.observeField("focusedChild", "onGetfocus")
    ' m.top.observeField("itemFocused", "onGetFocus")
    m.rowlist = m.top.findNode("exampleRowList")
    m.rowlist.ObserveField("itemSelected", "handleItemSelected")
    m.GetContentTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.GetContentTask.observeField("response", "handleRecommendedSections")
    m.GetContentTask.request = {
        type: "getBrowsePageQuery"
    }
    m.GetContentTask.functionName = m.GetContentTask.request.type
    m.GetContentTask.control = "run"
end sub

function buildContentNodeFromShelves(games)
    contentCollection = createObject("RoSGNode", "ContentNode")
    for i = 0 to (games.count() - 1) step 1
        if i mod 5 = 0
            row = createObject("RoSGNode", "ContentNode")
        end if
        row.title = ""
        game = games[i]
        rowItem = createObject("RoSGNode", "TwitchContentNode")
        rowItem.contentId = game.node.Id
        rowItem.contentType = "GAME"
        rowItem.viewersCount = game.node.viewersCount
        rowItem.contentTitle = game.node.displayName
        rowItem.gameDisplayName = game.node.displayName
        rowItem.gameBoxArtUrl = Left(game.node.avatarUrl, Len(game.node.avatarUrl) - 11) + "188x250.jpg"
        rowItem.gameId = game.node.Id
        rowItem.gameName = game.node.name

        rowItem.Title = game.node.displayName
        rowItem.secondaryTitle = game.node.viewersCount
        rowItem.HDPosterUrl = Left(game.node.avatarUrl, Len(game.node.avatarUrl) - 11) + "188x250.jpg"
        rowItem.ShortDescriptionLine1 = game.node.viewersCount
        row.appendChild(rowItem)
        if row.getChildCount() = 5
            contentCollection.appendChild(row)
        end if
    end for
    return contentCollection
end function


sub handleRecommendedSections()
    ? "Pause"
    if m.GetContentTask.response.data <> invalid and m.GetContentTask.response.data.directoriesWithTags <> invalid
        contentCollection = buildContentNodeFromShelves(m.GetContentTask.response.data.directoriesWithTags.edges)
        ? "pause"
        if m.GetContentTask.response.data.directoriesWithTags.pageInfo <> invalid
            if m.GetContentTask.response.data.directoriesWithTags.pageInfo.hasNextPage
                if m.GetContentTask.response.data.directoriesWithTags.edges.peek().cursor <> invalid
                    m.top.cursor = m.GetContentTask.response.data.directoriesWithTags.edges.peek().cursor
                end if
            end if
        end if
    else
        for each error in m.GetContentTask.response.errors
            ? "RESP: "; error.message
        end for
    end if
    updateRowList(contentCollection)
end sub

sub appendMoreRows()
    m.GetContentTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.GetContentTask.observeField("response", "handleRecommendedSections")
    m.GetContentTask.request = {
        type: "getBrowsePageQuery"
        cursor: m.top.cursor
    }
    m.GetContentTask.functionName = m.GetContentTask.request.type
    m.GetContentTask.control = "run"
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
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        ? "Home Scene Key Event: "; key
        if key = "up" or key = "back"
            m.top.backPressed = true
            return true
        end if
        if key = "down"
            appendMoreRows()
            return true
        end if
    end if
end function