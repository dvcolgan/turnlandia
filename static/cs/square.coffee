class Square

    constructor: (json) ->
        _.extend(@, json)

    draw: ->

        if @terrainType == 'water' or @terrainType == 'mountains' # or @terrainType == 'forest'
            if not @subTiles
                @subTiles = TB.board.getSubtiles(@col, @row)
            @drawSubTile(@subTiles[0][0], 0, 0)
            @drawSubTile(@subTiles[0][1], TB.camera.zoomedSubGridSize, 0)
            @drawSubTile(@subTiles[1][0], 0, TB.camera.zoomedSubGridSize)
            @drawSubTile(@subTiles[1][1], TB.camera.zoomedSubGridSize, TB.camera.zoomedSubGridSize)


    drawSubTile: (subTile, subTileOffsetX, subTileOffsetY) ->

        screenX = TB.camera.worldColToScreenPosX(@col)
        screenY = TB.camera.worldRowToScreenPosY(@row)

        TB.ctx.drawImage(
            TB.images[@terrainType+'Tiles'],
            subTile[0], subTile[1],
            TB.gridSize/2, TB.gridSize/2,
            screenX + subTileOffsetX, screenY + subTileOffsetY,
            TB.camera.zoomedSubGridSize, TB.camera.zoomedSubGridSize
        )

