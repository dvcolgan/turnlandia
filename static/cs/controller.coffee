GameController = ($scope, Phone) ->
    $scope.phones = Phone.query()
    $scope.orderProp = 'age'

PhoneDetailCtrl = ($scope, $routeParams, Phone) ->
    $scope.phone = Phone.get {phoneId: $routeParams.phoneId}, (phone) ->
        $scope.mainImageUrl = phone.images[0]

    $scope.setImage = (imageUrl) ->
        $scope.mainImageUrl = imageUrl

