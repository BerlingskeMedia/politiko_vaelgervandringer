angular.module "transitionMenuDirective", []
  .directive "transitionMenu", ($document) ->
    restrict: "E"
    templateUrl: "/upload/tcarlsen/voter-transitions/partials/transition-menu.html"
    link: (scope, element, attr) ->
      startTop = 0
      startLeft = 0
      top = 0
      left = 0

      drag = (event) ->
        event.preventDefault()

        startTop = event.pageY - top
        startLeft = event.pageX - left

        $document.on "mousemove", mousemove
        $document.on "touchmove", mousemove
        $document.on "mouseup", mouseup
        $document.on "touchend", mouseup

      mousemove = (event) ->
        top = event.pageY - startTop
        left = event.pageX - startLeft

        element.css
          marginLeft: 0
          opacity: 0.7
          MsTransform: "translate3d(#{left}px, #{top}px, 0)"
          MozTransform: "translate3d(#{left}px, #{top}px, 0)"
          WebkitTransform: "translate3d(#{left}px, #{top}px, 0)"
          transform: "translate3d(#{left}px, #{top}px, 0)"

      mouseup = ->
        element.css "opacity", "1"

        $document.off "mousemove", mousemove
        $document.off "touchmove", mousemove
        $document.off "mouseup", mouseup
        $document.off "touchend", mouseup

      element.find("menu-helper").on "mousedown", drag
      element.find("menu-helper").on "touchstart", drag
