(function() {
  var socket;

  socket = io.connect('http://127.0.0.1:3000/');

  $('#test').click(function() {
    return socket.emit('/subscribe', 5);
  });

  socket.on('commentToScreen', function(data) {
    return alert(data);
  });

}).call(this);
