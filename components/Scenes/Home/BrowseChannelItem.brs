
sub init()
    ' m.itemThumbnail = m.top.findNode("itemThumbnail")
    ' m.itemTitle = m.top.findNode("itemTitle")
    ' m.itemStreamer = m.top.findNode("itemStreamer")
    ' m.itemCategory = m.top.findNode("itemCategory")
    ' m.itemViewers = m.top.findNode("itemViewers")
    ' m.viewsRect = m.top.findNode("viewsRect")

    ' m.top.observeField("itemHasFocus", "onItemHasFocus")

    m.itemposter = m.top.findNode("itemPoster")
    m.itemmask = m.top.findNode("itemMask")
    m.itemlabel = m.top.findNode("itemLabel")
    m.liveicon = m.top.findNode("liveIcon")
end sub

sub showcontent()
    itemcontent = m.top.itemContent
    m.itemposter.uri = itemcontent.HDPosterUrl
    m.itemlabel.text = itemcontent.title
    m.liveicon.visible = itemcontent.live
end sub

sub showfocus()
    scale = 1 + (m.top.focusPercent * 0.08)
    m.itemposter.scale = [scale, scale]
end sub

sub showrowfocus()
    m.itemmask.opacity = 0.75 - (m.top.rowFocusPercent * 0.75)
    ' m.itemlabel.opacity = m.top.rowFocusPercent
end sub