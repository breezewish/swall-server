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
#server.listen 3000

app_http = require('express')()
app_http.all '*', (req, res)->
    res.redirect 'https://swall.me' + req.url
    res.end()

app_http.listen 80


routes = require '../build/routes/index'
users  = require '../build/routes/users'


#Function used to darken.
colorLuminance = (hex, lum)->
    hex = String(hex).replace(/[^0-9a-f]/gi, '')
    if (hex.length < 6)
            hex = hex[0]+hex[0]+hex[1]+hex[1]+hex[2]+hex[2]

    lum = lum || 0
    rgb = "#"
    i = 0
    while i<3
        c = parseInt(hex.substr(i*2,2), 16)
        c = Math.round(Math.min(Math.max(0, c + (c * lum)), 255)).toString(16)
        rgb += ("00"+c).substr(c.length)
        ++i

    return rgb


db          = mongoose.createConnection 'mongodb://localhost/test'
information = mongoose.Schema {time: Number, ip: String, us: String, msg: String}
Comment     = db.model 'Comment', information

GLOBAL.Comment = Comment
GLOBAL.info = 
    title: '2014同济大学软件学院迎新晚会'
    buttom2: '#01FF70'
    buttomborder2: colorLuminance('#01FF70', -0.2)
    buttom3: '#F8F8FF'
    buttomborder3: colorLuminance('#F8F8FF', -0.2)


io.on 'connect', (socket)->
    console.log 'connected.'

    #Change the color of the buttom
    socket.on 'chacol', (data)->
        info.buttom2 = data.buttom2
        info.buttomborder2 = colorLuminance(data.buttom2, -0.2)
        info.buttom3 = data.buttom3
        info.buttomborder3 = colorLuminance(data.buttom3, -0.2)

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
