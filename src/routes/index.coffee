express = require 'express'
router  = express.Router()


# GET home page.
router.get '/1', (req,res)->
    if req.query.page
        info.page = req.query.page
    else
        info.page = 1

    res.render 'takeComment', info


# Change the keyword-filter array
router.post '/:id/keywords', (req, res)->
    if req.query.keywords and typeof req.query.keywords is 'array'
        info.keywords['id_' + req.params.id] = req.query.keywords
        filters['id_' + req.params.id]       = require('keyword-filter').init req.query.keywords


router.post '/:id', (req, res)->
    # Accept comment from user
    if filtKeyWord req.body.msg, filters['id_' + req.params.id]
        if req.headers['x-requested-with'] == 'XMLHttpRequest'
            res.sendStatus 200
        else
            res.render 'takeComment', info 
        return

    console.log 'pass'

    infos = 
        color: req.body.color
        id: parseInt req.params.id
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
        res.render 'takeComment', info 


router.get '/', (req, res)->
	res.redirect('/1')


router.get '/:id/info', (req, res)->
    res.json
        id: 1
        link: 'www.swall.me/' + req.params.id
        title: '软件学院迎新晚会'
        keywords: info.keywords['id_' + req.params.id]


module.exports = router

