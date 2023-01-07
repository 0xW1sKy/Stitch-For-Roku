' This source code is derived from the Twemoji project, found here https://github.com/twitter/twemoji
' Copyright (c) 2018 Twitter, Inc and other contributors

' Permission is hereby granted, free of charge, to any person obtaining a copy
' of this software and associated documentation files (the "Software"), to deal
' in the Software without restriction, including without limitation the rights
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
' copies of the Software, and to permit persons to whom the Software is
' furnished to do so, subject to the following conditions:

' The above copyright notice and this permission notice shall be included in
' all copies or substantial portions of the Software.

' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
' OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
' THE SOFTWARE.

' Convinence Function that will strip uneeded mofifiers, get the correct code point,
' and then return the URI needed, all from the raw text string for the emoji.
' Parameter: rawText: The raw text of the emoji.
' Returns: The URI needed to display this emoji in a poster node from the Twemoji project.

function emojiPointName(rawText as string) as string
    zeroWidth = &h200D
    unicodeSurrogates = []
    foundZeroWidth = false
    for i = 0 to rawText.len() - 1
        unicodeSurrogates.push(asc(rawText.mid(i, 1)))
        if unicodeSurrogates[i] = zeroWidth
            foundZeroWidth = true
        end if
    end for

    codePoint = ""
    if foundZeroWidth
        codePoint = toCodePoint(unicodeSurrogates)
    else
        ' Remove modifiers for FEOF since there is not a zero width modifier
        removeModsRegex = createObject("roRegex", "\x{FE0F}", "")
        trimmedText = removeModsRegex.replace(rawText, "")
        unicodeSurrogates = []
        for i = 0 to rawText.len() - 1
            unicodeSurrogates.push(asc(rawText.mid(i, 1)))
        end for

        codePoint = toCodePoint(unicodeSurrogates)
    end if

    return toURI(codePoint)
end function

' Takes in an array containing the unicode surrogates (2 bytes in stream) for an
' Emoji character, and returns the code point needed.
' Parameter: unicodeSurrogates: The two byte surrogates for the unicode emoji character
' Parameter: Separator- for complex characters, such as modifiers and combined emojis, the
' code points will be separated by this separator. Defaults to "-".
function toCodePoint(unicodeSurrogates as object, sep = "-" as string)
    r = []
    c = 0
    p = 0
    i = 0
    while i < unicodeSurrogates.count()
        c = unicodeSurrogates[i]
        i++
        if p <> 0
            r.push(strI((&h10000 + ((p - &hD800) << 10) + (c - &hDC00)), 16))
            p = 0
        else if &hD800 <= c and c <= &hDBFF
            p = c
        else
            r.push(strI(c, 16))
        end if
    end while
    return lCase(r.join(sep))
end function

' Convience function to format and return the correct URI to use for a specified emoji.
' Parameter: pointName: The point name for the desired emoji.
' Parameter: size: The size for the emoji. Default is "72x72"
' Returns: Returns valid URI to retreive the specified emoji from the Twemoji project.
function toURI(pointName as string, size = "72x72" as string) as string
    template = "https://twemoji.maxcdn.com/v/latest/{size}/{point}.png"

    return template.replace("{size}", size).replace("{point}", pointName)
end function