# This file is the entry point to the game on the browser side

requestAnimationFrame = window.requestAnimationFrame or window.mozRequestAnimationFrame or
                        window.webkitRequestAnimationFrame or window.msRequestAnimationFrame
window.requestAnimationFrame = requestAnimationFrame

window.TB =
    #@action_log = new action.ActionLog()
    #@actions = []
    #@current_action = 'move'

    boardWidth: 0
    boardHeight: 0

    players: {}
    scroll: { x: 0, y: 0 }
    activeSquare: { col: 0, row: 0 }

    currentAction: 'initial'

    zoomLevel: 1
    zoomFactor: 1
    maxZoomLevel: 3

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

        TB.lastMouse = { x: 0, y: 0 }
        TB.lastScroll = { x: 0, y: 0 }
        TB.dragging = false

        TB.squareData = new util.Hash2D()

        TB.board = new Board()
        TB.cursor = new Cursor()
        TB.scroll = { x: 0, y: 0 }

        TB.ctx = $(TB.selector).get(0).getContext('2d')

        TB.fetcher = new DataFetcher()
        TB.fetcher.loadInitialData (data) ->
            TB.actions = data.actions
            TB.actionManager = new ActionManager()
            TB.registerEventHandlers()
            TB.startMainLoop()
            TB.loadSectorsOnScreen()



    loadSectorsOnScreen: ->
        sectorPixelSize = TB.sectorSize * TB.gridSize * TB.zoomFactor
        sectorsWide = Math.ceil((TB.boardWidth / TB.sectorSize / TB.gridSize) * TB.zoomFactor)
        sectorsHigh = Math.ceil((TB.boardHeight / TB.sectorSize / TB.gridSize) * TB.zoomFactor)

        startSectorX = null
        startSectorY = null
        endSectorX = null
        endSectorY = null
        for sectorSectorX in [0..sectorsWide]
            for sectorSectorY in [0..sectorsHigh]
                x = (Math.floor(TB.scroll.x / sectorPixelSize)) + sectorSectorX
                y = (Math.floor(TB.scroll.y / sectorPixelSize)) + sectorSectorY

                if startSectorX == null or x < startSectorX then startSectorX = x
                if startSectorY == null or y < startSectorY then startSectorY = y
                if endSectorX == null or x > endSectorX then endSectorX = x
                if endSectorY == null or y > endSectorY then endSectorY = x

        TB.fetcher.loadSectors startSectorX, startSectorY, endSectorX, endSectorY, (squares) ->
            for square in squares
                TB.squareData.set(square.col, square.row, square)




    registerEventHandlers: ->
        $(TB.selector).mousedown (event) =>
            event.preventDefault()
            TB.lastMouse = { x: event.offsetX, y: event.offsetY }
            TB.lastScroll.x = TB.scroll.x
            TB.lastScroll.y = TB.scroll.y
            TB.dragging = true

        $(TB.selector).mousemove (event) =>
            TB.cursor.move(event.offsetX + TB.scroll.x, event.offsetY + TB.scroll.y)

            TB.activeSquare.col = TB.pixelToSectorCoord(event.offsetX + TB.scroll.x)
            TB.activeSquare.row = TB.pixelToSectorCoord(event.offsetY + TB.scroll.y)

            TB.cursor.move(event.offsetX + TB.scroll.x, event.offsetY + TB.scroll.y)
            if TB.dragging
                event.preventDefault()
                TB.scroll.x = TB.lastScroll.x - (event.offsetX - TB.lastMouse.x)
                TB.scroll.y = TB.lastScroll.y - (event.offsetY - TB.lastMouse.y)

                TB.loadSectorsOnScreen()

        $(document).mouseup (event) =>
            if Math.abs(TB.scroll.x - TB.lastScroll.x) < 5 and Math.abs(TB.scroll.y - TB.lastScroll.y) < 5
                col = TB.mouseXToCol(event.offsetX)
                row = TB.mouseYToRow(event.offsetY)

                TB.board.placeUnit(col, row, 3)

            console.log TB.dragging
            TB.dragging = false

        $(TB.selector).mousewheel (event, delta, deltaX, deltaY) =>

            previousCol = TB.worldToScreenPosX(TB.pixelToSectorCoord(event.offsetX))
            previousRow = TB.worldToScreenPosY(TB.pixelToSectorCoord(event.offsetY))

            TB.zoomLevel -= delta
            if TB.zoomLevel < 1 then TB.zoomLevel = 1
            if TB.zoomLevel > TB.maxZoomLevel then TB.zoomLevel = TB.maxZoomLevel

            if TB.zoomLevel == 1 then TB.zoomFactor = 1
            if TB.zoomLevel == 2 then TB.zoomFactor = 36/48
            if TB.zoomLevel == 3 then TB.zoomFactor = 24/48
            #if TB.zoomLevel == 4 then TB.zoomFactor = 12/48
            #if TB.zoomLevel == 5 then TB.zoomFactor = 6/48


            #previousCol
            #screenX = event.offsetX
            #screenY = event.offsetY

            #worldX = TB.screenToWorldPosX(screenX)
            #worldY = TB.screenToWorldPosY(screenY)

            #TB.scroll.x = TB.scroll.x - TB.scroll.x * TB.zoomFactor
            #TB.scroll.y = TB.zoomFactor - TB.scroll.y * TB.zoomFactor
        
        resizeBoard = =>
            TB.boardWidth = $(window).width() - (48+20) - 220
            TB.boardHeight = $(window).height() - 96
            $(TB.selector).attr('width', TB.boardWidth).attr('height', TB.boardHeight)
            TB.ctx = $(TB.selector).get(0).getContext('2d')
            $(window).resize(resizeBoard)
        resizeBoard()



    startMainLoop: ->
        start = null
        mainLoop = (timestamp) =>

            TB.update()
            TB.draw()

            requestAnimationFrame(mainLoop)
        requestAnimationFrame(mainLoop)



    update: ->


    draw: ->
        TB.board.draw()
        TB.actionManager.draw()
        TB.cursor.draw()

    worldToScreenPosX: (worldX) -> worldX - TB.scroll.x
    worldToScreenPosY: (worldY) -> worldY - TB.scroll.y
    screenToWorldPosX: (screenX) -> screenX + TB.scroll.x
    screenToWorldPosY: (screenY) -> screenY + TB.scroll.y
    pixelToSectorCoord: (coord) -> Math.floor((coord) / (TB.gridSize * TB.zoomFactor))
    mouseXToCol: (mouseX) ->
        TB.pixelToSectorCoord(mouseX + TB.scroll.x)
    mouseYToRow: (mouseY) ->
        TB.pixelToSectorCoord(mouseY + TB.scroll.y)


    fillOutlinedText: (text, screenX, screenY) ->
        TB.ctx.fillStyle = 'black'
        TB.ctx.fillText(text, screenX+1, screenY+1)
        TB.ctx.fillText(text, screenX+1, screenY-1)
        TB.ctx.fillText(text, screenX-1, screenY+1)
        TB.ctx.fillText(text, screenX-1, screenY-1)
        TB.ctx.fillStyle = 'white'
        TB.ctx.fillText(text, screenX, screenY)

