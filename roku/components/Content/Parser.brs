' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub parserinit()
  print "Parser.brs - [init]"
end sub

' Parses the response string as XML
' The parsing logic will be different for different RSS feeds
sub parseResponse()
  print "Parser.brs - [parseResponse]"
  str = m.top.response.content
  num = m.top.response.num
  ? "got this far..."
  top_and_recommended = getRecommendedStreams()

  'For the 3 rows before the "grid"
  categories = getCategorySearchResults()
  list = [
    {
      Title: "Featured"
      ContentList: select(top_and_recommended, 0, 4)
    }
    {
      Title: "Recommended"
      ContentList: select(top_and_recommended, 5)
    }
    {
      Title: "Categories"
      ContentList: categories
    }
  ]
  'Logic for creating a "row" vs. a "grid"
  contentAA = {}
  content = invalid
  if num = 3
    content = createGrid(top_and_recommended)
  else
    content = createRow(list, num)
  end if

  'Add the newly parsed content row/grid to the cache until everything is ready
  if content <> invalid
    contentAA[num.toStr()] = content
    if m.UriHandler = invalid then m.UriHandler = m.top.getParent()
    m.UriHandler.contentCache.addFields(contentAA)
  else
    print "Error: content was invalid"
  end if
end sub

'Create a row of content
function createRow(list as object, num as integer)
  print "Parser.brs - [createRow]"
  Parent = createObject("RoSGNode", "ContentNode")
  row = createObject("RoSGNode", "ContentNode")
  row.Title = list[num].Title
  for each itemAA in list[num].ContentList
    item = createObject("RoSGNode", "ContentNode")
    AddAndSetFields(item, itemAA)
    row.appendChild(item)
  end for
  Parent.appendChild(row)
  return Parent
end function

'Create a grid of content - simple splitting of a feed to different rows
'with the title of the row hidden.
'Set the for loop parameters to adjust how many columns there
'should be in the grid.
function createGrid(list as object)
  print "Parser.brs - [createGrid]"
  Parent = createObject("RoSGNode", "ContentNode")
  for i = 0 to list.count() step 4
    row = createObject("RoSGNode", "ContentNode")
    if i = 0
      row.Title = "Followed Channels"
    end if
    for j = i to i + 3
      if list[j] <> invalid
        item = createObject("RoSGNode", "ContentNode")
        AddAndSetFields(item, list[j])
        row.appendChild(item)
      end if
    end for
    Parent.appendChild(row)
  end for
  return Parent
end function
