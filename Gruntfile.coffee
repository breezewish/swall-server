module.exports = (grunt)->
    grunt.util.linefeed = '\n';
    grunt.initConfig
            pkg: grunt.file.readJSON('package.json')
            copy:
                project:
                    files: [{
                        expand: true
                        cwd: 'src/'
                        src: ['**/*.js', '*.js']
                        dest: 'build/'
                        ext: '.js'
                        extDot: 'last'
                    }]
            coffee:
                project:
                    files: [{
                        expand: true
                        cwd: 'src/'
                        src: ['**/*.coffee', '*.coffee']
                        dest: 'build/'
                        ext: '.js'
                        extDot: 'last'
                    }]
            watch:
                project:
                    files: ['src/**/*', 'config.cson']
                    tasks: ['copy', 'coffee', 'stylus', 'autoprefixer', 'uglify']
            autoprefixer:
                project:
                    files: [{
                            expand: true
                            cwd: 'src/'
                            src: ['**/*.css', '*.css']
                            dest: 'build/'
                            ext: '.css'
                            extDot: 'last'
                    }]
            stylus:
                theme:
                    expand: true
                    cwd: 'src/'
                    src: ['**/*.styl', '*.styl']
                    dest: 'src/'
                    ext: '.css'
                    extDot: 'last'
            uglify:
                my_target:
                    files:
                        'build/takeComment.min.js': ['build/takeComment.js', 'build/static/externaljs.js']

    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-autoprefixer'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.registerTask 'default', ['copy', 'coffee', 'autoprefixer', 'stylus', 'uglify', 'watch']

