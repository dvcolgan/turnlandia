define ['lodash'], (_) ->

    class Action
        constructor: (json) ->
            _.extend(@, json)

    class ActionLog
        constructor: ->
            @actions = []
            @$dom_node = jQuery('.action-log')

        add: (action) ->
            @actions.push(action)
            $new_entry = jQuery('<div class="action-log-entry"></div>')
            $new_entry.text(action.kind)
            @$dom_node.append($new_entry)

        get_last_action: ->
            return @actions[@actions.length-1]
        remove_last_action: ->
            @$dom_node.find('.action-log-entry:last').remove()
            return @actions.pop()

    return {
        Action: Action
        ActionLog: ActionLog
    }
