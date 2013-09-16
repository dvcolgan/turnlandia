
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

