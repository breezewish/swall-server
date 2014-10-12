express = require('express')
router = express.Router()


# GET home page.
router.get '/1', (req,res)->
	console.log 'a'
	res.render 'takeComment'

router.get '/', (req, res)->
	console.log 'a'
	res.redirect('/1')
	res.render 'index', { title: 'Express' }

router.get '/1/info', (req, res)->
    res.json {
        id: 1,
        link: 'www.swall.me/1',
        title: '软件学院迎新晚会'
    }

module.exports = router
