(function() {
  var Activity, Comment, actInfo, activity1, app, app_http, bodyParser, calButtonHeight, calButtonWidth, checkMsg, compression, config, cookieParser, cson, express, favicon, fs, https, id_1, io, logger, mongoose, msgInfo, path, routes, server, spdy, spdyOptions, urlparser, users;

  express = require('express');

  path = require('path');

  favicon = require('serve-favicon');

  logger = require('morgan');

  cookieParser = require('cookie-parser');

  bodyParser = require('body-parser');

  mongoose = require('mongoose');

  urlparser = require('url');

  https = require('https');

  fs = require('fs');

  cson = require('cson');

  compression = require('compression');

  spdy = require('spdy');

  GLOBAL.DEBUG = false;

  config = cson.parseFileSync('config.cson');

  spdyOptions = {
    key: fs.readFileSync(path.join(__dirname, '../www_swall_me.key')),
    cert: fs.readFileSync(path.join(__dirname, '../www_swall_me_bundle.crt'))
  };

  app = require('express')();

  if (DEBUG) {
    server = require('http').Server(app);
  } else {
    server = spdy.createServer(spdyOptions, app);
  }

  io = require('socket.io')(server);

  GLOBAL.io = io;

  if (DEBUG) {
    server.listen(3000);
  } else {
    server.listen(443);
  }

  app_http = require('express')();

  app_http.all('*', function(req, res) {
    res.redirect('https://swall.me' + req.url);
    return res.end();
  });

  if (!DEBUG) {
    app_http.listen(80);
  }

  app.use(compression());

  routes = require('../build/routes/index');

  users = require('../build/routes/users');

  GLOBAL.db = mongoose.createConnection('mongodb://localhost/test');

  msgInfo = mongoose.Schema({
    color: String,
    id: Number,
    time: Number,
    ip: String,
    ua: String,
    msg: String
  });

  actInfo = mongoose.Schema({
    actid: Number,
    title: String,
    buttonbox: Array,
    keywords: Array
  });

  Comment = db.model('Comment', msgInfo);

  Activity = db.model('Activity', actInfo);

  GLOBAL.colorLuminance = function(hex, lum) {
    var c, i, rgb;
    hex = String(hex).replace(/[^0-9a-f]/gi, '');
    if (hex.length < 6) {
      hex = hex[0] + hex[0] + hex[1] + hex[1] + hex[2] + hex[2];
    }
    lum = lum || 0;
    rgb = "#";
    i = 0;
    while (i < 3) {
      c = parseInt(hex.substr(i * 2, 2), 16);
      c = Math.round(Math.min(Math.max(0, c + (c * lum)), 255)).toString(16);
      rgb += ("00" + c).substr(c.length);
      ++i;
    }
    return rgb;
  };

  calButtonWidth = function(id) {
    return ((100 - (info[id].buttonbox.length - 1) * 1.25) / info[id].buttonbox.length) + "%";
  };

  calButtonHeight = function(id) {
    return ((100 - (info[id].buttonbox.length - 1) * 5) / info[id].buttonbox.length) + "%";
  };

  GLOBAL.Comment = Comment;

  id_1 = {
    actid: 1,
    title: '2014同济大学软件学院迎新晚会',
    buttonbox: [
      {
        bg: '#F8F8F8',
        bb: colorLuminance('#F8F8FF', -0.2)
      }, {
        bg: '#79BD8F',
        bb: colorLuminance('#79BD8F', -0.2)
      }, {
        bg: '#00B8FF',
        bb: colorLuminance('#00B8FF', -0.2)
      }
    ],
    keywords: config.keywords
  };

  GLOBAL.info = {
    id_1: id_1
  };

  activity1 = Activity(id_1);

  activity1.save(function(err, activity1) {
    if (err) {
      return console.log(err);
    }
  });

  info.page = 1;

  info['id_1'].buttonwidth = calButtonWidth('id_1');

  info['id_1'].buttonheight = calButtonHeight('id_1');

  checkMsg = function(msg, array) {
    var keyword, _i, _len;
    for (_i = 0, _len = array.length; _i < _len; _i++) {
      keyword = array[_i];
      if (msg.indexOf(keyword) !== -1) {
        return true;
      }
    }
    return false;
  };

  GLOBAL.filterKeyWord = function(msg, keywords) {
    var chiNoPu, chinese, engNoPu, english;
    english = msg.replace(/[\u4e00-\u9fff\u3400-\u4dff\uf900-\ufaff0-9\s]/g, '');
    english = english.toLowerCase();
    chinese = msg.replace(/[A-Za-z0-9\s]/g, '');
    engNoPu = english.replace(/[\ |\~\～|\`\｀|\!\！|\@\@|\#\＃|\$\¥|\%\％|\^\^|\&\—|\*\＊|\(\（|\)\）|\-\－|\_\—|\+\＋|\=\＝|\|\｜|\\\＼|\[\［|\]\］|\{\｛|\}\｝|\;\；|\:\：|\"\“\”|\'\‘\’|\,\，|\<\《|\.\。|\>\》|\/\、\／|\?\？]/g, '');
    chiNoPu = chinese.replace(/[\ |\~\～|\`\｀|\!\！|\@\@|\#\＃|\$\¥|\%\％|\^\^|\&\—|\*\＊|\(\（|\)\）|\-\－|\_\—|\+\＋|\=\＝|\|\｜|\\\＼|\[\［|\]\］|\{\｛|\}\｝|\;\；|\:\：|\"\“\”|\'\‘\’|\,\，|\<\《|\.\。|\>\》|\/\、\／|\?\？]/g, '');
    if (DEBUG) {
      console.log('raw: ' + msg);
      console.log('english: ' + english);
      console.log('chinese: ' + chinese);
      console.log('english without punctuation: ' + engNoPu);
      console.log('chinese without punctuation: ' + chiNoPu);
    }
    if (checkMsg(msg, keywords) || checkMsg(english, keywords) || checkMsg(chinese, keywords) || checkMsg(engNoPu, keywords) || checkMsg(chiNoPu, keywords)) {
      return true;
    } else {
      return false;
    }
  };

  io.on('connect', function(socket) {
    socket.on('/subscribe', function(data) {
      socket.join(data.id);
      return socket.emit('sucscribeOk', data.id);
    });
    socket.on('/unsubscribe', function(data) {
      var room, _i, _len, _ref, _results;
      if (data === 'all') {
        _ref = io.sockets.adapter.rooms;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          room = _ref[_i];
          _results.push(socket.leave(room));
        }
        return _results;
      } else {
        return socket.leave(data.id);
      }
    });
    return socket.on('disconnect', function() {
      var room, _i, _len, _ref, _results;
      _ref = io.sockets.adapter.rooms;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        room = _ref[_i];
        _results.push(socket.leave(room));
      }
      return _results;
    });
  });

  io.on('disconnect', function() {
    return console.log('disconnected.');
  });

  app.set('views', path.join(__dirname, path.join('..', 'views')));

  app.set('view engine', 'ejs');

  app.use(logger('dev'));

  app.use(bodyParser.json());

  app.use(bodyParser.urlencoded({
    extended: false
  }));

  app.use(cookieParser());

  app.use(express["static"](path.join(__dirname, path.join('..', 'public'))));

  app.use(express["static"](path.join(__dirname, path.join('..', 'build'))));

  app.use('/', routes);

  app.use('/users', users);

  app.use(function(req, res, next) {
    var err;
    err = new Error('Not Found');
    err.status = 404;
    return next(err);
  });

  if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
      res.status(err.status || 500);
      return res.render('error', {
        message: err.message,
        error: err
      });
    });
  }

  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    return res.render('error', {
      message: err.message,
      error: {}
    });
  });

  module.exports = app;

}).call(this);
