request = require('request')

request {url: 'http://127.0.0.1:5984/turnbased_dev/_design/get-all-squares/_view/getAllSquares', json: true}, (error, response, body) ->
    if not error and response.statusCode == 200
        console.log "Check out all my squares"
        for row in body.rows
            console.log row.key + ' ' + row.value.col + ',' + row.value.row

