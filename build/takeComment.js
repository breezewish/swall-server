(function() {
  var inputArea, sendMessage, socket, theWindow;

  socket = io.connect('http://127.0.0.1:3000/');

  theWindow = $(window);

  inputArea = $('.inputMessage');

  sendMessage = function() {
    var comment;
    comment = inputArea.val();
    if (comment) {
      inputArea.val('');
      return socket.emit('comment', comment);
    }
  };

  theWindow.keydown(function(event) {
    var typing;
    if (event.which === 13) {
      sendMessage();
      socket.emit('stop typing');
      return typing = false;
    }
  });

}).call(this);
