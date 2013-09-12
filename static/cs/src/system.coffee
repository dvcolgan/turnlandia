define ['lodash', 'src/action', 'src/board'], (_, action, board) ->

    class System
        constructor: ->
            window.TB = @
            @action_log = new action.ActionLog()
            @actions = []
            @current_action = 'move'
            $('button[data-action="move"].btn-action').addClass('active')
            $.getJSON '/api/initial-load/', (data, status) =>
                if status == 'success'
                    _.extend(@, data.board_consts)
                    for action_ in data.actions
                        @add_action(action_)
                    @account = data.account

                @board = new board.Board($('.board'))

            $(document).keydown (event) =>
                switch event.which
                    # 1, 2, 3, and 4 keys
                    when 49 then @set_action('move')
                    when 50 then @set_action('attack')
                    when 51 then @set_action('city')
                    #when 52 then @set_action('undo')

            $('.btn-action, .btn-action img').click (event) =>
                if $(event.target).data('action')
                    which = $(event.target).data('action')
                else
                    which = $(event.target).parents('.btn-action').data('action')

                if which == 'undo'
                    @action_log.remove_last_action()
                    $.ajax({
                        url: '/api/undo/' + @action_log.get_last_action().id + '/'
                        method: 'POST'
                        dataType: 'json'
                        success: (data) =>
                            true
                        error: (data) =>
                            alert('Problem saving your action.  The page will now refresh.  Sorry, I should make this more robust sometime.')
                            window.location.href += ''
                    })
                else
                    @set_action(which)


        set_action: (action_) ->
            console.log('setting action to ' + action_)
            @current_action = action_
            $btn_dom_node = $('button[data-action=' + action_ + ']')
            $('.btn-action').not($btn_dom_node).removeClass('active')
            $btn_dom_node.addClass('active')
            #switch vm.currentAction()
            #    when 'move', 'initial' then 'crosshair'
            #    when 'attack' then 'crosshair'
            #    when 'city' then 'crosshair'


        add_action: (data) ->
            new_action = new action.Action(data)
            @actions.push(new_action)
            @action_log.add(new_action)

    new System()


