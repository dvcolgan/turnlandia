# The code that creates a board object should listen for the needsector event and pass in the
# sector data when they handle the event with receiveSectorData.
#
# The board class has the data of a sector as well as the dom nodes for a sector.
# Only the dom nodes of the sectors that are on the screen persist - if they go off the screen,
# they are removed and garbage collected.
#
# However, the data for that sector remains and is not discarded.
#
# When a sector needs to be shown, it first checks to see if it needs the data.
# If it does, it raises the needsector event and defers until the receiveSectorData method
# is called.  If it already has the data, or if the data is received, it creates the dom node.

class Board

    constructor: (@selector) ->
        @scroll = { x: 0, y: 0 }
        @lastMouse = { x: 0, y: 0 }
        @lastScroll = { x: 0, y: 0 }
        @dragging = false

        @gridSize = 48
        @sectorSize = 10

        @squareData = new Hash2D()
        @squareDomNodes = new Hash2D()
        @sectorData = new Hash2D()
        @sectorDomNodes = new Hash2D()

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
        @makeSectorDomNode(sectorX, sectorY)
        @scrollSector(sectorX, sectorY)

    loadSectorsOnScreen: ->
        # Don't load the sector if it is beyond the current board extent
        #if (sectorX > @maxSectorX or
        #sectorX < @minSectorX or
        #sectorY > @maxSectorY or
        #sectorY < @minSectorY)
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
                        @makeSectorDomNode(sectorX, sectorY)
                        @scrollSector(sectorX, sectorY)
                else
                    if @sectorDomNodes.get(sectorX, sectorY) != 'loading'
                        @scrollSector(sectorX, sectorY)


    # Showing a sector fully creates the dom node and everything in it
    makeSectorDomNode: (sectorX, sectorY) ->
        $sectorDomNode = $('<div class="sector disable-select"></div>')
        $sectorDomNode.data('x', sectorX)
        $sectorDomNode.data('y', sectorY)
        $(@selector).append($sectorDomNode)
        @sectorDomNodes.set(sectorX, sectorY, $sectorDomNode)

        thisSectorData = @sectorData.get(sectorX, sectorY)

        for row in [0...@sectorSize]
            for col in [0...@sectorSize]
                thisSquare = thisSectorData[sectorX*@sectorSize+col][sectorY*@sectorSize+row]
                $squareDomNode = $('<div class="grid-square">
                                        <div class="subtile north-west"></div>
                                        <div class="subtile north-east"></div>
                                        <div class="subtile south-west"></div>
                                        <div class="subtile south-east"></div>
                                    </div>')
                $squareDomNode
                    .css('left', (col * @gridSize) + 'px')
                    .css('top', (row * @gridSize) + 'px')

                # Determine how this square will look
                if thisSquare.terrainType == 'water' or thisSquare.terrainType == 'mountains' or thisSquare.terrainType == 'forest'
                    $squareDomNode.find('.subtile').css('background-image', 'url(/static/images/' + thisSquare.terrainType + '-tiles.png)')
                    $squareDomNode.find('.north-west').css('background-position', @getTile24CSSOffset(thisSquare.northWestTile24))
                    $squareDomNode.find('.north-east').css('background-position', @getTile24CSSOffset(thisSquare.northEastTile24))
                    $squareDomNode.find('.south-west').css('background-position', @getTile24CSSOffset(thisSquare.southWestTile24))
                    $squareDomNode.find('.south-east').css('background-position', @getTile24CSSOffset(thisSquare.southEastTile24))

                #@$dom_node.css('background-color': @owner_color)
                $squareDomNode.css('background-color': '#00aa44')

                $squareDomNode.data('col', @col).data('row', @row)

                $sectorDomNode.append($squareDomNode)

        

    scrollSector: (sectorX, sectorY) ->
        $domNode = @sectorDomNodes.get(sectorX, sectorY)
        $domNode.css('left',((sectorX * @sectorSize * @gridSize) - @scroll.x) + 'px')
        $domNode.css('top', ((sectorY * @sectorSize * @gridSize) - @scroll.y) + 'px')




    getTile24CSSOffset: (tile) ->
        return (24 * (tile) % 144 * -1) + 'px ' + (parseInt(24 * tile / 144) * 24 * -1) + 'px'






