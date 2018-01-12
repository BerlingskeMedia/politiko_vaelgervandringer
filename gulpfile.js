/*jslint indent:2, node:true, sloppy:true*/
var
  gulp = require('gulp'),
  del = require('del'),
  coffee = require('gulp-coffee'),
  ngannotate = require('gulp-ng-annotate'),
  rename = require("gulp-rename"),
  uglify = require('gulp-uglify'),
  sass = require('gulp-sass'),
  autoprefixer = require('gulp-autoprefixer'),
  minifycss = require('gulp-minify-css'),
  concat = require('gulp-concat'),
  imagemin = require('gulp-imagemin'),
  header = require('gulp-header'),
  cleanhtml = require('gulp-cleanhtml'),
  changed = require('gulp-changed'),
  googlecdn = require('gulp-google-cdn'),
  gulpif = require('gulp-if'),
  jade = require('gulp-jade'),
  connect = require('gulp-connect'),
  plumber = require('gulp-plumber'),
  sourcemaps = require('gulp-sourcemaps'),

  pkg = require('./package.json');

var banner = [
  '/**',
  ' ** <%= pkg.name %> - <%= pkg.description %>',
  ' ** @author <%= pkg.author %>',
  ' ** @version v<%= pkg.version %>',
  ' **/',
  ''
].join('\n');

var build = false;
var dest = 'app/upload/tcarlsen/voter-transitions';
/* Scripts */
gulp.task('scripts', function () {
  return gulp.src('src/**/*.coffee')
    .pipe(plumber())
    .pipe(gulpif(!build, changed(dest)))
    .pipe(gulpif(!build, sourcemaps.init()))
    .pipe(concat('scripts.min.js'))
    .pipe(coffee())
    .pipe(ngannotate())
    .pipe(uglify())
    .pipe(gulpif(!build, sourcemaps.write()))
    .pipe(gulpif(build, header(banner, {pkg: pkg})))
    .pipe(gulp.dest(dest))
    .pipe(connect.reload());
});
/* Styles */
gulp.task('styles', function () {
  return gulp.src('src/**/*.scss')
    .pipe(plumber())
    .pipe(gulpif(!build, changed(dest)))
    .pipe(gulpif(!build, sourcemaps.init()))
    .pipe(concat('styles.min.css'))
    .pipe(sass())
    .pipe(autoprefixer())
    .pipe(minifycss())
    .pipe(gulpif(!build, sourcemaps.write()))
    .pipe(gulpif(build, header(banner, {pkg: pkg})))
    .pipe(gulp.dest(dest))
    .pipe(connect.reload());
});
/* Dom elements */
gulp.task('dom', function () {
  return gulp.src('src/**/*.jade')
    .pipe(plumber())
    .pipe(gulpif(!build, changed(dest)))
    .pipe(jade({pretty: true}))
    .pipe(gulpif(build, cleanhtml()))
    .pipe(rename({dirname: '/partials'}))
    .pipe(gulp.dest(dest))
    .pipe(connect.reload());
});
/* Images */
gulp.task('images', function () {
  return gulp.src('src/images/**')
    .pipe(plumber())
    .pipe(gulpif(!build, changed('app/img')))
    // imagemin is not breaking
    // .pipe(imagemin())
    .pipe(gulp.dest(dest + '/img'))
    .pipe(connect.reload());
});
/* JSON data files */
gulp.task('datafiles', function () {
  return gulp.src('datafiles/*.json')
    .pipe(plumber())
    .pipe(gulp.dest(dest))
    .pipe(connect.reload());
});
/* Moving the local files to app */
gulp.task('copy_app_skeleton', function () {
  gulp.src('app_skeleton/**/*')
  .pipe(gulp.dest('app'));
});
/* Index.html */
gulp.task('html', function () {
  return gulp.src('src/**/*.html')
    .pipe(plumber())
    // .pipe(gulpif(!build, changed('src/**/*.html')))
    .pipe(gulpif(!build, gulp.dest('app/')))
    .pipe(connect.reload());
});
/* Watch task */
gulp.task('watch', function () {
  gulp.watch('src/**/*.coffee', ['scripts']);
  gulp.watch('src/**/*.scss', ['styles']);
  gulp.watch('src/**/*.jade', ['dom']);
  gulp.watch('src/images/**', ['images']);
});
/* Server */
gulp.task('connect', function () {
  connect.server({
    root: 'app',
    port: 9000,
    livereload: true
  });
});
/* CORS Proxy */
gulp.task('corsproxy', function () {
  require('corsproxy/bin/corsproxy');
});
/* Build task */
gulp.task('build', function () {
  if (process.argv.indexOf('--production') > -1){
    build = true;
    dest = 'build';
    del(dest);
    console.log('Building into ./' + dest);
    gulp.start('scripts', 'styles', 'dom', 'images', 'datafiles');
  } else {
    build = false;
    dest = 'app/upload/tcarlsen/voter-transitions';
    console.log('Building into ./' + dest);
    gulp.start('scripts', 'styles', 'dom', 'images', 'datafiles', 'copy_app_skeleton', 'html');
  }
});

gulp.task('serve', ['corsproxy', 'connect']);

/* Default task */
gulp.task('default', ['corsproxy', 'connect', 'scripts', 'styles', 'dom', 'images', 'datafiles', 'copy_app_skeleton', 'html', 'watch']);
