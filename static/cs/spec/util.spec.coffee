util = require('../util')

describe "the exciting and glorious 2D hash table", ->

    it "should not use the same hash table for every instance", ->
        hash1 = new util.Hash2D()
        hash2 = new util.Hash2D()

        hash1.set('one', 'two', 'first')
        hash2.set('one', 'two', 'second')

        expect(hash1.get('one', 'two')).toBe('first')


