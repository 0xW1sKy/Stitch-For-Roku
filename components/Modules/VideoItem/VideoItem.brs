
sub init()
    m.itemlabel = m.top.findNode("itemLabel")
    m.itemmask = m.top.findNode("itemMask")
end sub

sub showcontent()
    m.timestampRect = m.top.findNode("timestampRect")
    m.timestampLabel = m.top.findNode("timestampLabel")
    m.itemposter = m.top.findNode("itemPoster")
    m.circlePoster = m.top.findNode("circlePoster")
    m.liveicon = m.top.findNode("liveIcon")
    m.itemSubtitle = m.top.findNode("itemSubtitle")
    m.itemThirdTitle = m.top.findNode("itemThirdTitle")
    m.itemViewers = m.top.findNode("itemViewers")
    m.viewsRect = m.top.findNode("viewsRect")
    m.runtimeRect = m.top.findNode("runtimeRect")
    m.runtimeLabel = m.top.findNode("runtimeLabel")
    GlobalSettings()
    if m.top.itemContent.contentType = "GAME"
        GameSettings()
    else if m.top.itemContent.contentType = "LIVE"
        LiveSettings()
    else if m.top.itemContent.contentType = "VOD"
        VodSettings()
    else if m.top.itemContent.contentType = "CLIP"
        ClipSettings()
    else if m.top.itemContent.contentType = "USER"
        UserSettings()
    end if
end sub

sub GlobalSettings()
    m.itemSubtitle.color = m.global.constants.colors.hinted.grey9
    m.itemThirdTitle.color = m.global.constants.colors.hinted.grey9
end sub

sub GameSettings()
    m.runtimeRect.visible = false
    m.runtimeLabel.visible = false
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
    m.timestampLabel.visible = false
    m.timestampRect.visible = false
    m.itemSubtitle.text = m.top.itemContent.viewersDisplay
    m.itemposter.uri = m.top.itemContent.gameBoxArtUrl
    m.itemlabel.text = m.top.itemContent.contentTitle
end sub

sub LiveSettings()
    m.itemViewers.text = m.top.itemContent.viewersDisplay
    m.viewsRect.height = m.itemViewers.boundingRect().height
    m.viewsRect.width = m.itemViewers.boundingRect().width + 6
    m.itemposter.uri = m.top.itemContent.previewImageURL
    m.itemSubtitle.text = m.top.itemContent.streamerDisplayName
    m.itemThirdTitle.text = m.top.itemContent.gameDisplayName
    m.itemlabel.text = m.top.itemContent.contentTitle
    m.timestampLabel.visible = false
    m.timestampRect.visible = false
end sub

sub VodSettings()
    m.liveicon.visible = false
    m.itemViewers.text = m.top.itemContent.viewersDisplay
    m.itemThirdTitle.text = m.top.itemContent.gameDisplayName
    m.viewsRect.height = m.itemViewers.boundingRect().height
    m.viewsRect.width = m.itemViewers.boundingRect().width + 6
    m.timestampLabel.text = m.top.itemContent.relativePublishDate
    m.timestampRect.height = m.timestampLabel.boundingRect().height
    m.timestampRect.width = m.timestampLabel.boundingRect().width + 6
    m.itemposter.uri = m.top.itemContent.previewImageURL
    m.itemSubtitle.text = m.top.itemContent.streamerDisplayName
    m.itemThirdTitle.text = m.top.itemContent.gameDisplayName
    m.itemlabel.text = m.top.itemContent.contentTitle
end sub

sub ClipSettings()
    m.liveicon.visible = false
    m.itemViewers.text = m.top.itemContent.viewersDisplay
    m.itemThirdTitle.text = m.top.itemContent.gameDisplayName
    m.viewsRect.height = m.itemViewers.boundingRect().height
    m.viewsRect.width = m.itemViewers.boundingRect().width + 6
    m.timestampLabel.text = m.top.itemContent.relativePublishDate
    m.timestampRect.height = m.timestampLabel.boundingRect().height
    m.timestampRect.width = m.timestampLabel.boundingRect().width + 6
    m.itemposter.uri = m.top.itemContent.previewImageURL
    m.itemSubtitle.text = m.top.itemContent.streamerDisplayName
    m.itemThirdTitle.text = m.top.itemContent.gameDisplayName
    m.itemlabel.text = m.top.itemContent.contentTitle
end sub

sub UserSettings()
    m.runtimeRect.visible = false
    m.runtimeLabel.visible = false
    m.itemposter.visible = false
    m.circlePoster.uri = m.top.itemContent.streamerProfileImageUrl
    m.circlePoster.visible = true
    m.itemlabel.maxwidth = 150
    m.itemlabel.translation = "[0,160]"
    m.itemSubtitle.translation = "[0, 170]"
    m.itemThirdTitle.translation = "[0, 180]"
    m.liveicon.visible = false
    m.itemViewers.visible = false
    m.viewsRect.visible = false
    m.itemSubtitle.text = m.top.itemContent.followerDisplay
    m.timestampLabel.visible = false
    m.timestampRect.visible = false
    m.itemlabel.text = m.top.itemContent.contentTitle
end sub


sub onGetFocus()
    if m.top.itemHasFocus
        if m.itemLabel.localBoundingRect().width > m.itemLabel.maxWidth
            m.itemLabel.repeatCount = -1
        end if
    else
        m.itemLabel.repeatCount = 0
    end if
end sub

sub showrowfocus()
    m.itemmask.opacity = 0.75 - (m.top.rowFocusPercent * 0.75)
end sub