module.exports = (grunt)->
    grunt.util.linefeed = '\n';
    grunt.initConfig
            pkg: grunt.file.readJSON('package.json')
            copy:
                project:
                    files: [{
                        expand: true
                        cwd: 'src/'
                        src: ['**/*.js']
                        dest: 'build/'
                        ext: '.js'
                        extDot: 'last'
                    }]
            coffee:
                project:
                    files: [{
                        expand: true
                        cwd: 'src/'
                        src: ['**/*.coffee']
                        dest: 'build/'
                        ext: '.js'
                        extDot: 'last'
                    }]
            cson:
                project:
                    files: [{
                        expand: true
                        cwd: 'src/'
                        src: ['**/*.cson']
                        dest: 'build/'
                        ext: '.json'
                        extDot: 'last'
                    }]
            watch:
                project:
                    files: ['src/**/*']
                    tasks: ['copy', 'coffee', 'cson', 'stylus', 'autoprefixer', 'uglify']
            stylus:
                project:
                    files: [{
                        expand: true
                        cwd: 'src/'
                        src: ['**/*.styl']
                        dest: 'build/'
                        ext: '.css'
                        extDot: 'last'
                    }]
            autoprefixer:
                project:
                    files: [{
                            expand: true
                            cwd: 'build/'
                            src: ['**/*.css']
                            dest: 'build/'
                            ext: '.css'
                            extDot: 'last'
                    }]
            uglify:
                project:
                    src: [
                        'build/public/js/jshashtable.js'
                        'build/public/js/jquery.numberformatter.js'
                        'build/public/js/jquery.transform.js'
                        'build/public/js/jquery.flapper.js'
                        'build/public/js/takeComment.js'
                    ]
                    dest: 'build/public/js/takeComment.min.js'

    grunt.loadNpmTasks 'grunt-contrib-copy'
    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-autoprefixer'
    grunt.loadNpmTasks 'grunt-contrib-stylus'
    grunt.loadNpmTasks 'grunt-contrib-uglify'
    grunt.loadNpmTasks 'grunt-cson'

    grunt.registerTask 'default', ['copy', 'coffee', 'cson', 'stylus', 'autoprefixer', 'uglify', 'watch']

