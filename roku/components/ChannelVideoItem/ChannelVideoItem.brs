sub init()
    m.itemThumbnail = m.top.findNode("itemThumbnail")
    m.itemTitle = m.top.findNode("itemTitle")
    m.itemStreamer = m.top.findNode("itemStreamer")
    m.itemCategory = m.top.findNode("itemCategory")
    'm.itemViewers = m.top.findNode("itemViewers")
    m.itemDuration = m.top.findNode("itemDuration")
    m.itemPosted = m.top.findNode("itemPosted")
    m.viewsRect = m.top.findNode("viewsRect")

    m.top.observeField("itemHasFocus", "onItemHasFocus")
end sub

sub onItemHasFocus()
    ? "Channel Video Item > onItemHasFocus"
    if m.top.itemHasFocus
        m.itemTitle.repeatCount = -1
    else
        m.itemTitle.repeatCount = 0
    end if
end sub

sub showContent()
    ' ? "Channel Video Item > showContent"
    itemContent = m.top.itemContent
    m.itemThumbnail.uri = itemContent.HDPosterUrl
    m.itemTitle.text = itemContent.Title
    m.itemStreamer.text = itemContent.Description
    'm.itemCategory.text = itemContent.Categories
    'm.itemViewers.text = itemContent.ShortDescriptionLine2
    m.itemDuration.text = itemContent.Categories[0]
    m.itemPosted.text = itemContent.ReleaseDate
    m.viewsRect.width = m.itemDuration.localBoundingRect().width + 14
    m.viewsRect.height = m.itemDuration.localBoundingRect().height
end sub