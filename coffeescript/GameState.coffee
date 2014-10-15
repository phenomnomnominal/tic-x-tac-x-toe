define ['jquery', 'GameStates'], ($, GameStates) ->
  $html = $ 'html'

  get = (state) ->
    $html.attr('class').split ' '

  set = (state) ->
    $html.addClass state

  unset = (state) ->
    $html.removeClass state

  reset = (state) ->
    for own name, state of GameStates
      $html.removeClass state

  { get, set, unset, reset }
