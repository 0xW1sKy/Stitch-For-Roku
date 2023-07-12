sub init()
     m.itemMask = m.top.findNode("maskId")
     m.streamerName = m.top.findNode("streamerName")
     m.streamerProfile = m.top.findNode("streamerProfile")
     m.gameId = m.top.findNode("gameId")
     m.selectionIndicator = m.top.findNode("selectionIndicator")
     m.selected = m.top.findNode("selected")
end sub

sub handleBoundingWidth()
     if m.streamerName.localBoundingRect().width >= m.gameId.localBoundingRect().width
          m.selected.width = m.streamerName.localBoundingRect().width + 36
     else
          m.selected.width = m.gameId.localBoundingRect().width + 36
     end if
end sub
