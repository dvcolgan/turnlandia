class Square

    constructor: (json) ->
        _.extend(@, json)

    draw: ->
        screenX = (@col * TB.camera.zoomedGridSize) - TB.camera.x
        screenY = (@row * TB.camera.zoomedGridSize) - TB.camera.y

        if @terrainType == 'water' or @terrainType == 'mountains' or @terrainType == 'forest'
            @drawSubTile(TB.images[@terrainType+'Tiles'], @northWestTile24, screenX, screenY, TB.camera.subGridSize, 0, 0)
            @drawSubTile(TB.images[@terrainType+'Tiles'], @northEastTile24, screenX, screenY, TB.camera.subGridSize, TB.camera.subGridSize, 0)
            @drawSubTile(TB.images[@terrainType+'Tiles'], @southWestTile24, screenX, screenY, TB.camera.subGridSize, 0, TB.camera.subGridSize)
            @drawSubTile(TB.images[@terrainType+'Tiles'], @southEastTile24, screenX, screenY, TB.camera.subGridSize, TB.camera.subGridSize, TB.camera.subGridSize)

            unitX = screenX + TB.camera.zoomedGridSize/2
            unitY = screenY + TB.camera.zoomedGridSize/2
            unitRadius = (TB.camera.zoomedUnitSize) / 2

            textX = unitX
            textY = unitY + (6 * TB.zoomFactor)

            if @unitAmount > 0
                TB.ctx.fillStyle = 'blue'
                TB.ctx.beginPath()
                TB.ctx.arc(unitX, unitY, unitRadius, 0, 2*Math.PI)
                TB.ctx.fill()
                TB.ctx.stroke()

                TB.ctx.fillStyle = 'black'
                TB.ctx.fillText(@unitAmount, textX+1, textY+1)
                TB.ctx.fillText(@unitAmount, textX+1, textY-1)
                TB.ctx.fillText(@unitAmount, textX-1, textY+1)
                TB.ctx.fillText(@unitAmount, textX-1, textY-1)
                TB.ctx.fillStyle = 'white'
                TB.ctx.fillText(@unitAmount, textX, textY)

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

