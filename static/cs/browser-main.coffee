# This file is the entry point to the game on the browser side

browserMain =
    #window.TB = @
    #@action_log = new action.ActionLog()
    #@actions = []
    #@current_action = 'move'

    players: {}

    init: ->
        @board = new Board('.board')

        $(document).on 'needsector', '.board', (event, x, y) =>
            console.log 'needsector handler ' + x + ' ' +  y
            $.ajax({
                url: '/api/squares/' + (x*10) + '/' + (y*10) + '/' + ((x+1)*10) + '/' + ((y+1)*10) + '/'
                method: 'GET'
                dataType: 'json'
                success: (data) =>
                    console.log 'after ajax ' + x + ' ' + y
                    @board.receiveSectorData(x, y, data)
            })

        $.ajax
            url: '/api/users/'
            method: 'GET'
            dataType: 'json'
            success: (data) =>
                @players = data







        # Set up event handlers

    createBoard: ->
        for col, rows of @squares
            for row, square of rows

                $domNode = $('<div class="grid-square">
                                  <div class="subtile north-west"></div>
                                  <div class="subtile north-east"></div>
                                  <div class="subtile south-west"></div>
                                  <div class="subtile south-east"></div>
                              </div>')
                $domNode
                    .css('left', parseInt(col * @gridSize) + 'px')
                    .css('top', parseInt(row * @gridSize) + 'px')
                $('.scroll-pane').append($domNode)

                if square.terrainType == 'water' or square.terrainType == 'mountains' or square.terrainType == 'forest'
                    $domNode.find('.subtile').css('background-image', 'url(/static/images/' + square.terrainType + '-tiles.png)')
                    $domNode.find('.north-west').css('background-position', @getTile24CSSOffset(square.northWestTile24))
                    $domNode.find('.north-east').css('background-position', @getTile24CSSOffset(square.northEastTile24))
                    $domNode.find('.south-west').css('background-position', @getTile24CSSOffset(square.southWestTile24))
                    $domNode.find('.south-east').css('background-position', @getTile24CSSOffset(square.southEastTile24))

                #$domNode.css('background-color': @owner_color)
                $domNode.css('background-color': '#00aa44')

                $domNode.data('col', col).data('row', row)

                if col not of @squareDomNodes
                    @squareDomNodes[col] = {}
                if row not of @squareDomNodes[col]
                    @squareDomNodes[col][row] = {}
                @squareDomNodes[col][row] = $domNode


                ## Warning crazy hacks afoot
                #for i in [0...@units.length]
                #    $unit_dom_node = $('<div class="unit"></div>')
                #    if i == 0 then $unit_dom_node.addClass('first')
                #    if i == 1 then $unit_dom_node.addClass('second')
                #    if i == 2 then $unit_dom_node.addClass('third')
                #    if i == 3 then $unit_dom_node.addClass('fourth')
                #    if @units.length == 1 then $unit_dom_node.addClass('one')
                #    if @units.length == 2 then $unit_dom_node.addClass('two')
                #    if @units.length == 3 then $unit_dom_node.addClass('three')
                #    if @units.length == 4 then $unit_dom_node.addClass('four')
                #    $domNode.append($unit_dom_node)
                #    @units[i] = new Unit(@, $unit_dom_node, @units[i])
