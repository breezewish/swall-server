express      = require('express')
path         = require('path')
favicon      = require('serve-favicon')
logger       = require('morgan')
cookieParser = require('cookie-parser')
bodyParser   = require('body-parser')
mongoose     = require('mongoose')
urlparser    = require('url')


app    = require('express')()
server = require('http').Server(app)
io     = require('socket.io')(server)


server.listen 3000


routes = require('../build/routes/index')
users  = require('../build/routes/users')


db          = mongoose.createConnection 'mongodb://localhost/test'
information = mongoose.Schema {time: Number, ip: String, us: String, msg: String}
Comment     = db.model 'Comment', information


io.on 'connect', (socket)->
#   socket.emit 'news', { hello: 'world' }
    console.log 'connected.'
    socketId = urlparser.parse(socket.handshake.headers.referer).pathname.split('/')[1]
    console.log socketId

    if socket.handshake.headers['user-agent'] == null or socket.handshake.headers['user-agent'] == undefined
        socket.handshake.headers['user-agent'] = 'null'
    
    # Accept comment from user
    socket.on 'comment', (data)->
        info    = {time: Date.now(), ip: socket.handshake.address, us: socket.handshake.headers['user-agent'], msg: data}
        comment = Comment info

        comment.save (err, comment)->
            if err
                return console.log err
            console.log comment

        io.to(socketId).emit('commentToScrren', info)

    # Client ask for message
    socket.on '/subscribe', (data)->
        # add to subscribe pool
        socket.join socketId

    socket.on '/unsubscribe', (data)->
        if data == 'all'
            # unsubscribeAll socket
            for room in io.sockets.manager.rooms
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
app.use(bodyParser.urlencoded({ extended: false }))
app.use(cookieParser())
app.use(require('stylus').middleware(path.join(__dirname, path.join('..', 'public'))))
app.use(express.static(path.join(__dirname, path.join('..', 'public'))))
app.use(express.static(path.join(__dirname, path.join('..', 'build'))))


app.use('/', routes)
app.use('/users', users)


# catch 404 and forward to error handler
app.use((req, res, next)->
    err        = new Error('Not Found')
    err.status = 404
    next(err)
)


# error handlers

# development error handler
# will print stacktrace
if (app.get('env') == 'development')
    app.use((err, req, res, next)->
        res.status(err.status || 500);
        res.render('error', {
            message: err.message,
            error: err
        })
    )


# production error handler
# no stacktraces leaked to user
app.use((err, req, res, next)->
    res.status(err.status || 500)
    res.render('error', {
        message: err.message,
        error: {}
    })
)


module.exports = app
