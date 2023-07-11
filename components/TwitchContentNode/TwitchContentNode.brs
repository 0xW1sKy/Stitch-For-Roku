function updateViewersDisplay()
    suffix = ""
    if m.top.contentType = "LIVE"
        suffix = tr("Viewers")
    end if
    if m.top.contentType = "VOD"
        suffix = tr("Views")
    end if
    if m.top.contentType = "GAME"
        suffix = tr("Viewers")
    end if
    m.top.viewersDisplay = Substitute("{0} {1}", numberToText(m.top.viewersCount), suffix)
end function

sub numberToText(number as object) as object
    if IsString(number)
        number = number.ToInt()
    end if
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

function IsString(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifString") <> invalid
end function

function IsValid(value as dynamic) as boolean
    return Type(value) <> "<uninitialized>" and value <> invalid
end function