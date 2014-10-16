(function() {
  var Comment, app, bodyParser, cookieParser, db, express, favicon, fs, https, httpsOptions, information, io, logger, mongoose, path, routes, server, urlparser, users;

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

  httpsOptions = {
    key: fs.readFileSync(path.join(__dirname, '../www_swall_me.key')),
    cert: fs.readFileSync(path.join(__dirname, '../www_swall_me_bundle.crt'))
  };

  app = require('express')();

  server = https.createServer(httpsOptions, app);

  io = require('socket.io')(server);

  GLOBAL.io = io;

  server.listen(80);

  server.listen(443);

  routes = require('../build/routes/index');

  users = require('../build/routes/users');

  db = mongoose.createConnection('mongodb://localhost/test');

  information = mongoose.Schema({
    time: Number,
    ip: String,
    us: String,
    msg: String
  });

  Comment = db.model('Comment', information);

  GLOBAL.Comment = Comment;

  io.on('connect', function(socket) {
    console.log('connected.');
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

  app.use(require('stylus').middleware(path.join(__dirname, path.join('..', 'public'))));

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
