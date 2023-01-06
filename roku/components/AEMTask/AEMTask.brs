' ********** Copyright 2018 Roku, Inc.  All Rights Reserved. **********
Library "Roku_Ads.brs"

function init()
    '
    '  Following info must be provided
    '
    '   m.top.streamConfig.url          :  master URL
    '   m.top.streamConfig.params       :  optional object, adsParams of initial request
    '   m.top.streamConfig.useStitched  :  true or false
    '
    m.top.adPlaying = False
    m.top.functionName = "runTask"
    if m.top.blockAds
        m.useStitched = false
    else
        m.useStitched = true
    end if
end function

function runTask()
    '
    '  1. Load and instanciate Adopter
    '
    adapter = loadAdapter()
    '
    '  2. Request preplay
    '
    loadStream(adapter)
    '
    '  3. Play content
    '
    runLoop(adapter)
end function

function loadAdapter() as object
    '  not calling callStitchedAdHandledEvent(). App is responsible to call RAF.fireTrackingEvents()
    ' if invalid <> m.top.streamConfig["useStitched"] and false = m.top.streamConfig.useStitched then m.useStitched = false
    if m.top.blockAds
        m.useStitched = false
    else
        m.useStitched = true
    end if
    '
    '  1. Load and instanciate Adopter
    '
    adapter = RAFX_SSAI({ name: "adobe", ' Required, "adobe"
    trackingmode: "xmkr" }) ' Required
    if adapter <> invalid
        adapter.init() ' Required
        print "RAFX_SSAI version ";adapter["__version__"]
    end if
    return adapter
end function

function loadStream(adapter as object) as void
    if invalid = adapter
        ? "Adapter Invalid"
        ? "Adapter Invalid"
        ? "Adapter Invalid"
        return
    end if
    streamInfo = invalid
    ' if true
    '     '
    '     '   2.1  Compose request info and fetch Manifest and Tracking URLs
    '     '
    '     request = {
    '         type: m.top.streamConfig.type ' m.top.streamConfig.type, ' Required, adapter.StreamType.LIVE or VOD
    '         url: m.top.streamConfig.url '.url ' Required, master-URL
    '     }
    '     if invalid <> m.top.streamConfig["params"]
    '         ' As providing  body, adapter will make POST request instead of GET
    '         request["body"] = formatjson(m.top.streamConfig.params) ' Optional, {adsParams: {param1,param2,...}}
    '     end if
    '     requestResult = adapter.requestStream(request) ' Required, requesting Ad Metadata
    '     if requestResult["error"] <> invalid
    '         print "Error requesting stream ";requestResult
    '     else
    '         streamInfo = adapter.getStreamInfo() ' Required when vod, optional when live
    '         ? "STREAMINFO: "; streamInfo
    '     end if
    ' else
    '   2.2  Optional, for Apps manifest_url and tracking_url known already:
    ' streamInfo = {
    '     type: m.top.streamConfig.type, ' Required. adapter.StreamType.LIVE or VOD
    '     tracking_url: m.top.tracking_url, ' Required. App must provide valid URL
    '     manifest_url: m.top.streamConfig.url 'm.top.manifest_url ' Required. App must provide valid URL
    ' }
    ' adapter.setStreamInfo(streamInfo)
    ' ' end if
    ' if invalid <> streamInfo
    '     '
    '     '  2.3  Setup video node.  Select here variant
    '     '
    '     vidContent = createObject("RoSGNode", "ContentNode")
    '     vidContent.title = m.top.streamConfig.title
    '     if invalid <> streamInfo.manifest_url
    '         vidContent.url = streamInfo.manifest_url
    '         if 0 < vidContent.url.instr("/master/") then
    '             vidContent.streamformat = "hls"
    '         else if 0 < vidContent.url.instr("/dash/") then
    '             vidContent.streamformat = "dash"
    '         end if
    '     end if
    '     if invalid <> m.top.streamConfig.streamFormat
    '         vidContent.streamFormat = m.top.streamConfig.streamFormat
    '     end if
    '     m.top.video.content = vidContent
    '     m.top.video.setFocus(true)
    '     m.top.video.visible = true
    '     m.top.video.enableCookies()
    ' end if
    '
    '   2.4  other RAF settings
    '
    request = {
        url: m.top.streamConfig.url ' Required, masterURL
        '  Either kbps or callback is required bellow when trackingmode: simple
        ' Max kbps to select URL from multiple bit rate streams.
        '  callback : function(m3u8str as string) as string
        '     Write your own stream selector here
        '     return valid_selected_stream_url
        '  end function
    }
    requestResult = adapter.requestStream(request) ' Required
    if requestResult["error"] <> invalid
        print "Error requesting stream ";requestResult
    else
        '
        '  2.2  Get stream info returned from manifest server
        '
        streamInfo = adapter.getStreamInfo()
        if streamInfo = invalid or streamInfo["error"] <> invalid
            print "error "; streamInfo
        else
            '
            '  2.3  Configure video node
            '
            vidContent = createObject("RoSGNode", "ContentNode")
            vidContent.url = streamInfo.playURL
            '   When trackingmode:simple,  playURL is selected bitrate stream
            '   When trackingmode:xmkr,    playURL is equal to masterURL
            vidContent.title = m.top.streamConfig.title
            vidContent.streamformat = "hls"
            m.top.video.content = vidContent
            m.top.video.setFocus(true)
            m.top.video.visible = true
            m.top.video.EnableCookies()
        end if
        adIface = Roku_Ads()
        adIface.enableAdMeasurements(true) ' Required
        ' adIface.setContentLength()    ' Set app/content specific info
        ' adIface.setNielsenProgramId() ' Set app/content specific info
        ' adIface.setNielsenGenre()     ' Set app/content specific info
        ' adIface.setNielsenAppId()     ' Set app/content specific info
        adIface.setDebugOutput(true)
    end if
end function

function runLoop(adapter as object) as void
    if invalid = adapter
        ? "ADAPTER IS INVALID"
        ? "ADAPTER IS INVALID"
        ? "ADAPTER IS INVALID"
        return
    end if
    '

    '
    '   3.2  Enable adapter Ad tracking
    '
    port = CreateObject("roMessagePort")
    '
    '  Option:  RAFX_SSAI() adapter provides options to use RAF
    '    A. use RAF (default)
    '       When AdPod found, calls stitchedAdsInit()
    '       When msg, calls stitchedAdHandledEvent()
    '       this option allows both video and interactive ads rendered by RAF
    '    B. no RAF.stitchedAd call
    '       App is responsible to fire pixel via RAF.fireTrackingEvents()
    '       See callback functions in this sample
    '
    adapter.enableAds({ player: { sgnode: m.top.video, port: port }, ' Required
        useStitched: m.useStitched ' Optional, default is true
    })
    '
    '   3.1  Set callbacks
    '
    addCallbacks(adapter) ' Required when not using RAF.stitchedAdHandledEvent()
    '   3.3  Observe video node
    '
    m.top.video.observeFieldScoped("position", port) ' Required
    m.top.video.observeFieldScoped("control", port)
    m.top.video.observeFieldScoped("state", port)
    '
    '   3.4  Start playback and fire uo:contentImpression
    '
    m.top.video.control = "play"
    ? "Playing Video and Starting Loop"
    while true
        msg = wait(1000, port)
        if type(msg) = "roSGNodeEvent" and msg.getField() = "control" and msg.getNode() = m.top.video.id and not m.top.adPlaying and (msg.getData() = "stop" or msg.getData() = "done") or m.top.video = invalid
            exit while ' video node stopped. quit loop
        end if
        '
        '  3.5  Have adapter handle events
        '
        curAd = adapter.onMessage(msg) ' Required
        if "roSGNodeEvent" = type(msg) and "state" = msg.getField() and "finished" = msg.getData() and msg.getNode() = m.top.video.id then
            exit while ' stream ended. quit loop
        end if
    end while
    m.top.video.unobserveFieldScoped("position")
    m.top.video.unobserveFieldScoped("control")
    m.top.video.unobserveFieldScoped("state")
end function

'
'   Required, Configure callback functions when NOT using RAF.stitchedAdHandledEvent()
'
function addCallbacks(adapter) as void
    adapter.addEventListener(adapter.AdEvent.PODS, podsCallback)
    adapter.addEventListener(adapter.AdEvent.POD_START, podStartCallback)
    adapter.addEventListener(adapter.AdEvent.IMPRESSION, adEventCallback)
    adapter.addEventListener(adapter.AdEvent.FIRST_QUARTILE, adEventCallback)
    adapter.addEventListener(adapter.AdEvent.MIDPOINT, adEventCallback)
    adapter.addEventListener(adapter.AdEvent.THIRD_QUARTILE, adEventCallback)
    adapter.addEventListener(adapter.AdEvent.COMPLETE, adEventCallback)
    adapter.addEventListener(adapter.AdEvent.POD_END, podEndCallback)
    '
    m.adPod = invalid
    m.adIndex = 0
    m.COMPLETE = adapter.AdEvent.COMPLETE
end function

function podsCallback(podsInfo as object)
    adPods = podsInfo["adPods"] ' New list of adPods found
    print " Pod count: ";adPods.count()
    for each adPod in adPods
        print "   RenderTime: ";adPod.renderTime;"   Ad count: ";adPod.ads.count()
    end for
end function
function podStartCallback(podInfo as object)
    print "At ";podInfo.position;" from Adapter -- " ; podInfo.event
    if not m.top.adPlaying
        m.top.adPlaying = True
        m.top.video.enableTrickPlay = false
    end if
    if not m.useStitched
        m.adPod = podInfo["adPod"]
        if invalid <> m.adPod
            adIface = Roku_Ads()
            ' fire Pod pixel
            adIface.fireTrackingEvents(m.adPod, { type: podInfo.event }) ' Required
            m.adIndex = 0
        end if
    end if
end function
function adEventCallback(adInfo as object) as void
    print "At ";adInfo.position;" from Adapter -- " ; adInfo.event
    if invalid <> m.adPod and m.adIndex < m.adPod.ads.count()
        adIface = Roku_Ads()
        ' fire Ad pixel
        ad = m.adPod.ads[m.adIndex]
        adIface.fireTrackingEvents(ad, { type: adInfo.event }) ' Required
        if m.COMPLETE = adInfo.event
            m.adIndex += 1
        end if
    end if
end function
function podEndCallback(podInfo as object)
    print "At ";podInfo.position;" from Adapter -- " ; podInfo.event
    m.top.adPlaying = False
    m.top.video.enableTrickPlay = true
    m.top.video.setFocus(true)
    if invalid <> m.adPod
        adIface = Roku_Ads()
        ' fire Pod pixel
        adIface.fireTrackingEvents(m.adPod, { type: podInfo.event }) ' Required
        m.adIndex = 0
    end if
    m.adPod = invalid
end function