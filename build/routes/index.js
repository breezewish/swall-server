(function() {
  var express, router;

  express = require('express');

  router = express.Router();

  router.get('/1', function(req, res) {
    console.log('a');
    return res.render('takeComment');
  });

  router.get('/', function(req, res) {
    console.log('a');
    res.redirect('/1');
    return res.render('index', {
      title: 'Express'
    });
  });

  router.get('/1/info', function(req, res) {
    return res.json({
      id: 1,
      link: 'www.swall.me/1',
      title: '软件学院迎新晚会'
    });
  });

  module.exports = router;

}).call(this);
