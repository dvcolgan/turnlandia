request = require('request')

_ = require('./lib/lodash')
perlin = require('./lib/perlin')

util = require('./util')

db = 'http://127.0.0.1:5984'

square =
    getTraversalCost: (terrainType) ->
        switch terrainType
            when 'road' then 1
            when 'plains' then 2
            when 'water' then 0
            when 'mountains' then 0
            when 'forest' then 3
            when 'city' then 1


    getUsers: ->
        players =
            1:
                username: 'davidscolgan'
                email: 'dvcolgan@woot.egg'
                color: '#88cc88'
                leaderName: 'Larry King Live'
                peopleName: 'CNN Journalists'

                wood: 10
                food: 10
                ore: 10
                money: 10
            2:
                username: 'dooskington'
                email: 'engineer@nope.egg'
                color: '#730117'
                leaderName: 'Grand Wizard Dooskington'
                peopleName: 'Programmers'

                wood: 10
                food: 10
                ore: 10
                money: 10
            3:
                username: 'technocf'
                email: 'i_love@nodejs.egg'
                color: '#cccc88'
                leaderName: 'Montazuma'
                peopleName: 'TechnoChocolateLanders'

                wood: 10
                food: 10
                ore: 10
                money: 10
            4:
                username: 'tinfoilboy'
                email: 'tin@foil.egg'
                color: '#133777'
                leaderName: 'TinFoilTornado'
                peopleName: 'All the peeps'

                wood: 10
                food: 10
                ore: 10
                money: 10
        return players

    getActions: (userID, callback) ->
        url = 'http://127.0.0.1:5984/turnbased_dev_actions/_design/actions/_view/get?key=' + userID
        request {url: url, json: true}, (error, response, body) =>
            if body.error
                callback([])
            else
                callback(body)

    saveAction: (userID, action, callback) ->

        request {url: db + '/turnbased_dev_actions/_design/actions', method: 'PUT', json:true, body: action }, ->
            callback()



    getRegion: (startCol, startRow, width, height, callback) ->

        # First get all of the squares that go in this region from the database
        # Check to see if they are all accounted for by checking the length
        # if they are all accounted for, we are done, just return them
        # otherwise create new squares for those that don't exist yet and save them to the database

        start = '[' + startCol + ',' + startRow + ']'
        end = '[' + (startCol+width-1) + ',' + (startRow+height-1) + ']'

        keysToGet = []
        for col in [startCol...startCol+width]
            for row in [startRow...startRow+height]
                keysToGet.push([col, row])

        url = 'http://127.0.0.1:5984/turnbased_dev_squares/_design/squares/_view/get?keys=' + JSON.stringify(keysToGet)
        request {url: url, json: true}, (error, response, body) =>
            squares = new util.Hash2D()
            if body.rows
                for storedSquare in body.rows
                    [col, row] = storedSquare.key
                    squares.set(col, row, storedSquare.value)
            else
                body.rows = []

            if body.rows.length != width * height
                console.log 'new squares needed: ' + body.rows.length + ' is not ' + width * height
                newSquares = []
                for col in [startCol...startCol+width]
                    for row in [startRow...startRow+height]
                        if not squares.get(col, row)
                            newSquare = @generateSquare(col, row)
                            squares.set(col, row, newSquare)
                            newSquares.push(newSquare)

                url = 'http://127.0.0.1:5984/turnbased_dev_squares/_bulk_docs'
                request {url: url, json: true, method: 'POST', body: { 'docs': newSquares }}, (error, response, body) =>
                    console.log 'done generating squares'
                    callback(squares)
            else
                console.log 'no new squares needed'
                callback(squares)




                #options =
                #    url:'http://127.0.0.1:5984'
                #    body: JSON.stringify(newSquare)
                #request.post options, ->


                    


        #upper_col = int(col + width)
        #lower_col = int(col)
        #upper_row = int(row + height)
        #lower_row = int(row)

        #squares = (@model.objects.filter(col__lt=upper_col)
        #                             .filter(col__gte=lower_col)
        #                             .filter(row__lt=upper_row)
        #                             .filter(row__gte=lower_row))

        ## If we have a duplication of squares, that is kind of a problem, but shouldn't happen.
        #if squares.count() > width * height:
        #    raise Exception('The game has happened upon an inconsistent state.  Sorry about this.'
        #                'The admin has been contacted and is fixing the problem as we speak.')

        ## The common case will be that they all exist, so this expensive
        ## operation won't happen very often.
        #if squares.count() != width * height:
        #    # Nobody has gone out here yet, create the squares that don't exist
        #    batch = []
        #    for this_row in range(lower_row, upper_row):
        #        for this_col in range(lower_col, upper_col):
        #            if get_object_or_None(@model, col=this_col, row=this_row) == None:
        #                batch.append(@generate_unsaved_square(this_col, this_row))
        #    @model.objects.bulk_create(batch)
        #    print 'Created %d new squares' % len(batch)

        #    # Fetch these all again
        #    squares = (@model.objects.filter(col__lt=upper_col)
        #                            .filter(col__gte=lower_col)
        #                            .filter(row__lt=upper_row)
        #                            .filter(row__gte=lower_row))
        #    if squares.count() > width * height:
        #        raise Exception('The game has happened upon an inconsistent state after '
        #                    'trying to rectify the situation once already.  Sorry about this.'
        #                    'The admin has been contacted and is fixing the problem as we speak.')
        #else:
        #    print 'All squares already created'

        #squares = squares.order_by('row', 'col')
        



    generateSquare: (col, row) ->
        thisTerrain = @terrainTypeForSquare(col, row)

        north = @terrainTypeForSquare(col, row-1) == thisTerrain
        south = @terrainTypeForSquare(col, row+1) == thisTerrain
        east =  @terrainTypeForSquare(col+1, row) == thisTerrain
        west =  @terrainTypeForSquare(col-1, row) == thisTerrain

        northEast = @terrainTypeForSquare(col+1, row-1) == thisTerrain
        northWest = @terrainTypeForSquare(col-1, row-1) == thisTerrain
        southEast = @terrainTypeForSquare(col+1, row+1) == thisTerrain
        southWest = @terrainTypeForSquare(col-1, row+1) == thisTerrain

        if     west and     northWest and     north then northWestTile24 = 4
        if     west and not northWest and     north then northWestTile24 = 14
        if     west and     northWest and not north then northWestTile24 = 2
        if     west and not northWest and not north then northWestTile24 = 2
        if not west and     northWest and     north then northWestTile24 = 12
        if not west and not northWest and     north then northWestTile24 = 12
        if not west and     northWest and not north then northWestTile24 = 0
        if not west and not northWest and not north then northWestTile24 = 0

        if     east and     northEast and     north then northEastTile24 = 5
        if     east and not northEast and     north then northEastTile24 = 13
        if     east and     northEast and not north then northEastTile24 = 1
        if     east and not northEast and not north then northEastTile24 = 1
        if not east and     northEast and     north then northEastTile24 = 15
        if not east and not northEast and     north then northEastTile24 = 15
        if not east and     northEast and not north then northEastTile24 = 3
        if not east and not northEast and not north then northEastTile24 = 3

        if     west and     southWest and     south then southWestTile24 = 10
        if     west and not southWest and     south then southWestTile24 = 8
        if     west and     southWest and not south then southWestTile24 = 20
        if     west and not southWest and not south then southWestTile24 = 20
        if not west and     southWest and     south then southWestTile24 = 6
        if not west and not southWest and     south then southWestTile24 = 6
        if not west and     southWest and not south then southWestTile24 = 18
        if not west and not southWest and not south then southWestTile24 = 18

        if     east and     southEast and     south then southEastTile24 = 11
        if     east and not southEast and     south then southEastTile24 = 7
        if     east and     southEast and not south then southEastTile24 = 19
        if     east and not southEast and not south then southEastTile24 = 19
        if not east and     southEast and     south then southEastTile24 = 9
        if not east and not southEast and     south then southEastTile24 = 9
        if not east and     southEast and not south then southEastTile24 = 21
        if not east and not southEast and not south then southEastTile24 = 21

        newSquare =
            col: col
            row: row
            terrainType: thisTerrain
            northWestTile24: northWestTile24
            northEastTile24: northEastTile24
            southWestTile24: southWestTile24
            southEastTile24: southEastTile24


    terrainTypeForSquare: (col, row) ->
        terrainType = 'plains'

        frequency = 1.0/5
        forestValue = perlin.perlin2(col*frequency, row*frequency)
        if forestValue < 0.1
            terrainType = 'forest'

        frequency = 1.0/5
        mountainValue = perlin.perlin2(col*frequency, row*frequency)
        if mountainValue < -0.25
            terrainType = 'mountains'

            #frequencyX = 1.0/30
            #frequencyY = 1.0/15
            #riverValue = perlin.perlin2(col*frequencyX, row*frequencyY)
            #if riverValue < 0.04 and riverValue > -0.04
            #    terrainType = 'water'

        frequency = 1.0/20
        lakeValue = perlin.perlin2(col*frequency, row*frequency)
        if lakeValue < -0.2
            terrainType = 'water'

        return terrainType


if typeof module != 'undefined' then module.exports = square
