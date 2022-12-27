sub init()
  m.rowList = m.top.findNode("list")
  m.rowList.setFocus(true)
  setListContent()
  m.isMenuOpened = false
  m.openMenuAnimation = m.top.FindNode("openMenuAnimation")
  m.closeMenuAnimation = m.top.FindNode("closeMenuAnimation")
  m.top.observeField("focused", "onGetFocus")
  ' Homecreen Node
  m.HeroScreen = m.top.FindNode("HeroScreen")
  ' DetailsScreen Node with description & video player
  m.DetailsScreen = m.top.FindNode("DetailsScreen")
  ' MenuScreen
  m.MenuScreen = m.top.FindNode("MenuScreen")
  m.WarningDialog = m.top.findNode("WarningDialog")
end sub

sub setListContent()
  print "##SetListContent"
  m.rowList.content = CreateObject("roSGNode", "RowListContent")
  m.rowList.jumpToItem = m.global.menuSelectedIndex
  m.rowList.setFocus(true)
end sub


sub onRowItemSelected()
  print "##onRowItemSelected"; m.rowList.rowItemSelected[0]
  m.global.menuSelectedIndex = m.rowList.rowItemSelected[0]
  closeMenu()
end sub

function onFocused()
  if m.top.focused
    openMenu()
  else
    closeMenu()
  end if

end function

sub openMenu()
  if not m.isMenuOpened
    m.top.visible = true
    m.openMenuAnimation.control = "start"
    m.isMenuOpened = true
    setListContent()
  end if
end sub

sub closeMenu()
  if m.isMenuOpened
    m.closeMenuAnimation.control = "start"
    m.isMenuOpened = false
    setListContent()
  end if
end sub


function onKeyEvent(key, press) as boolean
  ? "Menu Screen >>> onKeyEvent: " press key m.global.menuSelectedIndex
  if key = "ok" and m.rowList.hasFocus()
    if m.global.menuSelectedIndex = 0
      ? "Menu Request for HOME"
      m.HeroScene.setFocus(true)
      return false
    end if
    if m.global.menuSelectedIndex = 1
      ? "Menu Request for MOVIES"
      return true
    end if
    if m.global.menuSelectedIndex = 2
      ? "Menu Request for SHOWS"
      return true
    end if
    if m.global.menuSelectedIndex = 3
      ? "Menu Request for BEST"
      return true
    end if
  end if
  return false
end function

