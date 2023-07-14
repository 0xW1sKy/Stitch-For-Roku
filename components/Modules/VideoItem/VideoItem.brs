
sub init()
    m.itemposter = m.top.findNode("itemPoster")
    m.itemmask = m.top.findNode("itemMask")
    m.itemlabel = m.top.findNode("itemLabel")
    m.liveicon = m.top.findNode("liveIcon")
    m.itemSubtitle = m.top.findNode("itemSubtitle")
    m.itemThirdTitle = m.top.findNode("itemThirdTitle")
    m.itemViewers = m.top.findNode("itemViewers")
    m.viewsRect = m.top.findNode("viewsRect")

end sub

sub showcontent()
    itemcontent = m.top.itemContent
    if itemcontent.contentType = "GAME"
        m.itemposter.width = 188
        m.itemposter.height = 250
        m.itemposter.loadwidth = 188
        m.itemposter.loadheight = 250
        m.itemlabel.maxwidth = 188
        m.itemlabel.translation = "[0,270]"
        m.itemSubtitle.translation = "[0, 280]"
        m.itemThirdTitle.translation = "[0, 290]"
        m.liveicon.visible = false
        m.itemViewers.visible = false
        m.viewsRect.visible = false
        m.itemSubtitle.text = itemcontent.viewersDisplay
        m.itemposter.uri = itemcontent.gameBoxArtUrl
    end if
    if itemcontent.contentType = "LIVE" or itemcontent.contentType = "VOD"
        m.itemViewers.text = itemcontent.viewersDisplay
        m.viewsRect.height = m.itemViewers.boundingRect().height
        m.viewsRect.width = m.itemViewers.boundingRect().width + 6
        m.itemposter.uri = itemcontent.previewImageURL
        m.itemSubtitle.text = itemcontent.streamerDisplayName
        m.itemThirdTitle.text = itemcontent.gameDisplayName
    end if
    if itemcontent.contentType = "VOD"
        m.liveicon.visible = false
        m.itemThirdTitle.text = itemcontent.gameDisplayName
    end if
    m.itemlabel.text = itemcontent.contentTitle
    m.itemSubtitle.color = m.global.constants.colors.hinted.grey9

    m.itemThirdTitle.color = m.global.constants.colors.hinted.grey9
end sub

sub onGetFocus()
    ? "focused"
    ? "itemLabel: "; m.itemLabel
    if m.top.itemHasFocus
        if m.itemLabel.width > m.itemLabel.maxWidth
            m.itemLabel.repeatCount = -1
        end if
    else
        m.itemLabel.repeatCount = 0
    end if
end sub

sub showrowfocus()
    ' scale = 1 + (m.top.rowFocusPercent * 0.08)
    ' m.itemposter.scale = [scale, scale]
    ' m.itemlabel.opacity = m.top.rowFocusPercent
    m.itemmask.opacity = 0.75 - (m.top.rowFocusPercent * 0.75)
end sub