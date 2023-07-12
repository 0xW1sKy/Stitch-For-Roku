function updateViewersDisplay()
    suffix = ""
    if m.top.contentType = "LIVE"
        suffix = tr("Viewers")
    end if
    if m.top.contentType = "VOD"
        suffix = tr("Views")
    end if
    if m.top.contentType = "GAME"
        suffix = tr("Viewers")
    end if
    m.top.viewersDisplay = Substitute("{0} {1}", numberToText(m.top.viewersCount), suffix)
end function

sub updateRelativePublishDate()
    m.top.relativePublishDate = getRelativeTimePublished(m.top.datePublished)
end sub
