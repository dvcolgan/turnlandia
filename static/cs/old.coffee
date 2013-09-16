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
#                                    last_turn_amount: 0
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
#                                last_turn_amount: 0 # This may take some work to get working
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
#reachable_squares = {}
#unreachable_squares = {}
#unchecked_squares = {}
#edge_squares = {}
#current_square = @move_start_square
## A unit should never be able to travel more than 6 squares
#for row in [@active_square.row-max_depth..@active_square.row+max_depth]
#    for col in [@active_square.col-max_depth..@active_square.col+max_depth]
#        distances[col + '|' + row] = 1000000
#        unchecked_squares[col + '|' + row] = @squares[col][row]

#distances[current_square.col + '|' + current_square.row] = 0

## this == current square, other == the neighbor in question
##while yes # yes yes yes yes yes yes
#for i in [0...max_depth]

#    for reachable_square of reachable_squares
#        this_square_key = (reachable_square.col) + '|' + (reachable_square.row)

#        left_square_key = (reachable_square.col-1) + '|' + (reachable_square.row)
#        right_square_key = (reachable_square.col+1) + '|' + (reachable_square.row)
#        top_square_key = (reachable_square.col) + '|' + (reachable_square.row-1)
#        bottom_square_key = (reachable_square.col) + '|' + (reachable_square.row+1)

#        for other_square_key in [left_square_key, right_square_key, top_square_key, bottom_square_key]

#            if other_square_key of unchecked_squares
#                other_square = unchecked_squares[other_square_key]
#                other_distance = other_square.traversal_cost + distances[this_square_key]
#                # If this square is outside of the traveling distance, mark it as such
#                if other_distance > max_depth
#                    unreachable_squares[other_square_key] = other_square
#                else if other_square_key not of distances or other_distance < distances[other_square_key]
#                    distances[other_square_key] = other_distance
#                    other_square.$dom_node.addClass('traversable-square')

#        current_square_key = current_square.col + '|' + current_square.row
#        reachable_squares[current_square_key] = unchecked_squares[current_square_key]
#        delete unchecked_squares[reachable_square]


#            this_square_distance = distances[visited_square_key]


#console.log('finished')







































class Sector
    # Sector size is in number of squares, square size is in pixels
    constructor: (@board, @$dom_node, @x, @y) ->

        @squares = {}

        @$dom_node
            .css('left',(@x * TB.sector_size * TB.grid_size - @board.scroll.x) + 'px')
            .css('top', (@y * TB.sector_size * TB.grid_size - @board.scroll.y) + 'px')

        first_square_x = @x * TB.sector_size
        first_square_y = @y * TB.sector_size

        $.getJSON '/api/sector/'+first_square_x+'/'+first_square_y+'/'+TB.sector_size+'/'+TB.sector_size+'/', (data, status) =>
            if status == 'success'
                for square_data, i in data

                    #units = []
                    #for unit in square.units
                    #    units.push({
                    #        owner: unit.owner
                    #        ownerColor: unit.owner_color
                    #        square: square.id
                    #        amount: ko.observable(unit.amount)
                    #        last_turn_amount: unit.last_turn_amount
                    #    })


                    $square_dom_node = $('<div class="grid-square">
                                            <div class="subtile north-west"></div>
                                            <div class="subtile north-east"></div>
                                            <div class="subtile south-west"></div>
                                            <div class="subtile south-east"></div>
                                        </div>')
                    $square_dom_node
                        .css('left', parseInt((i % TB.sector_size) * TB.grid_size) + 'px')
                        .css('top', parseInt(Math.floor(i / TB.sector_size) * TB.grid_size) + 'px')
                    @$dom_node.append($square_dom_node)

                    if square_data.col not of @squares
                        @squares[square_data.col] = {}
                    if square_data.col not of @board.squares
                        @board.squares[square_data.col] = {}

                    new_square = new Square(@, $square_dom_node, square_data)
                    @board.squares[square_data.col][square_data.row] = new_square

                    @squares[square_data.col][square_data.row] = new_square

                for action in TB.actions
                    src_in = @contains_square(action.src_col, action.src_row)
                    dest_in = @contains_square(action.dest_col, action.dest_row)

                    # Easiest case, the whole action is inside this sector, and we can just apply the arrow
                    if src_in and dest_in
                        @board.draw_arrow(@board.squares[action.src_col][action.src_row], @board.squares[action.dest_col][action.dest_row])
                        #else if src_in and not dest_in




            else
                alert(JSON.stringify(data))
    show: ->
    hide: ->

    contains_square: (col, row) ->
        return (col >= @x * TB.sector_size and row >= @y * TB.sector_size and col < @x * TB.sector_size + TB.sector_size and row < @y * TB.sector_size + TB.sector_size)


class Board
    constructor: (@$dom_node, board_consts) ->
        _.extend(@, board_consts)
        @scroll = { x: 0, y: 0 }
        @max_depth = 6 # How many moves a unit can move

        # TODO center the board over your HQ, for now center it at 0, 0
        @scroll.x = -@get_view_width()/2
        @scroll.y = -@get_view_height()/2

        @sectors = {}
        @squares = {}


        #for action in TB.actions
        #    @load_sector_of_point(action.src_col, action.src_row)
        #    @load_sector_of_point(action.dest_col, action.dest_row)



        # For movement
        @active_square = null
        @is_moving = null
        @move_start_square = null

        @$dom_node.on 'click', '.grid-square', (event) =>
            # If the user was dragging, ignore this click
            if not (Math.abs(@last_scroll.x - @scroll.x) < 5 and Math.abs(@last_scroll.y - @scroll.y) < 5)
                console.log 'ignoring click'
                return

            console.log TB.current_action
            if TB.current_action == 'road'
                $.ajax({
                    url: '/api/action/road/' + 1 + '/' + @active_square.col + '/' + @active_square.row + '/'
                    method: 'POST'
                    dataType: 'json'
                    success: (data) ->
                        true
                })

            else if TB.current_action == 'move'
                if not @is_moving
                    @move_start_square = @active_square
                    @is_moving = yes


                    # Maybe inefficient way of finding all the possible moves: find the shortest paths for all the squares
                    # To make it more efficient, calculate all of the paths on click of the unit
                    #
                    # SOMEDAY MAKE THIS BETTER AND NOT COPYPASTED CODE
                    # SOMEDAY MAKE ALL OF THIS BETTER
                    square_traversal_costs = @get_square_traversal_costs(@move_start_square.col, @move_start_square.row, @max_depth)
                    $('.reachable-square').removeClass('reachable-square')

                    graph = new astar.Graph(square_traversal_costs)

                    for col in [0..@max_depth*2]
                        for row in [0..@max_depth*2]
                            start = graph.nodes[@max_depth][@max_depth]
                            end = graph.nodes[col][row]
                            console.log('start ' + start.x + ' ' + start.y + ', end ' + end.x + ' ' + end.y)
                            result = astar.astar.search(graph.nodes, start, end)

                            total_cost = 0
                            skip = false
                            for node in result
                                # Can't move into a solid square
                                if node.cost == 0
                                    skip = true
                                total_cost += node.cost
                                if total_cost > @max_depth
                                    skip = true
                            if skip then continue

                            for node in result
                                $square_dom_node = @squares[(@move_start_square.col-@max_depth)+col][(@move_start_square.row-@max_depth)+row].$dom_node
                                $square_dom_node.addClass('reachable-square')
                else
                    console.log 'move done'
                    @is_moving = false
                    $('.reachable-square').removeClass('reachable-square')

                    $.ajax({
                        url: '/api/action/move/' + @move_start_square.col + '/' + @move_start_square.row + '/' + @active_square.col + '/' + @active_square.row + '/'
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
            @is_moving = no
            return true


        @$dom_node.on 'mouseenter', '.grid-square', (event) =>

            if not $(event.target).hasClass('grid-square')
                $square_dom_node = $(event.target).parents('.grid-square')
            else
                $square_dom_node = $(event.target)

            previous_active_square = @active_square

            @active_square = @squares[$square_dom_node.data('col')][$square_dom_node.data('row')]

            if @is_moving and previous_active_square != @active_square
                @draw_arrow(@move_start_square, @active_square)


    draw_arrow: (start_square, end_square) ->

        square_traversal_costs = @get_square_traversal_costs(start_square.col, start_square.row, @max_depth)

        graph = new astar.Graph(square_traversal_costs)

        start = graph.nodes[@max_depth][@max_depth]
        end = graph.nodes[(end_square.col - start_square.col) + @max_depth][(end_square.row - start_square.row) + @max_depth]
        result = astar.astar.search(graph.nodes, start, end)

        $('.arrow.unit-' + start_square.units[0].id).remove()

        # Find the orientation of the starting square
        if result[0].x == @max_depth
            if result[0].y > @max_depth
                next_direction = 'south'
            if result[0].y < @max_depth
                next_direction = 'north'
        if result[0].y == @max_depth
            if result[0].x > 0
                next_direction = 'west'
            if result[0].x < 0
                next_direction = 'east'
        last_direction = 'start'

        last_node = {x:@max_depth, y:@max_depth}

        total_cost = 0
        for node in result
            # Can't move into a solid square
            if node.cost == 0
                return
            total_cost += node.cost
            if total_cost > @max_depth
                return

        for node in result
            dx = node.x - last_node.x
            dy = node.y - last_node.y

            if node.x == last_node.x
                if dy > 0
                    next_direction = 'south'
                if dy < 0
                    next_direction = 'north'
            if node.y == last_node.y
                if dx > 0
                    next_direction = 'east'
                if dx < 0
                    next_direction = 'west'

            $square_dom_node = @squares[start_square.col+(last_node.x-@max_depth)][start_square.row+(last_node.y-@max_depth)].$dom_node
            $square_dom_node.prepend($('<div class="arrow ' + last_direction + '-' + next_direction + ' unit-' + start_square.units[0].id + '"></div>'))

            last_node = node

            if next_direction == 'north'
                last_direction = 'south'
            if next_direction == 'south'
                last_direction = 'north'
            if next_direction == 'east'
                last_direction = 'west'
            if next_direction == 'west'
                last_direction = 'east'

        $square_dom_node = @squares[start_square.col+(last_node.x-@max_depth)][start_square.row+(last_node.y-@max_depth)].$dom_node
        $square_dom_node.prepend($('<div class="arrow ' + last_direction + '-end unit-' + start_square.units[0].id + '"></div>'))

        console.log('done')

                    
    get_square_traversal_costs: (x, y, radius) ->
        square_traversal_costs = []
        for col in [x-radius..x+radius]
            traversal_row = []
            for row in [y-radius..y+radius]
                traversal_row.push(@squares[col][row].traversal_cost)
            square_traversal_costs.push(traversal_row)
        return square_traversal_costs
