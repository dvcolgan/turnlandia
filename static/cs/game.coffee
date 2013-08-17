GRID_SIZE = 48
SECTOR_SIZE = 10

randomChoice = (collection) ->
    collection[Math.floor(Math.random()*collection.length)]

getViewWidth = ->
    Math.floor(($(window).width() - (48+20)) / GRID_SIZE)
getViewHeight = ->
    Math.floor(($(window).height() - 96) / GRID_SIZE)

# given position and a width or height, return the coords that it would encompass
getCoordsHalfOffset = (position, length) ->
    [Math.ceil(-length/2)+position...Math.ceil(length/2)+position]

#TODO make this more robust
getColRowFromHash = ->
    pieces = window.location.hash.split('/')
    if pieces.length < 3
        window.location.hash = '#/0/0/'
        pieces = window.location.hash.split('/')
    pos =
        col: parseInt(pieces[1])
        row: parseInt(pieces[2])
    return pos


getXYFromColRow = (pos) ->
    return {
        x: pos.col * GRID_SIZE
        y: pos.row * GRID_SIZE
    }

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

    messages: ->

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
        lastMouseX = 0
        lastMouseY = 0
        lastViewX = 0
        lastViewY = 0
        dragging = false

        $('#board').width(getViewWidth() * GRID_SIZE).height(getViewHeight() * GRID_SIZE)

        gameViewModel = ->
            vm = @

            vm.accountID = window.accountID
            vm.accountColor = window.accountColor
            vm.players = ko.observableArray([])
            vm.currentColor = ko.observable('blue')
            vm.totalUnits = ko.observable(0)

            vm.unitAction = ko.observable('place')
            vm.currentSquareOwner = ko.observable('')

            vm.unplacedUnits = ko.observable(0)
            vm.currentCursor = ko.computed = ->
                switch vm.unitAction()
                    when 'place', 'initial' then 'crosshair'
                    when 'remove' then 'not-allowed'
                    when 'settle' then 'all-scroll'
                    when 'give' then 'e-resize'
                    when 'wall' then 'vertical-text'

            #gridPos = getColRowFromHash()
            #xyPos = getXYFromColRow(gridPos)
            vm.viewX = ko.observable(-$('#board').width()/2)
            vm.viewY = ko.observable(-$('#board').height()/2)

            vm.topCoords = ko.observableArray(getCoordsHalfOffset(0, getViewWidth()))
            vm.sideCoords = ko.observableArray(getCoordsHalfOffset(0, getViewHeight()))


            vm.sectors = ko.observableArray([])

            vm.findSquare = (col, row) ->
                for sector in vm.sectors()
                    for square in sector.squares
                        if square.col == col and square.row == row
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

            vm.handleSquareHover = (square, event) ->
                #TODO add me


            vm.modifyUnit = (square, event) ->
                # If the user was dragging, ignore this click
                if not (Math.abs(lastViewX - vm.viewX()) < 5 and Math.abs(lastViewY - vm.viewY()) < 5) then return

                # TODO - perhaps at some point if there are too many requests going on,
                # group all the actions of the last say 10 seconds together and push them all into one request
                # the payload is nothing more than the x, y, and action
                $.ajax '/api/square/' + square.col + '/' + square.row + '/' + vm.unitAction() + '/',
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
                            vm.findSquare(square.col-1, square.row)
                            vm.findSquare(square.col+1, square.row)
                            vm.findSquare(square.col, square.row-1)
                            vm.findSquare(square.col, square.row+1)
                        ]
                        2: [
                            vm.findSquare(square.col-1, square.row-1)
                            vm.findSquare(square.col+1, square.row+1)
                            vm.findSquare(square.col+1, square.row-1)
                            vm.findSquare(square.col-1, square.row+1)
                        ]
                        1: [
                            vm.findSquare(square.col-2, square.row)
                            vm.findSquare(square.col+2, square.row)
                            vm.findSquare(square.col, square.row-2)
                            vm.findSquare(square.col, square.row+2)
                        ]

                    for count, squares of placement
                        for square in squares
                            if square
                                if square.owner() or square.units().length > 0
                                    alert('Your placement is too close to another player.')
                                    return

                    for count, squares of placement
                        for square in squares
                            if square
                                square.units.push
                                    owner: vm.accountID
                                    ownerColor: vm.accountColor
                                    square: square.id
                                    amount: ko.observable(parseInt(count))
                                    last_turn_amount: 0
                                square.owner(vm.accountID)
                                square.ownerColor(vm.accountColor)
                    vm.unplacedUnits(0)
                    vm.unitAction('place')


                else if vm.unitAction() == 'place'
                    if vm.unplacedUnits() > 0

                        canPlace = false
                        if square.owner() == vm.accountID
                            canPlace = true
                        else
                            other = vm.findSquare(square.col-1, square.row)
                            if other and other.owner() == vm.accountID
                                canPlace = true

                            else
                                other = vm.findSquare(square.col+1, square.row)
                                if other and other.owner() == vm.accountID
                                    canPlace = true

                                else
                                    other = vm.findSquare(square.col, square.row-1)
                                    if other and other.owner() == vm.accountID
                                        canPlace = true

                                    else
                                        other = vm.findSquare(square.col, square.row+1)
                                        if other and other.owner() == vm.accountID
                                            canPlace = true

                        if not canPlace
                            alert('You can only place units on a square you own or adjacent to a square you own.')
                            return

                        # If there is already a unit of this color on this square, update the amount,
                        # otherwise add the whole unit
                        found = false
                        for unit in square.units()
                            if unit.owner == vm.accountID
                                if unit.amount() >= 20
                                    alert('A square can only hold 20 of your units at a time.')
                                    return
                                unit.amount(unit.amount()+1)
                                vm.unplacedUnits(vm.unplacedUnits()-1)
                                found = true
                                break
                        if not found
                            vm.unplacedUnits(vm.unplacedUnits()-1)
                            square.units.push({
                                owner: vm.accountID
                                ownerColor: vm.accountColor
                                square: square.id
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
                            vm.unplacedUnits(vm.unplacedUnits()+1)
                            break

                else if vm.unitAction() == 'settle'
                    # Convert all units of your own color into 4x that many resource points on this tile
                    for i in [0...square.units().length]
                        unit = square.units()[i]
                        if unit.owner == vm.accountID
                            if square.wallHealth() > 0
                                alert('You can not settle on a square with a wall.')
                                return
                            if square.owner() != vm.accountID
                                alert('You can not settle on a square you do not own.')
                                return
                            square.resourceAmount(square.resourceAmount()+4)
                            square.units()[i].amount(square.units()[i].amount()-1)
                            if square.units()[i].amount() == 0
                                square.units.splice(i, 1)
                            break

                else if vm.unitAction() == 'wall'
                    # Convert all units of your own color into a wall on this square
                    for i in [0...square.units().length]
                        unit = square.units()[i]
                        if unit.owner == vm.accountID
                            square.wallHealth(square.wallHealth()+2)
                            square.resourceAmount(0)
                            square.units()[i].amount(square.units()[i].amount()-1)
                            if square.units()[i].amount() == 0
                                square.units.splice(i, 1)
                            break



            vm.loadSectorsOnScreen = () ->
                sectorPixelSize = SECTOR_SIZE * GRID_SIZE
                sectorsWide  = Math.ceil(getViewWidth() / SECTOR_SIZE)
                sectorsHigh = Math.ceil(getViewHeight() / SECTOR_SIZE)

                for sectorX in [0..sectorsWide]
                    for sectorY in [0..sectorsHigh]
                        x = (Math.floor(vm.viewX() / sectorPixelSize) * SECTOR_SIZE) + sectorX * SECTOR_SIZE
                        y = (Math.floor(vm.viewY() / sectorPixelSize) * SECTOR_SIZE) + sectorY * SECTOR_SIZE
                        vm.loadSector(x, y)


            sectorsLoaded = {}
            vm.loadSector = (col, row) ->

                lookup = col+ ' ' + row
                if lookup of sectorsLoaded or col > MAX_COL or col < MIN_COL or row > MAX_ROW or row < MIN_ROW
                    return
                else
                    sectorsLoaded[lookup] = true

                $.getJSON '/api/sector/'+col+'/'+row+'/'+SECTOR_SIZE+'/'+SECTOR_SIZE+'/', (data, status) ->
                    if status == 'success'
                        squares = []
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


                            squares.push({
                                left: parseInt((i % SECTOR_SIZE) * GRID_SIZE) + 'px'
                                top: parseInt(Math.floor(i / SECTOR_SIZE) * GRID_SIZE) + 'px'
                                units: ko.observableArray(units)
                                owner: ko.observable(square.owner)
                                ownerColor: ko.observable(square.owner_color)
                                # TODO be consistent of row/col and x/y
                                id: square.id
                                col: square.col
                                row: square.row
                                wallHealth: ko.observable(square.wall_health)
                                resourceAmount: ko.observable(square.resource_amount)
                            })

                        vm.sectors.push({
                            col: col
                            row: row
                            squares: squares
                        })

                        # TODO move this to another ajax call
                        vm.unplacedUnits(data.unplaced_units)
                        for player in data.players_visible
                            vm.players.push(player)

                        if data.is_initial
                            vm.unitAction('initial')

                        sectorsLoaded[lookup] = true

                    else
                        alert(JSON.stringify(data))

            vm.loadSectorsOnScreen()


            $('#board').mousedown (event) ->
                event.preventDefault()
                lastMouseX = event.clientX
                lastMouseY = event.clientY
                lastViewX = vm.viewX()
                lastViewY = vm.viewY()
                dragging = true


            $('#board').mousemove (event) ->
                if dragging
                    event.preventDefault()
                    vm.viewX(lastViewX - (event.clientX - lastMouseX))
                    vm.viewY(lastViewY - (event.clientY - lastMouseY))

                    vm.loadSectorsOnScreen()

            $(document).mouseup (event) ->
                dragging = false

            $(document).keydown (event) ->
                switch event.which
                    when 49 then vm.unitAction('place')
                    when 50 then vm.unitAction('remove')
                    when 51 then vm.unitAction('settle')
                    when 52 then vm.unitAction('wall')

            resizeBoard = ->
                $('#board').width(getViewWidth() * GRID_SIZE).height(getViewHeight() * GRID_SIZE)
                # TODO Force update to coordinatse on the side, make them computed observables 
                vm.loadSectorsOnScreen()
            $(window).resize(resizeBoard)
            resizeBoard()



            null # return null or the view model will break because coffeescript
        ko.applyBindings(new gameViewModel)

        #opts =
        #    lines: 13
        #    length: 40
        #    width: 16
        #    radius: 60
        #    corners: 1
        #    rotate: 0
        #    direction: 1
        #    color: '#000'
        #    speed: 2.2
        #    trail: 60
        #    shadow: true
        #    hwaccel: true
        #    className: 'spinner'
        #    zIndex: 2e9
        #    top: (getViewHeight() * GRID_SIZE) / 2 - 120
        #    left: 'auto'
        #spinner = new Spinner(opts).spin($('#board').get(0))




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
