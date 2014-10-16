(function() {
  var express, router;

  express = require('express');

  router = express.Router();

  router.get('/1', function(req, res) {
    return res.render('takeComment', info);
  });

  router.post('/:id', function(req, res) {
    var comment, info;
    info = {
      id: parseInt(req.params.id),
      time: Date.now(),
      ip: req.remoteAddr,
      ua: req.headers['user-agent'] || '',
      msg: req.body.msg
    };
    comment = Comment(info);
    comment.save(function(err, comment) {
      if (err) {
        return console.log(err);
      }
    });
    io.to(req.params.id).emit('comment', info);
    return res.sendStatus(200);
  });

  router.get('/', function(req, res) {
    return res.redirect('/1');
  });

  router.get('/1/test', function(req, res) {
    return res.render('test');
  });

  router.get('/1/info', function(req, res) {
    return res.json({
      id: 1,
      link: 'www.swall.me/1',
      title: '软件学院迎新晚会',
      forbidden: []
    });
  });

  module.exports = router;

}).call(this);
