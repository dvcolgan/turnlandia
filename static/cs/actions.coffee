class Action
    isValid: ->
        return false

    save: ->
        actionData =
            unitCol: @unit.col
            unitRow: @unit.row
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
        if @movePath == undefined
            @finished = false
            @moves = []
        else
            @finished = true
            @moves = @parseMovePath(@movePath)

    save: ->
        @finished = true
        @movePath = @moves.join('|')
        super()

    isValid: ->
        true

    finish: (endCol, endRow) ->
        
    draw: ->
        
        # Calculate the move on the fly from the unit to the cursor
        if not @finished
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

            TB.actions.overlay.terrainCosts.iterateIntKeys (col, row, cost) =>
                matrix[6 + (col - centerCol)][6 + (row - centerRow)] = cost

            graph = new Graph(matrix)

            path = astar.search(graph.nodes, graph.nodes[6][6], graph.nodes[6+mouseColDiff][6+mouseRowDiff])
            @moves = []
            for node in path
                @moves.push [node.x - 6 + centerCol, node.y - 6 + centerRow]
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


class RecruitUnitAction extends Action

    constructor: (@col, @row) ->
        @kind = 'recruit'
        @name = 'Recruit Unit'

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

    constructor: (@col, @row) ->
        @kind = 'road'
        @name = 'Build Road'

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

    constructor: (@col, @row) ->
        @kind = 'tree'
        @name = 'Clear Forest'

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

    constructor: (@col, @row) ->
        @kind = 'city'
        @name = 'Build city'

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
    constructor: ->
        @actions = []
        @overlay = null
        @moveInProgress = null

    createOverlay: (unit, kind) ->
        fn = if kind == 'move'
            (col, row) -> TB.board.isPassable(col, row)
        else if kind == 'tree'
            (col, row) -> TB.board.getTerrainType(col, row) == 'forest'
        else if kind == 'road'
            (col, row) -> TB.board.getTerrainType(col, row) == 'plains'
        if fn then @overlay = new Overlay unit, fn

    undo: ->
        @actions.pop()

        $.ajax
            url: '/api/undo/'
            method: 'POST'
            dataType: 'json'
            success: (response) ->
            error: (response) ->
                $('html').text("Error undoing move.  Please check your internet connection and try again: #{JSON.stringify(response)}")


    beginMove: (col, row) ->
        @moveInProgress = new MoveAction(col, row)

    loadFromJSON: (json) ->
        for action in json
            if action.kind == 'initial'
                @actions.push(new InitialPlacementAction(action.col, action.row))
            if action.kind == 'move'
                @actions.push(new MoveAction(action.col, action.row, action.movePath))
            if action.kind == 'road'
                @actions.push(new BuildRoadAction(action.col, action.row))
            if action.kind == 'tree'
                @actions.push(new ClearForestAction(action.col, action.row))
            if action.kind == 'recruit'
                @actions.push(new RecruitUnitAction(action.col, action.row))


    handleAction: (kind, col, row) ->
        if kind == 'initial'
            action = new InitialPlacementAction(col, row)
        if kind == 'move'
            action = @moveInProgress
            action.col = TB.currentUnit.col
            action.row = TB.currentUnit.row
        if kind == 'road'
            action = new BuildRoadAction(col, row)
        if kind == 'city'
            action = new BuildCityAction(col, row)
        if kind == 'tree'
            action = new ClearForestAction(col, row)
            #if kind == 'recruit'
            #    action = new RecruitUnitAction(col, row)

        action.unit = TB.currentUnit

        if action.isValid()
            action.save()
            @actions.push(action)
            return false
        else
            return true


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
