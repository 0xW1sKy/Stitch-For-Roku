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
    ' m.button = m.top.findnode("exampleButton")
end sub

sub updatePage()
    m.username.text = m.top.contentRequested.streamerDisplayName
    m.GetContentTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
    ' ' observe content so we can know when feed content will be parsed
    m.GetContentTask.observeField("response", "updateChannelInfo")
    m.GetContentTask.request = {
        type: "getChannelHomeQuery"
        params: {
            id: m.top.contentRequested.streamerLogin
        }
    }
    m.GetContentTask.functionName = m.getcontenttask.request.type
    m.getcontentTask.control = "run"
    m.GetShellTask = CreateObject("roSGNode", "TwitchApiTask") ' create task for feed retrieving
    ' ' observe content so we can know when feed content will be parsed
    m.GetShellTask.observeField("response", "updateChannelShell")
    m.GetShellTask.request = {
        type: "getChannelShell"
        params: {
            id: m.top.contentRequested.streamerLogin
        }
    }
    m.getshellTask.functionName = m.getshelltask.request.type
    m.getshellTask.control = "run"
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
    poster.scale = [1.1, 1.1]
    poster.visible = true
    poster.translation = [0, (0 - poster.height / 3)]
    ' overlay = createObject("roSGNode", "Rectangle")
    ' overlay.color = "0x01010110"
    ' overlay.width = 1280
    ' overlay.height = 320
    ' poster.appendChild(overlay)
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
    channelContent = buildContentNodeFromShelves(m.GetcontentTask.response.data)
    updateRowList(channelContent)
    ' ? "Resp: "; m.GetcontentTask.response
    ' ? "Resp: "; m.GetcontentTask.response.data
end sub

function buildContentNodeFromShelves(inputData)
    shelves = inputData.channel.videoShelves.edges
    contentCollection = createObject("RoSGNode", "ContentNode")
    if inputData.channel.stream <> invalid
        row = createObject("RoSGNode", "ContentNode")
        row.title = "Live Stream"
        rowItem = m.top.contentRequested
        row.appendChild(rowItem)
        contentCollection.appendChild(row)
    end if
    for each shelf in shelves
        row = createObject("RoSGNode", "ContentNode")
        row.title = shelf.node.title
        for each stream in shelf.node.items
            rowItem = createObject("RoSGNode", "TwitchContentNode")
            rowItem.contentId = stream.id
            if stream.slug <> invalid
                rowItem.contentType = "CLIP"
                rowItem.clipSlug = stream.slug
            else
                rowItem.contentType = "VOD"
            end if
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
        if row?.getchild(0)?.contentType = "LIVE" or row?.getchild(0)?.contentType = "VOD"
            rowItemSize.push([320, 180])
            if hasRowLabel
                rowHeights.push(275)
            else
                rowHeights.push(235)
            end if
        end if
        if row?.getchild(0)?.contentType = "GAME"
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
    selectedRow = m.rowlist.content.getchild(m.rowlist.rowItemSelected[0])
    selectedItem = selectedRow.getChild(m.rowlist.rowItemSelected[1])
    m.top.playContent = true
    m.top.contentSelected = selectedItem
end function

sub FocusRowlist()
    if m.rowlist.focusedChild = invalid
        m.rowlist.setFocus(true)
    else if m.rowlist.focusedchild.id = "exampleRowList"
        m.rowlist.focusedChild.setFocus(true)
    end if
end sub

sub onGetFocus()
    if m.top?.focusedChild?.id <> invalid and m.top.focusedChild.id = "exampleButton"
        ?"do nothing"
    else
        FocusRowlist()
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    if press
        ? "Channel Page Key Event: "; key
        ' if key = "up"
        '     m.button.setFocus(true)
        '     return true
        ' end if
        ' if key = "down"
        '     m.rowlist.setFocus(true)
        '     return true
        ' end if
        if key = "back"
            m.top.backPressed = true
            return true
        end if
        if key = "OK"
            ? "selected"
        end if
    end if
end function

