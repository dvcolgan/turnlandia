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
        @zoomedUnitSize = TB.unitSize
        @zoomedSubGridSize = TB.gridSize/2

    moveBy: (x, y) ->
        @x += parseInt(x)
        @y += parseInt(y)
    moveTo: (x, y) ->
        @x = parseInt(x)
        @y = parseInt(y)

    worldColToScreenPosX: (worldX) -> worldX * TB.gridSize * @zoomFactor - @x
    worldRowToScreenPosY: (worldY) -> worldY * TB.gridSize * @zoomFactor - @y

    worldToScreenPosX: (worldX) -> worldX * @zoomFactor - @x
    worldToScreenPosY: (worldY) -> worldY * @zoomFactor - @y
    screenToWorldPosX: (screenX) -> screenX + @x
    screenToWorldPosY: (screenY) -> screenY + @y
    pixelToSquareCoord: (coord) -> Math.floor(coord / @zoomedGridSize)
    mouseXToCol: (mouseX) -> @pixelToSquareCoord(mouseX + @x)
    mouseYToRow: (mouseY) -> @pixelToSquareCoord(mouseY + @y)

    resize: ->
        @width = $(window).width() - 110
        @height = $(window).height() - 71

    zoom: (x, y, delta) ->
        #previousCol = TB.worldToScreenPosX(TB.pixelToSectorCoord(x))
        #previousRow = TB.worldToScreenPosY(TB.pixelToSectorCoord(y))

        @zoomLevel -= delta
        if @zoomLevel < 1 then @zoomLevel = 1
        if @zoomLevel > @maxZoomLevel then @zoomLevel = @maxZoomLevel

        if @zoomLevel == 1 then @zoomFactor = 1
        if @zoomLevel == 2 then @zoomFactor = 36/48
        if @zoomLevel == 3 then @zoomFactor = 24/48
        if @zoomLevel == 4 then @zoomFactor = 12/48
        if @zoomLevel == 5 then @zoomFactor = 6/48

        @zoomedGridSize = TB.gridSize*@zoomFactor
        @zoomedUnitSize = TB.unitSize*@zoomFactor
        @zoomedSubGridSize = @zoomedGridSize/2

        #if TB.zoomLevel == 4 then TB.zoomFactor = 12/48
        #if TB.zoomLevel == 5 then TB.zoomFactor = 6/48

        #previousCol
        #screenX = event.offsetX
        #screenY = event.offsetY

        #worldX = TB.screenToWorldPosX(screenX)
        #worldY = TB.screenToWorldPosY(screenY)

        #TB.scroll.x = TB.scroll.x - TB.scroll.x * TB.zoomFactor
        #TB.scroll.y = TB.zoomFactor - TB.scroll.y * TB.zoomFactor
    
        
