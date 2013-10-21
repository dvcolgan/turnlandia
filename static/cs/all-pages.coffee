# http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values
getParameterByName = (name) ->
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]")
    regexS = "[\\?&]" + name + "=([^&#]*)"
    regex = new RegExp(regexS)
    results = regex.exec(window.location.search)
    if(results == null)
        return ""
    else
        return decodeURIComponent(results[1].replace(/\+/g, " "))


ALL_PAGES =
    home: ->

    create_account: ->

    messages: ->

    settings: ->
        settingsViewModel = ->
            vm = @
            vm.leaderName = ko.observable($('#id_leader_name').val())
            vm.peopleName = ko.observable($('#id_people_name').val())
            vm.countryName = ko.observable($('#id_country_name').val())
            null

        ko.applyBindings(new settingsViewModel)

        startingColor = $('#id_color').val() or '#ffffff'
        $('#id_color').css('background-color', startingColor).css('color', startingColor)

        $('#id_color').ColorPicker
            color: startingColor

            onShow: (colpkr) ->
                $(colpkr).fadeIn(100)
                return false

            onChange: (hsb, hex, rgb) ->
                $('#id_color').val('#' + hex).css('background-color', '#' + hex).css('color', '#' + hex)

            onHide: (colpkr) ->
                $(colpkr).fadeOut(100)
                return false

        if getParameterByName('color')
            $('#id_color').parents('.form-group').addClass('has-error')
        if getParameterByName('leader_name')
            $('#id_leader_name').parents('.form-group').addClass('has-error')
        if getParameterByName('people_name')
            $('#id_people_name').parents('.form-group').addClass('has-error')
            

    game: ->
        TB.initialize()



$ ->
    # Make it so that the csrf token works
    $.ajaxSetup({
        crossDomain: false
        beforeSend: (xhr, settings) ->
            # these HTTP methods do not require CSRF protection
            if not /^(GET|HEAD|OPTIONS|TRACE)$/.test(settings.type)
                xhr.setRequestHeader("X-CSRFToken", $.cookie('csrftoken'))
    })

    cl = $('body').attr('class')
    if cl and cl of ALL_PAGES then ALL_PAGES[cl]()
