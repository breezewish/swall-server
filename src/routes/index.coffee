express = require 'express'
router  = express.Router()


# GET home page.
router.get '/1', (req,res)->
    if req.query.page
        info.page = req.query.page
    else
        info.page = 1

    res.render 'takeComment', info


router.post '/:id', (req, res)->
    # Accept comment from user
    if filtKeyWord req.body.msg
        if req.body.HTTP_X_REQUESTED_WITH == 'xmlhttprequest'
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

    if req.body.HTTP_X_REQUESTED_WITH == 'xmlhttprequest'
        res.sendStatus 200
    else
        res.render 'takeComment', info 


router.get '/', (req, res)->
	res.redirect('/1')


router.get '/1/test', (req, res)->
	res.render 'test'


router.get '/1/info', (req, res)->
    res.json
        id: 1
        link: 'www.swall.me/1'
        title: '软件学院迎新晚会'
        forbidden: []


module.exports = router

