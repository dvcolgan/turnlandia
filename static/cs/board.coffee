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

        @$dom_node
            .css('background-color': @owner_color)

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


                    $square_dom_node = $('<div class="grid-square"></div>')
                    $square_dom_node
                        .css('left', parseInt((i % TB.sector_size) * TB.grid_size) + 'px')
                        .css('top', parseInt(Math.floor(i / TB.sector_size) * TB.grid_size) + 'px')
                    @$dom_node.append($square_dom_node)

                    if square_data.col not of @squares
                        @squares[square_data.col] = {}

                    @squares[square_data.col][square_data.row] = new Square(@, $square_dom_node, square_data)

            else
                alert(JSON.stringify(data))
    show: ->
    hide: ->


class Board
    constructor: (@$dom_node, board_consts) ->
        _.extend(@, board_consts)
        @scroll = { x: 0, y: 0 }

        # TODO center the board over your HQ, for now center it at 0, 0
        @scroll.x = -@get_view_width()/2
        @scroll.y = -@get_view_height()/2

        @sectors = {}
        @squares = {}

        @last_mouse = { x: 0, y: 0 }
        @last_scroll = { x: 0, y: 0 }
        @dragging = false

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
                debugger
                console.log 'ignoring click'
                return

            console.log TB.current_action
            if TB.current_action == 'move'
                if not @is_moving
                    @move_start_square = @active_square
                    @is_moving = yes
                    console.log('setting ismoving to true')
            return

        $(document).keydown (event) =>
            @is_moving = no
            return true


        @$dom_node.on 'mouseenter', '.grid-square', (event) =>
            previous_active_square = @active_square

            $square_dom_node = $(event.target)
            @active_square = @get_square($square_dom_node.data('col'), $square_dom_node.data('row'))

            if @is_moving and previous_active_square != @active_square
                console.log 'handling square hover during move'
                $('.grid-square.moving-through').removeClass('moving-through')
                connecting_square = @move_start_square
                connecting_square.$dom_node.addClass('moving-through')
                while yes # yes yes yes yes yes yes
                    dists = {
                        left: Util.calculate_distance(
                            connecting_square.col-1,
                            connecting_square.row,
                            @active_square.col,
                            @active_square.row
                        ),
                        right: Util.calculate_distance(
                            connecting_square.col+1,
                            connecting_square.row,
                            @active_square.col,
                            @active_square.row
                        ),
                        up: Util.calculate_distance(
                            connecting_square.col,
                            connecting_square.row-1,
                            @active_square.col,
                            @active_square.row
                        ),
                        down: Util.calculate_distance(
                            connecting_square.col,
                            connecting_square.row+1,
                            @active_square.col,
                            @active_square.row
                        )
                    }
                    shortestDist = 0
                    shortest = null
                    for dir, dist of dists
                        if shortest == null or dist < shortestDist
                            shortestDist = dist
                            shortest = dir
                    console.log(shortest)

                    if shortest == 'left'
                        connecting_square = @get_square(connecting_square.col-1, connecting_square.row)
                    if shortest == 'right'
                        connecting_square = @get_square(connecting_square.col+1, connecting_square.row)
                    if shortest == 'up'
                        connecting_square = @get_square(connecting_square.col, connecting_square.row-1)
                    if shortest == 'down'
                        connecting_square = @get_square(connecting_square.col, connecting_square.row+1)

                    connecting_square.$dom_node.addClass('moving-through')
                    if connecting_square == @active_square
                        break


    get_square: (col, row) ->
        @sectors[Math.floor(col / TB.sector_size)][Math.floor(row / TB.sector_size)].squares[col][row]


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



    load_sectors_on_screen: ->
        sector_pixel_size = TB.sector_size * TB.grid_size
        sectors_wide  = Math.ceil(@get_view_width() / TB.sector_size / TB.grid_size)
        sectors_high = Math.ceil(@get_view_height() / TB.sector_size / TB.grid_size)

        for sector_col in [0..sectors_wide]
            for sector_row in [0..sectors_high]
                x = (Math.floor(@scroll.x / sector_pixel_size)) + sector_col
                y = (Math.floor(@scroll.y / sector_pixel_size)) + sector_row
                @load_sector(x, y)

    get_view_width: ->
        $(window).width() - (48+20) - 160
    get_view_height: ->
        $(window).height() - 96

