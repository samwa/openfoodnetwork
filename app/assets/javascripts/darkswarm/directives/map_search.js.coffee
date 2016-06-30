Darkswarm.directive 'mapSearch', ($timeout) ->
  # Install a basic search field in a map
  restrict: 'E'
  require: '^googleMap'
  replace: true
  template: '<input id="pac-input" placeholder="' + t('location_placeholder') + '"></input>'
  scope: {}
  link: (scope, elem, attrs, ctrl) ->
    $timeout =>
      map = ctrl.getMap()

      searchBox = scope.createSearchBox map
      scope.respondToSearch map, searchBox
      scope.biasResults map, searchBox


    scope.createSearchBox = (map) ->
      input = document.getElementById("pac-input")
      map.controls[google.maps.ControlPosition.TOP_LEFT].push input
      return new google.maps.places.SearchBox(input)

    scope.respondToSearch = (map, searchBox) ->
      google.maps.event.addListener searchBox, "places_changed", ->
        places = searchBox.getPlaces()
        for place in places when place.geometry.viewport?
          map.fitBounds place.geometry.viewport

    # Bias the SearchBox results towards places that are within the bounds of the
    # current map's viewport.
    scope.biasResults = (map, searchBox) ->
      google.maps.event.addListener map, "bounds_changed", ->
        bounds = map.getBounds()
        searchBox.setBounds bounds
