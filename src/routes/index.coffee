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
router.post '/:id/button', (req, res)->
    id = 'id_' + req.params.id
    intId = parseInt(req.params.id)

    if req.body.colors
        info[id].buttonbox = []
        delete info.buttonwidth
        delete info.buttonheight

        for color in req.body.colors
            info[id].buttonbox.append
                bg: color
                bb: colorLuminance color, -0.2

        Activity.update {actid: intId}, {$set: {"buttonbox": req.body.colors}}, (err, result)->
            if err
                return console.log result

        info[id].buttonwidth  = calButtonWidth(id)
        info[id].buttonheight = calButtonHeight(id)


# Change the keyword-filter array
router.post '/:id/keywords', (req, res)->
    id = 'id_' + req.params.id
    intId = parseInt(req.params.id)

    if req.body.keywords and req.body.keywords instanceof Array
        info[id].keywords = req.body.keywords

        Activity.update {actid: intId}, {$set: {"keywords": req.body.keywords}}, (err, result)->
            if err
                return console.log result

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

    infos = 
        color: req.body.color
        actid: parseInt req.params.id
        time: Date.now()
        ip: req.connection.remoteAddress
        ua: req.headers['user-agent'] or ''
        msg: req.body.msg

    comment = Comment infos

    comment.save (err, comment)->
        if err
            return console.log err

    io.to(req.params.id).emit 'comment', infos

    if req.headers['x-requested-with'] == 'XMLHttpRequest'
        res.sendStatus 200
    else
        allInfo =
            page: info.page
            activity: info[id]
        res.render 'takeComment', allInfo


router.get '/', (req, res)->
	res.redirect('/1')


router.get '/:id/info', (req, res)->
    id = 'id_' + req.params.id
    res.json
        actid: req.params.id
        link: 'www.swall.me/' + req.params.id
        title: '软件学院迎新晚会'
        keywords: info[id].keywords


module.exports = router

