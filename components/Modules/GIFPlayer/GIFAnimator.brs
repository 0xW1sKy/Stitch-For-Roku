sub init()
    m.animator = CreateObject("roSGNode", "Timer")
    m.animator.ObserveField("fire", "displayNextFrame")
    m.animator.repeat = true

    m.frames = []
    m.frameIndex = -1
    m.poster = invalid
end sub

function start(frames as object, fps as float, poster as object, frameDelay as object)
    m.frames = frames
    m.poster = poster
    m.frameDelay = frameDelay
    ? "framedelay: "; frameDelay
    ? "fps: "; fps
    m.animator.duration = m.frameDelay[0]
    m.animator.control = "start"
end function

function finish()
    m.animator.control = "stop"

    ' Restore first frame
    if m.frames.count() > 0
        m.poster.uri = m.frames[0]
    end if

    m.frameIndex = -1
    m.frames = []
    m.frameDelay = []
    m.poster = invalid
end function

sub displayNextFrame()
    m.frameIndex++
    if m.frameIndex >= m.frames.count()
        m.frameIndex = 0
    end if

    m.poster.uri = m.frames[m.frameIndex]
    m.animator.duration = m.frameDelay[m.frameIndex]
end sub