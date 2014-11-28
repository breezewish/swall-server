sendComment = (postData)->
    $.ajax
        type: 'POST'
        url: '/signup'
        data: postData
        timeout: 3000
        success: test


test = (data)->
    alert data
    console.log data


$(() ->
    $('form').submit ()->
        return false

    $('#signup').click ()->
        username = document.getElementById 'username'
        password = document.getElementById 'password'
        
        postData =
            username: username.value
            password: password.value

        sendComment postData
)

