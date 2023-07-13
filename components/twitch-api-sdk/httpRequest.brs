sub init()
    m.top.functionName = "basicRequest"
end sub

function writeResponse(data)
    if data <> invalid
        m.top.response = { "data": data }
    else
        m.top.response = { "response": invalid }
    end if
    m.top.control = "STOP"
end function

function basicRequest()
    req = HttpRequest({
        url: m.top.request.url
        headers: m.top.request.headers
        method: m.top.request.method
    })
    while true
        rsp = req.send().getString()
        if rsp <> invalid
            exit while
        end if
        sleep(10)
    end while
    writeResponse(rsp)
end function

