' Copyright Kasper Gammeltoft and other contributors. Licensed under MIT
' https://github.com/KasperGam/EmojiOnRoku/blob/main/LICENSE
sub init()
    m.components = m.top.findNode("layout")
    m.top.observeField("text", "setText")
    m.animation = m.top.findNode("testAnimation")
    ' m.animation.duration = 0
    m.vector = m.top.findNode("testVector2D")
    ' kvArray = [
    '     [0, 0],
    '     [(0 - (m.components.boundingRect().width * 0.25)), m.components.translation[1]],
    '     [(0 - (m.components.boundingRect().width * 0.5)), m.components.translation[1]],
    '     [(0 - (m.components.boundingRect().width * 0.75)), m.components.translation[1]],
    '     [(0 - (m.components.boundingRect().width)), m.components.translation[1]]
    ' ]
    ' m.vector.keyValue = kvArray
    m.top.observeField("color", "updateComponents")
    m.top.observeField("font", "updateComponents")
    m.top.observeField("horizAlign", "updateComponents")
    m.top.observeField("vertAlign", "updateComponents")
    m.top.observeField("width", "updateComponents")
    m.top.observeField("repeatCount", "doScroll")
    m.top.observeField("emojiSize", "updateComponents")
    m.top.observeField("maxWidth", "updateComponents")
    m.timer = m.top.findNode("timer")
    m.timer.observeField("fire", "onTimerFireChange")
    setText()
end sub

sub onTimerFireChange() as void
    m.animation.repeat = false
    m.animation.control = "stop"
    m.components.translation = [0, 0]
    m.timer.control = "stop"
end sub

function doScroll()
    ? "EmojiLabel > DO SCROLL"; m.top.repeatcount
    if m.top.repeatCount <> invalid
        if m.top.repeatCount <> 0
            ? "TEST"
            m.animation.repeat = true
            m.timer.repeat = true
            ? "STARTED"
            ' this sleep is so that when you change from one item to another,
            ' you have enough time to read the first 1-2 words before scrolling.
            sleep(300)
            m.animation.control = "start"
            m.timer.control = "start"
            m.animation.duration = (m.top.width / m.top.maxWidth) * 2
            m.timer.duration = (m.top.width / m.top.maxWidth) * 2
            ' else
            '     m.animation.repeat = false
            '     ' m.animation.control = "stop"
            '     m.animation.duration = 0
            '     m.timer.repeat = false
            '     m.timer.control = "stop"
        else
            m.animation.repeat = false
            m.animation.control = "stop"
            m.components.translation = [0, 0]
            m.timer.control = "stop"
        end if
    end if
end function

' Will update the components if an interface field has changed.
function updateComponents()
    ' Only update components if we are actually rendering text
    if m.top.text <> ""
        width = m.top.width
        height = m.top.height
        hAlign = m.top.horizAlign
        vAlign = m.top.vertAlign
        ' Set the layout group properties to reflect the horiz and vert
        ' aligments
        m.components.horizAlignment = hAlign
        m.components.vertAlignment = vAlign

        ' Set component properties
        comps = getAllComponents()
        totalWidth = 0
        for each comp in comps
            comp.visible = true
            if comp.subtype() = "Label"
                comp.width = 0
                comp.height = height
                comp.vertAlign = vAlign
                comp.color = m.top.color
                if m.top.font <> invalid
                    comp.font = m.top.font
                end if
            else
                ' For posters, use emojiSize first if set
                if m.top.emojiSize > 0
                    comp.width = m.top.emojiSize
                    comp.height = m.top.emojiSize
                    ' Then use height if set
                else if height > 0
                    comp.width = height
                    comp.height = height
                else
                    comp.width = 0
                    comp.height = 0
                end if
            end if
            totalWidth = totalWidth + comp.width
        end for
        width = totalWidth

        ' Check if we need to use ellipsis for this label
        ' checkBoundingWidth()
        boundingWidth = m.components.boundingRect().width
        if width = 0 or boundingWidth > width
            width = boundingWidth
        end if
        innerWidth = 0 - width
        m.top.width = width * 1.1
        m.animation.duration = (m.top.width / m.top.maxWidth)
        m.timer.duration = (m.top.width / m.top.maxWidth)
        m.vector.keyValue = [[0, 0], [innerWidth, 0]]

        if m.top.emojiSize > height
            height = m.top.emojiSize
        end if
        ' Set proper translation for horizontal alignment
        xTranslation = 0
        yTranslation = 0
        ' For center, that is in the middle of the node
        if hAlign = "center"
            xTranslation = width / 2
            ' For right, that is the right edge of the node
        else if hAlign = "right"
            xTranslation = width
        end if

        ' Set proper translation for vertical alignment
        ' For center, use the middle of the node
        if vAlign = "center"
            yTranslation = height / 2
            ' For bottom, use bottom edge of node
        else if vAlign = "bottom"
            yTranslation = height
        end if
        m.top.clippingRect = {
            width: m.top.maxWidth
            height: (m.top.height * 2)
            x: 0
            y: (0 - (m.top.height / 2))
        }
        ' m.top.translation = [m.top.translation[0], m.top.translation[1] + (height / 2)]
        ' m.components.translation = [xTranslation, height]
    end if
end function

' Convenience function to check if we need to truncate the label
function checkBoundingWidth()
    curWidth = 0
    width = m.top.width
    ' Reset previous ellipsis if present
    existingEllipsis = m.components.findNode("ellipsis")
    if existingEllipsis <> invalid
        m.components.removeChild(existingEllipsis)
    end if

    comps = getAllComponents()

    for index = 0 to comps.count() - 1
        comp = comps[index]
        ' If we are already over the width, then don't display any other components
        if curWidth >= width and width > 0
            comp.visible = false
        else
            ' See if this component extends beyond the available width
            compWidth = comp.boundingRect().width
            curWidth += compWidth

            if curWidth > width and width > 0
                diff = curWidth - width

                ' For labels, we might be able to have the label use proper ellipsis by itself
                if comp.subType() = "Label"
                    newCompWidth = compWidth - diff
                    ellipsis = createLabel("…")
                    minWidth = ellipsis.boundingRect().width
                    ' If the label is too short to have an ellipsis itself, insert one here
                    if newCompWidth <= minWidth
                        comp.visible = false
                        ellipsis.id = "ellipsis"
                        m.components.insertChild(ellipsis, index)
                    else
                        ' Label will use ellipsis with explicit width set
                        comp.width = newCompWidth
                    end if
                else
                    ' Replace with ellipsis
                    comp.visible = false
                    ellipsis = createLabel("…")
                    ellipsis.id = "ellipsis"
                    m.components.insertChild(ellipsis, index)
                end if
            end if
        end if
    end for
end function

' function normalizeText(text as string)
'     unicodeRegex = createObject("roRegex", unidecodeRegex(), "m")
'     matches = unicodeRegex.matchAll(text)
'     for each match in matches
'         matchText = match[0]
'         text = text.replace(matchText, textPointName(matchText))
'     end for
'     return text
' end function

' Updates the entire label components with new text.
function setText()
    labelText = m.top.text

    resetComponents()
    if labelText <> ""
        ' Check for emojis in this text
        emojiRegex = createObject("roRegex", regex(), "m")
        matches = emojiRegex.matchAll(labelText)

        for each match in matches
            matchText = match[0]
            ' Create the label representing all text before this match,
            ' if there is any
            loc = labelText.instr(matchText)
            if loc > 0
                leftText = labelText.left(loc)
                m.components.appendChild(createLabel(leftText))
            end if

            ' Get the URI for this emoji and create the poster
            pointURI = emojiPointName(matchText)
            m.components.appendChild(createPoster(pointURI))

            ' Update the remaining text. Set to be text after this emoji.
            labelText = labelText.mid(loc + matchText.len())
        end for

        ' If we have text at the end after the last emoji match, create
        ' a label for that text.
        if labelText <> ""
            m.components.appendChild(createLabel(labelText))
        end if
    end if

    ' Update the components.
    updateComponents()
end function

' Create a new label to display non-emoji text in the label.
function createLabel(withText as string)
    label = createObject("roSGNode", "Label")
    label.text = withText
    label.color = m.top.color
    label.vertAlign = m.top.vertAlign
    label.height = m.top.height
    if m.top.font <> invalid
        label.font = m.top.font
    end if

    return label
end function

' Create a new poster to show an emoji with.
function createPoster(uri as string)
    poster = CreateObject("roSGNode", "Poster")
    poster.uri = uri

    ' Use emoji size first if set
    if m.top.emojiSize > 0
        poster.width = m.top.emojiSize
        poster.height = m.top.emojiSize
        ' Then use height if set
    else if m.top.height > 0
        poster.width = m.top.height
        poster.height = m.top.height
    end if

    return poster
end function

' Returns all components for the current emoji label.
function getAllComponents()
    components = []
    for i = 0 to m.components.getChildCount() - 1
        components.push(m.components.getChild(i))
    end for

    return components
end function

' Removes all child components to reset the layout group.
function resetComponents()
    while m.components.getChildCount() > 0
        m.components.removeChildIndex(0)
    end while
end function


' function onSizeChange()
'     m.top.clippingRect = {
'         width: m.top.maxWidth
'         height: m.top.height
'         x: 0
'         y: -10
'     }
' end function