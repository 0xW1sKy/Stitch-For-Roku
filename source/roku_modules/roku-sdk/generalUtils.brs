'**********************************************************
'**  Video Player Example Application - General Utilities
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'**********************************************************

'******************************************************
'Registry Helper Functions
'******************************************************
function RegRead(key, section = invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key) then return sec.Read(key)
    return invalid
end function

function RegWrite(key, val, section = invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
    sec.Flush() 'commit it
end function

function RegDelete(key, section = invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Delete(key)
    sec.Flush()
end function


'******************************************************
'Insertion Sort
'Will sort an array directly, or use a key function
'******************************************************
sub Sort(A as object, key = invalid as dynamic)

    if type(A) <> "roArray" then return

    if (key = invalid) then
        for i = 1 to A.Count() - 1
            value = A[i]
            j = i - 1
            while j >= 0 and A[j] > value
                A[j + 1] = A[j]
                j = j - 1
            end while
            A[j + 1] = value
        next

    else
        if type(key) <> "Function" then return
        for i = 1 to A.Count() - 1
            valuekey = key(A[i])
            value = A[i]
            j = i - 1
            while j >= 0 and key(A[j]) > valuekey
                A[j + 1] = A[j]
                j = j - 1
            end while
            A[j + 1] = value
        next

    end if

end sub


'******************************************************
'Convert anything to a string
'
'Always returns a string
'******************************************************
function tostr(any)
    ret = AnyToString(any)
    if ret = invalid ret = type(any)
    if ret = invalid ret = "unknown" 'failsafe
    return ret
end function


'******************************************************
'Get a " char as a string
'******************************************************
function Quote()
    q$ = Chr(34)
    return q$
end function


'******************************************************
'isxmlelement
'
'Determine if the given object supports the ifXMLElement interface
'******************************************************
function isxmlelement(obj as dynamic) as boolean
    if obj = invalid return false
    if GetInterface(obj, "ifXMLElement") = invalid return false
    return true
end function


'******************************************************
'islist
'
'Determine if the given object supports the ifList interface
'******************************************************
function islist(obj as dynamic) as boolean
    if obj = invalid return false
    if GetInterface(obj, "ifArray") = invalid return false
    return true
end function


'******************************************************
'isint
'
'Determine if the given object supports the ifInt interface
'******************************************************
function isint(obj as dynamic) as boolean
    if obj = invalid return false
    if GetInterface(obj, "ifInt") = invalid return false
    return true
end function

'******************************************************
' validstr
'
' always return a valid string. if the argument is
' invalid or not a string, return an empty string
'******************************************************
function validstr(obj as dynamic) as string
    if isnonemptystr(obj) return obj
    return ""
end function


'******************************************************
'isstr
'
'Determine if the given object supports the ifString interface
'******************************************************
function isstr(obj as dynamic) as boolean
    if obj = invalid return false
    if GetInterface(obj, "ifString") = invalid return false
    return true
end function


'******************************************************
'isnonemptystr
'
'Determine if the given object supports the ifString interface
'and returns a string of non zero length
'******************************************************
function isnonemptystr(obj)
    if isnullorempty(obj) return false
    return true
end function


'******************************************************
'isnullorempty
'
'Determine if the given object is invalid or supports
'the ifString interface and returns a string of non zero length
'******************************************************
function isnullorempty(obj)
    if obj = invalid return true
    if not isstr(obj) return true
    if Len(obj) = 0 return true
    return false
end function


'******************************************************
'isbool
'
'Determine if the given object supports the ifBoolean interface
'******************************************************
function isbool(obj as dynamic) as boolean
    if obj = invalid return false
    if GetInterface(obj, "ifBoolean") = invalid return false
    return true
end function


'******************************************************
'isfloat
'
'Determine if the given object supports the ifFloat interface
'******************************************************
function isfloat(obj as dynamic) as boolean
    if obj = invalid return false
    if GetInterface(obj, "ifFloat") = invalid return false
    return true
end function


'******************************************************
'strtobool
'
'Convert string to boolean safely. Don't crash
'Looks for certain string values
'******************************************************
function strtobool(obj as dynamic) as boolean
    if obj = invalid return false
    if type(obj) <> "roString" return false
    o = strTrim(obj)
    o = Lcase(o)
    if o = "true" return true
    if o = "t" return true
    if o = "y" return true
    if o = "1" return true
    return false
end function


'******************************************************
'itostr
'
'Convert int to string. This is necessary because
'the builtin Stri(x) prepends whitespace
'******************************************************
function itostr(i as integer) as string
    str = Stri(i)
    return strTrim(str)
end function


'******************************************************
'Get remaining hours from a total seconds
'******************************************************
function hoursLeft(seconds as integer) as integer
    hours% = seconds / 3600
    return hours%
end function


'******************************************************
'Get remaining minutes from a total seconds
'******************************************************
function minutesLeft(seconds as integer) as integer
    hours% = seconds / 3600
    mins% = seconds - (hours% * 3600)
    mins% = mins% / 60
    return mins%
end function


'******************************************************
'Pluralize simple strings like "1 minute" or "2 minutes"
'******************************************************
function Pluralize(val as integer, str as string) as string
    ret = itostr(val) + " " + str
    if val <> 1 ret = ret + "s"
    return ret
end function


'******************************************************
'Trim a string
'******************************************************
function strTrim(str as string) as string
    st = CreateObject("roString")
    st.SetString(str)
    return st.Trim()
end function


'******************************************************
'Tokenize a string. Return roList of strings
'******************************************************
function strTokenize(str as string, delim as string) as object
    st = CreateObject("roString")
    st.SetString(str)
    return st.Tokenize(delim)
end function


'******************************************************
'Replace substrings in a string. Return new string
'******************************************************
function strReplace(basestr as string, oldsub as string, newsub as string) as string
    newstr = ""

    i = 1
    while i <= Len(basestr)
        x = Instr(i, basestr, oldsub)
        if x = 0 then
            newstr = newstr + Mid(basestr, i)
            exit while
        end if

        if x > i then
            newstr = newstr + Mid(basestr, i, x - i)
            i = x
        end if

        newstr = newstr + newsub
        i = i + Len(oldsub)
    end while

    return newstr
end function


'******************************************************
'Get all XML subelements by name
'
'return list of 0 or more elements
'******************************************************
function GetXMLElementsByName(xml as object, name as string) as object
    list = CreateObject("roArray", 100, true)
    if islist(xml.GetBody()) = false return list

    for each e in xml.GetBody()
        if e.GetName() = name then
            list.Push(e)
        end if
    next

    return list
end function


'******************************************************
'Get all XML subelement's string bodies by name
'
'return list of 0 or more strings
'******************************************************
function GetXMLElementBodiesByName(xml as object, name as string) as object
    list = CreateObject("roArray", 100, true)
    if islist(xml.GetBody()) = false return list

    for each e in xml.GetBody()
        if e.GetName() = name then
            b = e.GetBody()
            if type(b) = "roString" list.Push(b)
        end if
    next

    return list
end function


'******************************************************
'Get first XML subelement by name
'
'return invalid if not found, else the element
'******************************************************
function GetFirstXMLElementByName(xml as object, name as string) as dynamic
    if islist(xml.GetBody()) = false return invalid

    for each e in xml.GetBody()
        if e.GetName() = name return e
    next

    return invalid
end function


'******************************************************
'Get first XML subelement's string body by name
'
'return invalid if not found, else the subelement's body string
'******************************************************
function GetFirstXMLElementBodyStringByName(xml as object, name as string) as dynamic
    e = GetFirstXMLElementByName(xml, name)
    if e = invalid return invalid
    if type(e.GetBody()) <> "roString" return invalid
    return e.GetBody()
end function


'******************************************************
'Get the xml element as an integer
'
'return invalid if body not a string, else the integer as converted by strtoi
'******************************************************
function GetXMLBodyAsInteger(xml as object) as dynamic
    if type(xml.GetBody()) <> "roString" return invalid
    return strtoi(xml.GetBody())
end function


'******************************************************
'Parse a string into a roXMLElement
'
'return invalid on error, else the xml object
'******************************************************
function ParseXML(str as string) as dynamic
    if str = invalid return invalid
    xml = CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
end function


'******************************************************
'Get XML sub elements whose bodies are strings into an associative array.
'subelements that are themselves parents are skipped
'namespace :'s are replaced with _'s
'
'So an XML element like...
'
'<blah>
'    <This>abcdefg</This>
'    <Sucks>xyz</Sucks>
'    <sub>
'        <sub2>
'        ....
'        </sub2>
'    </sub>
'    <ns:doh>homer</ns:doh>
'</blah>
'
'returns an AA with:
'
'aa.This = "abcdefg"
'aa.Sucks = "xyz"
'aa.ns_doh = "homer"
'
'return an empty AA if nothing found
'******************************************************
sub GetXMLintoAA(xml as object, aa as object)
    for each e in xml.GetBody()
        body = e.GetBody()
        if type(body) = "roString" then
            name = e.GetName()
            name = strReplace(name, ":", "_")
            aa.AddReplace(name, body)
        end if
    next
end sub




'******************************************************
'Walk an AA and print it
'******************************************************
sub PrintAA(aa as object)
    print "---- AA ----"
    if aa = invalid
        print "invalid"
        return
    else
        cnt = 0
        for each e in aa
            x = aa[e]
            PrintAny(0, e + ": ", aa[e])
            cnt = cnt + 1
        next
        if cnt = 0
            PrintAny(0, "Nothing from for each. Looks like :", aa)
        end if
    end if
    print "------------"
end sub


'******************************************************
'Walk a list and print it
'******************************************************
sub PrintList(list as object)
    print "---- list ----"
    PrintAnyList(0, list)
    print "--------------"
end sub


'******************************************************
'Print an associativearray
'******************************************************
sub PrintAnyAA(depth as integer, aa as object)
    for each e in aa
        x = aa[e]
        PrintAny(depth, e + ": ", aa[e])
    next
end sub


'******************************************************
'Print a list with indent depth
'******************************************************
sub PrintAnyList(depth as integer, list as object)
    i = 0
    for each e in list
        PrintAny(depth, "List(" + itostr(i) + ")= ", e)
        i = i + 1
    next
end sub


'******************************************************
'Print anything
'******************************************************
sub PrintAny(depth as integer, prefix as string, any as dynamic)
    if depth >= 10
        print "**** TOO DEEP " + itostr(5)
        return
    end if
    prefix = string(depth * 2, " ") + prefix
    depth = depth + 1
    str = AnyToString(any)
    if str <> invalid
        print prefix + str
        return
    end if
    if type(any) = "roAssociativeArray"
        print prefix + "(assocarr)..."
        PrintAnyAA(depth, any)
        return
    end if
    if islist(any) = true
        print prefix + "(list of " + itostr(any.Count()) + ")..."
        PrintAnyList(depth, any)
        return
    end if

    print prefix + "?" + type(any) + "?"
end sub


'******************************************************
'Print an object as a string for debugging. If it is
'very long print the first 500 chars.
'******************************************************
sub Dbg(pre as dynamic, o = invalid as dynamic)
    p = AnyToString(pre)
    if p = invalid p = ""
    if o = invalid o = ""
    s = AnyToString(o)
    if s = invalid s = "???: " + type(o)
    if Len(s) > 4000
        s = Left(s, 4000)
    end if
    print p + s
end sub


'******************************************************
'Try to convert anything to a string. Only works on simple items.
'
'Test with this script...
'
'    s$ = "yo1"
'    ss = "yo2"
'    i% = 111
'    ii = 222
'    f! = 333.333
'    ff = 444.444
'    d# = 555.555
'    dd = 555.555
'    bb = true
'
'    so = CreateObject("roString")
'    so.SetString("strobj")
'    io = CreateObject("roInt")
'    io.SetInt(666)
'    tm = CreateObject("roTimespan")
'
'    Dbg("", s$ ) 'call the Dbg() function which calls AnyToString()
'    Dbg("", ss )
'    Dbg("", "yo3")
'    Dbg("", i% )
'    Dbg("", ii )
'    Dbg("", 2222 )
'    Dbg("", f! )
'    Dbg("", ff )
'    Dbg("", 3333.3333 )
'    Dbg("", d# )
'    Dbg("", dd )
'    Dbg("", so )
'    Dbg("", io )
'    Dbg("", bb )
'    Dbg("", true )
'    Dbg("", tm )
'
'try to convert an object to a string. return invalid if can't
'******************************************************
function AnyToString(any as dynamic) as dynamic
    if any = invalid return "invalid"
    if isstr(any) return any
    if isint(any) return itostr(any)
    if isbool(any)
        if any = true return "true"
        return "false"
    end if
    if isfloat(any) return Str(any)
    if type(any) = "roTimespan" return itostr(any.TotalMilliseconds()) + "ms"
    return invalid
end function


'******************************************************
'Walk an XML tree and print it
'******************************************************
sub PrintXML(element as object, depth as integer)
    print tab(depth * 3);"Name: [" + element.GetName() + "]"
    if invalid <> element.GetAttributes() then
        print tab(depth * 3);"Attributes: ";
        for each a in element.GetAttributes()
            print a;"=";left(element.GetAttributes()[a], 4000);
            if element.GetAttributes().IsNext() then print ", ";
        next
        print
    end if

    if element.GetBody() = invalid then
        ' print tab(depth*3);"No Body"
    else if type(element.GetBody()) = "roString" then
        print tab(depth * 3);"Contains string: [" + left(element.GetBody(), 4000) + "]"
    else
        print tab(depth * 3);"Contains list:"
        for each e in element.GetBody()
            PrintXML(e, depth + 1)
        next
    end if
    print
end sub


'******************************************************
'Dump the bytes of a string
'******************************************************
sub DumpString(str as string)
    print "DUMP STRING"
    print "---------------------------"
    print str
    print "---------------------------"
    l = Len(str) - 1
    i = 0
    for i = 0 to l
        c = Mid(str, i)
        val = Asc(c)
        print itostr(val)
    next
    print "---------------------------"
end sub


'******************************************************
'Validate parameter is the correct type
'******************************************************
function validateParam(param as object, paramType as string, functionName as string, allowInvalid = false) as boolean
    if type(param) = paramType then
        return true
    end if

    if allowInvalid = true then
        if type(param) = invalid then
            return true
        end if
    end if

    print "invalid parameter of type "; type(param); " for "; paramType; " in function "; functionName
    return false
end function