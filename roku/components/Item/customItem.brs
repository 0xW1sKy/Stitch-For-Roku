sub Init()
    m.Poster = m.top.findNode("poster")
    m.itemTitle = m.top.findNode("itemTitle")
    m.itemShortDescription = m.top.findNode("itemShortDescription")
    m.itemSubTitle = m.top.findNode("itemSubtitle")
end sub

sub itemContentChanged()
    m.Poster.loadDisplayMode = "scaleToZoom"
    if m.top.height < 400 and m.top.width < 400
        m.Poster.loadWidth = 300
        m.Poster.loadHeight = 150
    end if
    updateLayout()
    m.Poster.uri = m.top.itemContent.HDPOSTERURL
    m.itemTitle.text = m.top.itemContent.title
    m.itemShortDescription.text = m.top.itemContent.description
    m.itemSubTitle.text = m.top.itemContent.subtitle
end sub

sub updateLayout()
    if m.top.height > 0 and m.top.width > 0 then
        m.Poster.height = m.top.height
        m.Poster.width = m.top.width
        m.top.translation = [0, 0]
        m.itemShortDescription.width = m.Poster.width
        maxheight = m.top.height - 30
        '  go from bottom up
        m.itemSubTitle.translation = [0, maxheight]
        maxheight = maxheight - m.itemSubTitle.height
        m.itemShortDescription.translation = [0, maxheight]
        maxheight = maxheight - m.itemShortDescription.height
        m.itemTitle.translation = [0, maxheight]
    end if
end sub
