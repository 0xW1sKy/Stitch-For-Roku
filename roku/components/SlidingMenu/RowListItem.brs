sub init()
  m.itemlabel = m.top.findNode("itemLabel")
  m.icon = m.top.findNode("itemPoster")
  m.indicator = m.top.findNode("indicatorRect")
  m.transAnimationIn = m.top.findNode("transAnimationIn")
  m.translateInInterp =m.transAnimationIn.findNode("translateInInterp")

  m.transAnimationOut = m.top.findNode("transAnimationOut")
  m.translateOutInterp =m.transAnimationOut.findNode("translateOutInterp")

  m.transAnimationOut.observeField("state", "onTransitionOutAnimationChanged")
  m.isFirstTime = true
  m.itemLabelFont = m.itemlabel.font
  m.itemLabelFontSize = m.itemLabelFont.size
  m.isFocusing = false
  m.isMenuExpanded = false

  m.ITEM_SPACE = 20
  m.INDICATOR_MARGIN_TOP = 10
end sub

sub showcontent()
  m.isFocusing = false
  itemcontent = m.top.itemContent
  m.itemlabel.text = itemcontent.title
  toggleSelectedState()
  setupUI()
  if not m.isFirstTime
    if m.isMenuExpanded
      startCloseMenuAnimation()
    else
      startOpenMenuAnimation()
    end if
  end if
  m.isFirstTime = false
end sub

sub onItemFocused()
  if m.top.rowHasFocus and m.isMenuExpanded and not m.isFocusing 
     focusItem()
  else if  not m.top.rowHasFocus and m.isMenuExpanded and not m.isFocusing 
    unFocusItem()
  end if
  m.isFocusing = false
end sub

sub showRowfocus()
  if m.isMenuExpanded
    fontSize = m.itemLabelFontSize + (m.top.rowFocusPercent * 0.95)
    m.itemlabel.font.size = fontSize
    m.icon.opacity = 0.5 + (m.top.rowFocusPercent * 0.5)
    m.itemlabel.opacity = 0.5 + (m.top.rowFocusPercent * 0.5)
    m.isFocusing = true
  end if
end sub

sub startOpenMenuAnimation()
  m.itemlabel.visible = true
  m.transAnimationIn.duration = (m.top.rowIndex / 20) + m.transAnimationIn.duration
  m.transAnimationIn.control = "start"
  m.isMenuExpanded = true
end sub

sub startCloseMenuAnimation()
  m.isFocusing = false
  m.transAnimationOut.control = "start"
  m.isMenuExpanded = false
end sub

sub onTransitionOutAnimationChanged()
  if m.transAnimationOut.state = "stopped"
    m.itemlabel.visible = false
  end if
end sub

sub focusItem()
  m.itemlabel.font.size = m.itemLabelFontSize + 0.95
  m.icon.opacity = 1
  m.itemlabel.opacity = 1
end sub

sub unFocusItem()
  m.itemlabel.font.size = m.itemLabelFontSize
  m.icon.opacity = 0.5
  m.itemlabel.opacity = 0.5
end sub

sub setupUI()
  m.transAnimationIn.duration = 0.2
  m.transAnimationOut.duration = 0.2
  itemLabelYPos= (m.icon.BoundingRect().height/2) + (m.icon.BoundingRect().y) - (m.itemlabel.BoundingRect().height/3)

  itemLabelXPos = m.icon.BoundingRect().x + (m.icon.BoundingRect().width/2) + m.ITEM_SPACE
  m.translateInInterp.keyValue = [[-300, itemLabelYPos], [itemLabelXPos, itemLabelYPos] ]
  m.translateOutInterp.keyValue = [[itemLabelXPos, itemLabelYPos],[-300, itemLabelYPos] ]

  indicatorYPos= m.icon.BoundingRect().height + m.icon.BoundingRect().y + m.INDICATOR_MARGIN_TOP 
  indicatorWidth = m.icon.BoundingRect().width
  m.indicator.translation = [m.indicator.translation[0],indicatorYPos]
  m.indicator.width = indicatorWidth
end sub

sub toggleSelectedState()
 if m.global.menuSelectedIndex = m.top.rowIndex
  m.indicator.visible = true
  m.indicator.opacity = 1
 else
  m.indicator.visible = false
 end if
end sub

