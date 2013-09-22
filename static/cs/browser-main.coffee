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
                url: '/api/squares/' + (x*10) + '/' + (y*10) + '/' + ((x+1)*10-1) + '/' + ((y+1)*10-1) + '/'
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








