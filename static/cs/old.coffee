#
#            vm.doAction = (square, event) ->
#                # If the user was dragging, ignore this click
#                if not (Math.abs(lastViewX - vm.viewX()) < 5 and Math.abs(lastViewY - vm.viewY()) < 5) then return
#
#                if vm.currentAction() == 'move'
#                    if not vm.isMoving()
#                        vm.moveStartSquare(vm.activeSquare())
#                        vm.isMoving(true)
#                        console.log('setting ismoving to true')
#
#                return
#                        
#
#                # TODO - perhaps at some point if there are too many requests going on,
#                # group all the actions of the last say 10 seconds together and push them all into one request
#                # the payload is nothing more than the x, y, and action
#                $.ajax '/api/square/' + square.col + '/' + square.row + '/' + vm.unitAction() + '/',
#                    contentType: "application/json"
#                    type: 'POST'
#                    success: (data, status) ->
#                        if status != 'success'
#                            alert(JSON.stringify(data))
#                            # TODO remove the units from the board or force refresh if this happens
#                            #
#                if vm.unitAction() == 'initial'
#                    # Set the 8 on the square clicked on
#                    placement =
#                        8: [square]
#                        4: [
#                            vm.findSquare(square.col-1, square.row)
#                            vm.findSquare(square.col+1, square.row)
#                            vm.findSquare(square.col, square.row-1)
#                            vm.findSquare(square.col, square.row+1)
#                        ]
#                        2: [
#                            vm.findSquare(square.col-1, square.row-1)
#                            vm.findSquare(square.col+1, square.row+1)
#                            vm.findSquare(square.col+1, square.row-1)
#                            vm.findSquare(square.col-1, square.row+1)
#                        ]
#                        1: [
#                            vm.findSquare(square.col-2, square.row)
#                            vm.findSquare(square.col+2, square.row)
#                            vm.findSquare(square.col, square.row-2)
#                            vm.findSquare(square.col, square.row+2)
#                        ]
#
#                    for count, squares of placement
#                        for square in squares
#                            if square
#                                if square.owner() or square.units().length > 0
#                                    alert('Your placement is too close to another player.')
#                                    return
#
#                    for count, squares of placement
#                        for square in squares
#                            if square
#                                square.units.push
#                                    owner: vm.accountID
#                                    ownerColor: vm.accountColor
#                                    square: square.id
#                                    amount: ko.observable(parseInt(count))
#                                    lastTurnAmount: 0
#                                square.owner(vm.accountID)
#                                square.ownerColor(vm.accountColor)
#                    vm.unplacedUnits(0)
#                    vm.unitAction('place')
#
#
#                else if vm.unitAction() == 'place'
#                    if vm.unplacedUnits() > 0
#
#                        canPlace = false
#                        if square.owner() == vm.accountID
#                            canPlace = true
#                        else
#                            other = vm.findSquare(square.col-1, square.row)
#                            if other and other.owner() == vm.accountID
#                                canPlace = true
#
#                            else
#                                other = vm.findSquare(square.col+1, square.row)
#                                if other and other.owner() == vm.accountID
#                                    canPlace = true
#
#                                else
#                                    other = vm.findSquare(square.col, square.row-1)
#                                    if other and other.owner() == vm.accountID
#                                        canPlace = true
#
#                                    else
#                                        other = vm.findSquare(square.col, square.row+1)
#                                        if other and other.owner() == vm.accountID
#                                            canPlace = true
#
#                        if not canPlace
#                            alert('You can only place units on a square you own or adjacent to a square you own.')
#                            return
#
#                        # If there is already a unit of this color on this square, update the amount,
#                        # otherwise add the whole unit
#                        found = false
#                        for unit in square.units()
#                            if unit.owner == vm.accountID
#                                if unit.amount() >= 20
#                                    alert('A square can only hold 20 of your units at a time.')
#                                    return
#                                unit.amount(unit.amount()+1)
#                                vm.unplacedUnits(vm.unplacedUnits()-1)
#                                found = true
#                                break
#                        if not found
#                            vm.unplacedUnits(vm.unplacedUnits()-1)
#                            square.units.push({
#                                owner: vm.accountID
#                                ownerColor: vm.accountColor
#                                square: square.id
#                                amount: ko.observable(1)
#                                lastTurnAmount: 0 # This may take some work to get working
#                            })
#
#
#                else if vm.unitAction() == 'remove'
#                    for i in [0...square.units().length]
#                        unit = square.units()[i]
#                        if unit.owner == vm.accountID
#                            if unit.amount() == 1
#                                square.units.splice(i, 1)
#                            else
#                                unit.amount(unit.amount()-1)
#                            vm.unplacedUnits(vm.unplacedUnits()+1)
#                            break
#
#                else if vm.unitAction() == 'settle'
#                    # Convert all units of your own color into 4x that many resource points on this tile
#                    for i in [0...square.units().length]
#                        unit = square.units()[i]
#                        if unit.owner == vm.accountID
#                            if square.wallHealth() > 0
#                                alert('You can not settle on a square with a wall.')
#                                return
#                            if square.owner() != vm.accountID
#                                alert('You can not settle on a square you do not own.')
#                                return
#                            square.resourceAmount(square.resourceAmount()+4)
#                            square.units()[i].amount(square.units()[i].amount()-1)
#                            if square.units()[i].amount() == 0
#                                square.units.splice(i, 1)
#                            break
#
#                else if vm.unitAction() == 'wall'
#                    # Convert all units of your own color into a wall on this square
#                    for i in [0...square.units().length]
#                        unit = square.units()[i]
#                        if unit.owner == vm.accountID
#                            square.wallHealth(square.wallHealth()+2)
#                            square.resourceAmount(0)
#                            square.units()[i].amount(square.units()[i].amount()-1)
#                            if square.units()[i].amount() == 0
#                                square.units.splice(i, 1)
#                            break






# Modified Djykstra's algorithm to show all possible moves
#distances = {}
#reachableSquares = {}
#unreachableSquares = {}
#uncheckedSquares = {}
#edgeSquares = {}
#currentSquare = @moveStartSquare
## A unit should never be able to travel more than 6 squares
#for row in [@activeSquare.row-maxDepth..@activeSquare.row+maxDepth]
#    for col in [@activeSquare.col-maxDepth..@activeSquare.col+maxDepth]
#        distances[col + '|' + row] = 1000000
#        uncheckedSquares[col + '|' + row] = @squares[col][row]

#distances[currentSquare.col + '|' + currentSquare.row] = 0

## this == current square, other == the neighbor in question
##while yes # yes yes yes yes yes yes
#for i in [0...maxDepth]

#    for reachableSquare of reachableSquares
#        thisSquareKey = (reachableSquare.col) + '|' + (reachableSquare.row)

#        leftSquareKey = (reachableSquare.col-1) + '|' + (reachableSquare.row)
#        rightSquareKey = (reachableSquare.col+1) + '|' + (reachableSquare.row)
#        topSquareKey = (reachableSquare.col) + '|' + (reachableSquare.row-1)
#        bottomSquareKey = (reachableSquare.col) + '|' + (reachableSquare.row+1)

#        for otherSquareKey in [leftSquareKey, rightSquareKey, topSquareKey, bottomSquareKey]

#            if otherSquareKey of uncheckedSquares
#                otherSquare = uncheckedSquares[otherSquareKey]
#                otherDistance = otherSquare.traversalCost + distances[thisSquareKey]
#                # If this square is outside of the traveling distance, mark it as such
#                if otherDistance > maxDepth
#                    unreachableSquares[otherSquareKey] = otherSquare
#                else if otherSquareKey not of distances or otherDistance < distances[otherSquareKey]
#                    distances[otherSquareKey] = otherDistance
#                    otherSquare.$domNode.addClass('traversable-square')

#        currentSquareKey = currentSquare.col + '|' + currentSquare.row
#        reachableSquares[currentSquareKey] = uncheckedSquares[currentSquareKey]
#        delete uncheckedSquares[reachableSquare]


#            thisSquareDistance = distances[visitedSquareKey]


#console.log('finished')







































class Sector
    # Sector size is in number of squares, square size is in pixels
    constructor: (@board, @$domNode, @x, @y) ->

        @squares = {}

        @$domNode
            .css('left',(@x * TB.sectorSize * TB.gridSize - @board.scroll.x) + 'px')
            .css('top', (@y * TB.sectorSize * TB.gridSize - @board.scroll.y) + 'px')

        firstSquareX = @x * TB.sectorSize
        firstSquareY = @y * TB.sectorSize

        $.getJSON '/api/sector/'+firstSquareX+'/'+firstSquareY+'/'+TB.sectorSize+'/'+TB.sectorSize+'/', (data, status) =>
            if status == 'success'
                for squareData, i in data

                    #units = []
                    #for unit in square.units
                    #    units.push({
                    #        owner: unit.owner
                    #        ownerColor: unit.ownerColor
                    #        square: square.id
                    #        amount: ko.observable(unit.amount)
                    #        lastTurnAmount: unit.lastTurnAmount
                    #    })


                    $squareDomNode = $('<div class="grid-square">
                                            <div class="subtile north-west"></div>
                                            <div class="subtile north-east"></div>
                                            <div class="subtile south-west"></div>
                                            <div class="subtile south-east"></div>
                                        </div>')
                    $squareDomNode
                        .css('left', parseInt((i % TB.sectorSize) * TB.gridSize) + 'px')
                        .css('top', parseInt(Math.floor(i / TB.sectorSize) * TB.gridSize) + 'px')
                    @$domNode.append($squareDomNode)

                    if squareData.col not of @squares
                        @squares[squareData.col] = {}
                    if squareData.col not of @board.squares
                        @board.squares[squareData.col] = {}

                    newSquare = new Square(@, $squareDomNode, squareData)
                    @board.squares[squareData.col][squareData.row] = newSquare

                    @squares[squareData.col][squareData.row] = newSquare

                for action in TB.actions
                    srcIn = @containsSquare(action.srcCol, action.srcRow)
                    destIn = @containsSquare(action.destCol, action.destRow)

                    # Easiest case, the whole action is inside this sector, and we can just apply the arrow
                    if srcIn and destIn
                        @board.drawArrow(@board.squares[action.srcCol][action.srcRow], @board.squares[action.destCol][action.destRow])
                        #else if srcIn and not destIn




            else
                alert(JSON.stringify(data))
    show: ->
    hide: ->

    containsSquare: (col, row) ->
        return (col >= @x * TB.sectorSize and row >= @y * TB.sectorSize and col < @x * TB.sectorSize + TB.sectorSize and row < @y * TB.sectorSize + TB.sectorSize)


class Board
    constructor: (@$domNode, boardConsts) ->
        _.extend(@, boardConsts)
        @scroll = { x: 0, y: 0 }
        @maxDepth = 6 # How many moves a unit can move

        # TODO center the board over your HQ, for now center it at 0, 0
        @scroll.x = -@getViewWidth()/2
        @scroll.y = -@getViewHeight()/2

        @sectors = {}
        @squares = {}


        #for action in TB.actions
        #    @loadSectorOfPoint(action.srcCol, action.srcRow)
        #    @loadSectorOfPoint(action.destCol, action.destRow)



        # For movement
        @activeSquare = null
        @isMoving = null
        @moveStartSquare = null

        @$domNode.on 'click', '.grid-square', (event) =>
            # If the user was dragging, ignore this click
            if not (Math.abs(@lastScroll.x - @scroll.x) < 5 and Math.abs(@lastScroll.y - @scroll.y) < 5)
                console.log 'ignoring click'
                return

            console.log TB.currentAction
            if TB.currentAction == 'road'
                $.ajax({
                    url: '/api/action/road/' + 1 + '/' + @activeSquare.col + '/' + @activeSquare.row + '/'
                    method: 'POST'
                    dataType: 'json'
                    success: (data) ->
                        true
                })

            else if TB.currentAction == 'move'
                if not @isMoving
                    @moveStartSquare = @activeSquare
                    @isMoving = yes


                    # Maybe inefficient way of finding all the possible moves: find the shortest paths for all the squares
                    # To make it more efficient, calculate all of the paths on click of the unit
                    #
                    # SOMEDAY MAKE THIS BETTER AND NOT COPYPASTED CODE
                    # SOMEDAY MAKE ALL OF THIS BETTER
                    squareTraversalCosts = @getSquareTraversalCosts(@moveStartSquare.col, @moveStartSquare.row, @maxDepth)
                    $('.reachable-square').removeClass('reachable-square')

                    graph = new astar.Graph(squareTraversalCosts)

                    for col in [0..@maxDepth*2]
                        for row in [0..@maxDepth*2]
                            start = graph.nodes[@maxDepth][@maxDepth]
                            end = graph.nodes[col][row]
                            console.log('start ' + start.x + ' ' + start.y + ', end ' + end.x + ' ' + end.y)
                            result = astar.astar.search(graph.nodes, start, end)

                            totalCost = 0
                            skip = false
                            for node in result
                                # Can't move into a solid square
                                if node.cost == 0
                                    skip = true
                                totalCost += node.cost
                                if totalCost > @maxDepth
                                    skip = true
                            if skip then continue

                            for node in result
                                $squareDomNode = @squares[(@moveStartSquare.col-@maxDepth)+col][(@moveStartSquare.row-@maxDepth)+row].$domNode
                                $squareDomNode.addClass('reachable-square')
                else
                    console.log 'move done'
                    @isMoving = false
                    $('.reachable-square').removeClass('reachable-square')

                    $.ajax({
                        url: '/api/action/move/' + @moveStartSquare.col + '/' + @moveStartSquare.row + '/' + @activeSquare.col + '/' + @activeSquare.row + '/'
                        method: 'POST'
                        dataType: 'json'
                        success: (data) ->
                            true
                        error: (data) ->
                            alert('Problem saving your action.  The page will now refresh.  Sorry, I should make this more robust sometime.')
                            window.location.href += ''
                    })

            return

        $(document).keydown (event) =>
            @isMoving = no
            return true


        @$domNode.on 'mouseenter', '.grid-square', (event) =>

            if not $(event.target).hasClass('grid-square')
                $squareDomNode = $(event.target).parents('.grid-square')
            else
                $squareDomNode = $(event.target)

            previousActiveSquare = @activeSquare

            @activeSquare = @squares[$squareDomNode.data('col')][$squareDomNode.data('row')]

            if @isMoving and previousActiveSquare != @activeSquare
                @drawArrow(@moveStartSquare, @activeSquare)


    drawArrow: (startSquare, endSquare) ->

        squareTraversalCosts = @getSquareTraversalCosts(startSquare.col, startSquare.row, @maxDepth)

        graph = new astar.Graph(squareTraversalCosts)

        start = graph.nodes[@maxDepth][@maxDepth]
        end = graph.nodes[(endSquare.col - startSquare.col) + @maxDepth][(endSquare.row - startSquare.row) + @maxDepth]
        result = astar.astar.search(graph.nodes, start, end)

        $('.arrow.unit-' + startSquare.units[0].id).remove()

        # Find the orientation of the starting square
        if result[0].x == @maxDepth
            if result[0].y > @maxDepth
                nextDirection = 'south'
            if result[0].y < @maxDepth
                nextDirection = 'north'
        if result[0].y == @maxDepth
            if result[0].x > 0
                nextDirection = 'west'
            if result[0].x < 0
                nextDirection = 'east'
        lastDirection = 'start'

        lastNode = {x:@maxDepth, y:@maxDepth}

        totalCost = 0
        for node in result
            # Can't move into a solid square
            if node.cost == 0
                return
            totalCost += node.cost
            if totalCost > @maxDepth
                return

        for node in result
            dx = node.x - lastNode.x
            dy = node.y - lastNode.y

            if node.x == lastNode.x
                if dy > 0
                    nextDirection = 'south'
                if dy < 0
                    nextDirection = 'north'
            if node.y == lastNode.y
                if dx > 0
                    nextDirection = 'east'
                if dx < 0
                    nextDirection = 'west'

            $squareDomNode = @squares[startSquare.col+(lastNode.x-@maxDepth)][startSquare.row+(lastNode.y-@maxDepth)].$domNode
            $squareDomNode.prepend($('<div class="arrow ' + lastDirection + '-' + nextDirection + ' unit-' + startSquare.units[0].id + '"></div>'))

            lastNode = node

            if nextDirection == 'north'
                lastDirection = 'south'
            if nextDirection == 'south'
                lastDirection = 'north'
            if nextDirection == 'east'
                lastDirection = 'west'
            if nextDirection == 'west'
                lastDirection = 'east'

        $squareDomNode = @squares[startSquare.col+(lastNode.x-@maxDepth)][startSquare.row+(lastNode.y-@maxDepth)].$domNode
        $squareDomNode.prepend($('<div class="arrow ' + lastDirection + '-end unit-' + startSquare.units[0].id + '"></div>'))

        console.log('done')

                    
    getSquareTraversalCosts: (x, y, radius) ->
        squareTraversalCosts = []
        for col in [x-radius..x+radius]
            traversalRow = []
            for row in [y-radius..y+radius]
                traversalRow.push(@squares[col][row].traversalCost)
            squareTraversalCosts.push(traversalRow)
        return squareTraversalCosts
