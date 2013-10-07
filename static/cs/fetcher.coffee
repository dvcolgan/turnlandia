class DataFetcher
    constructor: ->
        @loadingStates = new util.Hash2D()

    loadInitialData: (callback) ->
        $.ajax
            url: '/api/initial-load/'
            method: 'GET'
            dataType: 'json'
            success: (data) =>
                # If a new turn has happened, invalidate the cache
                if 'turn' of localStorage
                    prevTurn = localStorage.get('turn')
                    if prevTurn != data.currentTurn
                        localStorage.setItem('turn', data.currentTurn)
                        localStorage.clear()
                callback(data)

    loadSectors: (startSectorX, startSectorY, endSectorX, endSectorY, callback) ->
        for sectorX in [startSectorX..endSectorX]
            for sectorY in [startSectorY..endSectorY]
                if @loadingStates.get(sectorX, sectorY) == null
                    @loadingStates.set(sectorX, sectorY, false)
                    @loadSector(sectorX, sectorY, callback)

    loadSector: (sectorX, sectorY, callback) ->
        key = (sectorX + '|' + sectorY)
        if key of localStorage
            squareData = JSON.parse(localStorage.getItem(key))
            if squareData[0].turn == 1 # MAKE THIS GENERERICIZED PLZ
                console.log 'cache hit at ' + key
                $(window).trigger
                    type: 'sectorLoaded'
                    squareData: squareData
                return
        $.ajax
            url: '/api/squares/' + (sectorX*TB.sectorSize) + '/' + (sectorY*TB.sectorSize) + '/' + (TB.sectorSize) + '/' + (TB.sectorSize) + '/'
            method: 'GET'
            dataType: 'json'
            success: (squareData) =>
                @loadingStates.set(sectorX, sectorY, true)
                #localStorage.setItem(key, JSON.stringify(squareData))
                #console.log 'setting localstorage ' + key
                $(window).trigger
                    type: 'sectorLoaded'
                    squareData: squareData

    loadSectorsOnScreen: ->
        sectorPixelSize = TB.sectorSize * TB.camera.zoomedGridSize
        sectorsWide = Math.ceil(TB.camera.width / TB.sectorSize / TB.camera.zoomedGridSize)
        sectorsHigh = Math.ceil(TB.camera.height / TB.sectorSize / TB.camera.zoomedGridSize)

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

