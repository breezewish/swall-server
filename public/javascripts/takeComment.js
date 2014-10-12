var socket = io.connect( 'http://127.0.0.1:3000/');

socket.on('connect', function() {
	alert('a');
});


var theWindow = $(window);
var inputArea = $('.inputMessage');


var sendMessage = function() {
	comment = inputArea.val();

	if(comment) {
		inputArea.val('');
		socket.emit('comment', comment);
	}
};


theWindow.keydown(function(event) {
	if(event.which === 13) {
		sendMessage();
		socket.emit('stop typing');
		typing = false;
	}
});
