
class Board

    constructor: ->
        @squares = new util.Hash2D()
        @units = new util.Hash2D()
        @trees = new util.Hash2D()
        @unfinalizedSquares = new util.Hash2D()

    placeUnitOnSquare: (col, row, ownerID) ->
        @squares.get(col, row).placeUnit(ownerID)





        # when a square is first loaded
        #   check all 8 of its neighbors
        #   if any of them are not yet loaded, load anyway, but add to a hashwhere key is the not yet loaded square, and the value is a list of squares that need to be reloaded when that square is loaded
        #
        #
        #
        #
        #

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
                if @getTerrainType(otherCol, otherRow) == 'forest'
                    tree = @trees.get(otherCol, otherRow)
                    tree.subTiles = @getSubtiles(otherCol, otherRow)
                else
                    square = @squares.get(otherCol, otherRow)
                    square.subTiles = @getSubtiles(otherCol, otherRow)

        return [[northWestTile, northEastTile],[southWestTile, southEastTile]]

    addSquare: (squareData) ->
        @squares.set(squareData.col, squareData.row, new Square(squareData))

    addUnit: (unitData) ->
        @units.set(unitData.col, unitData.row, new Unit(unitData))

    addTree: (treeData) ->
        @trees.set(treeData.col, treeData.row, new Tree(treeData))

    isPassable: (col, row) ->
        square = @squares.get(col, row)
        if square != null
            return square.terrainType != 'water' and square.terrainType != 'mountains'
        else
            return null

    getTerrainType: (col, row) ->
        square = @squares.get(col, row)
        if square != null
            if square.terrainType == 'plains'
                tree = @trees.get(col, row)
                if tree
                    return 'forest'
                else
                    return 'plains'
            else
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
        square = @squares.get(col, row)
        if square != null
            if square.terrainType == 'plains'
                tree = @trees.get(col, row)
                if tree
                    return 2
                else
                    return 1
            return square.traversalCost
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
                thisTree = @trees.get(col, row)
                if thisTree
                    thisTree.draw()
                thisUnit = @units.get(col, row)
                if thisUnit
                    thisUnit.draw()
