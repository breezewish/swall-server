express = require 'express'
router  = express.Router()


router.post '/signin', (req, res)->
    User.find {'username': req.body.username}, (err, docs)->
        if err
            return console.log err
        if docs.length == 0
            res.json
                is_exist: false
        else if req.body.password != docs[0].password
            res.json
                correct: false
        else if docs.length == 1 and req.body.password == docs[0].password
            req.session.username = req.body.username
            res.json
                succeeded: true


router.post '/signup', (req, res)->
    # Return if username exist.
    User.find {'username': req.body.username}, (err, docs)->
        if err
            return console.log err
        else if docs.length != 0
            res.json
                is_exist: true
            return
        else if docs.length == 0
            userInfo =
                username: req.body.username
                password: req.body.password
                activities: []
                time: Date.now()

            user = User userInfo

            user.save (err, user)->
                if err
                    return console.log err

            res.json
                is_exist: false


router.post '/create_activity', (req, res)->
    if req.body.title
        new_id =
            actid: info.total_activity + 1 
            title: req.body.title
            buttonbox: [
                {bg: '#f8f8f8', bb: colorLuminance('#f8f8ff', -0.2)}
                {bg: '#79bd8f', bb: colorLuminance('#79bd8f', -0.2)}
                {bg: '#00b8ff', bb: colorLuminance('#00b8ff', -0.2)}
            ]
            colors: [
                '#f8f8f8'
                '#79bd8f'
                '#00b8ff'
            ]
            keywords: config.keywords

        new_activity = Activity new_id
        new_activity.save (err, new_activity)->
            if err
                return console.log err

            Activity.count (err, count)->
                info.total_activity = count
                console.log count

            info['id_' + count] = new_id
            info['id_' + count].buttonwidth = calButtonWidth('id_' + count)
            info['id_' + count].buttonheight = calButtonHeight('id_' + count)

        res.sendStatus 200


router.post '/logout', (req, res)->
    if req.session.username
        req.session.destroy (err)->
            console.log err

    res.sendStatus 200


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

    if filterKeyword(req.body.msg, info[id].keywords) or /^[A-Za-z0-9\s]*$/.test(req.body.msg) == false

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
        ip: req.headers['x-forwarded-for'] or ''
        ua: req.headers['user-agent'] or ''
        msg: msg
        belongto: id

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


router.get '/signin', (req, res)->
    res.render 'panel', {signin: true, panel: false}


router.get '/signup', (req, res)->
    res.render 'signup'


router.get '/panel', (req, res)->
    console.log req.session.username
    if req.session.username
        User.find {'username': req.session.username}, (err, docs)->
            if err
                return console.log err
            if docs.length == 1
                userInfo =
                    signin: false
                    panel: true
                    username: req.session.username
                    activities: docs[0].activities

                res.render 'panel', userInfo

                return
    else
        res.json
            is_exist: false


# GET home page.
router.get '/:id', (req,res)->
    id = 'id_' + req.params.id
    if req.query.page
        info.page = req.query.page
    else
        info.page = 1

    if typeof info[id] == 'undefined'
        res.status 404
        res.render '404'
        return
    else
        allInfo =
            page: info.page
            activity: info[id]
        res.render 'takeComment', allInfo


router.get '/:id/info', (req, res)->
    id = 'id_' + req.params.id
    res.json
        actid: req.params.id
        link: 'www.swall.me/' + req.params.id
        title: info[id].title
        keywords: info[id].keywords


module.exports = router

