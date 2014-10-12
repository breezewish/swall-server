var express = require('express');
//var router = express.Router();

http = require('http');
var app = express();
var server = http.createServer(app);
var io = require('socket.io').listen(server);


/* GET home page. */
app.get('/', function(req, res) {
	res.redirect('/1');
});

app.get('/1', function (req, res) {
	res.render('takeComment');
	console.log(io);
});

io.on('connect', function(socket) {
	console.log('connected.');
	socket.on('comment', function(data) {
		console.log(data);
	});
});

io.on('disconnect', function() {
	console.log('disconnected.');
});

module.exports = app;
