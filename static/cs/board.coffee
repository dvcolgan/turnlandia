

class Board

    constructor: ->
        @squares = new util.Hash2D()
        @units = new util.Hash2D()
        @unfinalizedSquares = new util.Hash2D()
        @roadOverlay = new util.Hash2D()
        @showRoadOverlay = false
        @clearForestOverlay = new util.Hash2D()
        @showClearForestOverlay = false

    # when a square is first loaded
    #   check all 8 of its neighbors
    #   if any of them are not yet loaded, load anyway, but add to a hashwhere key is the not yet loaded square, and the value is a list of squares that need to be reloaded when that square is loaded
    getSubtiles: (col, row) ->
        thisTerrain = @getTerrainType(col, row)

        northTerrain     = @getTerrainType(col,   row-1)
        southTerrain     = @getTerrainType(col,   row+1)
        eastTerrain      = @getTerrainType(col+1, row)
        westTerrain      = @getTerrainType(col-1, row)
        northEastTerrain = @getTerrainType(col+1, row-1)
        northWestTerrain = @getTerrainType(col-1, row-1)
        southEastTerrain = @getTerrainType(col+1, row+1)
        southWestTerrain = @getTerrainType(col-1, row+1)

        if northTerrain     == null then @unfinalizedSquares.push(col,   row-1, [col, row])
        if southTerrain     == null then @unfinalizedSquares.push(col,   row+1, [col, row])
        if eastTerrain      == null then @unfinalizedSquares.push(col+1, row,   [col, row])
        if westTerrain      == null then @unfinalizedSquares.push(col-1, row,   [col, row])
        if northEastTerrain == null then @unfinalizedSquares.push(col+1, row-1, [col, row])
        if northWestTerrain == null then @unfinalizedSquares.push(col-1, row-1, [col, row])
        if southEastTerrain == null then @unfinalizedSquares.push(col+1, row+1, [col, row])
        if southWestTerrain == null then @unfinalizedSquares.push(col-1, row+1, [col, row])

        north     = northTerrain == thisTerrain
        south     = southTerrain == thisTerrain
        east      = eastTerrain == thisTerrain
        west      = westTerrain == thisTerrain
        northEast = northEastTerrain == thisTerrain
        northWest = northWestTerrain == thisTerrain
        southEast = southEastTerrain == thisTerrain
        southWest = southWestTerrain == thisTerrain

        s=TB.gridSize/2
        
        if     west and     northWest and     north then northWestTile = [s*4, s*0]
        if     west and not northWest and     north then northWestTile = [s*2, s*2]
        if     west and     northWest and not north then northWestTile = [s*2, s*0]
        if     west and not northWest and not north then northWestTile = [s*2, s*0]
        if not west and     northWest and     north then northWestTile = [s*0, s*2]
        if not west and not northWest and     north then northWestTile = [s*0, s*2]
        if not west and     northWest and not north then northWestTile = [s*0, s*0]
        if not west and not northWest and not north then northWestTile = [s*0, s*0]
                                                                                   
        if     east and     northEast and     north then northEastTile = [s*5, s*0]
        if     east and not northEast and     north then northEastTile = [s*1, s*2]
        if     east and     northEast and not north then northEastTile = [s*1, s*0]
        if     east and not northEast and not north then northEastTile = [s*1, s*0]
        if not east and     northEast and     north then northEastTile = [s*3, s*2]
        if not east and not northEast and     north then northEastTile = [s*3, s*2]
        if not east and     northEast and not north then northEastTile = [s*3, s*0]
        if not east and not northEast and not north then northEastTile = [s*3, s*0]
                                                                                   
        if     west and     southWest and     south then southWestTile = [s*4, s*1]
        if     west and not southWest and     south then southWestTile = [s*2, s*1]
        if     west and     southWest and not south then southWestTile = [s*2, s*3]
        if     west and not southWest and not south then southWestTile = [s*2, s*3]
        if not west and     southWest and     south then southWestTile = [s*0, s*1]
        if not west and not southWest and     south then southWestTile = [s*0, s*1]
        if not west and     southWest and not south then southWestTile = [s*0, s*3]
        if not west and not southWest and not south then southWestTile = [s*0, s*3]
                                                                                   
        if     east and     southEast and     south then southEastTile = [s*5, s*1]
        if     east and not southEast and     south then southEastTile = [s*1, s*1]
        if     east and     southEast and not south then southEastTile = [s*1, s*3]
        if     east and not southEast and not south then southEastTile = [s*1, s*3]
        if not east and     southEast and     south then southEastTile = [s*3, s*1]
        if not east and not southEast and     south then southEastTile = [s*3, s*1]
        if not east and     southEast and not south then southEastTile = [s*3, s*3]
        if not east and not southEast and not south then southEastTile = [s*3, s*3]

        otherUnfinalized = @unfinalizedSquares.get(col, row)
        if otherUnfinalized
            for [otherCol, otherRow] in otherUnfinalized
                square = @squares.get(otherCol, otherRow)
                square.subTiles = @getSubtiles(otherCol, otherRow)
        return [[northWestTile, northEastTile],[southWestTile, southEastTile]]

    addSquare: (col, row, terrainType) ->
        if terrainType == 0 then terrainType = 'plains'
        if terrainType == 1 then terrainType = 'water'
        if terrainType == 2 then terrainType = 'mountains'
        if terrainType == 3 then terrainType = 'forest'
        if terrainType == 4 then terrainType = 'road'
        if terrainType == 5 then terrainType = 'city'
        newSquare = new Square(col, row, terrainType)
        @squares.set(col, row, newSquare)
        newSquare.terrainType = @getTerrainType(col, row)

    addUnit: (col, row, ownerID, amount) ->
        unit = new Unit(col, row, ownerID, amount)
        @units.set(col, row, unit)

        @roadOverlay.set(unit.col, unit.row, 0)

        for i in [1..6]
            @roadOverlay.iterateIntKeys (thisCol, thisRow, dist) =>
                if dist == i-1
                    east = TB.board.isPassable(thisCol+1, thisRow)
                    west = TB.board.isPassable(thisCol-1, thisRow)
                    south = TB.board.isPassable(thisCol, thisRow+1)
                    north = TB.board.isPassable(thisCol, thisRow-1)
                    if east then @roadOverlay.set(thisCol+1, thisRow, i)
                    if west then @roadOverlay.set(thisCol-1, thisRow, i)
                    if south then @roadOverlay.set(thisCol, thisRow+1, i)
                    if north then @roadOverlay.set(thisCol, thisRow-1, i)

        @clearForestOverlay.set(unit.col, unit.row, 0)

        for i in [1..6]
            @clearForestOverlay.iterateIntKeys (thisCol, thisRow, dist) =>
                if dist == i-1
                    eastTerrain = TB.board.getTerrainType(thisCol+1, thisRow)
                    westTerrain = TB.board.getTerrainType(thisCol-1, thisRow)
                    southTerrain = TB.board.getTerrainType(thisCol, thisRow+1)
                    northTerrain = TB.board.getTerrainType(thisCol, thisRow-1)

                    east = eastTerrain == 'plains' or eastTerrain == 'forest'
                    west = westTerrain == 'plains' or westTerrain == 'forest'
                    south = southTerrain == 'plains' or southTerrain == 'forest'
                    north = northTerrain == 'plains' or northTerrain == 'forest'

                    if east then @clearForestOverlay.set(thisCol+1, thisRow, i)
                    if west then @clearForestOverlay.set(thisCol-1, thisRow, i)
                    if south then @clearForestOverlay.set(thisCol, thisRow+1, i)
                    if north then @clearForestOverlay.set(thisCol, thisRow-1, i)



    isPassable: (col, row) ->
        terrainType = @getTerrainType(col, row)
        if terrainType
            return terrainType != 'water' and terrainType != 'mountains'
        else
            return null

    getTerrainType: (col, row) ->
        square = @squares.get(col, row)
        if square != null
            return square.terrainType
        else
            return null

    getUnitCount: (col, row) ->
        unit = @units.get(col, row)
        if unit != null
            return unit.amount
        else
            return 0

    traversalCost: (col, row) ->
        terrainType = @getTerrainType(col, row)
        if terrainType != null
            if terrainType == 'plains' then return 2
            if terrainType == 'water' then return 0
            if terrainType == 'mountains' then return 0
            if terrainType == 'forest' then return 3
            if terrainType == 'road' then return 1
            if terrainType == 'city' then return 1
        else
            return 0


    draw: ->
        #tilesWide = Math.ceil(TB.camera.width / TB.images.grassImage.width)
        #tilesHigh = Math.ceil(TB.camera.height / TB.images.grassImage.height)
        #xOffset = TB.camera.x
        #for y in [0...tilesHigh]
        #    for x in [0...tilesWide]
        #        TB.ctx.drawImage(
        #            TB.images.grassImage,
        #            x*TB.images.grassImage.width,
        #            y*TB.images.grassImage.height
        #        )

        TB.ctx.textAlign = 'center'
        TB.ctx.fillStyle = '#148743'
        TB.ctx.fillRect(0, 0, TB.camera.width, TB.camera.height)
        TB.ctx.lineWidth = 1

        startCol = Math.floor(TB.camera.x/TB.camera.zoomedGridSize)
        startRow = Math.floor(TB.camera.y/TB.camera.zoomedGridSize)

        endCol = startCol + Math.ceil(TB.camera.width/TB.camera.zoomedGridSize)
        endRow = startRow + Math.ceil(TB.camera.height/TB.camera.zoomedGridSize)

        for row in [startRow..endRow]
            for col in [startCol..endCol]
                thisSquare = @squares.get(col, row)
                if thisSquare
                    thisSquare.draw()
                thisUnit = @units.get(col, row)
                if thisUnit
                    thisUnit.draw()
                if @showRoadOverlay and @roadOverlay.get(col, row) != null and @getTerrainType(col, row) == 'plains'
                    screenX = TB.camera.worldColToScreenPosX(col)
                    screenY = TB.camera.worldRowToScreenPosY(row)
                    TB.ctx.save()
                    TB.ctx.fillStyle = 'rgba(119,65,27,0.3)'
                    TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize)
                    TB.ctx.restore()

                if @showClearForestOverlay and @clearForestOverlay.get(col, row) != null and @getTerrainType(col, row) == 'forest'
                    screenX = TB.camera.worldColToScreenPosX(col)
                    screenY = TB.camera.worldRowToScreenPosY(row)
                    TB.ctx.save()
                    TB.ctx.fillStyle = 'rgba(0,255,0,0.3)'
                    TB.ctx.fillRect(screenX, screenY, TB.camera.zoomedGridSize, TB.camera.zoomedGridSize)
                    TB.ctx.restore()

