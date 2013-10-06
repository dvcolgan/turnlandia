class Cursor
    constructor: ->
        @pos = { x: 0, y: 0 }

    move: (x, y) ->
        @pos.x = x
        @pos.y = y

    draw: ->
        cursorSize = TB.gridSize * TB.zoomFactor
        offset = cursorSize/2
        TB.ctx.strokeStyle = 'black'
        TB.ctx.fillStyle = 'black'

        col = Math.floor(@pos.x / cursorSize)
        row = Math.floor(@pos.y / cursorSize)

        snappedX = col * cursorSize
        snappedY = row * cursorSize

        screenX = TB.worldToScreenPosX(snappedX)
        screenY = TB.worldToScreenPosY(snappedY)
        TB.ctx.strokeRect(screenX, screenY, cursorSize, cursorSize)

        TB.ctx.font = 'bold 16px Arial'
        TB.ctx.fillStyle = 'black'
        textX = screenX - 8
        textY = screenY - 4
        TB.ctx.fillText(col + ',' + row, textX+1, textY+1)
        TB.ctx.fillText(col + ',' + row, textX-1, textY+1)
        TB.ctx.fillText(col + ',' + row, textX+1, textY-1)
        TB.ctx.fillText(col + ',' + row, textX-1, textY-1)

        TB.ctx.fillStyle = 'white'
        TB.ctx.fillText(col + ',' + row, textX, textY)
