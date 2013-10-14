util = require('../util')

describe "the exciting and glorious 2D hash table", ->

    it "should not use the same hash table for every instance", ->
        hash1 = new util.Hash2D()
        hash2 = new util.Hash2D()

        hash1.set('one', 'two', 'first')
        hash2.set('one', 'two', 'second')

        expect(hash1.get('one', 'two')).toBe('first')

    it "should add the key/value pairs of the second to the first, overwriting the first in case of a collision", ->
        hash1 = new util.Hash2D()
        hash2 = new util.Hash2D()

        hash1.set('one', 'two', 'first')
        hash2.set('two', 'three', 'second')

        hash1.concat(hash2)

        expect(hash1.get('two', 'three')).toBe('second')

    it "should return a list of all the x,y,v pairs when I call iterate", ->
        hash = new util.Hash2D()

        hash.set(1, 2, 1)
        hash.set(2, 3, 1)
        hash.set(3, 4, 1)
        hash.set(4, 5, 1)

        all = []
        hash.iterate (x, y, val) ->
            all.push [x, y, val]

        expect(all).toEqual([['1','2',1],['2','3',1],['3','4',1],['4','5',1]])

    it "should return a properly formed 2D array when I call values2D", ->
        hash = new util.Hash2D()

        hash.set(0, 0, 1)
        hash.set(0, 1, 2)
        hash.set(0, 2, 3)
        hash.set(1, 0, 4)
        hash.set(1, 1, 5)
        hash.set(1, 2, 6)
        hash.set(2, 0, 7)
        hash.set(2, 1, 8)
        hash.set(2, 2, 9)

        expect(hash.values2D()).toEqual(
            [
                [1,2,3]
                [4,5,6]
                [7,8,9]
            ]
        )
