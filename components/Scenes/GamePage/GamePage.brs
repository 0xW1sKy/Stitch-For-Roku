sub init()
    m.top.backgroundColor = m.global.constants.colors.hinted.grey1
    m.top.observeField("focusedChild", "onGetfocus")
    ' m.top.observeField("itemFocused", "onGetFocus")
    m.rowlist = m.top.findNode("exampleRowList")
    m.rowlist.ObserveField("itemSelected", "handleItemSelected")
end sub

sub updatePage()
    m.top.pageTitle = m.top.contentRequested.gameName
    m.GetContentTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.GetContentTask.observeField("response", "handleRecommendedSections")
    m.GetContentTask.request = {
        type: "getGameDirectoryQuery"
        params: {
            gameAlias: m.top.contentRequested.gameName
        }
    }
end sub

function buildContentNodeFromShelves(streams)
    itemsPerRow = 3
    contentCollection = createObject("RoSGNode", "ContentNode")
    for i = 0 to (streams.count() - 1) step 1
        if i mod itemsPerRow = 0
            row = createObject("RoSGNode", "ContentNode")
        end if
        stream = streams[i]
        row.title = ""
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
        ' rowItem.gameDisplayName = stream.node.game.displayName
        ' rowItem.Title = stream.node.broadcaster.broadcastsettings.title
        ' rowItem.secondaryTitle = stream.node.broadcaster.displayName
        ' rowItem.HDPosterUrl = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", stream.node.broadcaster.login, "320", "180")
        ' rowItem.ShortDescriptionLine1 = stream.node.viewersCount
        ' rowItem.ShortDescriptionLine2 = stream.node.game.displayName
        row.appendChild(rowItem)
        if row.getChildCount() = itemsPerRow
            contentCollection.appendChild(row)
        end if
    end for
    return contentCollection
end function


function updateRowList(contentCollection)
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


sub handleRecommendedSections()
    contentCollection = buildContentNodeFromShelves(m.GetContentTask.response.data.game.streams.edges)
    updateRowList(contentCollection)
end sub

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
        if key = "back"
            m.top.backPressed = true
            return true
        end if
    end if
end function