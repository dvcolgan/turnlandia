class ActionManager
    constructor: ->
        $(document).on 'unitPlaced', @handleInitialPlacement

    handleInitialPlacement: (event) =>
        $.ajax({
            url: '/api/actions/'
            method: 'POST'
            dataType: 'json'
            data:
                type: 'initialPlacement'
                col: event.col
                row: event.row

            success: (response) ->
            error: (response) ->
                alert("Error saving move.  Please check your internet connection and try again: #{JSON.stringify(response)}")
        })


    draw: ->
        TB.ctx.textAlign = 'right'
        TB.fillOutlinedText("This Turn's Actions", TB.boardWidth - 16, 24)
        for action, i in TB.actions
            TB.fillOutlinedText(action.name, TB.boardWidth - 16, 24 + i*24 + 24)
