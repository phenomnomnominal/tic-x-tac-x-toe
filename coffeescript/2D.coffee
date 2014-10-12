define ['jquery'], ($) ->
  $window = $ window
  $td = $ 'td'

  $board = $ '#Board2D'

  resize = ->
    if $board.is ':visible'
      $td.height $td.outerWidth()

  update = (cell, state) ->
    $cell = $("[data-move='#{cell}']")
    $cell.removeClass()
    if state
      $cell.addClass state

  $ ->
    $window.on 'resize', resize
    resize()

  { update }
