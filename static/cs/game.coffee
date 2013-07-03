gameApp = angular.module 'gameApp', []

gameApp.config ($routeProvider) ->

    $routeProvider.when '/create-account/',
        templateUrl: 'partials/create-account.html'
        controller: CreateAccountController

    $routeProvider.when '/new-game/',
        templateUrl: 'partials/new-game.html'
        controller: GameController

    $routeProvider.when '/play/',
        templateUrl: 'partials/play.html'
        controller: PlayController


gameApp.config ($interpolateProvider) ->
    $interpolateProvider.startSymbol('{[{').endSymbol('}]}')

gameApp.directive 'blur', ->
    (scope, element, attrs) ->
        element.bind 'blur', ->
            scope.$apply(attrs.blur)


#gameApp.directive('uniqueOnServer', [

gameApp.directive "repeatPassword", ->
    return {
        require: "ngModel"
        link: (scope, elem, attrs, ctrl) ->
            otherInput = elem.inheritedData("$formController")[attrs.repeatPassword]

            ctrl.$parsers.push (value) ->
                if value == otherInput.$viewValue
                    ctrl.$setValidity("repeat", true)
                    return value
                ctrl.$setValidity("repeat", false)

            otherInput.$parsers.push (value) ->
                ctrl.$setValidity("repeat", value == ctrl.$viewValue)
                return value
    }

gameApp.directive 'unique', ($http, $compile) ->
    return {
        require: 'ngModel'
        restrict: 'A'
        link: (scope, element, attrs, ctrl) ->
            spinner = angular.element('<img src="/static/images/ajax-loader.gif" />')
            element.append(spinner)
            $compile(spinner)(scope)
            spinner.hide()

            #using push() here to run it as the last parser, after we are sure that other validators were run
            ctrl.$parsers.push (viewValue) ->
                spinner.show()
                #spinner.spin()
                if viewValue
                    $http.get('/api/account/exists/' + attrs.unique + '/' + viewValue + '/')
                        .success((data, status, headers, config) ->
                            spinner.hide()
                            if data.taken
                                ctrl.$setValidity('unique', false)
                            else
                                ctrl.$setValidity('unique', true)
                        )
                        .error((data, status, headers, config) ->
                            alert('could not connect to server')
                        )
                else
                    spinner.hide()
                return viewValue
    }


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

CreateAccountController = ($scope) ->
    $scope.newAccount =
        username: ''
        email: ''
        password: ''
        password2: ''
    $scope.passwordsMatch = null

    $scope.canSubmit = ->
        not ($scope.newAccount.username != '' and
             $scope.newAccount.email != '' and
             $scope.newAccount.password != '' and
             $scope.newAccount.password == $scope.newAccount.password2)
        
    
    #$scope.
    #$scope.checkPasswords = ->
    #    if $scope.form.password != $scope.form.password2
    #        $scope.passwordError = 



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


PlayController = ($scope) ->
    $scope.rows = (({
        color: 'white'
        unit: ''
        row: i
        col: j
    } for i in [0...28]) for j in [0...15])

    $scope.currentColor = '1E77B4'
    $scope.currentPlacement = 'unit'

    $scope.modifySquare = (square) ->
        if $scope.currentPlacement == 'unit'
            if square.unit == 'unit'
                square.unit = ''
            else
                square.unit = 'unit'
                square.color = $scope.currentColor

        else if $scope.currentPlacement == 'background'
            if square.color == $scope.currentColor
                square.color = 'white'
                square.unit = ''
            else
                square.color = $scope.currentColor

