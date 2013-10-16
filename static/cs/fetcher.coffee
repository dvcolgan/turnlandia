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
        $.ajax
            url: '/api/squares/' + (sectorX*TB.sectorSize) + '/' + (sectorY*TB.sectorSize) + '/' + (TB.sectorSize) + '/' + (TB.sectorSize) + '/'
            method: 'GET'
            dataType: 'text'
            success: (sectorData) =>
                @loadingStates.set(sectorX, sectorY, true)

                $(window).trigger
                    type: 'sectorLoaded'
                    sectorX: sectorX
                    sectorY: sectorY
                    sectorData: sectorData

    loadSectorsOnScreen: ->
        sectorPixelSize = TB.sectorSize * TB.camera.zoomedGridSize

        # Add one to account for tiny slivers of a sector on both sides of the screen
        sectorsWide = Math.ceil(TB.camera.width  / TB.camera.zoomedGridSize / TB.sectorSize) + 1
        sectorsHigh = Math.ceil(TB.camera.height / TB.camera.zoomedGridSize / TB.sectorSize) + 1

        startSectorX = Math.floor(TB.camera.x / sectorPixelSize)
        startSectorY = Math.floor(TB.camera.y / sectorPixelSize)
        endSectorX = Math.ceil((TB.camera.x + TB.camera.width) / sectorPixelSize)
        endSectorY = Math.ceil((TB.camera.y + TB.camera.height) / sectorPixelSize)

        @loadSectors(startSectorX, startSectorY, endSectorX, endSectorY)
