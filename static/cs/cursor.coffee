class Cursor
    constructor: ->
        @pos = { x: 0, y: 0 }

    move: (x, y) ->
        @pos.x = x
        @pos.y = y

    draw: ->
        cursorSize = TB.gridSize * TB.camera.zoomFactor

        col = Math.floor(@pos.x / cursorSize)
        row = Math.floor(@pos.y / cursorSize)

        screenX = TB.camera.worldToScreenPosX(col * TB.camera.zoomedGridSize)
        screenY = TB.camera.worldToScreenPosY(row * TB.camera.zoomedGridSize)

        TB.ctx.save()
        TB.ctx.strokeStyle = 'black'
        TB.ctx.fillStyle = 'black'
        TB.ctx.strokeRect(screenX, screenY, cursorSize, cursorSize)
        TB.ctx.restore()

        textX = screenX - 8
        textY = screenY - 4
        TB.fillOutlinedText(col + ',' + row, textX, textY)
