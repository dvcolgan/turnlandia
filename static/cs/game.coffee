GRID_SIZE = 42

randomChoice = (collection) ->
    collection[Math.floor(Math.random()*collection.length)]

getViewWidth = ->
    Math.floor(($(window).width() - (48+20)) / GRID_SIZE)
getViewHeight = ->
    Math.floor(($(window).height() - (110+24)) / GRID_SIZE)

# given position and a width or height, return the coords that it would encompass
getCoordsHalfOffset = (position, length) ->
    [Math.ceil(-length/2)+position...Math.ceil(length/2)+position]

GAME =
    world_names: [
        'Atlantis',
        'Azeroth',
        'Camelot',
        'Narnia',
        'Hyrule',
        'Middle-earth',
        'The Neverhood',
        'Rapture',
        'Terabithia',
        'Kanto',
        'The Grand Line',
        'Tatooine',
        'Naboo',
        'Pandora',
        'Corneria',
        'Termina',
        'Xen',
        'City 17',
        'Tokyo',
        'Ithica',
        'Peru',
    ]
    player_names: [
        ['Frodo Baggins', 'Shire Hobbits'],
        ['Elrond', 'Mirkwood Elves'],
        ['Durin Darkhammer', 'Moria Dwarves'],
        ['Ness', 'Eagleland'],
        ['Daphnes Nohansen Hyrule', 'Hylians'],
        ['Aragorn son of Arathorn', 'Gondorians'],
        ['Strong Bad', 'Strongbadia'],
        ['Captain Homestar', 'The Team'],
        ['T-Rex', 'Dinosaurs'],
        ['Refrigerator', 'Kitchen Appliances'],
        ['The Burger King', 'Fast Foodies'],
        ['Larry King Live', 'Interviewees'],
        ['King', 'Mimigas'],
        ['Luke Skywalker', 'The Rebel Alliance'],
        ['Darth Vader', 'The Empire'],
        ['Jean-Luc Picard', 'The Enterprise'],
        ['The Borg Queen', 'The Borg'],
        ['Bowser', 'Koopas'],
    ]

    home: ->

    create_accout: ->

    settings: ->
        settingsViewModel = ->
            vm = @
            vm.leaderName = ko.observable($('#id_leader_name').val())
            vm.peopleName = ko.observable($('#id_people_name').val())
            null

        ko.applyBindings(new settingsViewModel)

        startingColor = $('#id_color').val() or '#ffffff'
        $('#id_color').css('background-color', startingColor).css('color', startingColor)

        $('#id_color').ColorPicker
            color: startingColor

            onShow: (colpkr) ->
                $(colpkr).fadeIn(100)
                return false

            onChange: (hsb, hex, rgb) ->
                $('#id_color').val('#' + hex).css('background-color', '#' + hex).css('color', '#' + hex)

            onHide: (colpkr) ->
                $(colpkr).fadeOut(100)
                return false

    game: ->

        gameViewModel = ->
            vm = @

            vm.accountID = window.accountID
            vm.accountColor = window.accountColor
            vm.players = ko.observableArray([])
            vm.currentColor = ko.observable('blue')
            vm.totalUnits = ko.observable(0)

            vm.unitAction = ko.observable('place')

            vm.unitsRemaining = ko.observable(0)
            vm.currentCursor = ko.computed = ->
                switch vm.unitAction()
                    when 'place', 'initial' then 'crosshair'
                    when 'remove' then 'not-allowed'
                    when 'settle' then 'all-scroll'
                    when 'give' then 'e-resize'
                    when 'wall' then 'vertical-text'

            pieces = window.location.hash.split('/')
            if pieces.length < 3
                window.location.hash = '#/0/0/'
                pieces = window.location.hash.split('/')
            [_, x, y] = pieces
            x = parseInt(x)
            y = parseInt(y)

            vm.viewX = ko.observable(x)
            vm.viewY = ko.observable(y)
            vm.topCoords = ko.observableArray(getCoordsHalfOffset(vm.viewX(), getViewWidth()))
            vm.sideCoords = ko.observableArray(getCoordsHalfOffset(vm.viewY(), getViewHeight()))

            vm.squares = ko.observableArray([])

            vm.findSquare = (x, y) ->
                for square in vm.squares()
                    if square.x() == x and square.y() == y
                        return square
                return null

            vm.getUnitClass = (idx, square) ->
                return {
                    first: idx() == 0
                    second: idx() == 1
                    third: idx() == 2
                    fourth: idx() == 3
                    one: square.resourceAmount() == 0 and square.wallHealth() == 0 and square.units().length == 1
                    two: square.resourceAmount() == 0 and square.wallHealth() == 0 and square.units().length == 2
                    three: square.resourceAmount() == 0 and square.wallHealth() == 0 and square.units().length == 3
                    four: square.resourceAmount() > 0 or square.wallHealth() > 0 or square.units().length == 4
                }

            vm.moveWindow = (direction) ->
                amountBy = 10
                switch direction
                    when 'left'
                        dx = -amountBy
                        dy = 0
                    when 'right'
                        dx = amountBy
                        dy = 0
                    when 'up'
                        dx = 0
                        dy = -amountBy
                    when 'down'
                        dx = 0
                        dy = amountBy

                vm.viewX(vm.viewX()+dx)
                vm.viewY(vm.viewY()+dy)


            vm.modifyUnit = (square, event) ->
                # TODO - perhaps at some point if there are too many requests going on,
                # group all the actions of the last say 10 seconds together and push them all into one request
                # the payload is nothing more than the x, y, and action

                $.ajax '/api/square/' + square.x() + '/' + square.y() + '/' + vm.unitAction() + '/',
                    contentType: "application/json"
                    data: ko.toJSON(square)
                    type: 'POST'
                    success: (data, status) ->
                        if status != 'success'
                            alert(JSON.stringify(data))
                            # TODO remove the units from the board or force refresh if this happens
                            #
                if vm.unitAction() == 'initial'
                    # Set the 8 on the square clicked on
                    placement =
                        8: [square]
                        4: [
                            vm.findSquare(square.x()-1, square.y())
                            vm.findSquare(square.x()+1, square.y())
                            vm.findSquare(square.x(), square.y()-1)
                            vm.findSquare(square.x(), square.y()+1)
                        ]
                        2: [
                            vm.findSquare(square.x()-1, square.y()-1)
                            vm.findSquare(square.x()+1, square.y()+1)
                            vm.findSquare(square.x()+1, square.y()-1)
                            vm.findSquare(square.x()-1, square.y()+1)
                        ]
                        1: [
                            vm.findSquare(square.x()-2, square.y())
                            vm.findSquare(square.x()+2, square.y())
                            vm.findSquare(square.x(), square.y()-2)
                            vm.findSquare(square.x(), square.y()+2)
                        ]

                    for count, squares of placement
                        for square in squares
                            if square
                                square.units.push
                                    owner: vm.accountID
                                    ownerColor: vm.accountColor
                                    square: square.id()
                                    amount: ko.observable(parseInt(count))
                                    last_turn_amount: 0
                    vm.unitsRemaining(0)
                    vm.unitAction('place')


                else if vm.unitAction() == 'place'
                    if vm.unitsRemaining() > 0
                        # If there is already a unit of this color on this square, update the amount,
                        # otherwise add the whole unit
                        found = false
                        for unit in square.units()
                            if unit.owner == vm.accountID
                                unit.amount(unit.amount()+1)
                                vm.unitsRemaining(vm.unitsRemaining()-1)
                                found = true
                                break
                        if not found
                            vm.unitsRemaining(vm.unitsRemaining()-1)
                            square.units.push({
                                owner: vm.accountID
                                ownerColor: vm.accountColor
                                square: square.id()
                                amount: ko.observable(1)
                                last_turn_amount: 0 # This may take some work to get working
                            })


                else if vm.unitAction() == 'remove'
                    for i in [0...square.units().length]
                        unit = square.units()[i]
                        if unit.owner == vm.accountID
                            if unit.amount() == 1
                                square.units.splice(i, 1)
                            else
                                unit.amount(unit.amount()-1)
                            vm.unitsRemaining(vm.unitsRemaining()+1)
                            break

                else if vm.unitAction() == 'settle'
                    # Convert all units of your own color into 4x that many resource points on this tile
                    for i in [0...square.units().length]
                        unit = square.units()[i]
                        if unit.owner == vm.accountID
                            square.resourceAmount(square.resourceAmount()+unit.amount())
                            square.units.splice(i, 1)
                            break

                else if vm.unitAction() == 'wall'
                    # Convert all units of your own color into a wall on this square
                    for i in [0...square.units().length]
                        unit = square.units()[i]
                        if unit.owner == vm.accountID
                            square.wallHealth(square.wallHealth()+unit.amount()*2)
                            square.units.splice(i, 1)
                            break


            vm.fetchBoard = (centerX, centerY) ->
                
                $.getJSON '/api/sector/'+centerX+'/'+centerY+'/'+getViewWidth()+'/'+getViewHeight()+'/', (data, status) ->
                    if status == 'success'
                        xOffset = -vm.topCoords()[0]
                        yOffset = -vm.sideCoords()[0]
                        vmSquares = vm.squares()
                        for square, i in data.squares
                            units = []
                            for unit in square.units
                                units.push({
                                    owner: unit.owner
                                    ownerColor: unit.owner_color
                                    square: square.id
                                    amount: ko.observable(unit.amount)
                                    last_turn_amount: unit.last_turn_amount
                                })

                            vmSquare = vmSquares[i]
                            vmSquare.id(square.id)
                            vmSquare.left(((square.x+xOffset) * GRID_SIZE) + 'px')
                            vmSquare.top(((square.y+yOffset) * GRID_SIZE) + 'px')
                            vmSquare.units(units)
                            vmSquare.owner(square.owner)
                            vmSquare.ownerColor(square.owner_color)
                            vmSquare.x(square.x)
                            vmSquare.y(square.y)
                            vmSquare.wallHealth(square.wall_health)
                            vmSquare.resourceAmount(square.resource_amount)
                            console.log 'updating square'

                            #vm.squares.push({
                            #    left: ((square.x+xOffset) * GRID_SIZE) + 'px'
                            #    top: ((square.y+yOffset) * GRID_SIZE) + 'px'
                            #    units: ko.observableArray(units)
                            #    owner: ko.observable(square.owner)
                            #    ownerColor: ko.observable(square.owner_color)
                            #    x: square.x
                            #    y: square.y
                            #    wallHealth: ko.observable(square.wall_health)
                            #    resourceAmount: ko.observable(square.resource_amount)
                            #})
                        vm.unitsRemaining(data.total_units - data.units_placed)
                        vm.totalUnits(data.total_units)
                        for player in data.players_visible
                            vm.players.push(player)
                        #ng-style="{width: data.board_width, height: data.board_height}"
                        # at some point resize the board on screen resize
                        if data.is_initial
                            vm.unitAction('initial')
                        else
                            vm.unitAction('place')

                        $('.spinner').hide()
                    else
                        alert(JSON.stringify(data))


            # Initialize the board with empty squares
            for row in [0...getViewWidth()]
                for col in [0...getViewHeight()]
                    console.log 'setting square'
                    vm.squares.push({
                        left: ko.observable(0)
                        top: ko.observable(0)
                        units: ko.observableArray([])
                        owner: ko.observable(0)
                        id: ko.observable(0)
                        ownerColor: ko.observable('')
                        x: ko.observable(0)
                        y: ko.observable(0)
                        wallHealth: ko.observable(0)
                        resourceAmount: ko.observable(0)
                    })

            vm.fetchBoard(vm.viewX(), vm.viewY())


            null # return null or the view model will break because coffeescript
        ko.applyBindings(new gameViewModel)

        opts =
            lines: 13
            length: 40
            width: 16
            radius: 60
            corners: 1
            rotate: 0
            direction: 1
            color: '#000'
            speed: 2.2
            trail: 60
            shadow: true
            hwaccel: true
            className: 'spinner'
            zIndex: 2e9
            top: (getViewHeight() * GRID_SIZE) / 2 - 120
            left: 'auto'
        spinner = new Spinner(opts).spin($('#board').get(0))
        $('#board').width(getViewWidth() * GRID_SIZE).height(getViewHeight() * GRID_SIZE)

$ ->
    # Make it so that the csrf token works
    $.ajaxSetup({
        crossDomain: false
        beforeSend: (xhr, settings) ->
            # these HTTP methods do not require CSRF protection
            if not /^(GET|HEAD|OPTIONS|TRACE)$/.test(settings.type)
                xhr.setRequestHeader("X-CSRFToken", $.cookie('csrftoken'))
    })

    cl = $('body').attr('class')
    if cl then GAME[cl]()
