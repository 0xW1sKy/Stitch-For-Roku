function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()
    stream_link = getVodLink()
    ? "Stream Link: " + stream_link
    m.top.streamUrl = stream_link
end function

sub extractThumbnailUrl(streamUrl)
    index = Len(streamUrl)
    secondSlash = false
    while index > 0
        if Mid(streamUrl, index, 1) = "/"
            if secondSlash
                info_url = Mid(streamUrl, 1, index - 1) + "/storyboards/"
                url = CreateObject("roUrlTransfer")
                url.EnableEncodings(true)
                url.RetainBodyOnError(true)
                url.SetCertificatesFile("common:/certs/ca-bundle.crt")
                url.InitClientCertificates()
                url.SetUrl(info_url + m.top.videoId + "-info.json")
                ? "video info url > "; info_url + m.top.videoId + "-info.json"
                response_string = url.GetToString()
                thumbnailInfo = ParseJson(response_string)
                ' ? "thumbnail info > "; thumbnailInfo
                if thumbnailInfo <> invalid and thumbnailInfo[0] <> invalid
                    url2 = CreateObject("roUrlTransfer")
                    url2.EnableEncodings(true)
                    url2.RetainBodyOnError(true)
                    url2.SetCertificatesFile("common:/certs/ca-bundle.crt")
                    url2.InitClientCertificates()
                    url2.SetUrl(info_url + thumbnailInfo[1].images[0])
                    ' https: //dqrpb9wgowsf5.cloudfront.net / f339ec10e143fbac0b75_hasanabi_41619886427_1671303742 / storyboards / 1681696949 - info.json
                    ' https: //static - cdn.jtvnw.net / cf_vods / d2nvs31859zcd8 / f339ec10e143fbac0b75_hasanabi_41619886427_1671303742 / /thumb/thumb0 - 320x180.jpg
                    'url2.SetUrl(info_url + thumbnailInfo[0].images[0])
                    'url2.SetUrl("https://i.redd.it/u105ro5rg8o31.jpg")
                    ? "image url: "; info_url + thumbnailInfo[1].images[0]
                    '? "response code: "; url2.GetToFile("tmp:/thumbnails.jpg")
                    '? "response: "; url2.GetToString()
                    m.top.thumbnailInfo = { count: thumbnailInfo[1].count,
                        width: thumbnailInfo[1].width,
                        rows: thumbnailInfo[1].rows,
                        interval: thumbnailInfo[1].interval,
                        cols: thumbnailInfo[1].cols,
                        height: thumbnailInfo[1].height,
                        info_url: info_url,
                        thumbnail_parts: thumbnailInfo[1].images,
                    video_id: m.top.videoId }
                else
                    m.top.thumbnailInfo = { video_id: m.top.videoId }
                end if
                exit while
            end if
            secondSlash = true
        end if
        index -= 1
    end while
end sub

function getVodLink() as object
    userdata = getTokenFromRegistry()
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
            query: "query VodPlayerWrapper_Query(" + chr(10) + "  $videoId: ID!" + chr(10) + "  $platform: String!" + chr(10) + "  $playerType: String!" + chr(10) + "  $skipPlayToken: Boolean!" + chr(10) + ") {" + chr(10) + "  ...VodPlayerWrapper_token" + chr(10) + "}" + chr(10) + "" + chr(10) + "fragment VodPlayerWrapper_token on Query {" + chr(10) + "  video(id: $videoId) @skip(if: $skipPlayToken) {" + chr(10) + "    playbackAccessToken(params: {platform: $platform, playerType: $playerType}) {" + chr(10) + "      signature" + chr(10) + "      value" + chr(10) + "    }" + chr(10) + "    id" + chr(10) + "    __typename" + chr(10) + "  }" + chr(10) + "}" + chr(10) + ""
            variables: {
                "videoId": m.top.videoId
                "platform": "switch_web_tv"
                "playerType": "pulsar"
                "skipPlayToken": false
            }
        }
    })
    data = req.send()
    ? "RESPONSE: "; data
    response = ParseJSON(data)
    m.top.playbackAccessToken = response.data.video.playbackAccessToken
    ' seekpreviewurl = response.data.video.seekpreviewurl
    '"https://static-cdn.jtvnw.net/cf_vods/vod/7b652c53825567c2bb4c_kaicenat_41850780219_1676414633/storyboards/1738339385-info.json"
    vod_link = "https://usher.ttvnw.net/vod/" + m.top.videoId + ".m3u8?playlist_include_framerate=true&allow_source=true&player_type=pulsar&player_backend=mediaplayer&nauth=" + UrlEncode(response.data.video.playbackAccessToken.value) + "&nauthsig=" + response.data.video.playbackAccessToken.signature
    return vod_link
end function