class Unit
    constructor: (json) ->
        _.extend(@, json)


    draw: ->
        screenX = TB.camera.worldToScreenPosX(@col * TB.gridSize)
        screenY = TB.camera.worldToScreenPosY(@row * TB.gridSize)

        unitX = screenX + TB.camera.zoomedGridSize/2
        unitY = screenY + TB.camera.zoomedGridSize/2
        unitRadius = (TB.camera.zoomedUnitSize)/2

        textX = unitX
        textY = unitY + 5

        TB.ctx.save()
        TB.ctx.fillStyle = @ownerColor
        rgb = util.hexToRGB(@ownerColor)
        rgb.r = parseInt(rgb.r * 0.4)
        rgb.g = parseInt(rgb.g * 0.4)
        rgb.b = parseInt(rgb.b * 0.4)
        TB.ctx.strokeStyle = "rgba(#{rgb.r},#{rgb.g},#{rgb.b},1)"
        TB.ctx.lineWidth = 2
        TB.ctx.beginPath()
        #TB.ctx.arc(action.srcCol, action.srcRow, TB.camera.zoomedUnitSize / 2, 0, 2*Math.PI)
        TB.ctx.arc(unitX, unitY, TB.camera.zoomedUnitSize/2, 0, 2*Math.PI)
        TB.ctx.fill()
        TB.ctx.stroke()
        TB.ctx.textAlign = 'center'
        TB.fillOutlinedText(@amount, textX, textY)
        TB.ctx.restore()

class Tree
    constructor: (json) ->
        _.extend(@, json)

    draw: ->
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
            TB.images.forestTiles
            subTile[0], subTile[1],
            TB.gridSize/2, TB.gridSize/2,
            screenX + subTileOffsetX, screenY + subTileOffsetY,
            TB.camera.zoomedSubGridSize, TB.camera.zoomedSubGridSize
        )

class Road
