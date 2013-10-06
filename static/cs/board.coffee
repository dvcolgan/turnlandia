class DataFetcher
    constructor: ->
        @loadingStates = new util.Hash2D()


    loadInitialData: (callback) ->
        $.ajax
            url: '/api/initial-load/'
            method: 'GET'
            dataType: 'json'
            success: (data) =>
                callback(data)

    loadSectors: (startSectorX, startSectorY, endSectorX, endSectorY, callback) ->
        for sectorX in [startSectorX..endSectorX]
            for sectorY in [startSectorY..endSectorY]
                if @loadingStates.get(sectorX, sectorY) == null
                    @loadingStates.set(sectorX, sectorY, false)
                    @loadSector(sectorX, sectorY, callback)

    loadSector: (sectorX, sectorY, callback) ->
        $.ajax({
            url: '/api/squares/' + (sectorX*TB.sectorSize) + '/' + (sectorY*TB.sectorSize) + '/' + (TB.sectorSize) + '/' + (TB.sectorSize) + '/'
            method: 'GET'
            dataType: 'json'
            success: (data) =>
                @loadingStates.set(sectorX, sectorY, true)
                callback(data)
        })


class Board

    placeUnit: (col, row, owner) ->
        square = TB.squareData.get(col, row)
        if not square.units
            square.units = {}
            square.units[owner] =
                color: 'blue'
                amount: 1
        else
            square.units[owner].amount++
        $(document).trigger
            type: 'unitPlaced'
            col: col
            row: row
            

    draw: ->
        TB.ctx.textAlign = 'center'
        TB.ctx.fillStyle = '#148743'
        TB.ctx.fillRect(0, 0, TB.boardWidth, TB.boardHeight)
        TB.ctx.lineWidth = 1

        zoomedGridSize = TB.gridSize*TB.zoomFactor
        subGridSize = zoomedGridSize/2

        startCol = Math.floor(TB.scroll.x/zoomedGridSize)
        startRow = Math.floor(TB.scroll.y/zoomedGridSize)

        endCol = startCol + Math.ceil(TB.boardWidth/zoomedGridSize)
        endRow = startRow + Math.ceil(TB.boardHeight/zoomedGridSize)

        for row in [startRow..endRow]
            for col in [startCol..endCol]
                thisSquare = TB.squareData.get(col, row)

                screenX = (col * zoomedGridSize) - TB.scroll.x
                screenY = (row * zoomedGridSize) - TB.scroll.y

                if thisSquare

                    if thisSquare.terrainType == 'water' or thisSquare.terrainType == 'mountains' or thisSquare.terrainType == 'forest'
                        @drawSubTile(TB.images[thisSquare.terrainType+'Tiles'], thisSquare.northWestTile24, screenX, screenY, subGridSize, 0, 0)
                        @drawSubTile(TB.images[thisSquare.terrainType+'Tiles'], thisSquare.northEastTile24, screenX, screenY, subGridSize, subGridSize, 0)
                        @drawSubTile(TB.images[thisSquare.terrainType+'Tiles'], thisSquare.southWestTile24, screenX, screenY, subGridSize, 0, subGridSize)
                        @drawSubTile(TB.images[thisSquare.terrainType+'Tiles'], thisSquare.southEastTile24, screenX, screenY, subGridSize, subGridSize, subGridSize)

                    unitX = screenX+ zoomedGridSize/2
                    unitY = screenY+ zoomedGridSize/2
                    unitRadius = (TB.unitSize * TB.zoomFactor) / 2

                    textX = unitX
                    textY = unitY + (6 * TB.zoomFactor)

                    if thisSquare.units
                        for owner, unit of thisSquare.units
                            TB.ctx.fillStyle = 'blue'
                            TB.ctx.beginPath()
                            TB.ctx.arc(unitX, unitY, unitRadius, 0, 2*Math.PI)
                            TB.ctx.fill()
                            TB.ctx.stroke()

                            TB.ctx.fillStyle = 'black'
                            TB.ctx.fillText(unit.amount, textX+1, textY+1)
                            TB.ctx.fillText(unit.amount, textX+1, textY-1)
                            TB.ctx.fillText(unit.amount, textX-1, textY+1)
                            TB.ctx.fillText(unit.amount, textX-1, textY-1)
                            TB.ctx.fillStyle = 'white'
                            TB.ctx.fillText(unit.amount, textX, textY)


    drawSubTile: (image, subTile, screenX, screenY, subGridSize, subTileOffsetX, subTileOffsetY) ->
        TB.ctx.drawImage(
            image,
            @getTile24XOffset(subTile),
            @getTile24YOffset(subTile),
            TB.gridSize/2, TB.gridSize/2
            screenX + subTileOffsetX, screenY + subTileOffsetY,
            subGridSize, subGridSize
        )
    getTile24XOffset: (tile) ->
        return 24 * (tile) % 144
    getTile24YOffset: (tile) ->
        return parseInt(24 * tile / 144) * 24








