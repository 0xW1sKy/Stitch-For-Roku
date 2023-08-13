sub init()
    m.chatPanel = m.top.findNode("chatPanel")
    m.maskgroup = m.top.findNode("maskGroup")
    setChatPanelSize()
    setSizingParameters()
    ' determines how far down the screen the first message will appear
    ' set to 700 to have first message at bottom of screen.
    m.translation = m.lower_bound - m.line_height
end sub

function updatePanelTranslation()
    ' m.chatPanel.translation = [(m.top.width * 3), 0]
    setChatPanelSize()
    setSizingParameters()
    m.maskGroup.maskSize = [(m.chatpanel.width * m.global.constants.maskScaleFactor), (m.chatPanel.height * m.global.constants.maskScaleFactor)]
    m.maskGroup.maskOffset = [0, 0]
end function

function setSizingParameters()
    '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    ' Size and Spacing Settings
    '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    m.left_bound = m.font_size / 2
    m.right_bound = m.chatPanel.width - m.font_size
    m.badge_size = (m.font_size * 1.6)
    m.line_gap = m.font_size * 0.25
    m.line_height = (m.font_size * 1.4)

    m.message_height = (m.badge_size * 1.8)

    m.lower_bound = m.chatPanel.height - m.message_height
    '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
end function

function setChatPanelSize()
    m.font_size = m.top.fontSize
    ' m.chatPanel.width = m.global.constants.screenWidth
    ' m.chatPanel.height = m.global.constants.screenHeight
    m.translation = m.chatPanel.height - m.font_size
    m.lower_bound = m.chatPanel.height - m.font_size
    m.right_bound = m.chatPanel.width - m.font_size
    m.upper_bound = 0 - (m.chatPanel.height - m.font_size)
end function

sub onInvisible()
    if m.top.visible = false
        m.chat.control = "stop"
    else
        m.chat.control = "run"
    end if
end sub

sub stopJobs()
    if m.chat <> invalid
        m.chat.control = "stop"
    end if
    if m.EmoteJob <> invalid
        m.EmoteJob.control = "stop"
    end if
end sub

sub onVideoChange()
    if not m.top.control
        m.chat.control = "stop"
        m.top.control = true
    end if
end sub

sub onEnterChannel()
    ' ? "Chat >> onEnterChannel > " m.top.channel
    if get_user_setting("ChatWebOption", "true") = "true"
        m.chat = m.top.findnode("ChatJob")
        m.chat.forceLive = m.top.forceLive
        m.chat.observeField("nextComment", "onNewComment")
        m.chat.observeField("clientComment", "onNewComment")
        m.chat.channel = m.top.channel
        m.chat.control = "stop"
        m.chat.control = "run"
    end if
    m.EmoteJob = m.top.findnode("EmoteJob")
    m.EmoteJob.channel_id = m.top.channel_id
    m.EmoteJob.channel = m.top.channel
    m.EmoteJob.control = "run"
end sub

sub extractMessage(section) as object
    m.userstate_change = false
    words = section.Split(" ")
    if words[2] = "USERSTATE"
        m.userstate_change = true
    end if
    message = ""
    for i = 4 to words.Count() - 1
        message += words[i] + " "
    end for
    return message
end sub

function buildBadges(badges)
    group = createObject("roSGNode", "Group")
    group.visible = true
    badge_translation = 0
    for each badge in badges
        if badge <> invalid and badge <> ""
            if m.global.twitchBadges <> invalid
                if m.global.twitchBadges[badge] <> invalid
                    poster = createObject("roSGNode", "Poster")
                    poster.uri = m.global.twitchBadges[badge]
                    poster.width = m.badge_size
                    poster.height = m.badge_size
                    poster.visible = true
                    poster.translation = [badge_translation, 0]
                    group.appendChild(poster)
                    badge_translation += (m.badge_size + (m.badge_size / 6))
                end if
            end if
        end if
    end for
    return group
end function

function buildEmote(posterUri)
    poster = createObject("roSGNode", "Poster")
    poster.uri = posterUri
    poster.visible = true
    bounding_rect = poster.localBoundingRect()
    poster_width = bounding_rect.width
    poster_height = bounding_rect.height
    ratio = 1
    if poster_height <> 0
        ratio = m.badge_size / poster_height
        poster.height = (poster_height * ratio)
    else
        poster.height = m.badge_size
    end if
    if poster_width <> 0
        poster.width = (poster_width * ratio)
    else
        poster.width = m.badge_size
    end if
    return poster
end function

function buildUsername(display_name, color)
    username = createObject("roSGNode", "SimpleLabel")
    username.text = display_name
    if color = ""
        color = "FFFFFF"
    end if
    username.color = "0x" + color + "FF"
    username.visible = true
    username.fontSize = m.font_size
    username.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Bold.otf"
    return username
end function

function buildColon()
    colon = createObject("roSGNode", "SimpleLabel")
    colon.fontSize = m.font_size
    colon.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
    colon.color = "0xFFFFFFFF"
    colon.visible = true
    colon.text = ": "
    return colon
end function




function wordOrImage(word, isUrl = false)
    if m.global.emoteCache.DoesExist(word)
        return buildEmote(m.global.emoteCache[word])
    else
        message_text = createObject("roSGNode", "SimpleLabel")
        message_text.fontSize = m.font_size
        message_text.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
        message_text.visible = true
        message_text.text = word + chr(20)
        if isUrl
            message_text.color = m.global.constants.colors.twitch.purple9
        end if
        return message_text
    end if
end function

'

function buildMessage(message, x_translation, emote_set, username_translation)
    message_group = createObject("roSGNode", "Group")
    words = message.Split(" ")
    line_available_space = m.right_bound - x_translation
    current_line = 0
    for each word in words
        if asc(word.right(1)) = 917504
            word = word.mid(0, (word.len() - 1))
            ? "Found invalid character"
        end if
        ' Make room for emotes just in case
        urlRegex = createObject("roRegex", "https?:\/\/[a-zA-Z0-9\.]+", "i")
        isUrl = urlRegex.IsMatch(word)

        block = wordOrImage(word, isUrl)
        block_width = block.localBoundingRect().width
        '* '  "Useful for Debug"
        ' ? "left_bound: " m.left_bound
        ' ? "right_bound: " m.right_bound
        ' ? "x_translation: " x_translation
        ' ? "Block Width: " block_width
        ' ? "line_available_space: " line_available_space
        if block_width > m.right_bound
            ? "break it up!"
            block = createObject("roSGNode", "Group")
            charTranslation = 0
            charLine = 0
            charLineAvailableSpace = m.right_bound - x_translation
            for each char in word.split("")
                charNode = createObject("roSGNode", "SimpleLabel")
                charNode.fontSize = m.font_size
                charNode.fontUri = "pkg:/fonts/KlokanTechNotoSansCJK-Regular.otf"
                charNode.visible = true
                charNode.text = char
                if isUrl
                    charNode.color = m.global.constants.colors.twitch.purple9
                end if
                charWidth = charNode.localBoundingRect().width
                if (charLineAvailableSpace - charWidth) < 0
                    charLine++
                    charLineAvailableSpace = m.right_bound - m.left_bound
                    charTranslation = 0 - x_translation + m.left_bound
                end if
                charNode.translation = [(charTranslation), (charLine * (m.badge_size + m.line_gap))]
                charLineAvailableSpace -= charWidth
                charTranslation += charWidth
                block.appendChild(charNode)
            end for
            block_width = block.localBoundingRect().width
        else if line_available_space - block_width <= 0
            current_line++
            line_available_space = m.right_bound - m.left_bound
        end if
        block.translation = [(m.right_bound - line_available_space), (current_line * (m.badge_size + m.line_gap))]
        if block_width = 0
            block_width = m.badge_size
        end if
        line_available_space -= block_width
        message_group.appendChild(block)
    end for
    return message_group
end function

sub onNewComment()
    m.chat.readyForNextComment = false
    comment = m.chat.nextComment.Split(";")
    posteruri = invalid
    display_name = ""
    message = ""
    color = ""
    badges = []
    emote_set = {}
    for each section in comment
        if Left(section, 9) = "user-type"
            temp = extractMessage(section)
            temp = Left(temp, Len(temp) - 3)
            message = Right(temp, Len(temp) - 1)
        else if Left(section, 12) = "display-name"
            display_name = Right(section, Len(section) - 13)
        else if Left(section, 5) = "color"
            color = Right(section, Len(section) - 7)
        else if Left(section, 6) = "badges"
            badges = Right(section, Len(section) - 7).Split(",")
        else if Left(section, 6) = "emotes"
            emotes = Right(section, Len(section) - 7).Split("/")
            for each emote in emotes
                if emote <> ""
                    temp = emote.Split(":")
                    key = temp[0]
                    value = {}
                    value.starts = []
                    for each interval in temp[1].Split(",")
                        range = interval.Split("-")
                        value.starts.Push(Val(range[0]))
                        value.length = Val(range[1]) - Val(range[0]) + 1
                    end for
                    emote_set[key] = value
                end if
            end for
        end if
    end for
    quoteRegex = createObject("roRegex", "[\x{2018}\x{2019}]", "")
    message = quoteRegex.replace(message, "'")
    ' This Section grabs missing emotes on the fly... not sure if there is a better way to optimize.
    for each emoticon in emote_set.Items()
        e_start = emoticon.value.starts[0]
        emote_word = Mid(message, (e_start + 1), emoticon.value.length)
        if not m.global.emoteCache.DoesExist(emote_word)
            emoteCache = m.global.emoteCache
            emoteCache[emote_word] = "https://static-cdn.jtvnw.net/emoticons/v2/" + key + "/static/light/1.0"
            m.global.setField("emoteCache", emoteCache)
        end if
    end for
    if display_name = "" or message = ""
        m.chat.readyForNextComment = true
        return
    end if

    x_translation = m.left_bound

    badge_group = buildBadges(badges)
    badge_group.translation = [x_translation, 0]
    x_translation += badge_group.localBoundingRect().width + 1

    username = buildUsername(display_name, color)
    username.translation = [x_translation, 0]
    x_translation += username.localBoundingRect().width + 1

    colon = buildColon()
    colon.translation = [x_translation, 0]
    x_translation += colon.localBoundingRect().width + 1

    message_group = buildMessage(message, x_translation, emote_set, username.translation[0])
    message_group.translation = [0, 0]
    x_translation += message_group.localBoundingRect().width + 1

    group = createObject("roSGNode", "Group")

    group.appendChild(badge_group)
    group.appendChild(username)
    group.appendChild(colon)
    group.appendChild(message_group)
    group.translation = [m.left_bound, m.translation]
    m.chatPanel.appendChild(group)
    y_translation = group.localBoundingRect().height + m.line_gap
    if m.translation + y_translation > m.chatPanel.height
        for each chatmessage in m.chatPanel.getChildren(-1, 0)
            if (chatmessage.translation[1] + chatmessage.localBoundingRect().height) < 0 ' Wait until it's off the screen to remove it.
                m.chatPanel.removeChild(chatmessage)
            else
                chatmessage.translation = [chatmessage.translation[0], (chatmessage.translation[1] - y_translation)]
            end if
        end for
    else
        m.translation += (y_translation)
    end if
    m.chat.readyForNextComment = true
end sub