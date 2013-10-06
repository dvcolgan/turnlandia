request = require('request')
async = require('async')

db = 'http://127.0.0.1:5984'


manage =
    clearSquares: ->
        async.series([
            (callback) ->
                console.log 'deleting old actions database'
                request {url: db + '/turnbased_dev_actions', method: 'DELETE'}, ->
                    callback()

            (callback) ->
                console.log 'deleting old squares database'
                request {url: db + '/turnbased_dev_squares', method: 'DELETE'}, ->
                    callback()

            (callback) ->
                console.log 'creating new actions database'
                request {url: db + '/turnbased_dev_actions', method: 'PUT'}, ->
                    callback()

            (callback) ->
                console.log 'creating new squares database'
                request {url: db + '/turnbased_dev_squares', method: 'PUT'}, ->
                    callback()

            (callback) ->
                console.log 'adding actions design document'
                designDoc =
                    _id: '_design/actions'
                    'language': 'coffeescript',
                    'views':
                        'get':
                            'map': '(doc) -> emit(doc.userID, doc)'

                request {url: db + '/turnbased_dev_actions/_design/actions', method: 'PUT', json:true, body: designDoc }, ->
                    callback()

            (callback) ->
                console.log 'adding squares design document'
                designDoc =
                    _id: '_design/squares'
                    'language': 'coffeescript',
                    'views':
                        'get':
                            'map': '(doc) -> emit([doc.col, doc.row], doc)'

                request {url: db + '/turnbased_dev_squares/_design/squares', method: 'PUT', json:true, body: designDoc }, ->
                    console.log 'done'
        ])



manage[process.argv[2]]()
