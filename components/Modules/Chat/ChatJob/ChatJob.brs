function init()
    m.top.functionName = "main"
    m.delay = 29
end function


function main()
    ? "[ChatJob] - main"
    if m.top.channel <> ""
        receivedNewMessage = false
        tcpListen = createObject("roStreamSocket")
        addr = createObject("roSocketAddress")
        addr.SetAddress("irc.chat.twitch.tv:6667")
        tcpListen.SetSendToAddress(addr)
        tcpListen.notifyReadable(true)
        '? "connect "
        tcpListen.Connect()
        tcpListen.SendStr("CAP REQ :twitch.tv/tags twitch.tv/commands" + Chr(13) + Chr(10))
        tcpListen.SendStr("PASS SCHMOOPIIE" + Chr(13) + Chr(10))
        tcpListen.SendStr("NICK justinfan32006" + Chr(13) + Chr(10))
        ? "[ChatJob] - JOIN - "; m.top.channel
        tcpListen.SendStr("JOIN #" + m.top.channel + Chr(13) + Chr(10))
        queue = createObject("roArray", 300, true)
        waitingComment = ""
        waitingCommentAge = 0
        sendWaitingMessage = true
        while true
            get = ""
            received = ""
            '? "tcpListen isConnected " tcpListen.IsConnected()
            if tcpListen.GetCountRcvBuf() > 0
                while not get = Chr(10)
                    get = tcpListen.ReceiveStr(1)
                    '? "receive Status " tcpListen.Status()
                    received += get
                end while
            end if
            if tcpListen.GetCountRcvBuf() = 0 and tcpListen.IsReadable()
                tcpListen = createObject("roStreamSocket")
                tcpListen.SetSendToAddress(addr)
                tcpListen.Connect()
                tcpListen.SendStr("CAP REQ :twitch.tv/tags twitch.tv/commands" + Chr(13) + Chr(10))
                tcpListen.SendStr("PASS SCHMOOPIIE" + Chr(13) + Chr(10))
                tcpListen.SendStr("NICK justinfan32006" + Chr(13) + Chr(10))
                tcpListen.SendStr("JOIN #" + m.top.channel + Chr(13) + Chr(10))
            end if
            if not received = ""
                if Left(received, 4) = "PING"
                    tcpListen.SendStr("PONG :tmi.twitch.tv" + Chr(13) + Chr(10))
                else
                    queue.unshift(received)
                    receivedNewMessage = true
                end if
            end if
            if m.top.readyForNextComment and queue.count() > 0
                ' Check if delay is complete using irc timestamp
                oldestComment = queue.peek()
                _parsedMessage = MessageParser(oldestComment)
                currentTimestamp = CreateObject("roDateTime").AsSeconds()
                if _parsedMessage?.tags?.tmi_sent_ts <> invalid
                    commentTimeStamp = Val(_parsedMessage.tags.tmi_sent_ts.left(10), 10)
                    commentAge = currentTimestamp - commentTimestamp
                    if m.top.forceLive = true
                        sendWaitingMessage = false
                        m.top.nextCommentObj = MessageParser(queue.pop())
                    else if commentAge > m.delay ' measured in seconds
                        m.top.nextCommentObj = MessageParser(queue.pop())
                    end if
                    if sendWaitingMessage <> invalid
                        if sendWaitingMessage = true
                            if commentAge >= m.delay
                                sendWaitingMessage = false
                                ' m.top.nextCommentObj = MessageParser("display-name=System;user-type= :test!test@test.tmi.twitch.tv PRIVMSG #test :ReSyncing Chat To Stream || ReSyncing Chat To Stream || ReSyncing Chat To Stream || ReSyncing Chat To Stream || ReSyncing Chat To Stream || ReSyncing Chat To Stream || ReSyncing Chat To Stream || ReSyncing Chat To Stream || ReSyncing Chat To Stream  ")
                            else
                                if queue[0] <> invalid
                                    if receivedNewMessage
                                        m.top.nextCommentObj = MessageParser(queue[0])
                                        receivedNewMessage = false
                                    end if
                                end if
                            end if
                        end if
                    end if
                else
                    ' This will discard anything in the queue that doesn't have "tmi-sent-ts"
                    queue.pop()
                end if
            end if
        end while
    end if
end function


function MessageParser(message)
    try
        parsedMessage = {
            tags: {}
            source: {}
            command: {}
            parameters: ""
        }
        rawTagsComponent = invalid
        rawSourceComponent = invalid
        rawCommandComponent = invalid
        rawParametersComponent = invalid

        idx = 0

        if message.mid(idx, 1) = "@"
            endIdx = message.Instr(" ")
            rawTagsComponent = message.mid(1, endIdx)
            idx = endIdx + 1
        end if

        if message.mid(idx, 1) = ":"
            idx += 1
            endIdx = message.Instr(idx, " ")
            rawSourceComponent = message.mid(idx, endIdx)
            idx = endIdx + 1
        end if

        endIdx = message.InStr(idx, ":")
        if (endIdx = -1)
            endIdx = message.len()
        end if

        rawCommandComponent = message.mid(idx, endIdx).trim()

        if (endidx <> message.len())
            idx = endIdx + 1
            rawParametersComponent = message.mid(idx)
        end if

        parsedMessage.command = parseCommand(rawCommandComponent)

        if parsedMessage.command <> invalid
            if rawTagsComponent <> invalid
                parsedMessage.tags = parseTags(rawTagsComponent)
            end if
            parsedMessage.source = parseSource(rawSourceComponent)
            if rawParametersComponent <> invalid
                parsedMessage.parameters = rawParametersComponent.trim()
            end if
            if rawParametersComponent <> invalid
                if rawParametersComponent.mid(0, 1) = "!"
                    parsedMessage.command = parseParameters(rawParametersComponent, parsedMessage.command)
                end if
            end if
        else
            return invalid
        end if
        return parsedMessage
    catch e
        ? "Error Parsing Chat Message"
        return invalid
    end try
end function

function parseTags(tags)
    tagsToIgnore = {
        "client-nonce": invalid
        "flags": invalid
    }
    dictParsedtags = {}
    parsedTags = tags.split(";")
    for each tag in parsedTags
        parsedTag = tag.split("=")
        if parsedTag[1] <> invalid and parsedTag[1] <> ""
            tagValue = parsedTag[1]
        else
            tagValue = invalid
        end if
        if parsedTag[0] = "badges" or parsedTag[0] = "badge-info"
            if tagValue <> invalid
                dict = {}
                badges = tagValue.split(",")
                for each pair in badges
                    badgeParts = pair.split("/")
                    dict[badgeParts[0]] = badgeParts[1]
                end for
                dictParsedtags[parsedTag[0].replace("-", "_")] = dict
            else
                dictParsedTags[parsedTag[0].replace("-", "_")] = invalid
            end if
        else if parsedTag[0] = "emotes"
            if tagValue <> invalid
                dictEmotes = {}
                emotes = tagValue.split("/")
                for each emote in emotes
                    emoteParts = emote.split(":")
                    textPositions = []
                    positions = emoteParts[1].split(",")
                    for each position in positions
                        positionParts = position.split("-")
                        textPositions.push({
                            startPosition: positionParts[0]
                            endPosition: positionParts[1]
                        })
                    end for
                    dictEmotes[emoteParts[0]] = textPositions
                end for
                dictParsedtags[parsedTag[0].replace("-", "_")] = dictEmotes
            else
                dictParsedtags[parsedTag[0].replace("-", "_")] = invalid
            end if
        else if parsedTag[0] = "emote-sets"
            if tagValue <> invalid
                emoteSetIds = tagValue.split(",")
                dictParsedTags[parsedTag[0].replace("-", "_")] = emoteSetIds
            end if
        else
            if tagsToIgnore.DoesExist(parsedTag[0])
            else
                if tagValue <> invalid
                    dictParsedtags[parsedTag[0].replace("-", "_")] = tagValue
                end if
            end if
        end if
    end for
    return dictParsedtags
end function

function parseParameters(rawParameterscomponent, command)
    idx = 0
    commandParts = rawParameterscomponent.mid((idx + 1)).trim()
    paramsidx = commandParts.InStr(" ")
    if paramsIdx = -1
        command.botCommand = commandParts.mid(0)
    else
        command.botCommand = commandParts.mid(0, paramsidx)
        command.botCommandParams = commandParts.mid(paramsidx).trim()
    end if
    return command
end function

function parseSource(rawSourceComponent)
    if rawSourceComponent <> invalid
        sourceParts = rawSourceComponent.split("!")
        if sourceParts.count() = 2
            nick = sourceParts[0]
            host = sourceParts[1]
        else
            nick = invalid
            host = sourceParts[0]
        end if
        return {
            nick: nick
            host: host.trim()
        }
    else
        return invalid
    end if
end function



function parseCommand(rawCommandComponent)
    parsedCommand = invalid
    commandParts = rawCommandComponent.split(" ")

    if commandParts[0] = "JOIN" or commandParts[0] = "PART" or commandParts[0] = "NOTICE" or commandParts[0] = "CLEARCHAT" or commandParts[0] = "HOSTTARGET" or commandParts[0] = "PRIVMSG"
        parsedCommand = {
            command: commandParts[0]
            channel: commandParts[1]
        }
    else if commandParts[0] = "PING"
        parsedCommand = {
            command: commandParts[0]
        }
    else if commandParts[0] = "CAP"
        capRequestEnabled = false
        if commandParts[2] = "ACK"
            capRequestEnabled = true
        end if
        parsedCommand = {
            command: commandParts[0]
            isCapRequestEnabled: capRequestEnabled
        }
    else if commandParts[0] = "GLOBALUSERSTATE"
        parsedCommand = {
            command: commandParts[0]
        }
    else if commandParts[0] = "USERSTATE" or commandParts[0] = "ROOMSTATE"
        parsedCommand = {
            command: commandParts[0]
            channel: commandPArts[1]
        }
    else if commandParts[0] = "RECONNECT"
        ? "The Twitch IRC server is about to terminate the connection for maintenance."
        parsedCommand = {
            command: commandParts[0]
        }
    else if commandParts[0] = "421"
        ? "Unsupported IRC command: "; commandParts[2]
        return invalid
    else if commandParts[0] = "001"
        parsedCommand = {
            command: commandParts[0]
            channel: commandParts[1]
        }
    else if commandParts[0] = "002" or commandParts[0] = "003" or commandParts[0] = "004" or commandParts[0] = "353" or commandParts[0] = "366" or commandParts[0] = "372" or commandParts[0] = "375" or commandParts[0] = "376"
        ? "Numeric Message: "; commandParts[0]
        return invalid
    else
        ? "Unexpected Command: "; commandParts[0]
        return invalid
    end if
    return parsedCommand
end function