
class Board

    constructor: ->
        @squares = new util.Hash2D()


    addSquare: (square) ->
        @squares.set(square.col, square.row, new Square(square))


    draw: ->
        TB.ctx.textAlign = 'center'
        TB.ctx.fillStyle = '#148743'
        TB.ctx.fillRect(0, 0, TB.camera.width, TB.camera.height)
        TB.ctx.lineWidth = 1


        startCol = Math.floor(TB.camera.x/TB.camera.zoomedGridSize)
        startRow = Math.floor(TB.camera.y/TB.camera.zoomedGridSize)

        endCol = startCol + Math.ceil(TB.camera.width/TB.camera.zoomedGridSize)
        endRow = startRow + Math.ceil(TB.camera.height/TB.camera.zoomedGridSize)

        for row in [startRow..endRow]
            for col in [startCol..endCol]
                thisSquare = @squares.get(col, row)

                screenX = (col * TB.camera.zoomedGridSize) - TB.camera.x
                screenY = (row * TB.camera.zoomedGridSize) - TB.camera.y

                if thisSquare
                    thisSquare.draw(screenX, screenY)
