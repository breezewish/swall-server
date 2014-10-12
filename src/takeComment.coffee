socket = io.connect( 'http://127.0.0.1:3000/')


theWindow = $(window)
inputArea = $('.inputMessage')


#Omit connection check temporarily.
sendMessage = ()->
	comment = inputArea.val()

	if comment
		inputArea.val('')
		socket.emit 'comment', comment


theWindow.keydown (event)->
	# Auto-focus the current input when a key is typed
#	if (!(event.ctrlKey || event.metaKey || event.altKey))
#		$currentInput.focus()

	# When the client hits ENTER on their keyboard
	if event.which == 13
		sendMessage()
		socket.emit('stop typing')
		typing = false
