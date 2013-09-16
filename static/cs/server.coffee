sqlite3 = require('sqlite3').verbose()
express = require('express')
request = require('request')
async = require('async')
base64 = require('base64')
jpickle = require('jpickle')
square = require('./square')
 
app = express()
app.use(express.cookieParser())


getDjangoUserID = (req, callback) ->
    db = new sqlite3.Database('../../turnbased.sqlite')
    db.get 'SELECT * FROM django_session WHERE session_key = (?);', [req.cookies.sessionid], (err, row) ->
        console.log row
        sessionData = jpickle.loads(base64.decode(row.session_data).split(':')[1])
        id = sessionData._auth_user_id
        callback(id)

 

app.get '/api/squares/:startCol/:startRow/:endCol/:endRow/', (req, res) ->
    startCol = parseInt(req.params.startCol)
    startRow = parseInt(req.params.startRow)
    endCol = parseInt(req.params.endCol)
    endRow = parseInt(req.params.endRow)
    square.getRegion startCol, startRow, endCol, endRow, (data) ->
        res.send(data)


app.get '/api/user/', (req, res) ->
    getDjangoUserID req, (id) ->
        res.send({ "id": id })

app.get '/api/users/', (req, res) ->
    res.send(JSON.stringify(square.getUsers()))

app.get '/api/couch/', (req, res) ->
    request {url: 'http://127.0.0.1:5984/turnbased_dev/_design/get-all-squares/_view/getAllSquares', json: true}, (error, response, body) ->
        res.send(body)

 
app.listen(3000)
console.log('Listening on port 3000...')
