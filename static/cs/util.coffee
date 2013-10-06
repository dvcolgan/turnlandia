util =
    calculate_distance: (x1, y1, x2, y2) ->
        Math.sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1))

    random_choice: (collection) ->
        collection[Math.floor(Math.random()*collection.length)]

    Hash2D: class Hash2D
        constructor: ->
            @hash = {}

        get: (x, y) ->
            if x of @hash and y of @hash[x]
                return @hash[x][y]
            else
                return null

        set: (x, y, val) ->
            if x not of @hash
                @hash[x] = {}
            if y not of @hash[x]
                @hash[x][y] = {}
            @hash[x][y] = val

        delete: (x, y) ->
            val = @get(x, y)
            @set(x, y, null)
            return val

        values: ->
            result = []
            for x, yData of @hash
                for y, val of yData
                    result.push(val)
            return result

        concat: (other) ->
            @concatRaw(other.hash)

        concatRaw: (hash) ->
            for x, yData of hash
                for y, val of yData
                    @set(x, y, val)

        size: ->
            return @values().length

        getRaw: ->
            return @hash




if typeof module != 'undefined' then module.exports = util
