class Action
    constructor: (@kind, @col, @row, @unitCol, @unitRow, @movePath) ->

    isValid: ->
        return false

    save: ->

        actionData =
            kind: @kind
            col: @col
            row: @row
            unit_col: @unitCol
            unit_row: @unitRow
            move_path: @movePath

        $.ajax
            url: '/api/action/'
            method: 'POST'
            dataType: 'json'
            data: actionData
            success: (response) =>

            error: (response) ->
                alert("Error saving move.  Please check your internet connection and try again: #{JSON.stringify(response)}")

        if kind != 'initial'
            unit = TB.board.units.get(@unitCol, @unitRow)
            unit.actionsLeft -= 1
            return unit.actionsLeft
        else
            return
        


class InitialPlacementAction extends Action

    isValid: ->
        return TB.actions.count() < 8 and TB.board.isPassable(@unitCol, @unitRow) and TB.board.getUnitCount(@unitCol, @unitRow) == 0

    save: ->
        super()

    draw: ->
        # This is kludgily in the actionmanager draw function OOPS HOW DO I FIX THIS
        # If you place two on a square, this action has to know about another action


class MoveAction extends Action
    constructor: (@kind, @col, @row, @unitCol, @unitRow, @movePath) ->
        if @movePath == undefined
            @finished = false
            @moves = []
        else
            @finished = true
            @moves = @parseMovePath(@movePath)

    parseMovePath: (movePath) ->
        moves = (coord.split(',') for coord in movePath.split('|'))
        _.map(moves, (coords) -> [parseInt(coords[0]), parseInt(coords[1])])

    save: ->
        @finished = true
        @movePath = @moves.join('|')
        super()

    isValid: ->
        @moves.length > 0
        
    draw: ->
        # Calculate the move on the fly from the unit to the cursor
        if not @finished
            try
                centerCol = @unitCol
                centerRow = @unitRow
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

                TB.actions.overlay.terrainCosts.iterateIntKeys (col, row, cost) =>
                    matrix[6 + (col - centerCol)][6 + (row - centerRow)] = cost

                graph = new Graph(matrix)

                path = astar.search(graph.nodes, graph.nodes[6][6], graph.nodes[6+mouseColDiff][6+mouseRowDiff])
                @moves = []
                for node in path
                    @moves.push [node.x - 6 + centerCol, node.y - 6 + centerRow]
                #@moves = []
            catch
                @moves = []

        # Draw the arrows for the move
        prev = 'start'
        next = 'end'
        thisCol = @unitCol
        thisRow = @unitRow
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


class RecruitUnitAction extends Action

    isValid: ->
        for action in TB.actions.actions
            if action.col == @col and action.row == @row and action.kind == 'recruit' then return false
        unit = TB.board.units.get(@col, @row)
        if unit == null or unit.ownerID != TB.myAccount.id then return false
        if TB.myAccount.food < 2 then return false
        return true

    draw: ->
        screenX = TB.camera.worldColToScreenPosX(@col)
        screenY = TB.camera.worldRowToScreenPosY(@row)
        TB.ctx.save()
        TB.ctx.fillStyle = 'rgba(255,255,255,0.7)'
        TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize)
        TB.ctx.restore()


class BuildRoadAction extends Action

    isValid: ->
        for action in TB.actions.actions
            if action.col == @col and action.row == @row and action.kind == 'road' then return false
        terrainType = TB.board.getTerrainType(@col, @row)
        if terrainType != 'plains' then return false
        if TB.myAccount.wood < 10 then return false
        if TB.actions.overlay.positions.get(@col, @row) == null then return false
        return true

    draw: ->
        screenX = TB.camera.worldColToScreenPosX(@col)
        screenY = TB.camera.worldRowToScreenPosY(@row)
        TB.ctx.save()
        TB.ctx.fillStyle = 'rgba(119,65,27,0.7)'
        TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize)
        TB.ctx.restore()


class ClearForestAction extends Action

    isValid: ->
        for action in TB.actions.actions
            if action.col == @col and action.row == @row and action.kind == 'tree' then return false
        terrainType = TB.board.getTerrainType(@col, @row)
        if terrainType != 'forest' then return false
        if TB.actions.overlay.positions.get(@col, @row) == null then return false
        return true

    draw: ->
        screenX = TB.camera.worldColToScreenPosX(@col)
        screenY = TB.camera.worldRowToScreenPosY(@row)
        TB.ctx.save()
        TB.ctx.fillStyle = 'rgba(0,100,0,0.7)'
        TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize)
        TB.ctx.restore()









class BuildCityAction extends Action

    isValid: -> TB.myAccount.wood >= 10 and TB.board.isPassable(@col, @row)

    draw: ->






class Overlay
    constructor: (unit, validationFn) ->
        @positions = new util.Hash2D()
        @terrainCosts = new util.Hash2D()

        possibleMovements = new util.Hash2D()
        lastSquares = new util.Hash2D()
        lastSquares.set(unit.col, unit.row, 0)

        uncheckedSquares = new util.Hash2D()
        for i in [1..6]
            lastSquares.priorityPopAllIntKeys (col, row, dist) =>
                for [thisCol, thisRow] in [[col+1,row], [col-1,row], [col,row+1], [col,row-1]]

                    if possibleMovements.get(thisCol, thisRow) == null and TB.board.isPassable(thisCol, thisRow)
                        traversalCost = TB.board.traversalCost(thisCol, thisRow)
                        prevDist = uncheckedSquares.get(thisCol, thisRow, dist + traversalCost)
                        if prevDist == null or prevDist > dist + traversalCost
                            uncheckedSquares.set(thisCol, thisRow, dist + traversalCost)

            possibleMovements.concat(uncheckedSquares)
            lastSquares = uncheckedSquares
            uncheckedSquares = new util.Hash2D()

        possibleMovements.iterateIntKeys (thisCol, thisRow, dist) =>
            if validationFn(thisCol, thisRow) and dist <= 6
                @positions.set(thisCol, thisRow, dist)
                @terrainCosts.set(thisCol, thisRow, TB.board.traversalCost(thisCol, thisRow))


    draw: (col, row) ->
        if @positions.get(col, row) != null
            screenX = TB.camera.worldColToScreenPosX(col)
            screenY = TB.camera.worldRowToScreenPosY(row)
            TB.ctx.save()
            TB.ctx.fillStyle = 'rgba(255,255,255,0.3)'
            TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize)
            TB.ctx.restore()






class ActionManager
    @MAPPINGS:
        'initial': InitialPlacementAction
        'move': MoveAction
        'road': BuildRoadAction
        'tree': ClearForestAction
        'recruit': RecruitUnitAction
    constructor: ->
        @actions = []
        @overlay = null
        @moveInProgress = null


    unitsActionCount: (col, row) ->
        count = 0
        for action in @actions
            if action.unitCol == col and action.unitRow == row
                count++
        return count


    createOverlay: (unit, kind) ->
        fn = if kind == 'move'
            (col, row) -> TB.board.isPassable(col, row)
        else if kind == 'tree'
            (col, row) -> TB.board.getTerrainType(col, row) == 'forest'
        else if kind == 'road'
            (col, row) -> TB.board.getTerrainType(col, row) == 'plains'
        if fn then @overlay = new Overlay unit, fn

    undo: ->
        action = @actions.pop()
        if action
            unit = TB.board.units.get(action.unitCol, action.unitRow)
            if unit
                unit.actionsLeft++

            $.ajax
                url: '/api/undo/'
                method: 'POST'
                dataType: 'json'
                success: (response) ->
                error: (response) ->
                    $('html').text("Error undoing move.  Please check your internet connection and try again: #{JSON.stringify(response)}")


    beginMove: (col, row) -> @moveInProgress = new MoveAction('move', col, row, col, row)

    loadFromJSON: (json) ->
        for actionData in json
            action_class = ActionManager.MAPPINGS[actionData.kind]
            @actions.push(
                new action_class(
                    actionData.kind,
                    actionData.col, actionData.row,
                    actionData.unitCol, actionData.unitRow,
                    actionData.movePath))
                    #unit = TB.board.units.get(actionData.unitCol, actionData.unitRow)
                    #unit.actionsLeft -= 1

    handleAction: (kind, col, row, unitCol, unitRow) ->
        action = new ActionManager.MAPPINGS[kind](kind, col, row, unitCol, unitRow)

        if kind == 'move' then action.moves = @moveInProgress.moves

        if action.isValid()
            actionsLeft = action.save()
            @actions.push(action)
            console.log actionsLeft > 0
            more = (actionsLeft > 0)
        else
            more = false
        
        if more
            return true
        else
            @moveInProgress = null
            @overlay = null
            return false

    count: -> @actions.length


    draw: ->
        initialPlacements = new util.Hash2D()

        if not TB.isInitialPlacement
            for action, i in @actions
                action.draw()
            if @moveInProgress
                @moveInProgress.draw()
        else
            for action, i in @actions
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
