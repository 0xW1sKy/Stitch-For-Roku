' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' 1st function that runs for the scene on channel startup
sub init()
  'To see print statements/debug info, telnet on port 8089
  'print "HeroScene.brs - [init]"
  ' HeroScreen Node with RowList
  m.HeroScreen = m.top.FindNode("HeroScreen")
  ' DetailsScreen Node with description & video player
  m.DetailsScreen = m.top.FindNode("DetailsScreen")
  ' The spinning wheel node
  m.LoadingIndicator = m.top.findNode("LoadingIndicator")
  ' Dialog box node. Appears if content can't be loaded
  m.WarningDialog = m.top.findNode("WarningDialog")
  ' Transitions between screens
  m.FadeIn = m.top.findNode("FadeIn")
  m.FadeOut = m.top.findNode("FadeOut")
  ' Set focus to the scene
  m.menuScreen = CreateObject("roSGNode", "MenuScreen")
  m.top.setFocus(true)
  m.top.appendChild(m.menuScreen)
  m.menuScreen.translation = [-100, 0]
end sub

' Hero Grid Content handler fucntion. If content is set, stops the
' loadingIndicator and focuses on GridScreen.
sub OnChangeContent()
  'print "HeroScene.brs - [OnChangeContent]"
  m.loadingIndicator.control = "stop"
  if m.top.content <> invalid
    'Warn the user if there was a bad request
    if m.top.numBadRequests > 0
      m.HeroScreen.visible = "true"
      m.WarningDialog.visible = "true"
      m.WarningDialog.message = (m.top.numBadRequests).toStr() + " request(s) for content failed. Press * or OK or <- to continue."
    else
      m.HeroScreen.visible = "true"
      m.HeroScreen.setFocus(true)
    end if
  else
    m.WarningDialog.visible = "true"
  end if
end sub

' Row item selected handler function.
' On select any item on home scene, show Details node and hide Grid.



' Row item selected handler function.
' On select any item on home scene, show Details node and hide Grid.
sub OnRowItemSelected()
  print "HeroScene.brs - [OnRowItemSelected]"
  m.FadeIn.control = "start"
  m.HeroScreen.visible = "false"
  m.MenuScreen.visible = "false"
  m.DetailsScreen.content = m.HeroScreen.focusedContent
  m.DetailsScreen.setFocus(true)
  m.DetailsScreen.visible = "true"
end sub

' function HandleMenuOption()
'   m.FadeOut.control = "start"
'   m.HeroScreen.visible = "true"
'   m.detailsScreen.visible = "false"
'   m.menuScreen.focused = false
'   m.menuScren.visible = false
'   return true
' end function

' Called when a key on the remote is pressed
function onKeyEvent(key as string, press as boolean) as boolean
  print ">>> HomeScene >> OnkeyEvent >> ";key;" >> Press: "; press
  result = false
  ? "Menu Index: " m.global.menuSelectedIndex
  if press then
    if key = "back"
      print "------ [back pressed] ------"
      if m.menuScreen.visible = true
        if m.menuScreen.focused
          toggleMenu()
          return true
        end if
        m.WarningDialog.visible = "false"
        m.menuScreen.visible = false
        if m.HeroScreen.visible = true
          m.HeroScreen.setFocus(true)
        end if
        if m.detailsScreen.visible = true
          m.detailsScreen.setFocus(true)
        end if
        return true
      end if
      ' if WarningDialog is open
      if m.WarningDialog.visible = true
        m.WarningDialog.visible = "false"
        m.HeroScreen.setFocus(true)
        result = true
        ' if Details opened
      else if m.HeroScreen.visible = false and m.DetailsScreen.videoPlayerVisible = false
        m.FadeOut.control = "start"
        m.HeroScreen.visible = "true"
        m.detailsScreen.visible = "false"
        m.HeroScreen.setFocus(true)
        result = true
        ' if video player opened
      else if m.HeroScreen.visible = false and m.DetailsScreen.videoPlayerVisible = true
        m.DetailsScreen.videoPlayerVisible = false
        result = true
      end if
    else if key = "OK"
      print "------- [ok pressed] -------"
      if m.WarningDialog.visible = true
        m.WarningDialog.visible = "false"
        m.HeroScreen.setFocus(true)
      end if
    else if key = "options"
      print "------ [options pressed] ------"
      toggleMenu()
      ' m.menuScreen.setFocus(true)
    end if
  else
    if key = "OK" and m.global.menuSelectedIndex = 0 and m.menuScreen.focused
      selectHomeScreen()
      result = true
    end if
  end if
  return result
end function

function toggleMenu() as void
  if not m.menuScreen.focused
    m.menuScreen.focused = true
    m.menuScreen.visible = "true"
    m.menuScreen.setFocus(true)
  else
    m.menuScreen.focused = false
    chooseFocus()
  end if
end function

function selectHomeScreen() as void
  if m.WarningDialog.visible
    m.WarningDialog.visible = "false"
    m.HeroScreen.setFocus(true)
    result = true
  end if
  if m.DetailsScreen.videoPlayerVisible = true
    m.DetailsScreen.videoPlayerVisible = false
  end if
  if m.HeroScreen.visible = false and m.DetailsScreen.videoPlayerVisible = false
    m.FadeOut.control = "start"
    m.HeroScreen.visible = "true"
    m.detailsScreen.visible = "false"
    m.HeroScreen.setFocus(true)
  else if m.menuScreen.focused
    m.menuScreen.focused = false
  else if m.detailsScreen.visible
    m.detailsScreen.visible = false
  else if not m.HeroScreen.visible
    m.HeroScreen.visible = true
  end if
  m.HeroScreen.setFocus(true)
end function


function chooseFocus()
  if not m.DetailsScreen.visible
    if m.global.menuSelectedIndex = 0
      selectHomeScreen()
    end if
  else
    m.DetailsScreen.setFocus(true)
  end if

end function