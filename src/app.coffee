express = require('express')
path = require('path')
favicon = require('serve-favicon')
logger = require('morgan')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')


app = require('express')()
server = require('http').Server(app)
io = require('socket.io')(server)

server.listen 3000

#app = express()
#server = http.Server(app)
#io = require('socket.io')(server)

#server = server.listen app.get('port'), ()->
#  console.log 'Express server listening on port ' + app.get('port')

routes = require('../build/routes/index')
users = require('../build/routes/users')

console.log io

io.on 'connect', (socket)->
#   socket.emit 'news', { hello: 'world' }
    console.log 'connected.'
    socket.on 'comment', (data)->
        console.log data

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
    err = new Error('Not Found')
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
