gulp        = require 'gulp'
runSequence = require 'run-sequence'

sourcemaps  = require 'gulp-sourcemaps'
coffee      = require 'gulp-coffee'

sass        = require 'gulp-sass'
prefix      = require 'gulp-autoprefixer'
cssmin      = require 'gulp-cssmin'

rjs         = require 'requirejs'

paths =
  coffee: './coffeescript/**/*.coffee'
  sass: './sass/**/*.scss'

gulp.task 'default', (reportTaskDone) ->
  gulp.watch paths.coffee, ['build-scripts']
  gulp.watch paths.sass, ['build-styles']

  runSequence ['build-scripts', 'build-styles'], reportTaskDone

gulp.task 'coffee', ->
  gulp.src paths.coffee
    .pipe sourcemaps.init()
    .pipe coffee()
    .pipe sourcemaps.write '../maps/'
    .pipe gulp.dest('./javascript/')

gulp.task 'build-scripts', (reportTaskDone) ->
  runSequence 'coffee', 'requirejs', reportTaskDone

gulp.task 'build-styles', ->
  gulp.src paths.sass
    .pipe sass()
    .pipe prefix '> 1%'
    .pipe cssmin keepSpecialComments: 0
    .pipe gulp.dest('./')

gulp.task 'requirejs', (reportTaskDone) ->
  requirejsOptions =
    baseUrl: './javascript'
    optimize: 'uglify2'
    preserveLicenseComments: no
    generateSourceMaps: yes
    name: 'tictactoe'
    out: './tictactoe-min.js'
    paths:
      jquery: '../bower_components/jquery/dist/jquery'
      three: '../bower_components/threejs/build/three'
    shim:
      three:
        exports: 'THREE'

  rjs.optimize requirejsOptions
  reportTaskDone()
