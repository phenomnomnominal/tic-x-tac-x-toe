define ['jquery'], ($) ->
  $window = $ window
  $html = $ 'html'

  resize = ->
    width = $window.width()
    if width < 640
      $html.removeClass 'tablet desktop'
      $html.addClass 'mobile'
    else if width < 1024
      $html.removeClass 'mobile desktop'
      $html.addClass 'tablet'
    else
      $html.removeClass 'mobile tablet'
      $html.addClass 'desktop'

  $ ->
    $window.on 'resize', resize
    resize()
