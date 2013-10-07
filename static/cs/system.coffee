# This file is the entry point to the game on the browser side

requestAnimationFrame = window.requestAnimationFrame or window.mozRequestAnimationFrame or
                        window.webkitRequestAnimationFrame or window.msRequestAnimationFrame
window.requestAnimationFrame = requestAnimationFrame

window.TB =
    #@action_log = new action.ActionLog()
    #@actions = []
    #@current_action = 'move'

    players: {}

    currentAction: 'initial'

    dragging: false
    lastMouse: { x: 0, y: 0 }
    lastScroll: { x: 0, y: 0 }

    unitSize: 32
    gridSize: 48
    sectorSize: 10

    # Images that have been preloaded in the HTML
    images:
        gridImage: $('#grid-image').get(0)
        forestTiles: $('#forest-tiles').get(0)
        mountainsTiles: $('#mountains-tiles').get(0)
        waterTiles: $('#water-tiles').get(0)

    init: (selector) ->
        TB.selector = selector
        TB.ctx = $(TB.selector).get(0).getContext('2d')

        TB.camera = new Camera()

        TB.board = new Board()
        TB.cursor = new Cursor()
        TB.actions = new ActionManager()

        TB.fetcher = new DataFetcher()
        TB.fetcher.loadInitialData (data) ->
            for action in data.actions
                TB.actions.add(action)
            TB.registerEventHandlers()
            TB.startMainLoop()
            TB.fetcher.loadSectorsOnScreen()


    registerEventHandlers: ->
        $(TB.selector).mousedown (event) =>
            event.preventDefault()
            TB.lastMouse = { x: event.offsetX, y: event.offsetY }
            TB.lastScroll.x = TB.camera.x
            TB.lastScroll.y = TB.camera.y
            TB.dragging = true

        $(TB.selector).mousemove (event) =>
            TB.cursor.move(event.offsetX + TB.camera.x, event.offsetY + TB.camera.y)

            #TB.activeSquare.col = TB.pixelToSectorCoord(x + TB.camera.x)
            #TB.activeSquare.row = TB.pixelToSectorCoord(y + TB.camera.y)

            if TB.dragging
                event.preventDefault()
                TB.camera.move(
                    TB.lastScroll.x - (event.offsetX - TB.lastMouse.x),
                    TB.lastScroll.y - (event.offsetY - TB.lastMouse.y)
                )

                TB.fetcher.loadSectorsOnScreen()

        $(document).mouseup (event) =>
            TB.dragging = false
            #if Math.abs(TB.camera.x - TB.lastScroll.x) < 5 and Math.abs(TB.scroll.y - TB.lastScroll.y) < 5
            #    col = TB.mouseXToCol(x)
            #    row = TB.mouseYToRow(y)

            #    TB.board.placeUnit(col, row, 3)

            #console.log TB.dragging


        $(TB.selector).mousewheel (event, delta, deltaX, deltaY) =>
            TB.camera.zoom(event.offsetX, event.offsetY, delta)

        $(window).resize ->
            TB.camera.resize()
            $(TB.selector).attr('width', TB.camera.width).attr('height', TB.camera.height)
            TB.ctx = $(TB.selector).get(0).getContext('2d')
        $(window).trigger('resize')

        # Check out all my decoupling of the fetcher and the board~!
        $(window).on 'sectorLoaded', (event) ->
            for square in event.squareData
                TB.board.addSquare(square)




    startMainLoop: ->
        start = null
        mainLoop = (timestamp) ->

            TB.board.draw()
            TB.actions.draw()
            TB.cursor.draw()

            requestAnimationFrame(mainLoop)
        requestAnimationFrame(mainLoop)

    fillOutlinedText: (text, screenX, screenY) ->
        TB.ctx.fillStyle = 'black'
        TB.ctx.fillText(text, screenX+1, screenY+1)
        TB.ctx.fillText(text, screenX+1, screenY-1)
        TB.ctx.fillText(text, screenX-1, screenY+1)
        TB.ctx.fillText(text, screenX-1, screenY-1)
        TB.ctx.fillStyle = 'white'
        TB.ctx.fillText(text, screenX, screenY)

