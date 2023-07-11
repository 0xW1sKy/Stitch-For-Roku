sub init()
    m.top.functionName = "playContent"
    m.top.id = "PlayerTask"
end sub

sub playContent()

    video = m.top.video
    ' `view` is the node under which RAF should display its UI (passed as 3rd argument of showAds())
    view = video.getParent()
    content = video.content

    keepPlaying = true 'gets set to `false` when showAds() was exited via Back button

    port = CreateObject("roMessagePort")
    if keepPlaying then
        video.observeField("position", port)
        video.observeField("state", port)
        video.visible = true
        video.control = "play"
        video.setFocus(true) 'so we can handle a Back key interruption
    end if

    curPos = 0
    while keepPlaying
        msg = wait(0, port)
        if type(msg) = "roSGNodeEvent"
            if msg.GetField() = "position" then
                ' keep track of where we reached in content
                curPos = msg.GetData()
            else if msg.GetField() = "state" then
                curState = msg.GetData()
                print "PlayerTask: state = "; curState
                if curState = "stopped" then
                    exit while
                else if curState = "finished" then
                    print "PlayerTask: main content finished"
                    exit while
                    video.control = "stop"
                end if
            end if
        end if
    end while
    print "PlayerTask: exiting playContentWithAds()"
end sub