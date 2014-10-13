angular.module "voterTransitionsDirective", []
  .directive "voterTransitions", ($http) ->
    restrict: "E"
    templateUrl: "/upload/tcarlsen/voter-transitions/partials/voter-transitions.html"
    link: (scope, element, attr) ->
      parties = []

      scope.changeParti = (direction) ->
        currentIndex = parties.indexOf(scope.parti)
        newIndex = currentIndex + 1 if direction is 'next'
        newIndex = currentIndex - 1 if direction is 'prev'
        newIndex = 0 if newIndex is parties.length
        newIndex = parties.length - 1 if newIndex < 0

        scope.parti = parties[newIndex]

      $http.get "/upload/tcarlsen/voter-transitions/data.json"
        .then (response) ->
          scope.transitions = response.data
          scope.parti = "v"

          for parti, value of scope.transitions
            if parti isnt "andre" and parti isnt "blå_blok" and parti isnt "rød_blok" and parti isnt ""
              parties.push parti

      if Modernizr.touch
        swipeGuide = element.find("swipe-guide")

        swipeGuide
          .addClass "active"
          .on "touchstart", -> swipeGuide.removeClass "active"
