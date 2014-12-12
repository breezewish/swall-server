signin = (postData)->
    $.ajax
        type: 'POST'
        url: '/signin'
        data: postData
        timeout: 3000
        success: open_screen


create = (postData)->
    $.ajax
        type: 'POST'
        url: '/create_activity'
        data: postData
        timeout: 3000


remove_panel = ()->
    $('#panel').remove()


get_panel = (data, textStatus, jqXHR)->
    if data.is_exist == false
        return
    else
        $('#screen-left').removeAttr 'style'
        $('#signin-container').removeAttr 'style'
        $('body').append data
        $('#logout-button').click ()->
            $('body').animate
                scrollTop: $('body').offset().top
            , duration: 1000
            $('#screen-left').css 'width', '50%'
            $('#signin-container').css 'width', '50%'
            $('.activity').addClass 'hidden-item'
            setTimeout ()->
                    $.ajax
                        type: 'POST'
                        url: '/logout'
                        timeout: 3000
                        success: remove_panel
                , 2000

        $('form').submit ()->
            return false

        $('.menu-item').click ()->
            target_hook = $(this).attr 'scrollto'
            $('body').animate
                scrollTop:$(target_hook).offset().top - 270
            , duration: 1000

        $('#create-button').click ()->
            title = document.getElementById 'activity-title'

            postData =
                title: title.value
                
            create postData

        setTimeout ()->
            $('.activity').removeClass 'hidden-item'
        , 1000


open_panel = ()->
    $.ajax
        type: 'GET'
        url: '/panel'
        timeout: 3000
        success: get_panel


open_screen = (data, textStatus, jqXHR)->
    if data.succeeded
        open_panel()
    else
        $('#arrow-box').focus()


$(() ->
    open_panel()

    $('form').submit ()->
        return false

    $('#signin-button').click ()->
        username = document.getElementById 'username'
        password = document.getElementById 'password'
        
        postData =
            username: username.value
            password: password.value

        signin postData
)

