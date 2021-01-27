' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 

sub init()
    m.image = m.top.findNode("image")
    m.image.observeField("loadStatus", "omImageLoadStatusChange")
    m.rotationAnimation = m.top.findNode("rotationAnimation")
    m.rotationAnimationInterpolator = m.top.findNode("rotationAnimationInterpolator")
    m.fadeAnimation = m.top.findNode("fadeAnimation")
    m.loadingIndicatorGroup = m.top.findNode("loadingIndicatorGroup")
    m.loadingGroup = m.top.findNode("loadingGroup")
    m.background = m.top.findNode("background")
    
    m.areParentSizeObserversSet = false
    
    ' image could've been loaded by this time
    omImageLoadStatusChange()

    startAnimation()
end sub

sub updateLayout()
    ' check for parent node and set observers only once
    if not m.areParentSizeObserversSet
        parentNode = m.top.getParent()
        if parentNode <> invalid
            parentNode.observeField("width", "updateLayout")
            parentNode.observeField("height", "updateLayout")
            m.areParentSizeObserversSet = true
        end if
    end if

    componentWidth = getComponentWidth()
    componentHeight = getComponentHeight()
    
    m.background.width = componentWidth
    m.background.height = componentHeight
    
    if m.top.centered
        m.top.translation = [(getParentWidth() - componentWidth) / 2, (getParentHeight() - componentHeight) / 2]
    end if
    
    loadingGroupWidth = m.image.width
    
    loadingGroupHeight = m.image.height
    
    ' check whether image and text fit into component, if they don't - downscale image
    if m.imageAspectRatio <> invalid
        loadingGroupAspectRatio = loadingGroupWidth / loadingGroupHeight
        if loadingGroupWidth > componentWidth
            m.image.width = m.image.width - (loadingGroupWidth - componentWidth)
            m.image.height = m.image.width / m.imageAspectRatio
            loadingGroupWidth = m.image.width
            loadingGroupHeight = loadingGroupWidth / loadingGroupAspectRatio
        end if
        if loadingGroupHeight > componentHeight
            m.image.height = m.image.height - (loadingGroupHeight - componentHeight)
            m.image.width = m.image.height * m.imageAspectRatio
            loadingGroupHeight = m.image.height
            loadingGroupWidth = loadingGroupHeight * loadingGroupAspectRatio
        end if
    end if
    
    m.image.scaleRotateCenter = [m.image.width / 2, m.image.height / 2]
    
    ' position loading group, image and text at the center
    m.loadingGroup.translation = [(componentWidth - loadingGroupWidth) / 2, (componentHeight - loadingGroupHeight) / 2]
    m.image.translation = [(loadingGroupWidth - m.image.width) / 2, 0]
end sub


sub changeRotationDirection()
    if m.top.clockwise
        m.rotationAnimationInterpolator.key = [1, 0]
    else
        m.rotationAnimationInterpolator.key = [0, 1]
    end if
end sub


sub omImageLoadStatusChange()
    if m.image.loadStatus = "ready"
        m.imageAspectRatio = m.image.bitmapWidth / m.image.bitmapHeight
        
        if m.top.imageWidth > 0 and m.top.imageHeight <= 0
            m.image.height = m.image.width / m.imageAspectRatio
        else if m.top.imageHeight > 0 and m.top.imageWidth <= 0
            m.image.width = m.image.height * m.imageAspectRatio
        else if m.top.imageHeight <= 0 and m.top.imageWidth <= 0
            m.image.height = m.image.bitmapHeight
            m.image.width = m.image.bitmapWidth
        end if
        updateLayout()
    end if
end sub


sub onImageWidthChange()
    if m.top.imageWidth > 0
        m.image.width = m.top.imageWidth
        if m.top.imageHeight <= 0 and m.imageAspectRatio <> invalid
            m.image.height = m.image.width / m.imageAspectRatio
        end if
        updateLayout()
    end if
end sub


sub onImageHeightChange()
    if m.top.imageHeight > 0
        m.image.height = m.top.imageHeight
        if m.top.imageWidth <= 0 and m.imageAspectRatio <> invalid
            m.image.width = m.image.height * m.imageAspectRatio
        end if
        updateLayout()
    end if
end sub

sub onBackgroundImageChange()
    if m.top.backgroundUri <> ""
        previousBackground = m.background
        m.background = m.top.findNode("backgroundImage")
        m.background.opacity = previousBackground.opacity
        m.background.translation = previousBackground.translation
        m.background.width = previousBackground.width
        m.background.height = previousBackground.height
        m.background.uri = m.top.backgroundUri
        previousBackground.visible = false
    end if
end sub


sub onBackgroundOpacityChange()
    if m.background <> invalid
        m.background.opacity = m.top.backgroundOpacity
    end if
end sub


sub onControlChange()
    if m.top.control = "start"
        ' opacity could be set to 0 by fade animation so restore it
        m.loadingIndicatorGroup.opacity = 1
        startAnimation()
    else if m.top.control = "stop"
        ' if there is fadeInterval set, fully dispose component before stopping spinning animation
        if m.top.fadeInterval > 0
            m.fadeAnimation.duration = m.top.fadeInterval
            m.fadeAnimation.observeField("state", "onFadeAnimationStateChange")
            m.fadeAnimation.control = "start"
        else
            stopAnimation()
        end if
    end if
end sub


sub onFadeAnimationStateChange()
    if m.fadeAnimation.state = "stopped"
        stopAnimation()
    end if
end sub


function getComponentWidth() as Float
    if m.top.width = 0
        ' use parent's width
        return getParentWidth()
    else
        return m.top.width
    end if
end function


function getComponentHeight() as Float
    if m.top.height = 0
        ' use parent's height
        return getParentHeight()
    else
        return m.top.height
    end if
end function


function getParentWidth() as Float
    parentNode = m.top.getParent()
    if parentNode <> invalid and parentNode.width <> invalid
        return parentNode.width
    else
        return 1920
    end if
end function


function getParentHeight() as Float
    parentNode = m.top.getParent()
    if parentNode <> invalid and parentNode.height <> invalid
        return parentNode.height
    else
        return 1080
    end if
end function


sub startAnimation()
    ' don't start animation on devices that don't support it
    m.model = createObject("roDeviceInfo").getModel()
    'Get the first character of the model number. Anything less than a 4 corresponds to a device not suited to animations.
    first = Left(m.model, 1).trim()
    if first <> invalid and first.Len() = 1
        firstAsInt = val(first, 10)
        if (firstAsInt) > 3
            m.rotationAnimation.control = "start"
            m.top.state = "running"
        end if
    end if
end sub


sub stopAnimation()
    m.rotationAnimation.control = "stop"
    m.top.state = "stopped"
end sub


function max(a as Float, b as Float) as Float
    if a > b
        return a
    else
        return b
    end if
end function