sub init()
    m.top.backgroundColor = m.global.constants.colors.hinted.grey1
    m.top.observeField("focusedChild", "onGetfocus")
    ' m.top.observeField("itemFocused", "onGetFocus")
    m.rowlist = m.top.findNode("exampleRowList")
    m.rowlist.ObserveField("itemSelected", "handleItemSelected")
    m.username = m.top.findNode("username")
    m.followers = m.top.findNode("followers")
    m.description = m.top.findNode("description")
    m.livestreamlabel = m.top.findNode("livestreamlabel")
    m.liveDuration = m.top.findNode("liveDuration")
    m.avatar = m.top.findNode("avatar")
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.plyrTask = invalid
end sub

sub updatePage()
    m.username.text = m.top.contentRequested.streamerDisplayName
    m.GetContentTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
    ' ' observe content so we can know when feed content will be parsed
    m.GetContentTask.observeField("response", "updateChannelInfo")
    m.GetContentTask.request = {
        type: "getChannelHomeQuery"
        params: {
            id: m.top.contentRequested.streamerLogin
        }
    }
    m.GetShellTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
    ' ' observe content so we can know when feed content will be parsed
    m.GetShellTask.observeField("response", "updateChannelShell")
    m.GetShellTask.request = {
        type: "getChannelShell"
        params: {
            id: m.top.contentRequested.streamerLogin
        }
    }
end sub

sub updateChannelShell()
    setBannerImage()
end sub

function setBannerImage()
    bannerGroup = m.top.findNode("banner")
    poster = createObject("roSGNode", "Poster")
    if m.GetShellTask.response.data.userOrError.bannerImageUrl <> invalid
        poster.uri = m.GetShellTask.response.data.userOrError.bannerImageUrl
    else
        poster.uri = "pkg:/images/default_banner.png"
    end if
    poster.width = 1280
    poster.height = 320
    poster.visible = true
    poster.translation = [0, 0]
    overlay = createObject("roSGNode", "Rectangle")
    overlay.color = "0x010101F0"
    overlay.width = 1280
    overlay.height = 320
    poster.appendChild(overlay)
    bannerGroup.appendChild(poster)
end function

sub updateChannelInfo()
    ' m.GetcontentTask.response.data.channel
    ' id                : 71092938
    ' __typename        : User
    ' login             : xqc
    ' stream            :
    ' videoShelves      : @{edges=System.Object[]}
    ' self              : @{follower=; subscriptionBenefit=}
    ' displayName       : xQc
    ' hosting           :
    ' videos            : @{edges=System.Object[]}
    ' roles             : @{isPartner=True}
    ' broadcastSettings : @{isMature=False; id=71092938; __typename=BroadcastSettings}
    ' description       : THE BEST AT ABSOLUTELY EVERYTHING. THE JUICER. LEADER OF THE JUICERS.
    ' followers         : @{totalCount=11870230}
    ' profileImageURL   : https://static-cdn.jtvnw.net/jtv_user_pictures/xqc-profile_image-9298dca608632101-70x70.jpeg
    ' profileViewCount  :
    m.description.infoText = m.GetcontentTask.response.data.channel.description
    m.followers.text = numberToText(m.GetcontentTask.response.data.channel.followers.totalCount) + " " + tr("followers")
    m.avatar.uri = m.GetcontentTask.response.data.channel.profileImageUrl
    channelContent = buildContentNodeFromShelves(m.GetcontentTask.response.data.channel.videoShelves.edges)
    updateRowList(channelContent)
    ? "Resp: "; m.GetcontentTask.response
    ? "Resp: "; m.GetcontentTask.response.data
end sub

function buildContentNodeFromShelves(shelves)
    contentCollection = createObject("RoSGNode", "ContentNode")
    for each shelf in shelves
        row = createObject("RoSGNode", "ContentNode")
        row.title = shelf.node.title
        for each stream in shelf.node.items
            rowItem = createObject("RoSGNode", "TwitchContentNode")
            rowItem.contentId = stream.id
            rowItem.contentType = "VOD"
            if stream.previewThumbnailURL <> invalid
                rowItem.previewImageURL = Left(stream.previewThumbnailURL, len(stream.previewThumbnailURL) - 20) + "320x180." + Right(stream.previewThumbnailURL, 3)
            else if stream.thumbnailURL <> invalid
                rowItem.previewImageURL = stream.thumbnailURL
            end if
            rowItem.contentTitle = stream.title
            rowItem.viewersCount = stream.viewCount
            rowItem.streamerDisplayName = m.top.contentRequested.streamerDisplayName
            rowItem.streamerLogin = m.top.contentRequested.streamerLogin
            rowItem.streamerId = m.top.contentRequested.streamerId
            rowItem.streamerProfileImageUrl = m.top.contentRequested.streamerProfileImageUrl
            if stream.game <> invalid
                rowItem.gameDisplayName = stream.game.displayName
                rowItem.gameBoxArtUrl = Left(stream.game.boxArtUrl, Len(stream.game.boxArtUrl) - 20) + "188x250.jpg"
                rowItem.gameId = stream.game.Id
            end if
            row.appendChild(rowItem)
        end for
        contentCollection.appendChild(row)
    end for
    return contentCollection
end function


sub handleRecommendedSections()
    if m.GetContentTask.response.data <> invalid and m.GetContentTask.response.data.shelves <> invalid
        contentCollection = buildContentNodeFromShelves(m.GetContentTask.response.data.shelves.edges)
    else
        for each error in m.GetContentTask.response.errors
            ? "RESP: "; error.message
        end for
    end if
    updateRowList(contentCollection)
end sub



function updateRowList(contentCollection)
    rowItemSize = []
    showRowLabel = []
    rowHeights = []
    for each row in contentCollection.getChildren(contentCollection.getChildCount(), 0)
        if row.title <> ""
            hasRowLabel = true
        else
            hasRowLabel = false
        end if
        showRowLabel.push(hasRowLabel)
        defaultRowHeight = 275
        if row.getchild(0).contentType = "LIVE" or row.getchild(0).contentType = "VOD"
            rowItemSize.push([320, 180])
            if hasRowLabel
                rowHeights.push(275)
            else
                rowHeights.push(235)
            end if
        end if
        if row.getchild(0).contentType = "GAME"
            rowItemSize.push([188, 250])
            if hasRowLabel
                rowHeights.push(325)
            else
                rowHeights.push(305)
            end if
        end if
    end for
    m.rowList.rowHeights = rowHeights
    m.rowlist.showRowLabel = showRowLabel
    m.rowlist.rowItemSize = rowItemSize
    m.rowlist.content = contentCollection
    m.rowlist.numRows = contentCollection.getChildCount()
end function

function handleItemSelected()
    ? "Item Selected"
    selectedRow = m.rowlist.content.getchild(m.rowlist.rowItemSelected[0])
    selectedItem = selectedRow.getChild(m.rowlist.rowItemSelected[1])
    m.top.selectedItem = selectedItem
    runTask()
end function


function onTaskStateUpdated(msg as object)
    ? "Task State Updated: "; msg.getData()
    ' if msg.getData() = "stop"
    '     m.videoPlayer.visible = false
    '     m.rowlist.setFocus(true)
    ' end if
end function

sub onGetFocus()
    if m.rowlist.focusedChild = invalid
        m.rowlist.setFocus(true)
    else if m.rowlist.focusedchild.id = "exampleRowList"
        m.rowlist.focusedChild.setFocus(true)
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        ? "Home Scene Key Event: "; key
        if key = "back"
            m.top.backPressed = true
            return true
        end if
        if key = "OK"
            ? "selected"
        end if
    end if
end function


sub runTask()
    if m.top.selectedItem.contentType = "VOD"
        requestType = "getVodPlayerWrapperQuery"
        id = m.top.selectedItem.contentId
        m.GetVodTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
        ' ' observe content so we can know when feed content will be parsed
        m.GetVodTask.observeField("response", "handleVodLink")
        m.GetVodTask.request = {
            type: "getVodPlayerWrapperQuery"
            params: {
                id: m.top.selectedItem.contentId
            }
        }
    end if
    if m.top.selectedItem.contentType = "STREAM"
        m.GetStreamTask = CreateObject("roSGNode", "TwitchApi") ' create task for feed retrieving
        ' ' observe content so we can know when feed content will be parsed
        m.GetStreamTask.observeField("response", "handleStreamLink")
        m.GetStreamTask.request = {
            type: "getStreamPlayerQuery"
            params: {
                id: m.top.selectedItem.streamerLogin
            }
        }
    end if
end sub
sub playVideo()
    ? "vidContent"
    vidContent = m.top.selectedItem
    vidContent.title = m.top.selectedItem.contentTitle
    m.videoplayer.content = vidContent
    m.videoplayer.visible = true
    m.videoplayer.setFocus(true)
    m.videoplayer.enableCookies()
    m.videoplayer.control = "play"
end sub

function Encode(str as string) as string
    o = CreateObject("roUrlTransfer")
    return o.Escape(str)
end function

sub handleVodLink()
    m.top.selectedItem.url = "https://usher.ttvnw.net/vod/" + m.GetVodTask.response.data.video.id + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&nauth=" + Encode(m.GetVodTask.response.data.video.playbackAccessToken.value) + "&nauthsig=" + m.GetVodTask.response.data.video.playbackAccessToken.signature
    playVideo()
end sub

sub handleStreamLink()
    ' seekpreviewurl = response.data.video.seekpreviewurl
    '"https://static-cdn.jtvnw.net/cf_vods/vod/7b652c53825567c2bb4c_kaicenat_41850780219_1676414633/storyboards/1738339385-info.json"
    usherUrl = "https://usher.ttvnw.net/api/channel/hls/" + m.GetStreamTask.response.data.user.login + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&lr=true&token=" + Encode(m.GetStreamTask.response.data.user.stream.playbackaccesstoken.value) + "&sig=" + m.GetStreamTask.response.data.user.stream.playbackaccesstoken.signature
    ' return usherUrl
    req = HttpRequest({
        url: usherUrl
        headers: {
            "Accept": "*/*"
            "Origin": "https://switch.tv.twitch.tv"
            "Referer": "https://switch.tv.twitch.tv/"
        }
        method: "GET"
    })
    rsp = req.send().getString()
    list = rsp.Split(chr(10))
    first_stream_link = ""
    last_stream_link = ""
    link = ""
    cnt = 0
    ' streamitems_all = []
    stream_objects = []
    for line = 2 to list.Count() - 1
        stream_info = list[line + 1].Split(",")
        streamobject = {}
        for info = 0 to stream_info.Count() - 1
            info_parsed = stream_info[info].Split("=")
            streamobject[info_parsed[0].replace("#EXT-X-STREAM-INF:", "")] = toString(info_parsed[1], true).replace(chr(34), "")
        end for
        streamobject["URL"] = list[line + 2]
        stream_objects.push(streamobject)
        line += 2
    end for
    stream_bitrates = []
    stream_urls = []
    stream_qualities = []
    stream_content_ids = []
    stream_sticky = []
    for each stream_item in stream_objects
        stream_bitrates.push(Int(Val(stream_item["BANDWIDTH"])) / 1000)
        if stream_item["VIDEO"] = "chunked"
            value = stream_item["RESOLUTION"].split("x")[1] + "p" + stream_item["FRAME-RATE"].split(".")[0]
        else
            value = stream_item["VIDEO"]
        end if
        stream_content_ids.push(value)
        stream_urls.push(stream_item["URL"])
        if Int(Val(stream_item["RESOLUTION"].split("x")[1])) >= 720
            stream_qualities.push("HD")
        else
            stream_qualities.push("SD")
        end if
        stream_sticky.push("false")

    end for
    ' The stream needs a couple of seconds to load on AWS's server side before we display back to user.
    ' The idea is that this will provide a better user experience by removing stuttering.

    m.top.selectedItem.streamUrls = stream_urls
    m.top.selectedItem.streamQualities = stream_qualities
    m.top.selectedItem.streamContentIDs = stream_content_ids
    m.top.selectedItem.streamBitrates = stream_bitrates
    m.top.selectedItem.streamStickyHttpRedirects = stream_sticky
    playVideo()
end sub


function HttpRequest(params = invalid as dynamic) as object
    url = invalid
    method = invalid
    headers = {}
    data = invalid
    timeout = 0
    retries = 1
    interval = 500
    if params <> invalid then
        if params.url <> invalid then url = params.url
        if params.method <> invalid then method = params.method
        if params.headers <> invalid then headers = params.headers
        if params.data <> invalid then data = params.data
        if params.timeout <> invalid then timeout = params.timeout
        if params.retries <> invalid then retries = params.retries
        if params.interval <> invalid then interval = params.interval
    end if

    obj = {
        _timeout: timeout
        _retries: retries
        _interval: interval
        _deviceInfo: createObject("roDeviceInfo")
        _url: url
        _method: method
        _requestHeaders: headers
        _data: data
        _http: invalid
        _isAborted: false

        _isProtocolSecure: function(url as string) as boolean
            return left(url, 6) = "https:"
        end function

        _createHttpRequest: function() as object
            request = createObject("roUrlTransfer")
            request.setPort(createObject("roMessagePort"))
            request.setUrl(m._url)
            request.retainBodyOnError(true)
            request.enableCookies()
            request.setHeaders(m._requestHeaders)
            if m._method <> invalid then request.setRequest(m._method)

            'Checks if URL protocol is secured, and adds appropriate parameters if needed
            if m._isProtocolSecure(m._url) then
                request.setCertificatesFile("common:/certs/ca-bundle.crt")
                request.initClientCertificates()
            end if

            return request
        end function

        getPort: function()
            if m._http <> invalid then
                return m._http.getPort()
            else
                return invalid
            end if
        end function

        getCookies: function(domain as string, path as string) as object
            if m._http <> invalid then
                return m._http.getCookies(domain, path)
            else
                return invalid
            end if
        end function

        send: function(data = invalid as dynamic) as dynamic
            timeout = m._timeout
            retries = m._retries
            response = invalid

            if data <> invalid then m._data = data

            if m._data <> invalid and getInterface(m._data, "ifString") = invalid then
                m._data = formatJson(m._data)
            end if

            while retries > 0 and m._deviceInfo.getLinkStatus()
                if m._sendHttpRequest(m._data) then
                    event = m._http.getPort().waitMessage(timeout)

                    if m._isAborted then
                        m._isAborted = false
                        m._http.asyncCancel()
                        exit while
                    else if type(event) = "roUrlEvent" then
                        response = event
                        exit while
                    end if

                    m._http.asyncCancel()
                    timeout *= 2
                    sleep(m._interval)
                end if

                retries--
            end while

            return response
        end function

        _sendHttpRequest: function(data = invalid as dynamic) as dynamic
            m._http = m._createHttpRequest()

            if data <> invalid then
                return m._http.asyncPostFromString(data)
            else
                return m._http.asyncGetToString()
            end if
        end function

        abort: function()
            m._isAborted = true
        end function

    }

    return obj
end function