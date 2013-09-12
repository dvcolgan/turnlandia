define ['lodash', 'astar'], (_, astar) ->

    class Unit
        constructor: (@square, @$dom_node, data) ->
            _.extend(@, data)
            @$dom_node
                .css('background-color', @owner_color)
                .css('border-bottom-width', (@amount + 3)/2)
                .css('margin-top', (-(@amount + 3)/2) + 'px')
                .css('height', (22 + @amount/2) + 'px')
            @$dom_node.text(@amount)


    class Square
        constructor: (@sector, @$dom_node, data) ->
            _.extend(@, data)

            # Determine how this square will look
            if @terrain_type == 'water' or @terrain_type == 'mountains' or @terrain_type == 'forest'
                @$dom_node.find('.subtile').css('background-image', 'url(/static/images/' + @terrain_type + '-tiles.png)')
                @$dom_node.find('.north-west').css('background-position', @get_tile_24_css_offset(@north_west_tile_24))
                @$dom_node.find('.north-east').css('background-position', @get_tile_24_css_offset(@north_east_tile_24))
                @$dom_node.find('.south-west').css('background-position', @get_tile_24_css_offset(@south_west_tile_24))
                @$dom_node.find('.south-east').css('background-position', @get_tile_24_css_offset(@south_east_tile_24))

            #@$dom_node.css('background-color': @owner_color)
            @$dom_node.css('background-color': '#00aa44')

            @$dom_node.data('col', @col).data('row', @row)

            # Warning crazy hacks afoot
            for i in [0...@units.length]
                $unit_dom_node = $('<div class="unit"></div>')
                if i == 0 then $unit_dom_node.addClass('first')
                if i == 1 then $unit_dom_node.addClass('second')
                if i == 2 then $unit_dom_node.addClass('third')
                if i == 3 then $unit_dom_node.addClass('fourth')
                if @units.length == 1 then $unit_dom_node.addClass('one')
                if @units.length == 2 then $unit_dom_node.addClass('two')
                if @units.length == 3 then $unit_dom_node.addClass('three')
                if @units.length == 4 then $unit_dom_node.addClass('four')
                @$dom_node.append($unit_dom_node)
                @units[i] = new Unit(@, $unit_dom_node, @units[i])

        get_tile_24_css_offset: (tile) ->
            return (24 * (tile) % 144 * -1) + 'px ' + (parseInt(24 * tile / 144) * 24 * -1) + 'px'



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

            @last_mouse = { x: 0, y: 0 }
            @last_scroll = { x: 0, y: 0 }
            @dragging = false

            #for action in TB.actions
            #    @load_sector_of_point(action.src_col, action.src_row)
            #    @load_sector_of_point(action.dest_col, action.dest_row)

            resizeBoard = =>
                @$dom_node.width(@get_view_width()).height(@get_view_height())
                @load_sectors_on_screen()
            $(window).resize(resizeBoard)
            resizeBoard()

            @$dom_node.mousedown (event) =>
                event.preventDefault()
                @last_mouse = { x: event.clientX, y: event.clientY }
                @last_scroll.x = @scroll.x
                @last_scroll.y = @scroll.y
                @dragging = true


            @$dom_node.mousemove (event) =>
                if @dragging
                    event.preventDefault()
                    @scroll.x = @last_scroll.x - (event.clientX - @last_mouse.x)
                    @scroll.y = @last_scroll.y - (event.clientY - @last_mouse.y)

                    @scroll_sectors()
                    @load_sectors_on_screen()
                    #vm.activeSquare(null)

            $(document).mouseup (event) =>
                @dragging = false

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



        scroll_sectors: ->
            for x, row of @sectors
                for y, sector of row
                    sector.$dom_node.css('left',((sector.x * TB.sector_size * TB.grid_size) - @scroll.x) + 'px')
                    sector.$dom_node.css('top', ((sector.y * TB.sector_size * TB.grid_size) - @scroll.y) + 'px')


        load_sector: (sector_x, sector_y) ->
            # Don't load the sector if it is beyond the current board extent
            if (sector_x > @max_sector_x or
            sector_x < @min_sector_x or
            sector_y > @max_sector_y or
            sector_y < @min_sector_y)
                return

            if sector_x not of @sectors
                @sectors[sector_x] = {}
            if sector_y not of @sectors[sector_x]
                $sector_dom_node = $('<div class="sector disable-select"></div>')
                @$dom_node.append($sector_dom_node)
                @sectors[sector_x][sector_y] = new Sector(@, $sector_dom_node, sector_x, sector_y, TB.sector_size)
            else
                @sectors[sector_x][sector_y].show()

        load_sector_of_point: (col, row) ->
            sector_x = Math.floor(col / TB.sector_size) * TB.sector_size
            sector_y = Math.floor(row / TB.sector_size) * TB.sector_size
            @load_sector(sector_x, sector_y)


        load_sectors_on_screen: ->
            sector_pixel_size = TB.sector_size * TB.grid_size
            sectors_wide  = Math.ceil(@get_view_width() / TB.sector_size / TB.grid_size)
            sectors_high = Math.ceil(@get_view_height() / TB.sector_size / TB.grid_size)

            for sector_col in [0..sectors_wide]
                for sector_row in [0..sectors_high]
                    x = (Math.floor(@scroll.x / sector_pixel_size)) + sector_col
                    y = (Math.floor(@scroll.y / sector_pixel_size)) + sector_row
                    @load_sector(x, y)

        containing_sector_loaded: (col, row) ->
            sector_x = Math.floor(col / TB.sector_size) * TB.sector_size
            sector_y = Math.floor(row / TB.sector_size) * TB.sector_size
            return (sector_x of @sectors and sector_y of @sectors[sector_x])

        get_view_width: ->
            $(window).width() - 160 - 15 - 100
        get_view_height: ->
            $(window).height() - 40 - 5

    return {
        Board: Board
    }
