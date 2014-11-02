express = require 'express'
router  = express.Router()


# GET home page.
router.get '/:id', (req,res)->
    id = 'id_' + req.params.id
    if req.query.page
        info.page = req.query.page
    else
        info.page = 1

    allInfo =
        page: info.page
        activity: info[id]

    res.render 'takeComment', allInfo


# Change the color of the button
router.post '/:id/buttons', (req, res)->
    id = 'id_' + req.params.id
    intId = parseInt(req.params.id)

    if req.body.colors
        info[id].buttonbox = []

        delete info[id].buttonwidth
        delete info[id].buttonheight

        for color in req.body.colors
            info[id].buttonbox.push
                bg: color
                bb: colorLuminance color, -0.2

        Activity.update {actid: intId}, {$set: {"buttonbox": info[id].buttonbox, "colors" : req.body.colors}}, (err, result)->
            if err
                return console.log err

        info[id].buttonwidth  = calButtonWidth(id)
        info[id].buttonheight = calButtonHeight(id)

    res.json {}


# Change the keyword-filter array
router.post '/:id/keywords', (req, res)->
    id = 'id_' + req.params.id
    intId = parseInt(req.params.id)

    if req.body.keywords and req.body.keywords instanceof Array
        info[id].keywords = req.body.keywords

        Activity.update {actid: intId}, {$set: {"keywords": req.body.keywords}}, (err, result)->
            if err
                return console.log err

    res.json {}


# Accept comment from user
router.post '/:id', (req, res)->
    id = 'id_' + req.params.id

    if filterKeyword req.body.msg, info[id].keywords
        if req.headers['x-requested-with'] == 'XMLHttpRequest'
            res.sendStatus 200
        else
            allInfo =
                page: info.page
                activity: info[id]
            res.render 'takeComment', allInfo
        return

    console.log 'pass'

    # Process the msg
    msg = ''
    if req.body.msg.length > 100
        msg = req.body.msg.substr(0, 100) + '...'
    else
        msg = req.body.msg

    infos = 
        color: req.body.color
        actid: parseInt req.params.id
        time: Date.now()
        ip: req.connection.remoteAddress
        ua: req.headers['user-agent'] or ''
        msg: msg

    comment = Comment infos

    comment.save (err, comment)->
        if err
            return console.log err

    io.to(req.params.id).emit 'comment', infos

    if info[id].colors.indexOf(req.body.color) == -1
        if req.headers['x-requested-with'] == 'XMLHttpRequest'
            res.send '<p>不错哦，你hack成功了噢。ip：<%= ip %></p><p>来前排见见学长吧，可能有奖励噢。</p>'
        else
            res.render 'gotcha', {ip: req.connection.remoteAddress}

    if req.headers['x-requested-with'] == 'XMLHttpRequest'
        res.sendStatus 200
    else
        allInfo =
            page: info.page
            activity: info[id]
        res.render 'takeComment', allInfo


router.get '/', (req, res)->
    res.render 'about'


router.get '/:id/info', (req, res)->
    id = 'id_' + req.params.id
    res.json
        actid: req.params.id
        link: 'www.swall.me/' + req.params.id
        title: '软件学院迎新晚会'
        keywords: info[id].keywords


module.exports = router

