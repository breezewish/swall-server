socket = io.connect( 'http://127.0.0.1:3000/')

$('#test').click ()->
	socket.emit '/subscribe', 5

socket.on 'commentToScreen', (data)->
	alert data
