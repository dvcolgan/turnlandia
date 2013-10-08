class Action
    constructor: (json) ->
        _.extend(@, json)



class ActionManager
    constructor: ->
        $(document).on 'unitPlaced', @handleInitialPlacement
        @actions = []

    handleAction: (type, col, row) ->
        switch type
            when 'initial'
                actionData =
                    type: 'initial'
                    srcCol: col
                    srcRow: row
                    destCol: col
                    destRow: row

        @actions.push(new Action(actionData))

        $.ajax
            url: '/api/action/'
            method: 'POST'
            dataType: 'json'
            data: actionData
            success: (response) ->
            error: (response) ->
                alert("Error saving move.  Please check your internet connection and try again: #{JSON.stringify(response)}")


    draw: ->
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
