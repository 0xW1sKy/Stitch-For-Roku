sub updateMask()
    m.poster = m.top.findNode("examplePoster")
    m.maskGroup = m.top.findNode("exampleMaskGroup")
    m.maskGroup.maskSize = [(m.poster.width), (m.poster.height)]
    m.maskGroup.maskOffset = [0, 0]
end sub

sub showContent()

end sub