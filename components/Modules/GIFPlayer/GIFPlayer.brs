function init()
    ' m.poster = m.top.findNode("poster")
    ' m.timer = m.top.findNode("timer")
    m.top.observeField("width", "onSizeChange")
    m.top.observeField("height", "onSizeChange")
    ' m.top.observeField("control", "onControlChange")
    ' m.timer.observeField("fire", "onTimerFireChange")
    ' m.direction = 1
    ' m.top.frameOffsets = []
    ' m.currentIndex = 0
    m.animator = createObject("roSGNode", "GIFAnimator")
    m.decoder = createObject("roSGNode", "GIFDecoder")
    m.top.observeField("uri", "onUriChange")
    m.firstRun = true
end function

sub onUriChange()
    if m.firstRun
        m.firstRun = false
        ' ? "GifPlayer URI"; m.top.uri
        m.decoder.uri = m.top.uri
        m.decoder.observefield("finished", "gifDecoderDidFinish")
        m.decoder.control = "RUN"
    end if
end sub

sub gifDecoderDidFinish()
    ' ? "Decoder Finished"
    frames = m.decoder.frames
    fps = m.decoder.fps
    frameDelay = m.decoder.framedelay
    m.animator.callFunc("start", frames, fps, m.top, frameDelay)
end sub

sub focusItem(item as integer)
    ' Stop previous poster animation
    m.animator.callFunc("finish")
end sub

function onSizeChange()
    m.top.clippingRect = {
        width: m.top.width
        height: m.top.height
        x: 0
        y: 0
    }
end function

' function onControlChange() as void
'     if m.top.control = "start" and m.top.frameOffsets = invalid or m.top.frameOffsets.count() = 0 or m.top.spriteSheetUri = invalid or m.top.spriteSheetUri = ""
'         ? "Please set Set the frames and sprite sheet uri"
'         return
'     end if

'     m.timer.repeat = m.top.loopMode <> "once"
'     m.timer.control = m.top.control
' end function

' function onTimerFireChange() as void
'     if m.top.frameOffsets.count() = 0
'         return
'     end if

'     m.currentIndex += m.direction
'     if m.currentIndex < 0 'only could do this in ping pong
'         m.currentIndex = 1
'         direction = 1
'     else if m.currentIndex = m.top.frameOffsets.count()
'         if m.top.loopMode = "loop"
'             m.currentIndex = 0
'         else if m.top.loopMode = "ping-pong"
'             m.currentIndex = m.top.frameOffsets.count() - 1
'             direction = -1
'         end if
'     end if

'     frame = m.top.frameOffsets[m.currentIndex]
'     if frame <> invalid and frame.count() = 2
'         m.poster.translation = [-frame[0], -frame[1]]
'     end if
' end function