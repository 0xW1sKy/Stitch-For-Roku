' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

'setting top interfaces
sub Init()
  print "Description.brs - [Init]"
  m.top.Title = m.top.findNode("Title")
  m.top.Description = m.top.findNode("Description")
  m.top.ReleaseDate = m.top.findNode("ReleaseDate")
end sub

' Content change handler
' All fields population
sub OnContentChanged()
  print "Description.brs - [OnContentChanged]"
  item = m.top.content
  title = item.title.toStr()
  if title <> invalid then
    m.top.Title.text = title.toStr()
  end if

  value = item.description
  if value <> invalid then
    if value.toStr() <> "" then
      m.top.Description.text = value.toStr()
    else
      m.top.Description.text = "No description"
    end if
  end if

  value = item.ReleaseDate
  if value <> invalid then
    if value <> ""
      m.top.ReleaseDate.text = value.toStr()
    else
      m.top.ReleaseDate.text = "0 Viewers"
    end if
  end if
end sub
