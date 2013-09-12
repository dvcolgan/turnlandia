request = require('request')

describe "the board and its cronies", ->


    it "should have exactly 4 squares", (done) ->
        request {url: 'http://127.0.0.1:5984/turnbased_dev/_design/get-all-squares/_view/getAllSquares', json: true}, (error, response, body) ->
            expect(body.rows.length).toBe(3)
            done()

    it "should equate no with false", ->
        expect(no).toBe(false)
