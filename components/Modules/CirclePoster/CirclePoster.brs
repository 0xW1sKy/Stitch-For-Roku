sub init()
    m.poster = m.top.findNode("examplePoster")
    m.maskGroup = m.top.findNode("exampleMaskGroup")
    m.maskGroup.maskSize = [(m.poster.width / 2), (m.poster.height / 2)]
    m.maskGroup.maskOffset = [0, 0]
end sub