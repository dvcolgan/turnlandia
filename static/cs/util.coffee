util =
    calculate_distance: (x1, y1, x2, y2) ->
        Math.sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1))

    random_choice: (collection) ->
        collection[Math.floor(Math.random()*collection.length)]

    sum: (arr) -> _.reduce(arr, (sum, num) -> sum + num)

    # Stupid fix for firefox not implementing offsetXY correctly BLARG
    getMouseOffset: (e) ->
        target = e.target || e.srcElement
        style = target.currentStyle || window.getComputedStyle(target, null)
        borderLeftWidth = parseInt(style['borderLeftWidth'], 10)
        borderTopWidth = parseInt(style['borderTopWidth'], 10)
        rect = target.getBoundingClientRect()
        offsetX = e.clientX - borderLeftWidth - rect.left
        offsetY = e.clientY - borderTopWidth - rect.top
        return [offsetX, offsetY]


    # http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
    hexToRGB: (hex) ->
        shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i
        hex = hex.replace shorthandRegex, (m, r, g, b) ->
            return r + r + g + g + b + b

        result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
        return if result
            {
                r: parseInt(result[1], 16)
                g: parseInt(result[2], 16)
                b: parseInt(result[3], 16)
            }
        else
            null

    makeFPSCounter: (numSamples) ->
        timestamps = [+new Date()]
        fpsSamples = []

        return (timestamp) ->
            timestamps.push(timestamp)
            if timestamps.length > numSamples then timestamps.shift()
            deltas = (timestamps[i+1] - timestamps[i] for i in [0...numSamples-1])
            fps = (util.sum(deltas) / numSamples)
            fpsSamples.push(parseInt(1000 / fps))

            if fpsSamples.length > numSamples then fpsSamples.shift()
            fpsSum = 0
            for i in [0...numSamples-1]
                fpsSum = fpsSamples
            return parseInt(util.sum(fpsSamples) / numSamples)


    Hash2D: class Hash2D
        constructor: ->
            @hash = {}

        get: (x, y) ->
            if x of @hash and y of @hash[x]
                return @hash[x][y]
            else
                return null

        increment: (x, y) ->
            if x not of @hash
                @hash[x] = {}
            if typeof @hash[x][y] == 'number'
                @hash[x][y]++
            else
                @hash[x][y] = 1

        set: (x, y, val) ->
            if x not of @hash
                @hash[x] = {}
            @hash[x][y] = val

        delete: (x, y) ->
            val = @get(x, y)
            @set(x, y, null)
            delete @hash[x][y]
            return val

        iterate: (callback) ->
            for x, yData of @hash
                for y, val of yData
                    callback(x, y, val)

        iterateIntKeys: (callback) ->
            for x, yData of @hash
                for y, val of yData
                    callback(parseInt(x), parseInt(y), val)

        # Check out all my priority queues
        priorityPopAllIntKeys: (callback) ->
            for i in [0...@size()]
                smallest = { x: null, y: null, val: null }
                for x, yData of @hash
                    for y, val of yData
                        if smallest.val == null or val < smallest.val
                            smallest.x = x
                            smallest.y = y
                            smallest.val = val
                @delete(smallest.x, smallest.y)
                callback(parseInt(smallest.x), parseInt(smallest.y), smallest.val)

        push: (x, y, val) ->
            cur = @get(x, y)
            if $.isArray(cur)
                cur.push(val)
            else
                @set(x, y, [val])


        values: ->
            result = []
            for x, yData of @hash
                for y, val of yData
                    result.push(val)
            return result

        values2D: ->
            result = []
            for x, yData of @hash
                ys = []
                for y, val of yData
                    ys.push(val)
                result.push(ys)
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

        clear: ->
            @hash = {}




if typeof module != 'undefined' then module.exports = util
