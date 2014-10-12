(function() {
  var app, bodyParser, cookieParser, express, favicon, io, logger, path, routes, server, users;

  express = require('express');

  path = require('path');

  favicon = require('serve-favicon');

  logger = require('morgan');

  cookieParser = require('cookie-parser');

  bodyParser = require('body-parser');

  app = require('express')();

  server = require('http').Server(app);

  io = require('socket.io')(server);

  server.listen(3000);

  routes = require('../build/routes/index');

  users = require('../build/routes/users');

  console.log(io);

  io.on('connect', function(socket) {
    console.log('connected.');
    return socket.on('comment', function(data) {
      return console.log(data);
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
