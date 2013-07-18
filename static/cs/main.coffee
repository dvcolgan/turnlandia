ig.module(
	'game.main'
)
.requires(
    #'game.entities.player'
	'impact.entity'
	'impact.game'
	'impact.font'
    'game.board-square'
    'game.unit'
    #'game.levels.plains'
    #'game.levels.villiage'
    #'game.levels.castle'
    #'game.levels.example'
)
.defines =>

    @TurnBased = ig.Game.extend
        TILE_SIZE: 42

        font: new ig.Font('images/04b03.font-large.png')
        gridImage: new ig.Image('images/grid-small.png')
        gravity: 0
        clearColor: 'white'

        init: ->
            ig.input.bind(ig.KEY.LEFT_ARROW, 'left')
            ig.input.bind(ig.KEY.RIGHT_ARROW, 'right')
            ig.input.bind(ig.KEY.UP_ARROW, 'up')
            ig.input.bind(ig.KEY.DOWN_ARROW, 'down')
            ig.input.bind(ig.KEY.MOUSE1, 'mouseleft')

            ig.input.initMouse()
            @lastMouse = { x: 0, y: 0 }

            $.getJSON '/api/sector/20/10/40/20/', (data, status) ->
                if status == 'success'
                    @data = data
                    for square, i in data.squares
                        console.log 'created square' + i
                        console.log square.x + ' ' + square.y
                        ig.game.spawnEntity(BoardSquare, ig.game.TILE_SIZE * square.x, ig.game.TILE_SIZE * square.y, {
                            color: square.owner_color
                            resourceAmount: square.resource_amount
                            wallHealth: square.wall_health
                        })


            #map = [
            #    [1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1]
            #    [1,1,1,1,1,1,1,1,1,1]
            #]
            #@backgroundMaps.push(new ig.BackgroundMap(42, map, 'images/grid-small.png'))

            #window.soundManager.stopAll()
            #window.soundManager.play('intro-bgm')


        update: ->

            if ig.input.state('left')
                @screen.x -= 4
            if ig.input.state('right')
                @screen.x += 4
            if ig.input.state('up')
                @screen.y -= 4
            if ig.input.state('down')
                @screen.y += 4

            if ig.input.state('mouseleft')
                @screen.x += @lastMouse.x - ig.input.mouse.x
                @screen.y += @lastMouse.y - ig.input.mouse.y

            @lastMouse.x = ig.input.mouse.x
            @lastMouse.y = ig.input.mouse.y


            #if ig.input.pressed('mouseleft')
            #    @backgroundMaps[0].setTile(ig.input.mouse.x + @screen.x, ig.input.mouse.y + @screen.y, 0)

            @parent()

        draw: ->
            @parent()



    # Make it so that the csrf token works
    $.ajaxSetup({
        crossDomain: false
        beforeSend: (xhr, settings) ->
            # these HTTP methods do not require CSRF protection
            if not /^(GET|HEAD|OPTIONS|TRACE)$/.test(settings.type)
                xhr.setRequestHeader("X-CSRFToken", $.cookie('csrftoken'))
    })

    ig.main('#canvas', TurnBased, 12, $(window).width(), $(window).height()-21, 1)
    ig.system.resize($(window).width(),$(window).height()-21)
    $(window).resize ->
        ig.system.resize($(window).width(),$(window).height()-21)
