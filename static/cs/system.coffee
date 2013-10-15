# This file is the entry point to the game on the browser side

requestAnimationFrame = window.requestAnimationFrame or window.mozRequestAnimationFrame or
                        window.webkitRequestAnimationFrame or window.msRequestAnimationFrame
window.requestAnimationFrame = requestAnimationFrame

window.TB =
    players: {}

    currentAction: 'move'

    dragging: false
    lastMouse: { x: 0, y: 0 }
    lastScroll: { x: 0, y: 0 }
    activeSquare: { col: 0, row: 0 }

    unitSize: 32
    gridSize: 48
    sectorSize: 10
    myAccount: null
    isInitialPlacement: false

    # Images that have been preloaded in the HTML
    images:
        othertilesImage: $('#othertiles-image').get(0)
        gridImage: $('#grid-image').get(0)
        forestTiles: $('#forest-tiles').get(0)
        mountainsTiles: $('#mountains-tiles').get(0)
        waterTiles: $('#water-tiles').get(0)
        roadTiles: $('#road-tiles').get(0)
        cityTiles: $('#city-tiles').get(0)

    init: ->
        TB.ctx = $('.board').get(0).getContext('2d')

        TB.camera = new Camera()

        TB.board = new Board()
        TB.cursor = new Cursor()
        TB.actions = new ActionManager()

        TB.fetcher = new DataFetcher()
        TB.fetcher.loadInitialData (data) ->
            TB.registerEventHandlers()
            TB.isInitialPlacement = data.isInitialPlacement

            if TB.isInitialPlacement
                $('.game-toolbar').find('.btn-action').not('.btn-initial').not('.btn-undo').hide()
                $('.btn-initial').trigger('click')
            else
                $('.game-toolbar').find('.btn-initial').hide()
                $('.btn-move').trigger('click')

            TB.fpsCounter = util.makeFPSCounter(20)
            TB.myAccount = data.account
            $('#total-unit-display').text(data.totalUnits)
            TB.actions.loadFromJSON(data.actions)
            requestAnimationFrame(TB.mainLoop)
            TB.camera.moveTo(
                data.centerCol * TB.camera.zoomedGridSize
                data.centerRow * TB.camera.zoomedGridSize
            )
            TB.camera.moveBy(
                -TB.camera.width / 2
                -TB.camera.height / 2
            )
            TB.fetcher.loadSectorsOnScreen()


    registerEventHandlers: ->

        $('.btn-action').click (event) ->
            kind = $(@).data('action')
            if kind == 'undo'
                TB.actions.undo()
                requestAnimationFrame(TB.mainLoop)
            else if kind == 'move' and $(@).hasClass('yellow')
                TB.actions.cancelMove()
            else
                TB.currentAction = kind
                $('.btn-action').removeClass('active')
                $(@).addClass('active')
            requestAnimationFrame(TB.mainLoop)



        $('.board').mousedown (event) =>
            event.preventDefault()
            TB.lastMouse = { x: event.offsetX, y: event.offsetY }
            TB.lastScroll.x = TB.camera.x
            TB.lastScroll.y = TB.camera.y
            TB.dragging = true
            requestAnimationFrame(TB.mainLoop)

        $('.board').mousemove(( ->
            lastX = null
            lastY = null
            (event) =>
                if event.clientX == lastX and event.clientY == lastY
                    return
                lastX = event.clientX
                lastY = event.clientY

                TB.cursor.move(event.offsetX + TB.camera.x, event.offsetY + TB.camera.y)

                TB.activeSquare.col = TB.camera.mouseXToCol(event.offsetX)
                TB.activeSquare.row = TB.camera.mouseYToRow(event.offsetY)

                if TB.dragging
                    event.preventDefault()
                    TB.camera.moveTo(
                        TB.lastScroll.x - (event.offsetX - TB.lastMouse.x),
                        TB.lastScroll.y - (event.offsetY - TB.lastMouse.y)
                    )

                    TB.fetcher.loadSectorsOnScreen()

                requestAnimationFrame(TB.mainLoop)
        )())

        $('.board').mouseup (event) =>
            TB.dragging = false
            if Math.abs(TB.camera.x - TB.lastScroll.x) < 5 and Math.abs(TB.camera.y - TB.lastScroll.y) < 5
                TB.actions.handleAction(
                    TB.currentAction
                    TB.camera.mouseXToCol(event.offsetX)
                    TB.camera.mouseYToRow(event.offsetY)
                )
            requestAnimationFrame(TB.mainLoop)

        $('.board').mouseleave (event) =>
            TB.dragging = false
            requestAnimationFrame(TB.mainLoop)


        $('.board').mousewheel (event, delta, deltaX, deltaY) =>
            TB.camera.zoom(event.offsetX, event.offsetY, delta)
            requestAnimationFrame(TB.mainLoop)

        $(window).resize ->
            TB.camera.resize()
            $('.board').attr('width', TB.camera.width).attr('height', TB.camera.height)
            $('.stats-bar').css('width', TB.camera.width)
            TB.ctx = $('.board').get(0).getContext('2d')
            requestAnimationFrame(TB.mainLoop)
        $(window).trigger('resize')

        # Check out all my decoupling of the fetcher and the board~!
        $(window).on 'squaresLoaded', (event) ->
            for squareData in event.squareData
                TB.board.addSquare(squareData)
            requestAnimationFrame(TB.mainLoop)

        $(window).on 'objectsLoaded', (event) ->
            for unitData in event.sectorData.units
                TB.board.addUnit(unitData)
            for treeData in event.sectorData.trees
                TB.board.addTree(treeData)
            requestAnimationFrame(TB.mainLoop)


    mainLoop: (timestamp) ->

        TB.board.draw()
        TB.actions.draw()
        TB.cursor.draw()

        #fps = TB.fpsCounter(timestamp)
        #TB.fillOutlinedText(fps + ' FPS', 30, 30)


    fillOutlinedText: (text, screenX, screenY) ->
        TB.ctx.save()
        TB.ctx.font = 'bold 16px Arial'
        TB.ctx.fillStyle = 'black'
        TB.ctx.fillText(text, screenX+1, screenY+1)
        TB.ctx.fillText(text, screenX+1, screenY-1)
        TB.ctx.fillText(text, screenX-1, screenY+1)
        TB.ctx.fillText(text, screenX-1, screenY-1)
        TB.ctx.fillStyle = 'white'
        TB.ctx.fillText(text, screenX, screenY)
        TB.ctx.restore()

