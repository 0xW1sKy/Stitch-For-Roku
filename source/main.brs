sub Main(input as dynamic)
    ' Add deep linking support here. Input is an associative array containing
    ' parameters that the client defines. Examples include "options, contentID, etc."
    ' See guide here: https://sdkdocs.roku.com/display/sdkdoc/External+Control+Guide
    ' For example, if a user clicks on an ad for a movie that your app provides,
    ' you will have mapped that movie to a contentID and you can parse that ID
    ' out from the input parameter here.
    ' Call the service provider API to look up
    ' the content details, or right data from feed for id
    if input <> invalid
        print "Received Input -- write code here to check it!"
        ' if input.instant_on_run_mode <> invalid
        '     print "Instant On Run Mode: "; input.instant_on_run_mode
        ' end if
        ' if input.lastExitOrTerminationReason <> invalid
        '     print "Last Exit or Termination Reason: "; input.lastExitOrTerminationReason
        ' end if
        ' if input.source <> invalid
        '     print "Source: "; input.source
        ' end if
        ' if input.splashTime <> invalid
        '     print "Splash Time: "; input.splashTime
        ' end if
        if input.reason <> invalid
            if input.reason = "ad" then
                print "Channel launched from ad click"
                'do ad stuff here
            end if
        end if
        if input.contentID <> invalid
            m.contentID = input.contentID
            print "contentID is: " + input.contentID
            'launch/prep the content mapped to the contentID here
        end if
    end if
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    ' Set global constants
    m.global = screen.getGlobalNode()
    setConstants()
    screen.setMessagePort(m.port)
    m.scene = screen.CreateScene("HeroScene")
    ' The main function that runs when the application is launched.
    screen.show()
    ' vscode_rdb_on_device_component_entry
    m.scene.observeField("exitApp", m.port)
    m.scene.setFocus(true)
    ' m.global = m.screen.getGlobalNode()
    while (true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent" then
            if msg.isScreenClosed() then
                return
            end if
        else if msgType = "roSGNodeEvent" then
            field = msg.getField()
            if field = "exitApp" then
                return
            end if
        end if
    end while
end sub