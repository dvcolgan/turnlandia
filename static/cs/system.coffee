class System
    constructor: ->
        window.TB = @
        @moves = []
        @current_action = 'place'
        $.getJSON '/api/initial-load/', (data, status) =>
            if status == 'success'
                _.extend(@, data.board_consts)
                for move in data.moves
                    @add_move(move)
                @account = data.account

            @board = new Board($('#board'))

        $(document).keydown (event) =>
            switch event.which
                # 1, 2, 3, and 4 keys
                when 49 then @set_action('move')
                when 50 then @set_action('attack')
                when 51 then @set_action('city')
                #when 52 then @set_action('undo')

        $('.btn-action').click (event) =>
            @set_action($(event.target).data('action'))


    set_action: (action) ->
        console.log('setting action to ' + action)
        @current_action = action
        $btn_dom_node = $('button[data-action=' + action + ']')
        $('.btn-action').not($btn_dom_node).removeClass('active')
        $btn_dom_node.addClass('active')
        #switch vm.currentAction()
        #    when 'move', 'initial' then 'crosshair'
        #    when 'attack' then 'crosshair'
        #    when 'city' then 'crosshair'


    add_move: (data) ->
        @moves.push(new Move(data))


new System()


#
#            vm.doAction = (square, event) ->
#                # If the user was dragging, ignore this click
#                if not (Math.abs(lastViewX - vm.viewX()) < 5 and Math.abs(lastViewY - vm.viewY()) < 5) then return
#
#                if vm.currentAction() == 'move'
#                    if not vm.isMoving()
#                        vm.moveStartSquare(vm.activeSquare())
#                        vm.isMoving(true)
#                        console.log('setting ismoving to true')
#
#                return
#                        
#
#                # TODO - perhaps at some point if there are too many requests going on,
#                # group all the actions of the last say 10 seconds together and push them all into one request
#                # the payload is nothing more than the x, y, and action
#                $.ajax '/api/square/' + square.col + '/' + square.row + '/' + vm.unitAction() + '/',
#                    contentType: "application/json"
#                    type: 'POST'
#                    success: (data, status) ->
#                        if status != 'success'
#                            alert(JSON.stringify(data))
#                            # TODO remove the units from the board or force refresh if this happens
#                            #
#                if vm.unitAction() == 'initial'
#                    # Set the 8 on the square clicked on
#                    placement =
#                        8: [square]
#                        4: [
#                            vm.findSquare(square.col-1, square.row)
#                            vm.findSquare(square.col+1, square.row)
#                            vm.findSquare(square.col, square.row-1)
#                            vm.findSquare(square.col, square.row+1)
#                        ]
#                        2: [
#                            vm.findSquare(square.col-1, square.row-1)
#                            vm.findSquare(square.col+1, square.row+1)
#                            vm.findSquare(square.col+1, square.row-1)
#                            vm.findSquare(square.col-1, square.row+1)
#                        ]
#                        1: [
#                            vm.findSquare(square.col-2, square.row)
#                            vm.findSquare(square.col+2, square.row)
#                            vm.findSquare(square.col, square.row-2)
#                            vm.findSquare(square.col, square.row+2)
#                        ]
#
#                    for count, squares of placement
#                        for square in squares
#                            if square
#                                if square.owner() or square.units().length > 0
#                                    alert('Your placement is too close to another player.')
#                                    return
#
#                    for count, squares of placement
#                        for square in squares
#                            if square
#                                square.units.push
#                                    owner: vm.accountID
#                                    ownerColor: vm.accountColor
#                                    square: square.id
#                                    amount: ko.observable(parseInt(count))
#                                    last_turn_amount: 0
#                                square.owner(vm.accountID)
#                                square.ownerColor(vm.accountColor)
#                    vm.unplacedUnits(0)
#                    vm.unitAction('place')
#
#
#                else if vm.unitAction() == 'place'
#                    if vm.unplacedUnits() > 0
#
#                        canPlace = false
#                        if square.owner() == vm.accountID
#                            canPlace = true
#                        else
#                            other = vm.findSquare(square.col-1, square.row)
#                            if other and other.owner() == vm.accountID
#                                canPlace = true
#
#                            else
#                                other = vm.findSquare(square.col+1, square.row)
#                                if other and other.owner() == vm.accountID
#                                    canPlace = true
#
#                                else
#                                    other = vm.findSquare(square.col, square.row-1)
#                                    if other and other.owner() == vm.accountID
#                                        canPlace = true
#
#                                    else
#                                        other = vm.findSquare(square.col, square.row+1)
#                                        if other and other.owner() == vm.accountID
#                                            canPlace = true
#
#                        if not canPlace
#                            alert('You can only place units on a square you own or adjacent to a square you own.')
#                            return
#
#                        # If there is already a unit of this color on this square, update the amount,
#                        # otherwise add the whole unit
#                        found = false
#                        for unit in square.units()
#                            if unit.owner == vm.accountID
#                                if unit.amount() >= 20
#                                    alert('A square can only hold 20 of your units at a time.')
#                                    return
#                                unit.amount(unit.amount()+1)
#                                vm.unplacedUnits(vm.unplacedUnits()-1)
#                                found = true
#                                break
#                        if not found
#                            vm.unplacedUnits(vm.unplacedUnits()-1)
#                            square.units.push({
#                                owner: vm.accountID
#                                ownerColor: vm.accountColor
#                                square: square.id
#                                amount: ko.observable(1)
#                                last_turn_amount: 0 # This may take some work to get working
#                            })
#
#
#                else if vm.unitAction() == 'remove'
#                    for i in [0...square.units().length]
#                        unit = square.units()[i]
#                        if unit.owner == vm.accountID
#                            if unit.amount() == 1
#                                square.units.splice(i, 1)
#                            else
#                                unit.amount(unit.amount()-1)
#                            vm.unplacedUnits(vm.unplacedUnits()+1)
#                            break
#
#                else if vm.unitAction() == 'settle'
#                    # Convert all units of your own color into 4x that many resource points on this tile
#                    for i in [0...square.units().length]
#                        unit = square.units()[i]
#                        if unit.owner == vm.accountID
#                            if square.wallHealth() > 0
#                                alert('You can not settle on a square with a wall.')
#                                return
#                            if square.owner() != vm.accountID
#                                alert('You can not settle on a square you do not own.')
#                                return
#                            square.resourceAmount(square.resourceAmount()+4)
#                            square.units()[i].amount(square.units()[i].amount()-1)
#                            if square.units()[i].amount() == 0
#                                square.units.splice(i, 1)
#                            break
#
#                else if vm.unitAction() == 'wall'
#                    # Convert all units of your own color into a wall on this square
#                    for i in [0...square.units().length]
#                        unit = square.units()[i]
#                        if unit.owner == vm.accountID
#                            square.wallHealth(square.wallHealth()+2)
#                            square.resourceAmount(0)
#                            square.units()[i].amount(square.units()[i].amount()-1)
#                            if square.units()[i].amount() == 0
#                                square.units.splice(i, 1)
#                            break
