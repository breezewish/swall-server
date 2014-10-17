express = require 'express'
router  = express.Router()


# GET home page.
router.get '/1', (req,res)->
    res.render 'takeComment', info


router.post '/:id', (req, res)->
    # Accept comment from user
    infos    = {color: req.body.color, id: parseInt(req.params.id), time: Date.now(), ip: req.connection.remoteAddress, ua: req.headers['user-agent'] or '', msg: req.body.msg}
    comment = Comment infos

    comment.save (err, comment)->
        if err
            return console.log err

    console.log infos

    io.to(req.params.id).emit 'comment', infos

    res.sendStatus(200)


router.get '/', (req, res)->
	res.redirect('/1')


router.get '/1/test', (req, res)->
	res.render 'test'


router.get '/1/info', (req, res)->
    res.json {
        id: 1,
        link: 'www.swall.me/1',
        title: '软件学院迎新晚会',
        forbidden: []
    }


module.exports = router

