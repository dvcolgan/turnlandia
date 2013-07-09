gameApp = angular.module 'gameApp', []

gameApp.config ($routeProvider) ->

    #$routeProvider.when '/create-account/',
    #    templateUrl: 'partials/create-account.html'
    #    controller: 'CreateAccountController'

    #$routeProvider.when '/new-game/',
    #    templateUrl: 'partials/new-game.html'
    #    controller: 'GameController'

        #$routeProvider.when '/edit-icon/',
        #    templateUrl: 'partials/edit-icon.html'
        #    controller: EditIconController
        

    $routeProvider.when '/board/:centerX/:centerY/',
        templateUrl: 'partials/play.html'
        controller: 'PlayController'

    $routeProvider.otherwise
        redirectTo: '/board/0/0/'

gameApp.config ($httpProvider) ->
    $httpProvider.defaults.headers.post['X-CSRFToken'] = $('input[name=csrfmiddlewaretoken]').val()

gameApp.config ($interpolateProvider) ->
    $interpolateProvider.startSymbol('{[{').endSymbol('}]}')

gameApp.directive 'blur', ->
    (scope, element, attrs) ->
        element.bind 'blur', ->
            scope.$apply(attrs.blur)


#gameApp.directive('uniqueOnServer', [

#http://stackoverflow.com/questions/14012239/password-check-directive-in-angularjs
gameApp.directive 'valueMatches', ->
    return {
        require: "ngModel"
        scope:
            valueMatches: '='
        link: (scope, element, attrs, ctrl) ->
            scope.$watch (->
                combined = null

                if scope.valueMatches and ctrl.$viewValue
                    combined = scope.valueMatches + '_' + ctrl.$viewValue
                return combined
            ), ((value) ->
                # TODO something is still wrong in here, this just doesn't want to work
                if (value)
                    ctrl.$parsers.unshift (viewValue) ->
                        origin = scope.valueMatches
                        if origin != viewValue
                            ctrl.$setValidity("valueMatches", false)
                            return undefined
                        else
                            ctrl.$setValidity("valueMatches", true)
                            return viewValue
            )
    }


gameApp.directive 'uniqueUsername', ($http, $compile) ->
    return {
        require: 'ngModel'
        restrict: 'A'
        link: (scope, element, attrs, ctrl) ->
            ctrl.$parsers.push (viewValue) ->
                if viewValue
                    $http.get('/api/account/exists/username/' + viewValue + '/')
                        .success((data, status, headers, config) ->
                            console.log 'here'
                            if data.taken
                                ctrl.$setValidity('unique', false)
                            else
                                ctrl.$setValidity('unique', true)
                        )
                        .error((data, status, headers, config) ->
                            alert('could not connect to server')
                        )
                return viewValue
    }








    #gameApp.directive 'imgEditor', ($http, $compile) ->
    #    return {
    #        replace: true
    #        restrict: 'E'
    #        scope: {}
    #        templateUrl: 'directives/img-editor.html'
    #        link: (scope, element, attrs, ctrl) ->
    #        controller: 
    #    }
    #
    #
    #EditIconController = ($scope) ->
    #    $scope.iconData = []
    #    for i in [0...24]
    #        row = []
    #        for j in [0...24]
    #            row.push({
    #                color: 'white'
    #            })
    #        $scope.iconData.push(row)
    #
    #    $scope.currentColor = 'black'
    #
    #    $scope.setPixel = (pixel, color) ->
    #        pixel.color = color










gameApp.factory 'Data', ->
    return {
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
    }



randomChoice = (collection) ->
    collection[Math.floor(Math.random()*collection.length)]

CreateAccountController = ($scope, $http, $location) ->
    $scope.newAccount =
        username: ''
        password: ''
        password2: ''

    $scope.submit = ->
        $http.post('/api/account/', $scope.newAccount)
            .success((data, status, headers, config) ->
                $location.path('/play/')
            )
            .error((data, status, headers, config) ->
                alert(data.error)
            )




GameController = ($scope, Data) ->
    $scope.data = Data
    $scope.world_name = ''
    $scope.leader_name = ''
    $scope.people_name = ''
    $scope.getRandomWorldName = ->
        $scope.world_name = randomChoice($scope.data.world_names)
    $scope.getRandomCivName = ->
        names = randomChoice($scope.data.player_names)
        $scope.leader_name = names[0]
        $scope.people_name = names[1]



PlayController = ($scope, $http, $timeout, $routeParams) ->
    $scope.getViewWidth = ->
        Math.floor((angular.element(window).width() - (48+20)) / 48)
    $scope.getViewHeight = ->
        angular.element(window).height()
        Math.floor((angular.element(window).height() - (220)) / 48)

    $scope.fetchBoard = (centerX, centerY) ->
        
        $http.get('/api/sector/'+centerX+'/'+centerY+'/'+$scope.getViewWidth()+'/'+$scope.getViewHeight()+'/')
            .success((data, status, headers, config) ->
                $scope.data = data
                $scope.centerX = parseInt(centerX)
                $scope.centerY = parseInt(centerY)
                for square in $scope.data.squares
                    square.left = ((square.x-($scope.centerX-data.view_width /2)) * 48) + 'px'
                    square.top =  ((square.y-($scope.centerY-data.view_height/2)) * 48) + 'px'
                $scope.topCoords = [$scope.centerX-data.view_width/2...$scope.centerX+data.view_width/2]
                $scope.sideCoords = [$scope.centerY-data.view_height/2...$scope.centerY+data.view_height/2]
                $scope.data.board_width = ($scope.data.view_width * 48) + 'px'
                $scope.data.board_height = ($scope.data.view_height * 48) + 'px'
                $scope.unitsRemaining = data.remaining_counts
            )
            .error((data, status, headers, config) ->
                alert(data.error)
            )
    $scope.fetchBoard($routeParams.centerX, $routeParams.centerY)

    $scope.findSquare = (x, y) ->
        for square in $scope.data.squares
            if square.x == x and square.y == y
                return square
        throw 'Square not loaded'

    $scope.modifyUnit = (square, action) ->
        if action == 'initial'
            # Set the 8 on the square clicked on
            square8 = square
            # Set 4 4s around the 8
            squares4 = [
                $scope.findSquare(square.x-1, square.y)
                $scope.findSquare(square.x+1, square.y)
                $scope.findSquare(square.x, square.y-1)
                $scope.findSquare(square.x, square.y+1)
            ]
            squares2 = [
                $scope.findSquare(square.x-1, square.y-1)
                $scope.findSquare(square.x+1, square.y+1)
                $scope.findSquare(square.x+1, square.y-1)
                $scope.findSquare(square.x-1, square.y+1)
            ]
            squares1 = [
                $scope.findSquare(square.x-1, square.y-1)
                $scope.findSquare(square.x+1, square.y+1)
                $scope.findSquare(square.x+1, square.y-1)
                $scope.findSquare(square.x-1, square.y+1)
            ]

            $http.post('/api/square/' + square.x + '/' + square.y + '/' + action + '/', {
                action: action
            }).success((data, status, headers, config) ->
            )
            .error((data, status, headers, config) ->
            )

        else
            $http.post('/api/square/' + square.x + '/' + square.y + '/' + action + '/', {
                action: action
            }).success((data, status, headers, config) ->
                if action == 'place'
                    # If there is already a unit of this color on this square, update the amount,
                    # otherwise add the whole unit
                    found = false
                    for unit in square.units
                        # TODO this needs to be fixed to use the account's color so the units will get a color
                        if unit.color == data.unit.color
                            unit.amount = data.unit.amount
                            found = true
                            break
                    if not found
                        square.units.push(data.unit)


                else if action == 'remove'
                    for i in [0...square.units.length]
                        if square.units[i].color == $scope.currentColor
                            if data.amount == 0
                                square.units.splice(i, 1)
                            else
                                square.units[i].amount = data.amount
                            break


                for remaining in $scope.unitsRemaining
                    if remaining.color == $scope.currentColor
                        remaining.remaining = data.units_remaining
                        break
            )
            .error((data, status, headers, config) ->
                alert(data.error)
            )

    $scope.currentColor = 'blue'
    $scope.unitAction = 'place'

