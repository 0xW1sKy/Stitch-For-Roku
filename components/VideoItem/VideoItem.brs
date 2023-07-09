
sub init()
    m.itemposter = m.top.findNode("itemPoster")
    m.itemmask = m.top.findNode("itemMask")
    m.itemlabel = m.top.findNode("itemLabel")
    m.liveicon = m.top.findNode("liveIcon")
    m.itemstreamer = m.top.findNode("itemStreamer")
    m.itemCategory = m.top.findNode("itemCategory")
    m.itemViewers = m.top.findNode("itemViewers")
    m.viewsRect = m.top.findNode("viewsRect")

end sub

sub showcontent()
    itemcontent = m.top.itemContent
    m.itemposter.uri = itemcontent.HDPosterUrl
    m.itemlabel.text = itemcontent.title
    m.liveicon.visible = itemcontent.live
    m.itemstreamer.text = itemcontent.secondaryTitle
    m.itemstreamer.color = m.global.constants.colors.hinted.grey9
    m.itemCategory.text = itemcontent.shortDescriptionLine2
    m.itemCategory.color = m.global.constants.colors.hinted.grey9
    m.itemViewers.text = itemcontent.shortDescriptionLine1
    m.viewsRect.height = m.itemViewers.boundingRect().height
    m.viewsRect.width = m.itemViewers.boundingRect().width + 6
end sub

sub showfocus()

end sub

sub showrowfocus()
    ' scale = 1 + (m.top.rowFocusPercent * 0.08)
    ' m.itemposter.scale = [scale, scale]
    ' m.itemlabel.opacity = m.top.rowFocusPercent
    m.itemmask.opacity = 0.75 - (m.top.rowFocusPercent * 0.75)
end sub