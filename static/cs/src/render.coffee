get_view_width: ->
    $(window).width() - 160 - 15 - 100
get_view_height: ->
    $(window).height() - 40 - 5


constructor: (@square, @$dom_node, data) ->
    _.extend(@, data)
    @$dom_node
        .css('background-color', @owner_color)
        .css('border-bottom-width', (@amount + 3)/2)
        .css('margin-top', (-(@amount + 3)/2) + 'px')
        .css('height', (22 + @amount/2) + 'px')
    @$dom_node.text(@amount)

