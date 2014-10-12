(function() {
  var Comment, app, bodyParser, cookieParser, db, express, favicon, information, io, logger, mongoose, path, routes, server, urlparser, users;

  express = require('express');

  path = require('path');

  favicon = require('serve-favicon');

  logger = require('morgan');

  cookieParser = require('cookie-parser');

  bodyParser = require('body-parser');

  mongoose = require('mongoose');

  urlparser = require('url');

  app = require('express')();

  server = require('http').Server(app);

  io = require('socket.io')(server);

  server.listen(3000);

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

  io.on('connect', function(socket) {
    var socketId;
    console.log('connected.');
    socketId = urlparser.parse(socket.handshake.headers.referer).pathname.split('/')[1];
    console.log(socketId);
    if (socket.handshake.headers['user-agent'] === null || socket.handshake.headers['user-agent'] === void 0) {
      socket.handshake.headers['user-agent'] = 'null';
    }
    socket.on('comment', function(data) {
      var comment, info;
      info = {
        time: Date.now(),
        ip: socket.handshake.address,
        us: socket.handshake.headers['user-agent'],
        msg: data
      };
      comment = Comment(info);
      comment.save(function(err, comment) {
        if (err) {
          return console.log(err);
        }
        return console.log(comment);
      });
      return io.to(socketId).emit('commentToScrren', info);
    });
    socket.on('/subscribe', function(data) {
      return socket.join(socketId);
    });
    socket.on('/unsubscribe', function(data) {
      var room, _i, _len, _ref, _results;
      if (data === 'all') {
        _ref = io.sockets.manager.rooms;
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
