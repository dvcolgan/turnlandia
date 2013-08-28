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


GAME =
    world_names: [
        'Atlantis',
        'Azeroth',
        'Camelot',
        'Narnia',
        'Hyrule',
        'Middle-earth',
        'The Neverhood',
        'Rapture',
        'Terabithia',
        'Kanto',
        'The Grand Line',
        'Tatooine',
        'Naboo',
        'Pandora',
        'Corneria',
        'Termina',
        'Xen',
        'City 17',
        'Tokyo',
        'Ithica',
        'Peru',
    ]
    player_names: [
        ['Frodo Baggins', 'Shire Hobbits'],
        ['Elrond', 'Mirkwood Elves'],
        ['Durin Darkhammer', 'Moria Dwarves'],
        ['Ness', 'Eagleland'],
        ['Daphnes Nohansen Hyrule', 'Hylians'],
        ['Aragorn son of Arathorn', 'Gondorians'],
        ['Strong Bad', 'Strongbadia'],
        ['Captain Homestar', 'The Team'],
        ['T-Rex', 'Dinosaurs'],
        ['Refrigerator', 'Kitchen Appliances'],
        ['The Burger King', 'Fast Foodies'],
        ['Larry King Live', 'Interviewees'],
        ['King', 'Mimigas'],
        ['Luke Skywalker', 'The Rebel Alliance'],
        ['Darth Vader', 'The Empire'],
        ['Jean-Luc Picard', 'The Enterprise'],
        ['The Borg Queen', 'The Borg'],
        ['Bowser', 'Koopas'],
    ]

    home: ->

    create_accout: ->

    messages: ->

    settings: ->
        settingsViewModel = ->
            vm = @
            vm.leaderName = ko.observable($('#id_leader_name').val())
            vm.peopleName = ko.observable($('#id_people_name').val())
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

        gameViewModel = ->







            null # return null or the view model will break because coffeescript
        ko.applyBindings(new gameViewModel)

        #opts =
        #    lines: 13
        #    length: 40
        #    width: 16
        #    radius: 60
        #    corners: 1
        #    rotate: 0
        #    direction: 1
        #    color: '#000'
        #    speed: 2.2
        #    trail: 60
        #    shadow: true
        #    hwaccel: true
        #    className: 'spinner'
        #    zIndex: 2e9
        #    top: (getViewHeight() * GRID_SIZE) / 2 - 120
        #    left: 'auto'
        #spinner = new Spinner(opts).spin($('#board').get(0))




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
    if cl then GAME[cl]()


