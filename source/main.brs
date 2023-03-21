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
    RunUserInterface()
end sub

' Initializes the scene and shows the main homepage.
' Handles closing of the channel.
sub RunUserInterface()
    ' The main function that runs when the application is launched.
    m.screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    ' Set global constants
    setConstants()
    m.screen.setMessagePort(m.port)
    m.scene = m.screen.CreateScene("HeroScene")
    m.screen.show()
    m.global = m.screen.getGlobalNode()
    ' vscode_rdb_on_device_component_entry
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then
                return
            end if
        end if
    end while
end sub
