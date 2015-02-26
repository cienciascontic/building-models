var gulp        = require('gulp');
var config      = require('../config').jsx;
var react = require('gulp-react');
 
gulp.task('jsx', function() {
  return gulp.src(config.src)
    .pipe(react())
    .pipe(gulp.dest(config.dest));
});