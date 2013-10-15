class Action
    isValid: ->
        return false

    save: ->
        actionData =
            kind: @kind
            col: @col
            row: @row
            move_path: @movePath

        $.ajax
            url: '/api/action/'
            method: 'POST'
            dataType: 'json'
            data: actionData
            success: (response) ->
            error: (response) ->
                alert("Error saving move.  Please check your internet connection and try again: #{JSON.stringify(response)}")


class InitialPlacementAction extends Action
    constructor: (@col, @row) ->
        @kind = 'initial'
        @name = 'Initial Placement'

    isValid: ->
        return TB.actions.count() < 8 and TB.board.isPassable(@col, @row) and TB.board.getUnitCount(@col, @row) == 0

    save: ->
        super()

    draw: ->
        # This is kludgily in the actionmanager draw function OOPS HOW DO I FIX THIS
        # If you place two on a square, this action has to know about another action


class MoveAction extends Action
    parseMovePath: (movePath) ->
        moves = (coord.split(',') for coord in movePath.split('|'))
        _.map(moves, (coords) -> [parseInt(coords[0]), parseInt(coords[1])])

    constructor: (@col, @row, @movePath) ->
        @kind = 'move'
        @name = 'Move'
        if @movePath
            @started = true
            @finished = true
            @moves = @parseMovePath(@movePath)
        else
            @moves = []
            @started = false
            @finished = false
            $('.btn-move').addClass('yellow').find('span').text('Move To?')

            @possibleMoves = new util.Hash2D()
            @squareTraversalCosts = new util.Hash2D()
            
            @possibleMoves.set(@col, @row, 0)
            for i in [1..6]
                @possibleMoves.iterateIntKeys (col, row, dist) =>
                    if dist == i-1
                        east = TB.board.isPassable(col+1, row)
                        west = TB.board.isPassable(col-1, row)
                        south = TB.board.isPassable(col, row+1)
                        north = TB.board.isPassable(col, row-1)
                        if east then @possibleMoves.set(col+1, row, i)
                        if west then @possibleMoves.set(col-1, row, i)
                        if south then @possibleMoves.set(col, row+1, i)
                        if north then @possibleMoves.set(col, row-1, i)

            @possibleMoves.delete(@col, @row)
            @possibleMoves.iterateIntKeys (col, row, dist) =>
                @squareTraversalCosts.set(col, row, TB.board.traversalCost(col, row))


    save: ->
        if @started == false
            @started = true
        else if @finished == false
            $('.btn-move').removeClass('yellow').find('span').text('Move Unit')
            @finished = true
            @movePath = @moves.join('|')
            super()


    isValid: ->
        return TB.board.units.get(@col, @row) and
               TB.board.units.get(@col, @row).amount > 0 and
               TB.board.units.get(@col, @row).owner == TB.myAccount.id

    update: (mouseX, mouseY) ->
        TB.mouse.x
        for action in @actions
            if action.type == 'move'
                action.update(mouseX, mouseY)

    draw: ->
        if not @finished
            @possibleMoves.iterate (col, row) =>

                screenX = TB.camera.worldColToScreenPosX(col)
                screenY = TB.camera.worldRowToScreenPosY(row)
                TB.ctx.save()
                TB.ctx.fillStyle = 'rgba(255,255,255,0.3)'
                TB.ctx.fillRect(screenX, screenY, 48, 48)
                TB.ctx.restore()
                

        # Calculate the move on the fly from the unit to the cursor
        if not @finished
            try
                centerCol = @col
                centerRow = @row
                mouseColDiff = TB.activeSquare.col - centerCol
                mouseRowDiff = TB.activeSquare.row - centerRow

                matrix = [[0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]
                          [0,0,0,0,0,0,0,0,0,0,0,0,0]]

                @squareTraversalCosts.iterateIntKeys (col, row, cost) =>
                    matrix[6 + (col - centerCol)][6 + (row - centerRow)] = cost
                graph = new Graph(matrix)

                path = astar.search(graph.nodes, graph.nodes[6][6], graph.nodes[6+mouseColDiff][6+mouseRowDiff])
                @moves = []
                for node in path
                    @moves.push [node.x - 6 + centerCol, node.y - 6 + centerRow]
            catch err
                #@moves = []


        # Draw the arrows for the move
        prev = 'start'
        next = 'end'
        thisCol = @col
        thisRow = @row
        for [nextCol,nextRow], i in @moves

            if nextCol > thisCol then next = 'east'
            if nextCol < thisCol then next = 'west'
            if nextRow < thisRow then next = 'north'
            if nextRow > thisRow then next = 'south'

            @drawArrow(thisCol, thisRow, prev, next)

            if next == 'north' then prev = 'south'
            if next == 'south' then prev = 'north'
            if next == 'west' then prev = 'east'
            if next == 'east' then prev = 'west'

            thisCol = nextCol
            thisRow = nextRow

            if i == @moves.length-1
                @drawArrow(thisCol, thisRow, prev, 'end')


    drawArrow: (col, row, prev, next) ->
        screenX = TB.camera.worldColToScreenPosX(col)
        screenY = TB.camera.worldRowToScreenPosY(row)
        [tileX, tileY] = @getArrowTileOffset(prev, next)
        TB.ctx.drawImage(
            TB.images.othertilesImage,
            tileX, tileY,
            TB.gridSize, TB.gridSize
            screenX, screenY,
            TB.camera.zoomedGridSize, TB.camera.zoomedGridSize
        )


    getArrowTileOffset: (dir1, dir2) ->
        if dir1 == 'west'  and dir2 == 'end'   or dir1 == 'end'   and dir2 == 'west'  then return [parseInt(TB.gridSize*0), parseInt(TB.gridSize*0)]
        if dir1 == 'south' and dir2 == 'end'   or dir1 == 'end'   and dir2 == 'south' then return [parseInt(TB.gridSize*1), parseInt(TB.gridSize*0)]
        if dir1 == 'east'  and dir2 == 'end'   or dir1 == 'end'   and dir2 == 'east'  then return [parseInt(TB.gridSize*2), parseInt(TB.gridSize*0)]
        if dir1 == 'north' and dir2 == 'end'   or dir1 == 'end'   and dir2 == 'north' then return [parseInt(TB.gridSize*3), parseInt(TB.gridSize*0)]

        if dir1 == 'south' and dir2 == 'east'  or dir1 == 'east'  and dir2 == 'south' then return [parseInt(TB.gridSize*0), parseInt(TB.gridSize*1)]
        if dir1 == 'north' and dir2 == 'east'  or dir1 == 'east'  and dir2 == 'north' then return [parseInt(TB.gridSize*1), parseInt(TB.gridSize*1)]
        if dir1 == 'west'  and dir2 == 'north' or dir1 == 'north' and dir2 == 'west'  then return [parseInt(TB.gridSize*2), parseInt(TB.gridSize*1)]
        if dir1 == 'west'  and dir2 == 'south' or dir1 == 'south' and dir2 == 'west'  then return [parseInt(TB.gridSize*3), parseInt(TB.gridSize*1)]

        if dir1 == 'start' and dir2 == 'east'  or dir1 == 'east'  and dir2 == 'start' then return [parseInt(TB.gridSize*0), parseInt(TB.gridSize*2)]
        if dir1 == 'start' and dir2 == 'north' or dir1 == 'north' and dir2 == 'start' then return [parseInt(TB.gridSize*1), parseInt(TB.gridSize*2)]
        if dir1 == 'start' and dir2 == 'west'  or dir1 == 'west'  and dir2 == 'start' then return [parseInt(TB.gridSize*2), parseInt(TB.gridSize*2)]
        if dir1 == 'start' and dir2 == 'south' or dir1 == 'south' and dir2 == 'start' then return [parseInt(TB.gridSize*3), parseInt(TB.gridSize*2)]

        if dir1 == 'start' and dir2 == 'end'   or dir1 == 'end'   and dir2 == 'start' then return [parseInt(TB.gridSize*0), parseInt(TB.gridSize*3)]
        if dir1 == 'west'  and dir2 == 'east'  or dir1 == 'east'  and dir2 == 'west'  then return [parseInt(TB.gridSize*1), parseInt(TB.gridSize*3)]
        if dir1 == 'north' and dir2 == 'south' or dir1 == 'south' and dir2 == 'north' then return [parseInt(TB.gridSize*2), parseInt(TB.gridSize*3)]





class BuildRoadAction extends Action

    constructor: (@col, @row) ->
        @kind = 'road'
        @name = 'Build Road'

    isValid: -> TB.myAccount.wood >= 10 and TB.board.isPassable(@col, @row)

class BuildCityAction extends Action

    constructor: (@col, @row) ->
        @kind = 'city'
        @name = 'Build city'

    isValid: -> TB.myAccount.wood >= 10 and TB.board.isPassable(@col, @row)

    draw: ->






class ActionManager
    constructor: ->
        @actions = []

    undo: ->
        @actions.pop()

        $.ajax
            url: '/api/undo/'
            method: 'POST'
            dataType: 'json'
            success: (response) ->
            error: (response) ->
                $('html').text("Error undoing move.  Please check your internet connection and try again: #{JSON.stringify(response)}")

    cancelMove: ->
        action = _.last(@actions)
        if action.kind == 'move' and not action.finished
            console.log 'canceling'
            @actions.pop()
            $('.btn-move').removeClass('yellow').find('span').text('Move Unit')
        else
            console.log action.kind + ' ' + action.finished

    loadFromJSON: (json) ->
        for action in json
            if action.kind == 'initial'
                @actions.push(new InitialPlacementAction(action.col, action.row))
            if action.kind == 'move'
                @actions.push(new MoveAction(action.col, action.row, action.movePath))
            if action.kind == 'road'
                @actions.push(new BuildRoadAction(action.col, action.row))


    handleAction: (kind, col, row) ->
        console.log kind
        if kind == 'initial'
            action = new InitialPlacementAction(col, row)
        if kind == 'move'
            action = _.last(@actions)
            if action # If there are previous actions
                if action.kind == 'move' # then we need to pop this off and readd it
                    action = @actions.pop()
                    if action.finished
                        @actions.push(action)
                        action = new MoveAction(col, row)

                else
                    # If the last action was not a move, make a new one
                    action = new MoveAction(col, row)
            else
                # If there are no previous actions then just make a new move
                action = new MoveAction(col, row)
        if kind == 'road'
            action = new BuildRoadAction(col, row)
        if kind == 'city'
            action = new BuildCityAction(col, row)


        if action.isValid()
            action.save()
            @actions.push(action)
        else
            console.log 'invalid move'


    count: -> @actions.length


    draw: ->
        TB.ctx.textAlign = 'right'
        TB.fillOutlinedText("This Turn's Actions", TB.camera.width - 16, 24)
        initialPlacements = new util.Hash2D()

        if not TB.isInitialPlacement
            for action, i in @actions
                TB.fillOutlinedText(action.name, TB.camera.width - 16, 24 + i*24 + 24)
                action.draw()
        else
            console.log 'is initial placement'
            for action, i in @actions
                TB.fillOutlinedText(action.name, TB.camera.width - 16, 24 + i*24 + 24)

                if TB.isInitialPlacement
                    initialPlacements.increment(action.col, action.row)

            for col, rowData of initialPlacements.getRaw()
                for row, amount of rowData

                    screenX = TB.camera.worldToScreenPosX(col * TB.gridSize)
                    screenY = TB.camera.worldToScreenPosY(row * TB.gridSize)

                    unitX = screenX + TB.camera.zoomedGridSize/2
                    unitY = screenY + TB.camera.zoomedGridSize/2
                    unitRadius = (TB.camera.zoomedUnitSize)/2

                    textX = unitX
                    textY = unitY - 3

                    # Draw a shadow under the unit
                    TB.ctx.save()

                    TB.ctx.beginPath()
                    TB.ctx.fillStyle = 'rgba(0,0,0,0.5)'
                    TB.ctx.arc(unitX, unitY, TB.camera.zoomedUnitSize/2, 0, 2*Math.PI)
                    TB.ctx.fill()

                    rgb = util.hexToRGB(TB.myAccount.color)
                    TB.ctx.fillStyle = "rgba(#{rgb.r},#{rgb.g},#{rgb.b},0.5)"
                    rgb.r = parseInt(rgb.r * 0.4)
                    rgb.g = parseInt(rgb.g * 0.4)
                    rgb.b = parseInt(rgb.b * 0.4)
                    TB.ctx.strokeStyle = "rgba(#{rgb.r},#{rgb.g},#{rgb.b},0.5)"
                    TB.ctx.lineWidth = 2

                    TB.ctx.beginPath()
                    ##TB.ctx.arc(action.srcCol, action.srcRow, TB.camera.zoomedUnitSize / 2, 0, 2*Math.PI)
                    TB.ctx.arc(unitX, unitY-8, TB.camera.zoomedUnitSize/2, 0, 2*Math.PI)
                    TB.ctx.fill()
                    TB.ctx.stroke()

                    TB.ctx.restore()

                    TB.ctx.textAlign = 'center'
                    TB.fillOutlinedText(amount, textX, textY)
