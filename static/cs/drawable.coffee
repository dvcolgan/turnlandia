class Drawable
    constructor: ->

    update: ->

    drawAbsolute: ->


    drawTranslated: ->


        G.ctx.save()
        G.ctx.translate(x, y)
        G.ctx.rotate(rot)
        G.ctx.translate(-offset.x, -offset.y)
        G.ctx.drawImage(
            G.images.spritesheetImage,
            @frames[@currentFrame]*@width, @row*@height,
            @width, @height,
            0, 0,
            @width, @height)
        G.ctx.restore()




        TB.ctx.textAlign = 'right'
        TB.fillOutlinedText("This Turn's Actions", TB.camera.width - 16, 24)
        initialPlacements = new util.Hash2D()

        for action, i in @actions
            TB.fillOutlinedText(action.type, TB.camera.width - 16, 24 + i*24 + 24)

            if action.type == 'initial'
                initialPlacements.increment(action.srcCol, action.srcRow)

        for col, rowData of initialPlacements.getRaw()
            for row, amount of rowData
                screenX = (action.srcCol * TB.camera.zoomedGridSize) - TB.camera.x
                screenY = (action.srcRow * TB.camera.zoomedGridSize) - TB.camera.y
                unitX = screenX + TB.camera.zoomedGridSize/2
                unitY = screenY + TB.camera.zoomedGridSize/2
                unitRadius = (TB.camera.zoomedUnitSize) / 2

                #textX = unitX
                #textY = unitY + (6 * TB.zoomFactor)

                textX = 300
                textY = 300 + 5
                amount = 10

                TB.ctx.save()
                TB.ctx.fillStyle = 'white'
                TB.ctx.beginPath()
                #TB.ctx.arc(action.srcCol, action.srcRow, TB.camera.zoomedUnitSize / 2, 0, 2*Math.PI)
                TB.ctx.arc(unitX, unitY, TB.camera.zoomedUnitSize / 2, 0, 2*Math.PI)
                TB.ctx.fill()
                TB.ctx.stroke()

                TB.ctx.fillStyle = 'black'
                TB.ctx.textAlign = 'center'
                TB.ctx.fillText(amount, textX+1, textY+1)
                TB.ctx.fillText(amount, textX+1, textY-1)
                TB.ctx.fillText(amount, textX-1, textY+1)
                TB.ctx.fillText(amount, textX-1, textY-1)
                TB.ctx.fillStyle = 'white'
                TB.ctx.fillText(amount, textX, textY)
                TB.ctx.restore()
