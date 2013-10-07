class Square

    constructor: (json) ->
        _.extend(@, json)

        # Convert all of the raw json units in this square's json to wrapped Unit objects
        units = []
        for unit in @units
            units.push(new Unit(unit))
        @units = units


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


    draw: (x, y) ->

        if @terrainType == 'water' or @terrainType == 'mountains' or @terrainType == 'forest'
            @drawSubTile(TB.images[@terrainType+'Tiles'], @northWestTile24, x, y, TB.camera.subGridSize, 0, 0)
            @drawSubTile(TB.images[@terrainType+'Tiles'], @northEastTile24, x, y, TB.camera.subGridSize, TB.camera.subGridSize, 0)
            @drawSubTile(TB.images[@terrainType+'Tiles'], @southWestTile24, x, y, TB.camera.subGridSize, 0, TB.camera.subGridSize)
            @drawSubTile(TB.images[@terrainType+'Tiles'], @southEastTile24, x, y, TB.camera.subGridSize, TB.camera.subGridSize, TB.camera.subGridSize)

            #unitX = screenX+ zoomedGridSize/2
            #unitY = screenY+ zoomedGridSize/2
            #unitRadius = (TB.unitSize * TB.zoomFactor) / 2

            #textX = unitX
            #textY = unitY + (6 * TB.zoomFactor)

            #if @units
            #    for owner, unit of @units
            #        TB.ctx.fillStyle = 'blue'
            #        TB.ctx.beginPath()
            #        TB.ctx.arc(unitX, unitY, unitRadius, 0, 2*Math.PI)
            #        TB.ctx.fill()
            #        TB.ctx.stroke()

            #        TB.ctx.fillStyle = 'black'
            #        TB.ctx.fillText(unit.amount, textX+1, textY+1)
            #        TB.ctx.fillText(unit.amount, textX+1, textY-1)
            #        TB.ctx.fillText(unit.amount, textX-1, textY+1)
            #        TB.ctx.fillText(unit.amount, textX-1, textY-1)
            #        TB.ctx.fillStyle = 'white'
            #        TB.ctx.fillText(unit.amount, textX, textY)

    drawSubTile: (image, subTile, screenX, screenY, subGridSize, subTileOffsetX, subTileOffsetY) ->
        TB.ctx.drawImage(
            image,
            @getTile24XOffset(subTile),
            @getTile24YOffset(subTile),
            TB.gridSize/2, TB.gridSize/2
            screenX + subTileOffsetX, screenY + subTileOffsetY,
            subGridSize, subGridSize
        )

    getTile24XOffset: (tile) -> return 24 * (tile) % 144
    getTile24YOffset: (tile) -> return parseInt(24 * tile / 144) * 24

