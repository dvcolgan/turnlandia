class ActionManager
    constructor: ->
        $(document).on 'unitPlaced', @handleInitialPlacement
        @actions = []

    add: (action) ->
        @actions.push(action)

    handleInitialPlacement: (event) =>
        $.ajax({
            url: '/api/action/'
            method: 'POST'
            dataType: 'json'
            data:
                type: 'initial'
                col: event.col
                row: event.row

            success: (response) ->
            error: (response) ->
                alert("Error saving move.  Please check your internet connection and try again: #{JSON.stringify(response)}")
        })


    draw: ->
        TB.ctx.textAlign = 'right'
        TB.fillOutlinedText("This Turn's Actions", TB.board.width - 16, 24)
        for action, i in @actions
            TB.fillOutlinedText(action.name, TB.board.width - 16, 24 + i*24 + 24)
