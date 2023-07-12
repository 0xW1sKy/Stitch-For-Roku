sub init()
    m.top.observeField("focusedChild", "onGetfocus")
    ' m.top.observeField("itemFocused", "onGetFocus")
    m.rowlist = m.top.findNode("exampleRowList")
    m.rowlist.ObserveField("itemSelected", "handleItemSelected")
    m.GetContentTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.GetContentTask.observeField("response", "handleRecommendedSections")
    m.GetContentTask.request = {
        type: "getCategoriesQuery"
    }
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
        rowItem.gameBoxArtUrl = Left(game.node.boxArtUrl, Len(game.node.boxArtUrl) - 20) + "188x250.jpg"
        rowItem.gameId = game.node.Id
        rowItem.gameName = game.node.name

        rowItem.Title = game.node.displayName
        rowItem.secondaryTitle = game.node.viewersCount
        rowItem.HDPosterUrl = Left(game.node.boxArtUrl, Len(game.node.boxArtUrl) - 20) + "188x250.jpg"
        rowItem.ShortDescriptionLine1 = game.node.viewersCount
        row.appendChild(rowItem)
        if row.getChildCount() = 5
            contentCollection.appendChild(row)
        end if
    end for
    return contentCollection
end function


sub handleRecommendedSections()
    if m.GetContentTask.response.data <> invalid and m.GetContentTask.response.data.games <> invalid
        contentCollection = buildContentNodeFromShelves(m.GetContentTask.response.data.games.edges)
    else
        for each error in m.GetContentTask.response.errors
            ? "RESP: "; error.message
        end for
    end if
    updateRowList(contentCollection)
end sub


function updateRowList(contentCollection)
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
    m.rowList.rowHeights = rowHeights
    m.rowlist.showRowLabel = showRowLabel
    m.rowlist.rowItemSize = rowItemSize
    m.rowlist.content = contentCollection
    m.rowlist.numRows = contentCollection.getChildCount()
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
    end if
end function