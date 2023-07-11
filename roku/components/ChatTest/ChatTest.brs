function init()
    m.top.functionName = "main"
end function

function getTwitchBadges()
    access_token = ""
    device_code = ""
    ' doubled up here in stead of defaulting to "" because access_token is dependent on device_code
    if get_user_setting("device_code") <> invalid
        device_code = get_user_setting("device_code")
        if get_user_setting("access_token") <> invalid
            access_token = "OAuth " + get_user_setting("access_token")
        end if
    end if
    req = HttpRequest({
        url: "https://gql.twitch.tv/gql"
        headers: {
            "Accept": "*/*"
            "Authorization": access_token
            "Client-Id": "ue6666qo983tsx6so1t0vnawi233wa"
            "Device-ID": device_code
            "Origin": "https://switch.tv.twitch.tv"
            "Referer": "https://switch.tv.twitch.tv/"
        }
        method: "POST"
        data: {
            "operationName": "ChatList_Badges",
            "variables": {
                "channelLogin": m.top.channel
            },
            "extensions": {
                "persistedQuery": {
                    "version": 1,
                    "sha256Hash": "86f43113c04606e6476e39dcd432dee47c994d77a83e54b732e11d4935f0cd08"
                }
            }
        }
    })
    rsp = ParseJSON(req.send())
    badgelist = {}
    for each badge in rsp.data.badges
        ' badge.setID = 1979-revolution_1
        ' badge.title = 1979 Revolution
        ' badge.id = MTk3OS1yZXZvbHV0aW9uXzE7MTs=
        identifier = badge.setID + "/" + badge.version
        badgelist[identifier] = badge.image2x
    end for
    for each badge in rsp.data.user.broadcastBadges
        ' badge.setID = 1979-revolution_1
        ' badge.title = 1979 Revolution
        ' badge.id = MTk3OS1yZXZvbHV0aW9uXzE7MTs=
        identifier = badge.setID + "/" + badge.version
        badgelist[identifier] = badge.image2x
    end for
    return badgelist
end function

function getChannelUserId() as object
    url = createUrl()
    search_results_url = "https://api.twitch.tv/helix/users?login=" + m.top.channel
    url.SetUrl(search_results_url.EncodeUri())
    response_string = url.GetToString()
    user_data = ParseJson(response_string)
    user_id = ""
    if user_data.data[0].id <> invalid
        user_id = user_data.data[0].id
    end if

    return user_id
end function

sub getChannel7tvEmotes(channel_id)
    temp = getjsondata("https://7tv.io/v3/users/twitch/" + channel_id)
    assocEmotes = {}
    if temp.emote_set <> invalid
        if temp.emote_set.emotes <> invalid
            for each emote in temp.emote_set.emotes
                uri = "https://cdn.7tv.app/emote/" + emote.id + "/1x.webp"
                assocEmotes[emote.name] = uri
            end for
        end if
    end if
    if m.global.channel7TVEmotes = invalid
        m.global.addFields({ channel7TVEmotes: assocEmotes })
    else
        m.global.setField("channel7TVEmotes", assocEmotes)
    end if
end sub

sub getGlobal7tvEmotes()
    temp = getjsondata("https://7tv.io/v3/emote-sets/global")
    assocEmotes = {}
    for each emote in temp.emotes
        uri = "https://cdn.7tv.app/emote/" + emote.id + "/1x.webp"
        assocEmotes[emote.name] = uri
    end for
    if m.global.global7TVEmotes = invalid
        m.global.addFields({ global7TVEmotes: assocEmotes })
    else
        m.global.setField("global7TVEmotes", assocEmotes)
    end if
end sub

function main()
    'messagePort = CreateObject("roMessagePort")
    if m.global.twitchBadges = invalid
        m.global.addFields({ twitchBadges: getTwitchBadges() })
    else
        m.global.setField("twitchBadges", getTwitchBadges())
    end if

    if m.global.globalTTVEmotes = invalid
        temp = getjsondata("https://api.betterttv.net/3/cached/emotes/global")
        assocEmotes = {}
        for each emote in temp
            assocEmotes[emote.code] = emote.id
        end for
        m.global.addFields({ globalTTVEmotes: assocEmotes })
    end if

    getGlobal7tvEmotes()

    if m.top.channel <> ""
        tcpListen = createObject("roStreamSocket")

        addr = createObject("roSocketAddress")
        addr.SetAddress("irc.chat.twitch.tv:6667")

        'messagePort = createObject("roMessagePort")

        tcpListen.SetSendToAddress(addr)
        'tcpListen.SetMessagePort(messagePort)
        tcpListen.notifyReadable(true)
        ? "connect " tcpListen.Connect()
        tcpListen.SendStr("CAP REQ :twitch.tv/tags twitch.tv/commands" + Chr(13) + Chr(10))
        user_auth_token = get_user_setting("access_token")
        m.loggedinUserName = get_user_setting("login")
        if m.loggedInUsername <> "" and user_auth_token <> invalid and user_auth_token <> ""
            ? "PASS " tcpListen.SendStr("PASS oauth:" + user_auth_token + Chr(13) + Chr(10))
            ? "USER " tcpListen.SendStr("USER " + m.loggedinUsername + " 8 * :" + m.loggedinUsername + Chr(13) + Chr(10))
            ? "NICK " tcpListen.SendStr("NICK " + m.loggedinUsername + Chr(13) + Chr(10))
            ? "first eOK " tcpListen.eOK()
            ? "first IsReadable " tcpListen.IsReadable()
            ? "first IsWritable " tcpListen.IsWritable()
            ? "first IsException " tcpListen.IsException()
            ? "first eSuccess " tcpListen.eSuccess()
            '? "PASS oauth:" + user_auth_token
            '? "USER " + m.loggedinUsername + " 8 * :" + m.loggedinUsername
            '? "NICK " + m.loggedinUsername
        else
            tcpListen.SendStr("PASS SCHMOOPIIE" + Chr(13) + Chr(10))
            tcpListen.SendStr("NICK justinfan32006" + Chr(13) + Chr(10))
        end if
        ? "ChatTest >> JOIN > " m.top.channel
        tcpListen.SendStr("JOIN #" + m.top.channel + Chr(13) + Chr(10))

        'm.top.observeField("sendMessage", "sendMessage")

        channel_id = getChannelUserId()


        temp = getjsondata("https://api.betterttv.net/3/cached/users/twitch/" + channel_id)
        assocEmotes = {}
        if temp.sharedEmotes <> invalid
            for each emote in temp.sharedEmotes
                assocEmotes[emote.code] = emote.id
            end for
        end if
        if m.global.channelTTVEmotes = invalid
            m.global.addFields({ channelTTVEmotes: assocEmotes })
        else
            m.global.setField("channelTTVEmotes", assocEmotes)
        end if

        temp = getjsondata("https://api.betterttv.net/3/cached/frankerfacez/users/twitch/" + channel_id)
        assocEmotes = {}
        for each emote in temp
            assocEmotes[emote.code] = emote.images["1x"]
        end for
        if m.global.channelTTVFrankerEmotes = invalid
            m.global.addFields({ channelTTVFrankerEmotes: assocEmotes })
        else
            m.global.setField("channelTTVFrankerEmotes", assocEmotes)
        end if

        getChannel7tvEmotes(channel_id)

        queue = createObject("roArray", 300, true)
        first = 0
        last = 0
        waitingComment = ""
        waitingCommentAge = 0
        sendWaitingMessage = true
        while true
            get = ""
            received = ""
            '? "tcpListen isConnected " tcpListen.IsConnected()
            if m.top.sendMessage <> "" and m.top.readyForNextComment
                ' ? "tcpListen isConnected " tcpListen.IsConnected()
                ' ? "second eOK " tcpListen.eOK()
                ' ? "second IsReadable " tcpListen.IsReadable()
                ' ? "second IsWritable " tcpListen.IsWritable()
                ' ? "second IsException " tcpListen.IsException()
                ' ? "second eSuccess " tcpListen.eSuccess()
                sent = tcpListen.SendStr("PRIVMSG #" + m.top.channel + " :" + m.top.sendMessage + Chr(13) + Chr(10))
                ' ? "Send Status " tcpListen.Status()
                ' ? "sent ;) " sent
                if sent > 0
                    m.top.nextComment = ""
                    m.top.clientComment = m.top.sendMessage
                end if
                m.top.sendMessage = ""
                'm.top.clientComment = m.top.sendMessage
            end if

            if tcpListen.GetCountRcvBuf() > 0
                while not get = Chr(10)
                    get = tcpListen.ReceiveStr(1)
                    '? "receive Status " tcpListen.Status()
                    received += get
                end while
            end if

            if tcpListen.GetCountRcvBuf() = 0 and tcpListen.IsReadable()
                ? "chat connection failed?"
                'tcpListen.Close()
                tcpListen = createObject("roStreamSocket")
                tcpListen.SetSendToAddress(addr)
                'tcpListen.SetMessagePort(messagePort)
                'tcpListen.notifyReadable(true)
                ? "connect " tcpListen.Connect()
                tcpListen.SendStr("CAP REQ :twitch.tv/tags twitch.tv/commands" + Chr(13) + Chr(10))
                user_auth_token = get_user_setting("access_token")
                if m.loggedinUsername <> "" and user_auth_token <> invalid and user_auth_token <> ""
                    ? "PASS " tcpListen.SendStr("PASS oauth:" + user_auth_token + Chr(13) + Chr(10))
                    ? "USER " tcpListen.SendStr("USER " + m.loggedinUsername + " 8 * :" + m.loggedinUsername + Chr(13) + Chr(10))
                    ? "NICK " tcpListen.SendStr("NICK " + m.loggedinUsername + Chr(13) + Chr(10))
                    '? "PASS oauth:" + user_auth_token
                    '? "USER " + m.loggedinUsername + " 8 * :" + m.loggedinUsername
                    '? "NICK " + m.loggedinUsername
                else
                    tcpListen.SendStr("PASS SCHMOOPIIE" + Chr(13) + Chr(10))
                    tcpListen.SendStr("NICK justinfan32006" + Chr(13) + Chr(10))
                end if
                tcpListen.SendStr("JOIN #" + m.top.channel + Chr(13) + Chr(10))
            end if

            if not received = ""
                if Left(received, 4) = "PING"
                    ? "PONG"
                    tcpListen.SendStr("PONG :tmi.twitch.tv" + Chr(13) + Chr(10))
                    '? "send PONG Status " tcpListen.Status()
                else
                    'queue[last] = received
                    queue.unshift(received)
                    ' ? "Message queue: " queue.count()
                    if last + 1 < 100
                        last += 1
                    else
                        last = 0
                    end if
                end if
            end if

            if sendWaitingMessage and m.top.readyForNextComment
                sendWaitingMessage = false
                m.top.nextComment = "display-name=System;user-type= :test!test@test.tmi.twitch.tv PRIVMSG #test :Delaying Chat to sync to stream. Please hold...  " ' whitespace at end is removed by comment parser
            end if
            if m.top.readyForNextComment and queue.count() > 0
                ' Check if delay is complete using irc timestamp
                oldestComment = queue.peek()
                commentComponents = oldestComment.Split(";")
                currentTimestamp = CreateObject("roDateTime").AsSeconds()
                commentTimestamp = ""
                comment = ""
                for each section in commentComponents
                    if Left(section, 11) = "tmi-sent-ts"
                        ' tmi-sent-ts=1550868292494 (in ms) -> 1550868292 (in secs)
                        timestamp_ms = Right(section, Len(section) - 12)
                        ' convert millisecond epoch to second epoch
                        timestamp_s = Left(timestamp_ms, 10)
                        commentTimestamp = Val(timestamp_s, 10)
                    else if Left(section, 9) = "user-type"
                        comment = section
                    end if
                end for
                ' This will discard anything in the queue that doesn't have "tmi-sent-ts"
                if GetInterface(commentTimestamp, "ifString") <> invalid
                    queue.pop()
                else
                    commentAge = currentTimestamp - commentTimestamp
                    ' This block is useful for debugging
                    ' if waitingComment <> oldestComment or waitingCommentAge <> commentAge
                    '     waitingComment = oldestComment
                    '     waitingCommentAge = commentAge
                    '     ? "Message " comment " was sent " waitingCommentAge " secs ago"
                    '     ? "Queue size: " queue.count()
                    ' end if
                    if commentAge > 30 ' measured in seconds
                        m.top.nextComment = queue.pop()
                        'queue[first] = invalid
                        if first + 1 < 100
                            first += 1
                        else
                            first = 0
                        end if
                    end if
                end if

            end if

        end while
    end if


end function