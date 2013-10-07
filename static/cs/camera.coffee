class Camera
    constructor: ->
        @x = 0
        @y = 0
        @lastX = 0
        @lastY = 0
        @width = 800
        @height = 600

        @zoomFactor = 1
        @zoomLevel = 1
        @maxZoomLevel = 3

        @zoomedGridSize = TB.gridSize
        @subGridSize = TB.gridSize/2

    move: (@x, @y) ->

    worldToScreenPosX: (worldX) -> worldX - @x
    worldToScreenPosY: (worldY) -> worldY - @y
    screenToWorldPosX: (screenX) -> screenX + @x
    screenToWorldPosY: (screenY) -> screenY + @y
    pixelToSectorCoord: (coord) -> Math.floor((coord) / (TB.gridSize * @zoomFactor))
    mouseXToCol: (mouseX) -> TB.pixelToSectorCoord(mouseX + @x)
    mouseYToRow: (mouseY) -> TB.pixelToSectorCoord(mouseY + @y)

    resize: ->
        @width = $(window).width() - (48+20) - 220
        @height = $(window).height() - 96


    zoom: (x, y, delta) ->
        #previousCol = TB.worldToScreenPosX(TB.pixelToSectorCoord(x))
        #previousRow = TB.worldToScreenPosY(TB.pixelToSectorCoord(y))

        @zoomLevel -= delta
        if @zoomLevel < 1 then @zoomLevel = 1
        if @zoomLevel > @maxZoomLevel then @zoomLevel = @maxZoomLevel

        if @zoomLevel == 1 then @zoomFactor = 1
        if @zoomLevel == 2 then @zoomFactor = 36/48
        if @zoomLevel == 3 then @zoomFactor = 24/48

        @zoomedGridSize = TB.gridSize*@zoomFactor
        @subGridSize = @zoomedGridSize/2

        #if TB.zoomLevel == 4 then TB.zoomFactor = 12/48
        #if TB.zoomLevel == 5 then TB.zoomFactor = 6/48

        #previousCol
        #screenX = event.offsetX
        #screenY = event.offsetY

        #worldX = TB.screenToWorldPosX(screenX)
        #worldY = TB.screenToWorldPosY(screenY)

        #TB.scroll.x = TB.scroll.x - TB.scroll.x * TB.zoomFactor
        #TB.scroll.y = TB.zoomFactor - TB.scroll.y * TB.zoomFactor
