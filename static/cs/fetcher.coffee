class DataFetcher
    constructor: ->
        @loadingStates = new util.Hash2D()

    loadInitialData: (callback) ->
        $.ajax
            url: '/api/initial-load/'
            method: 'GET'
            dataType: 'json'
            success: (data) =>
                callback(data)

    loadSectors: (startSectorX, startSectorY, endSectorX, endSectorY, callback) ->
        for sectorX in [startSectorX..endSectorX]
            for sectorY in [startSectorY..endSectorY]
                if @loadingStates.get(sectorX, sectorY) == null
                    @loadingStates.set(sectorX, sectorY, false)
                    @loadSector(sectorX, sectorY, callback)

    loadSector: (sectorX, sectorY, callback) ->
        key = (sectorX + '|' + sectorY)
        excludeSquares = ''
        if key of localStorage
            squareData = JSON.parse(localStorage.getItem(key))
            $(window).trigger
                type: 'squaresLoaded'
                squareData: squareData
            excludeSquares = 'nosquares/'
        $.ajax
            url: '/api/squares/' + (sectorX*TB.sectorSize) + '/' + (sectorY*TB.sectorSize) + '/' + (TB.sectorSize) + '/' + (TB.sectorSize) + '/' + excludeSquares
            method: 'GET'
            dataType: 'json'
            success: (sectorData) =>
                @loadingStates.set(sectorX, sectorY, true)
                if not excludeSquares
                    localStorage.setItem(key, JSON.stringify(sectorData.squares))
                    $(window).trigger
                        type: 'squaresLoaded'
                        squareData: sectorData.squares

                $(window).trigger
                    type: 'objectsLoaded'
                    sectorData: sectorData

    loadSectorsOnScreen: ->
        sectorPixelSize = TB.sectorSize * TB.camera.zoomedGridSize

        # Add one to account for tiny slivers of a sector on both sides of the screen
        sectorsWide = Math.ceil(TB.camera.width  / TB.camera.zoomedGridSize / TB.sectorSize) + 3
        sectorsHigh = Math.ceil(TB.camera.height / TB.camera.zoomedGridSize / TB.sectorSize) + 3

        startSectorX = null
        startSectorY = null
        endSectorX = null
        endSectorY = null
        for sectorSectorX in [0..sectorsWide]
            for sectorSectorY in [0..sectorsHigh]
                x = (Math.floor(TB.camera.x / sectorPixelSize)) + sectorSectorX
                y = (Math.floor(TB.camera.y / sectorPixelSize)) + sectorSectorY

                if startSectorX == null or x < startSectorX then startSectorX = x
                if startSectorY == null or y < startSectorY then startSectorY = y
                if endSectorX == null or x > endSectorX then endSectorX = x
                if endSectorY == null or y > endSectorY then endSectorY = x

        @loadSectors(startSectorX, startSectorY, endSectorX, endSectorY)

