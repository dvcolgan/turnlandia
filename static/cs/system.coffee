# This file is the entry point to the game on the browser side

requestAnimationFrame = window.requestAnimationFrame or window.mozRequestAnimationFrame or
                        window.webkitRequestAnimationFrame or window.msRequestAnimationFrame
window.requestAnimationFrame = requestAnimationFrame


class Account
    constructor: (@id, @username, @color) ->

window.TB =
    players: {}

    currentAction: 'move'

    dragging: false
    lastMouse: { x: 0, y: 0 }
    lastScroll: { x: 0, y: 0 }
    activeSquare: { col: 0, row: 0 }

    unitSize: 32
    gridSize: 48
    sectorSize: 50
    myAccount: null
    accounts: {}
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

            # TODO REMOVE ME WHEN THIS IS DONE
            TB.myAccount.wood = 100

            $('#total-unit-display').text(data.totalUnits)
            $('#wood-display').text(data.account.wood)
            $('#food-display').text(data.account.food)
            $('#ore-display').text(data.account.ore)
            $('#money-display').text(data.account.money)
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
                TB.board.showRoadOverlay = (kind == 'road')
            requestAnimationFrame(TB.mainLoop)


        $('.board').mousedown (event) =>
            event.preventDefault()
            [offsetX, offsetY] = util.getMouseOffset(event)
            TB.lastMouse = { x: offsetX, y: offsetY }
            TB.lastScroll.x = TB.camera.x
            TB.lastScroll.y = TB.camera.y
            TB.dragging = true
            requestAnimationFrame(TB.mainLoop)

        $('.board').mousemove(( ->
            lastX = null
            lastY = null
            (event) =>
                [offsetX, offsetY] = util.getMouseOffset(event)
                if offsetX == lastX and offsetY == lastY
                    return
                lastX = offsetX
                lastY = offsetY

                TB.activeSquare.col = TB.camera.mouseXToCol(offsetX)
                TB.activeSquare.row = TB.camera.mouseYToRow(offsetY)

                if TB.dragging
                    event.preventDefault()
                    TB.camera.moveTo(
                        TB.lastScroll.x - (offsetX - TB.lastMouse.x),
                        TB.lastScroll.y - (offsetY - TB.lastMouse.y)
                    )

                    TB.fetcher.loadSectorsOnScreen()

                requestAnimationFrame(TB.mainLoop)
        )())

        $('.board').mouseup (event) =>
            [offsetX, offsetY] = util.getMouseOffset(event)
            TB.dragging = false
            if Math.abs(TB.camera.x - TB.lastScroll.x) < 5 and Math.abs(TB.camera.y - TB.lastScroll.y) < 5
                TB.actions.handleAction(
                    TB.currentAction
                    TB.camera.mouseXToCol(offsetX)
                    TB.camera.mouseYToRow(offsetY)
                )
            requestAnimationFrame(TB.mainLoop)

        $('.board').mouseleave (event) =>
            TB.dragging = false
            requestAnimationFrame(TB.mainLoop)


        $('.board').mousewheel (event, delta, deltaX, deltaY) =>
            [offsetX, offsetY] = util.getMouseOffset(event)
            TB.camera.zoom(offsetX, offsetY, delta)
            requestAnimationFrame(TB.mainLoop)

        $(window).resize ->
            TB.camera.resize()
            $('.board').attr('width', TB.camera.width).attr('height', TB.camera.height)
            $('.stats-bar').css('width', TB.camera.width)
            TB.ctx = $('.board').get(0).getContext('2d')
            requestAnimationFrame(TB.mainLoop)
        $(window).trigger('resize')

        # Check out all my decoupling of the fetcher and the board~!
        $(window).on 'sectorLoaded', (event) ->
            if event.sectorData
                [squareData, unitData, accountData] = event.sectorData.split('|')

                if squareData
                    startCol = event.sectorX * TB.sectorSize
                    startRow = event.sectorY * TB.sectorSize
                    console.log startCol + ' ' + startRow
                    for rowData, row in squareData.split('\n')
                        for terrainType, col in rowData.split(',')
                            TB.board.addSquare(startCol + col, startRow + row, parseInt(terrainType))

                if accountData
                    for thisAccountData in accountData.split('\n')
                        [accountID, username, color] = thisAccountData.split(',')
                        TB.accounts[accountID] = new Account(parseInt(accountID), username, color)

                if unitData
                    for thisUnitData in unitData.split('\n')
                        [col, row, ownerID, amount] = thisUnitData.split(',')
                        TB.board.addUnit(parseInt(col), parseInt(row), parseInt(ownerID), parseInt(amount))

                requestAnimationFrame(TB.mainLoop)


    mainLoop: (timestamp) ->

        TB.board.draw()
        TB.actions.draw()
        TB.drawCursor()
        #fps = TB.fpsCounter(timestamp)
        #TB.fillOutlinedText(fps + ' FPS', 30, 30)


    drawCursor: ->
        cursorSize = TB.camera.zoomedGridSize

        screenX = TB.camera.worldColToScreenPosX(TB.activeSquare.col)
        screenY = TB.camera.worldRowToScreenPosY(TB.activeSquare.row)
        console.log screenX + ' ' + screenY

        TB.ctx.save()
        TB.ctx.strokeStyle = 'black'
        TB.ctx.fillStyle = 'black'
        TB.ctx.strokeRect(screenX, screenY, cursorSize, cursorSize)
        TB.ctx.restore()

        textX = screenX - 8
        textY = screenY - 4
        TB.fillOutlinedText(TB.activeSquare.col + ',' + TB.activeSquare.row, textX, textY)



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

