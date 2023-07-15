function isNodeEvent(msg, field as string) as boolean
    return type(msg) = "roSGNodeEvent" and msg.getField() = field
end function


function getMsgPicker(msg, subnode = "" as string) as object
    node = msg.getRoSGNode()
    ' Subnode allows for handling alias messages
    if subnode <> ""
        node = node.findNode(subnode)
    end if
    coords = node.rowItemSelected
    target = node.content.getChild(coords[0]).getChild(coords[1])
    return target
end function

function getButton(msg, subnode = "buttons" as string) as object
    buttons = msg.getRoSGNode().findNode(subnode)
    if buttons = invalid then return invalid
    active_button = buttons.focusedChild
    return active_button
end function

function leftPad(base as string, fill as string, length as integer) as string
    while len(base) < length
        base = fill + base
    end while
    return base
end function

function ticksToHuman(ticks as longinteger) as string
    totalSeconds = int(ticks / 10000000)
    hours = stri(int(totalSeconds / 3600)).trim()
    minutes = stri(int((totalSeconds - (val(hours) * 3600)) / 60)).trim()
    seconds = stri(totalSeconds - (val(hours) * 3600) - (val(minutes) * 60)).trim()
    if val(hours) > 0 and val(minutes) < 10 then minutes = "0" + minutes
    if val(seconds) < 10 then seconds = "0" + seconds
    r = ""
    if val(hours) > 0 then r = hours + ":"
    r = r + minutes + ":" + seconds
    return r
end function

' Format time as 12 or 24 hour format based on system clock setting
function formatTime(time) as string
    hours = time.getHours()
    minHourDigits = 1
    di = CreateObject("roDeviceInfo")
    if di.GetClockFormat() = "12h"
        meridian = "AM"
        if hours = 0
            hours = 12
            meridian = "AM"
        else if hours = 12
            hours = 12
            meridian = "PM"
        else if hours > 12
            hours = hours - 12
            meridian = "PM"
        end if
    else
        ' For 24hr Clock, no meridian and pad hours to 2 digits
        minHourDigits = 2
        meridian = ""
    end if

    return Substitute("{0}:{1} {2}", leftPad(stri(hours).trim(), "0", minHourDigits), leftPad(stri(time.getMinutes()).trim(), "0", 2), meridian)

end function

function div_ceiling(a as integer, b as integer) as integer
    if a < b then return 1
    if int(a / b) = a / b
        return a / b
    end if
    return a / b + 1
end function

'Returns the item selected or -1 on backpress or other unhandled closure of dialog.
function get_dialog_result(dialog, port)
    while dialog <> invalid
        msg = wait(0, port)
        if isNodeEvent(msg, "backPressed")
            return -1
        else if isNodeEvent(msg, "itemSelected")
            return dialog.findNode("optionList").itemSelected
        end if
    end while
    'Dialog has closed outside of this loop, return -1 for failure
    return -1
end function

function lastFocusedChild(obj as object) as object
    if isValid(obj)
        if isValid(obj.focusedChild) and isValid(obj.focusedChild.focusedChild) and LCase(obj.focusedChild.focusedChild.subType()) = "tvepisodes"
            if isValid(obj.focusedChild.focusedChild.lastFocus)
                return obj.focusedChild.focusedChild.lastFocus
            end if
        end if

        child = obj
        for i = 0 to obj.getChildCount()
            if isValid(obj.focusedChild)
                child = child.focusedChild
            end if
        end for
        return child
    else
        return invalid
    end if
end function

sub setFieldTextValue(field, value)
    node = m.top.findNode(field)
    if node = invalid or value = invalid then return

    ' Handle non strings... Which _shouldn't_ happen, but hey
    if type(value) = "roInt" or type(value) = "Integer"
        value = str(value).trim()
    else if type(value) = "roFloat" or type(value) = "Float"
        value = str(value).trim()
    else if type(value) <> "roString" and type(value) <> "String"
        value = ""
    end if

    node.text = value
end sub

' Returns whether or not passed value is valid
function isValid(input) as boolean
    return input <> invalid
end function

' Returns whether or not passed value is valid and not empty
' Accepts a string, or any countable type (arrays and lists)
function isValidAndNotEmpty(input) as boolean
    if not isValid(input) then return false
    ' Use roAssociativeArray instead of list so we get access to the doesExist() method
    countableTypes = { "array": 1, "list": 1, "roarray": 1, "roassociativearray": 1, "rolist": 1 }
    inputType = LCase(type(input))
    if inputType = "string" or inputType = "rostring"
        trimmedInput = input.trim()
        return trimmedInput <> ""
    else if countableTypes.doesExist(inputType)
        return input.count() > 0
    else
        print "Called isValidAndNotEmpty() with invalid type: ", inputType
        return false
    end if
end function

' Rounds number to nearest integer
function roundNumber(f as float) as integer
    ' BrightScript only has a "floor" round
    ' This compares floor to floor + 1 to find which is closer
    m = int(f)
    n = m + 1
    x = abs(f - m)
    y = abs(f - n)
    if y > x
        return m
    else
        return n
    end if
end function

' Converts ticks to minutes
function getMinutes(ticks) as integer
    ' A tick is .1ms, so 1/10,000,000 for ticks to seconds,
    ' then 1/60 for seconds to minutes... 1/600,000,000
    return roundNumber(ticks / 600000000.0)
end function

'
' Returns whether or not a version number (e.g. 10.7.7) is greater or equal
' to some minimum version allowed (e.g. 10.8.0)
function versionChecker(versionToCheck as string, minVersionAccepted as string)
    leftHand = CreateObject("roLongInteger")
    rightHand = CreateObject("roLongInteger")

    regEx = CreateObject("roRegex", "\.", "")
    version = regEx.Split(versionToCheck)
    if version.Count() < 3
        for i = version.Count() to 3 step 1
            version.AddTail("0")
        end for
    end if

    minVersion = regEx.Split(minVersionAccepted)
    if minVersion.Count() < 3
        for i = minVersion.Count() to 3 step 1
            minVersion.AddTail("0")
        end for
    end if

    leftHand = (version[0].ToInt() * 10000) + (version[1].ToInt() * 100) + (version[2].ToInt() * 10)
    rightHand = (minVersion[0].ToInt() * 10000) + (minVersion[1].ToInt() * 100) + (minVersion[2].ToInt() * 10)

    return leftHand >= rightHand
end function

function findNodeBySubtype(node, subtype)
    foundNodes = []

    for each child in node.getChildren(-1, 0)
        if lcase(child.subtype()) = "group"
            return findNodeBySubtype(child, subtype)
        end if

        if lcase(child.subtype()) = lcase(subtype)
            foundNodes.push({
                node: child,
                parent: node
            })
        end if
    end for

    return foundNodes
end function

function AssocArrayEqual(Array1 as object, Array2 as object) as boolean
    if not isValid(Array1) or not isValid(Array2)
        return false
    end if

    if not Array1.Count() = Array2.Count()
        return false
    end if

    for each key in Array1
        if not Array2.DoesExist(key)
            return false
        end if

        if Array1[key] <> Array2[key]
            return false
        end if
    end for

    return true
end function

' Search string array for search value. Return if it's found
function inArray(haystack, needle) as boolean
    valueToFind = needle

    if LCase(type(valueToFind)) <> "rostring" and LCase(type(valueToFind)) <> "string"
        valueToFind = str(needle)
    end if

    valueToFind = lcase(valueToFind)

    for each item in haystack
        if lcase(item) = valueToFind then return true
    end for

    return false
end function

function toString(input, replaceInvalid = false) as string
    if LCase(type(input)) = "rostring" or LCase(type(input)) = "string"
        return input
    end if

    if replaceInvalid
        if input = invalid
            return ""
        end if
    end if
    return str(input)
end function

function select(arr, start = invalid, finish = invalid, step_ = 1):
    if step_ = 0 then print "ValueError: slice step cannot be zero" : stop
    if start = invalid then if step_ > 0 then start = 0 else start = arr.count() - 1
    if finish = invalid then if step_ > 0 then finish = arr.count() - 1 else finish = 0
    if start < 0 then start = arr.count() + start 'negative counts backwards from the end
    if finish < 0 then finish = arr.count() + finish
    res = []
    for i = start to finish step step_:
        res.push(arr[i])
    end for
    return res
end function


' Helper function to add and set fields of a content node
function AddAndSetFields(node as object, aa as object)
    'This gets called for every content node -- no logging since it's pretty verbose
    addFields = {}
    setFields = {}
    for each field in aa
        if node.hasField(field)
            setFields[field] = aa[field]
        else
            addFields[field] = aa[field]
        end if
    end for
    node.setFields(setFields)
    node.addFields(addFields)
end function


'Create a row of content
function createRow(list as object, num as integer)
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
    Parent = createObject("RoSGNode", "ContentNode")
    for i = 0 to list.count() step 5
        row = createObject("RoSGNode", "ContentNode")
        if i = 0
            row.Title = "Followed Channels"
        end if
        for j = i to i + 4
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


sub numberToText(number as object) as object
    result = ""
    if number < 1000
        result = number.toStr()
    else if number < 1000 * 1000
        n = (number / 1000).toStr()
        ' Regex: any numbers with a dot and a decimal different from 0 OR any amount of numbers (stops at the dot). In that order.
        r = CreateObject("roRegex", "([0-9]+\.[1-9])|([0-9]+)", "")
        result = r.Match(n)[0] + "K"
    else
        n = (number / 1000 * 1000).toStr()
        r = CreateObject("roRegex", "([0-9]+\.[1-9])|([0-9]+)", "")
        result = r.Match(n)[0] + "M"
    end if
    return result
end sub


function getRelativeTimePublished(timePublished as string) as string
    secondsSincePublished = createObject("roDateTime")
    secondsSincePublished.FromISO8601String(timePublished)
    currentTime = createObject("roDateTime").AsSeconds()
    elapsedTime = currentTime - secondsSincePublished.AsSeconds()

    elapsedTime = Int(elapsedTime / 60)
    if elapsedTime < 60
        if elapsedTime = 1
            return "1 minute ago"
        else
            return elapsedTime.ToStr() + " minutes ago"
        end if
    end if

    elapsedTime = Int(elapsedTime / 60)
    if elapsedTime < 24
        if elapsedTime = 1
            return "1 hour ago"
        else
            return elapsedTime.ToStr() + " hours ago"
        end if
    end if

    elapsedTime = Int(elapsedTime / 24)
    if elapsedTime < 30
        if elapsedTime = 1
            return "1 day ago"
        else
            return elapsedTime.ToStr() + " days ago"
        end if
    end if

    elapsedTime = Int(elapsedTime / 30)
    if elapsedTime < 12
        if elapsedTime = 1
            return "Last month"
        else
            return elapsedTime.ToStr() + " months ago"
        end if
    end if

    elapsedTime = Int(elapsedTime / 12)
    if elapsedTime = 1
        return "1 year ago"
    else
        return elapsedTime.ToStr() + " years ago"
    end if

end function