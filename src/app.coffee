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
cson         = require 'cson'
compression  = require 'compression'
spdy         = require 'spdy'
#filter       = require 'keyword-filter'


GLOBAL.DEBUG  = false
#GLOBAL.filter = filter


config = cson.parseFileSync 'config.cson'


spdyOptions =
    key: fs.readFileSync(path.join(__dirname, '../www_swall_me.key'))
    cert: fs.readFileSync(path.join(__dirname, '../www_swall_me_bundle.crt'))


app        = require('express')()
if DEBUG
    server = require('http').Server(app)
else
    server = spdy.createServer(spdyOptions, app)
io         = require('socket.io')(server)


GLOBAL.io = io


if DEBUG
    server.listen 3000
else
    server.listen 443


app_http = require('express')()
app_http.all '*', (req, res)->
    res.redirect 'https://swall.me' + req.url
    res.end()


if not DEBUG
    app_http.listen 80
app.use compression()


routes = require '../build/routes/index'
users  = require '../build/routes/users'


GLOBAL.db           = mongoose.createConnection 'mongodb://localhost/test'
msgInfo             = mongoose.Schema
    color: String
    id: Number
    time: Number
    ip: String
    ua: String
    msg: String
actInfo             = mongoose.Schema
    actid: Number
    title: String
    buttonbox: Array
    keywords: Array
Comment             = db.model 'Comment', msgInfo
Activity            = db.model 'Activity', actInfo


GLOBAL.Comment  = Comment
GLOBAL.Activity = Activity
GLOBAL.info = {}


# Filter
# GLOBAL.myFilter = (msg, array)->


#Function used to darken.
GLOBAL.colorLuminance = (hex, lum)->
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


GLOBAL.calButtonWidth  = (id)->
    ((100 - (info[id].buttonbox.length - 1) * 1.25) / info[id].buttonbox.length) + "%"

GLOBAL.calButtonHeight = (id)->
    ((100 - (info[id].buttonbox.length - 1) * 5) / info[id].buttonbox.length) + "%"


Activity.find {'actid': 1}, (err, docs)->
    if err
        return console.log err
    else if docs.length == 0
        id_1 =
            actid: 1
            title: '2014同济大学软件学院迎新晚会'
            buttonbox: [
                {bg: '#F8F8F8', bb: colorLuminance('#F8F8FF', -0.2)}
                {bg: '#79BD8F', bb: colorLuminance('#79BD8F', -0.2)}
                {bg: '#00B8FF', bb: colorLuminance('#00B8FF', -0.2)}
            ]
            keywords: config.keywords

        activity1 = Activity id_1
        activity1.save (err, activity1)->
            if err
                return console.log err


Activity.find {}, (err, docs)->
    if err
        return console.log err

    for activity in docs
        info['id_' + activity.actid] = activity
        info['id_1'].buttonwidth = calButtonWidth('id_1')
        info['id_1'].buttonheight = calButtonHeight('id_1')


info.page = 1


#filter.init info.id_1.keywords
#GLOBAL.filters =
#    id_1: filter
checkMsg = (msg, keywords)->
    for keyword in keywords
        if msg.indexOf(keyword) != -1
            return true
    return false

GLOBAL.filterKeyword = (msg, keywords)->
    # English with punctuation
    english = msg.replace /[\u4e00-\u9fff\u3400-\u4dff\uf900-\ufaff0-9\s]/g, ''
    english = english.toLowerCase()

    # Chinese with punctuation
    chinese = msg.replace /[A-Za-z0-9\s]/g, ''

    # English without punctuation
    engNoPu = english.replace /[\ |\~\～|\`\｀|\!\！|\@\@|\#\＃|\$\¥|\%\％|\^\^|\&\—|\*\＊|\(\（|\)\）|\-\－|\_\—|\+\＋|\=\＝|\|\｜|\\\＼|\[\［|\]\］|\{\｛|\}\｝|\;\；|\:\：|\"\“\”|\'\‘\’|\,\，|\<\《|\.\。|\>\》|\/\、\／|\?\？]/g, ''

    # Chinese without punctuation
    chiNoPu = chinese.replace /[\ |\~\～|\`\｀|\!\！|\@\@|\#\＃|\$\¥|\%\％|\^\^|\&\—|\*\＊|\(\（|\)\）|\-\－|\_\—|\+\＋|\=\＝|\|\｜|\\\＼|\[\［|\]\］|\{\｛|\}\｝|\;\；|\:\：|\"\“\”|\'\‘\’|\,\，|\<\《|\.\。|\>\》|\/\、\／|\?\？]/g, ''

    if DEBUG
        console.log 'raw: ' + msg
        console.log 'english: ' + english
        console.log 'chinese: ' + chinese
        console.log 'english without punctuation: ' + engNoPu
        console.log 'chinese without punctuation: ' + chiNoPu

    if (
        checkMsg(msg, keywords) or
        checkMsg(english, keywords) or
        checkMsg(chinese, keywords) or
        checkMsg(engNoPu, keywords) or
        checkMsg(chiNoPu, keywords)
    )
        true
    else
        false


io.on 'connect', (socket)->
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
app.set 'views', path.join(__dirname, path.join('..', 'views'))
app.set 'view engine', 'ejs'


# uncomment after placing your favicon in /public
#app.use(favicon(__dirname + '/public/favicon.ico'));
app.use logger('dev')
app.use bodyParser.json()
app.use bodyParser.urlencoded({extended: false})
app.use cookieParser()
app.use express.static(path.join(__dirname, path.join('..', 'public')))
app.use express.static(path.join(__dirname, path.join('..', 'build')))


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

