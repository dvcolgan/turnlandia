
class Board
    scroll: { x: 0, y: 0 }
    lastMouse: { x: 0, y: 0 }
    lastScroll: { x: 0, y: 0 }
    dragging: false

    gridSize: 48
    sectorSize: 10

    squareData: new Hash2D()
    squareDomNodes: new Hash2D()
    sectorData: new Hash2D()
    sectorDomNodes: new Hash2D()

    constructor: (@selector) ->
        $(@selector).mousedown (event) =>
            event.preventDefault()
            @lastMouse = { x: event.clientX, y: event.clientY }
            @lastScroll.x = @scroll.x
            @lastScroll.y = @scroll.y
            @dragging = true

        $(@selector).mousemove (event) =>
            if @dragging
                event.preventDefault()
                @scroll.x = @lastScroll.x - (event.clientX - @lastMouse.x)
                @scroll.y = @lastScroll.y - (event.clientY - @lastMouse.y)

                @loadSectorsOnScreen()

        $(document).mouseup (event) =>
            @dragging = false

        resizeBoard = =>
            $(@selector).width(@getViewWidth()).height(@getViewHeight())
            $(window).resize(resizeBoard)
        resizeBoard()
        



    getViewWidth: ->
        $(window).width() - (48+20) - 160
    getViewHeight: ->
        $(window).height() - 96

    # Only call this in the handler of the needsector event
    receiveSectorData: (sectorX, sectorY, squares) ->
        @sectorData.set(sectorX, sectorY, squares)
        @showSector(sectorX, sectorY)
        @scrollSector(sectorX, sectorY)

    loadSectorsOnScreen: ->
        # Don't load the sector if it is beyond the current board extent
        #if (sector_x > @max_sector_x or
        #sector_x < @min_sector_x or
        #sector_y > @max_sector_y or
        #sector_y < @min_sector_y)
        #    return


        # When you move the mouse,
        # find all the sectors that should be loaded
        # for each sector
        #     check to see if you have the sector data
        #     if you do, show that sector
        #     if you don't
        #         if the sector is not loading, mark it as loading and load it and provide a callback to show that sector when it is done loading
        #         else do nothing

        # Find all of the sectors that should be visible
        sectorPixelSize = @sectorSize * @gridSize
        sectorsWide = Math.ceil(@getViewWidth() / @sectorSize / @gridSize)
        sectorsHigh = Math.ceil(@getViewHeight() / @sectorSize / @gridSize)

        startSectorX = null
        startSectorY = null
        endSectorX = null
        endSectorY = null
        for sectorSectorX in [0..sectorsWide]
            for sectorSectorY in [0..sectorsHigh]
                x = (Math.floor(@scroll.x / sectorPixelSize)) + sectorSectorX
                y = (Math.floor(@scroll.y / sectorPixelSize)) + sectorSectorY

                if startSectorX == null or x < startSectorX then startSectorX = x
                if startSectorY == null or y < startSectorY then startSectorY = y
                if endSectorX == null or x > endSectorX then endSectorX = x
                if endSectorY == null or y > endSectorY then endSectorY = x

        # Remove any dom nodes that are no longer visible
        for $domNode in @sectorDomNodes.values()
            sectorX = $domNode.data('y')
            sectorY = $domNode.data('x')
            if not ((sectorX <= endSectorX and sectorX >= startSectorX) and
                    (sectorY <= endSectorY and sectorY >= startSectorY))
                @sectorDomNodes.delete(sectorX, sectorY).remove()


        for sectorX in [startSectorX..endSectorX]
            for sectorY in [startSectorY..endSectorY]
                # If we don't have this sector showing
                if @sectorDomNodes.get(sectorX, sectorY) == null
                    # Three cases:
                    # we do have the data -> show it
                    # don't have the data, but it is loading -> skip
                    # don't have the data, it is not loading -> load
                    if @sectorData.get(sectorX, sectorY) == null
                        @sectorData.set(sectorX, sectorY, 'loading')
                        $(@selector).trigger('needsector', [sectorX, sectorY])
                    else if @sectorData.get(sectorX, sectorY) != 'loading'
                        # We have the data but it isn't showing, so show it and scroll it
                        @showSector(sectorX, sectorY)
                        @scrollSector(sectorX, sectorY)
                else
                    if @sectorDomNodes.get(sectorX, sectorY) != 'loading'
                        @scrollSector(sectorX, sectorY)




    # Showing a sector fully creates the dom node and everything in it
    showSector: (sectorX, sectorY) ->
        $sectorDomNode = $('<div class="sector disable-select"></div>')
        $sectorDomNode.data('x', sectorX)
        $sectorDomNode.data('y', sectorY)
        $(@selector).append($sectorDomNode)
        @sectorDomNodes.set(sectorX, sectorY, $sectorDomNode)
                    

    scrollSector: (sectorX, sectorY) ->
        $domNode = @sectorDomNodes.get(sectorX, sectorY)
        $domNode.css('left',((sectorX * @sectorSize * @gridSize) - @scroll.x) + 'px')
        $domNode.css('top', ((sectorY * @sectorSize * @gridSize) - @scroll.y) + 'px')




    getTile24CSSOffset: (tile) ->
        return (24 * (tile) % 144 * -1) + 'px ' + (parseInt(24 * tile / 144) * 24 * -1) + 'px'






