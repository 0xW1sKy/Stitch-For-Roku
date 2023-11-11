sub init()
    ' m.top.observeFieldScoped("text", "onTextChanged")
    m.top.iconUri = ""
    m.top.focusedIconUri = ""
    m.top.showFocusFootprint = false
    m.top.minWidth = 0
    m.top.ellipsizeOnBoundary = false
    m.top.ellipsisText = Chr(160)
end sub

'
' Whenever the text changes, pad both sides with whitespace so we can center the button text
'
sub onTextChanged()
    addSpaceAfter = true
    minChars = m.top.minChars
    if minChars = invalid then minChars = 50
    while m.top.text.Len() < minChars
        if addSpaceAfter = true
            m.top.text = m.top.text + Chr(160)
        else
            m.top.text = Chr(160) + m.top.text
        end if
        addSpaceAfter = not addSpaceAfter
    end while
end sub