sub init()
    m.top.functionName = "runTask"
end sub

function runTask()
    ? "Hit"
    '  2. Request preplay
    '
    loadStream()
    '
    '  3. Play content
    '
    runLoop()
end function

function loadStream()
    ? "Hit2"
    '
    '  2.3  Setup video node.  Select here variant
    '
    vidContent = m.top.content
    vidContent.title = m.top.content.contentTitle
    m.top.video.content = vidContent
    m.top.video.setFocus(true)
    m.top.video.visible = true
    m.top.video.enableCookies()
end function

function runLoop() as void
    ? "Hit3"
    port = CreateObject("roMessagePort")
    '   3.3  Observe video node
    '
    m.top.video.observeFieldScoped("position", port) ' Required
    m.top.video.observeFieldScoped("control", port)
    m.top.video.observeFieldScoped("state", port)
    '
    '   3.4  Start playback and fire uo:contentImpression
    '
    m.top.video.control = "play"
    while true
        msg = wait(1000, port)
        '
        '  3.5  Have adapter handle events
        '
        if "roSGNodeEvent" = type(msg)
            if "state" = msg.getField() and "finished" = msg.getData() and msg.getNode() = m.top.video.id then
                exit while ' stream ended. quit loop
            end if
            if "state" = msg.getField() and "stopped" = msg.getData() and msg.getNode() = m.top.video.id then
                exit while ' video node stopped. quit loop
            end if
        end if
    end while
    m.top.video.unobserveFieldScoped("position")
    m.top.video.unobserveFieldScoped("control")
    m.top.video.unobserveFieldScoped("state")
end function