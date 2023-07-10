sub init()
    m.top.observeField("focusedChild", "onGetfocus")
    ' m.top.observeField("itemFocused", "onGetFocus")
    m.rowlist = m.top.findNode("exampleRowList")
    m.rowlist.content = CreateObject("roSGNode", "RowListContent")
    m.GetContentTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
    ' observe content so we can know when feed content will be parsed
    m.GetContentTask.observeField("response", "handleRecommendedSections")
    m.GetContentTask.request = {
        type: "getHomePageQuery"
    }
end sub

sub handleRecommendedSections()
    contentCollection = createObject("RoSGNode", "ContentNode")
    if m.GetContentTask.response.data <> invalid and m.GetContentTask.response.data.shelves <> invalid
        for each shelf in m.GetContentTask.response.data.shelves.edges
            row = createObject("RoSGNode", "ContentNode")
            node = shelf.node
            ? "NODE TITLE: "; node.title.fallbackLocalizedTitle
            row.title = node.title.fallbackLocalizedTitle
            for each stream in node.content.edges
                streamnode = stream.node
                ' data = {
                '     streamerid = streamnode.broadcaster.id
                '     streamerthumbnail = streamnode.broadcaster.largeProfileImageUrl
                '     login = streamnode.broadcaster.login
                ' }
                try
                    rowItem = createObject("RoSGNode", "ContentNode")
                    rowItem.Title = streamnode.broadcaster.broadcastSettings.title
                    rowItem.secondaryTitle = streamnode.broadcaster.displayName
                    rowItem.HDPosterUrl = Substitute("https://static-cdn.jtvnw.net/previews-ttv/live_user_{0}-{1}x{2}.jpg", streamnode.broadcaster.login, "320", "180")
                    rowItem.ShortDescriptionLine1 = streamnode.viewersCount
                    rowItem.ShortDescriptionLine2 = streamnode.game.displayName
                    row.appendChild(rowItem)
                catch e
                    ?"ERROR: "; e
                end try
            end for
            contentCollection.appendChild(row)
        end for
    else
        for each error in m.GetContentTask.response.errors
            ? "RESP: "; error.message
        end for
    end if
    m.rowlist.content = contentCollection
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
        if key = "up" or key = "back"
            m.top.backPressed = true
            return true
        end if
    end if
end function