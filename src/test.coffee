socket = io.connect( 'http://127.0.0.1:3000/')

$('#test1').click ()->
	socket.emit '/subscribe', 5

$('#test2').click ()->
 	socket.emit '/unsubscribe', {id: '1'}

socket.on 'comment', (data)->
	console.log data, data['time'], data['ip'], data['us'], data['msg']	
