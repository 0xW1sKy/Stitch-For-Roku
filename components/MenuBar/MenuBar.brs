sub init()
    m.rowList = m.top.findNode("buttonList")
    m.top.setFocus(true)
end sub

sub onRowItemSelected()
    print "##onRowItemSelected"; m.rowList.rowItemSelected[0]
    m.top.rowItemSelected = m.rowList.rowItemSelected[0]
end sub


sub onRowItemFocused()
    print "##onRowItemFocused"
end sub

sub OnChangeContent()
    print "##onChangeContent"
end sub