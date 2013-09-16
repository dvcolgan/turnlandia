request = require('request')


manage =
    clearSquares: ->
        console.log 'deleting old database'
        url = 'http://127.0.0.1:5984/turnbased_dev'
        request {url: url, method: 'DELETE'}, (error, response, body) =>

            console.log 'creating new database'
            url = 'http://127.0.0.1:5984/turnbased_dev'
            request {url: url, method: 'PUT'}, (error, response, body) =>

                console.log 'adding design document'
                designDoc =
                    _id: '_design/squares'
                    'language': 'coffeescript',
                    'views':
                        'get':
                            'map': '(doc) -> emit([doc.col, doc.row], doc)'
                url = 'http://127.0.0.1:5984/turnbased_dev/_design/squares'
                request {url: url, method: 'PUT', json:true, body: designDoc }, (error, response, body) =>
                    console.log 'done'



manage[process.argv[2]]()
