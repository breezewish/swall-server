express = require 'express'
router  = express.Router()


# GET home page.
router.get '/1', (req,res)->
	res.render 'takeComment'


router.post '/:id', (req, res)->
    # Accept comment from user
    info    = {id: parseInt(req.params.id), time: Date.now(), ip: req.remoteAddr, ua: req.headers['user-agent'] or '', msg: req.body.msg}
    comment = Comment info

    comment.save (err, comment)->
        if err
            return console.log err

    io.to(req.params.id).emit 'comment', info

    console.log info

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

