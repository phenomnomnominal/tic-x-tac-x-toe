define ['jquery', 'three', 'CellStates', 'orbit'], ($, Three, CellStates) ->
  $window = $ window
  $canvas = $ 'canvas'
  $board = $ '#Board3D'

  CUBE_SIZE = 25
  SCENE = null
  CAMERA = null
  CONTROLS = null
  BOARD = null
  GEOMETRY = null
  MATERIALS = {}
  RENDERER = null

  xSpeed = null
  ySpeed = null
  noWebGL = not window.WebGLRenderingContext

  resize = ->
    if $board.is ':visible'
      CAMERA.aspect = $board.width() / $board.height()
      CAMERA.updateProjectionMatrix()
      RENDERER.setSize $board.width(), $board.height()
      $canvas.width $board.width()
      $canvas.height $board.height()

  update = (cell, state) ->
    if state
      BOARD.children[cell].material = MATERIALS[state]
    else
      BOARD.children[cell].material = MATERIALS.wire

  addCubes = ->
    for n in [4**3 - 1..0]
      cube = new Three.Mesh(GEOMETRY, MATERIALS.wire)
      cube.position.x = CUBE_SIZE * (-1.5 + Math.floor(n / 16))
      cube.position.y = CUBE_SIZE * (-1.5 + Math.floor((n % 16) / 4))
      cube.position.z = CUBE_SIZE * (-1.5 + (n % 4))
      BOARD.add cube

  resetBoard = ->
    xSpeed = 0
    ySpeed = 0
    BOARD.rotation.z = Math.PI / 2
    BOARD.rotation.x = Math.PI / 6
    BOARD.rotation.y = -Math.PI / 4
    CONTROLS.reset()

  initialiseBoard = ->
    SCENE = new Three.Scene()

    BOARD = new Three.Object3D()
    SCENE.add BOARD

    light1 = new Three.PointLight(0xFFEEAA, 0.5)
    light1.position = new Three.Vector3(-1000, 1000, -1000)
    SCENE.add light1

    light2 = new Three.PointLight(0xFFEEAA, 0.5)
    light2.position = new Three.Vector3(1000, 1000, 1000)
    SCENE.add light2

    GEOMETRY = new Three.BoxGeometry(CUBE_SIZE, CUBE_SIZE, CUBE_SIZE)
    MATERIALS.wire = new Three.MeshBasicMaterial(color: 0x888888, opacity : 0.5, depthTest : no, wireframe: yes, transparent: yes)
    MATERIALS[CellStates.PLAYER_MOVE] = new Three.MeshBasicMaterial(color: 0xFF0000, opacity : 0.75, depthTest : no, transparent: yes)
    MATERIALS[CellStates.COMPUTER_MOVE] = new Three.MeshBasicMaterial(color: 0x0000FF, opacity : 0.75, depthTest : no, transparent: yes)
    MATERIALS[CellStates.POSSIBLE_MOVE] = new Three.MeshBasicMaterial(color: 0xFFAAAA, opacity : 0.75, depthTest : no, transparent: yes)
    MATERIALS[CellStates.COMPUTER_LAST_MOVE] = new Three.MeshBasicMaterial(color: 0xAAAAFF, opacity : 0.75, depthTest : no, transparent: yes)
    MATERIALS[CellStates.WIN] = new Three.MeshBasicMaterial(color: 0x00FF00, opacity : 0.75, depthTest : no, transparent: yes)

    if noWebGL
      RENDERER = new Three.CanvasRenderer(canvas: $canvas.get(0), antialias: yes, alpha: yes)
    else
      RENDERER = new Three.WebGLRenderer(canvas: $canvas.get(0), antialias: yes, alpha: yes)

    RENDERER.setSize $board.width(), $window.height()
    RENDERER.setClearColor 0xFFFFFF, 1

    CAMERA = new Three.PerspectiveCamera(45, $board.width() / $board.height(), 0.1, 10000)
    CAMERA.position.z = 300
    SCENE.add CAMERA

    CONTROLS = new Three.OrbitControls(CAMERA, $canvas.get(0))
    CONTROLS.noPan = true
    CONTROLS.noZoom = true

    addCubes()
    resetBoard()

  animate = ->
    requestAnimationFrame animate
    render()

  render = ->
    BOARD.rotation.x += 0.01 * xSpeed
    if xSpeed > 0 then xSpeed -= 0.01
    if xSpeed < 0 then xSpeed += 0.01
    BOARD.rotation.y += 0.01 * ySpeed
    if ySpeed > 0 then ySpeed -= 0.01
    if ySpeed < 0 then ySpeed += 0.01
    RENDERER.render SCENE, CAMERA

  rotate = (e) ->
    switch e.keyCode
      when 37 then ySpeed -= 0.5
      when 38 then xSpeed -= 0.5
      when 39 then ySpeed += 0.5
      when 40 then xSpeed += 0.5

  $ ->
    $window.on 'resize', resize
    $window.on 'keydown', rotate
    initialiseBoard()
    resize()
    animate()

  { update, noWebGL }
