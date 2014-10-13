express      = require 'express'
path         = require 'path'
favicon      = require 'serve-favicon'
logger       = require 'morgan'
cookieParser = require 'cookie-parser'
bodyParser   = require 'body-parser'
mongoose     = require 'mongoose'
urlparser    = require 'url'
https        = require 'https'
fs           = require 'fs'

httpsOptions =
    key: fs.readFileSync(path.join(__dirname, '../www_swall_me.key'))
    cert: fs.readFileSync(path.join(__dirname, '../www_swall_me_bundle.crt'))

app    = require('express')()
server = https.createServer(httpsOptions, app)
#server = require('http').Server(app)
io     = require('socket.io')(server)

GLOBAL.io = io

server.listen 443

routes = require '../build/routes/index'
users  = require '../build/routes/users'


db          = mongoose.createConnection 'mongodb://localhost/test'
information = mongoose.Schema {time: Number, ip: String, us: String, msg: String}
Comment     = db.model 'Comment', information

GLOBAL.Comment = Comment

io.on 'connect', (socket)->
    console.log 'connected.'
    # Client ask for message
    socket.on '/subscribe', (data)->
        # add to subscribe pool
        socket.join data.id
        socket.emit 'sucscribeOk', data.id

    socket.on '/unsubscribe', (data)->
        if data == 'all'
            # unsubscribeAll socket
            for room in io.sockets.adapter.rooms
                socket.leave room
        else
            # unsubscribe socket, data.id
            socket.leave data.id

    socket.on 'disconnect', ()->
        # unsubscribeAll socket
        for room in io.sockets.adapter.rooms
            socket.leave room


io.on 'disconnect', ()->
    console.log 'disconnected.'


# view engine setup
app.set('views', path.join(__dirname, path.join('..', 'views')))
app.set('view engine', 'ejs')


# uncomment after placing your favicon in /public
#app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({extended: false}))
app.use(cookieParser())
app.use(require('stylus').middleware(path.join(__dirname, path.join('..', 'public'))))
app.use(express.static(path.join(__dirname, path.join('..', 'public'))))
app.use(express.static(path.join(__dirname, path.join('..', 'build'))))


app.use '/', routes
app.use '/users', users


# catch 404 and forward to error handler
app.use (req, res, next)->
    err        = new Error('Not Found')
    err.status = 404
    next(err)


# error handlers

# development error handler
# will print stacktrace
if (app.get('env') == 'development')
    app.use (err, req, res, next)->
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        })


# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next)->
    res.status(err.status || 500)
    res.render('error', {
        message: err.message,
        error: {}
    })


module.exports = app
