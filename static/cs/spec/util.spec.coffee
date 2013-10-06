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

