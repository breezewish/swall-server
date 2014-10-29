(function() {
  var express, router;

  express = require('express');

  router = express.Router();

  router.get('/:id', function(req, res) {
    var allInfo, id;
    id = 'id_' + req.params.id;
    if (req.query.page) {
      info.page = req.query.page;
    } else {
      info.page = 1;
    }
    allInfo = {
      page: info.page,
      activity: info[id]
    };
    return res.render('takeComment', allInfo);
  });

  router.post('/:id/button', function(req, res) {
    var color, id, _i, _len, _ref;
    id = 'id_' + req.params.id;
    if (req.body.colors) {
      info[id].buttonbox = [];
      delete info.buttonwidth;
      delete info.buttonheight;
      _ref = req.body.colors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        color = _ref[_i];
        info[id].buttonbox.append({
          bg: color,
          bb: colorLuminance(color, -0.2)
        });
      }
      db.collection('activity', function(err, collection) {
        if (err) {
          return console.log(err);
        }
        return collection.update({
          actid: id
        }, {
          $set: {
            "buttonbox": req.body.colors
          }
        }, function(err, result) {
          if (err) {
            return console.log(err);
          }
        });
      });
      info[id].buttonwidth = calButtonWidth(id);
      return info[id].buttonheight = calButtonHeight(id);
    }
  });

  router.post('/:id/keywords', function(req, res) {
    var id;
    id = 'id_' + req.params.id;
    if (req.body.keywords && req.body.keywords instanceof Array) {
      info[id].keywords = req.body.keywords;
      db.collection('activity', function(err, collection) {
        if (err) {
          return console.log(err);
        }
        return collection.update({
          actid: id
        }, {
          $set: {
            "keywords": req.body.keywords
          }
        }, function(err, result) {
          if (err) {
            return console.log(err);
          }
        });
      });
    }
    return res.json({});
  });

  router.post('/:id', function(req, res) {
    var allInfo, comment, id, infos;
    id = 'id_' + req.params.id;
    if (filterKeyword(req.body.msg, info[id].keywords)) {
      if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
        res.sendStatus(200);
      } else {
        allInfo = {
          page: info.page,
          activity: info[id]
        };
        res.render('takeComment', allInfo);
      }
      return;
    }
    console.log('pass');
    infos = {
      color: req.body.color,
      actid: parseInt(req.params.id),
      time: Date.now(),
      ip: req.connection.remoteAddress,
      ua: req.headers['user-agent'] || '',
      msg: req.body.msg
    };
    comment = Comment(infos);
    comment.save(function(err, comment) {
      if (err) {
        return console.log(err);
      }
    });
    io.to(req.params.id).emit('comment', infos);
    if (req.headers['x-requested-with'] === 'XMLHttpRequest') {
      return res.sendStatus(200);
    } else {
      allInfo = {
        page: info.page,
        activity: info[id]
      };
      return res.render('takeComment', allInfo);
    }
  });

  router.get('/', function(req, res) {
    return res.redirect('/1');
  });

  router.get('/:id/info', function(req, res) {
    var id;
    id = 'id_' + req.params.id;
    return res.json({
      actid: req.params.id,
      link: 'www.swall.me/' + req.params.id,
      title: '软件学院迎新晚会',
      keywords: info[id].keywords
    });
  });

  module.exports = router;

}).call(this);
