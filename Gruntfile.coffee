module.exports = (grunt)->
	grunt.util.linefeed = '\n';
	grunt.initConfig(
		pkg: grunt.file.readJSON('package.json'),
		copy:
			project:
				files: [{
				expand: true,
				cwd: 'src/',
				src: ['**/*.js', '*.js'],
				dest: 'build/',
				ext: '.js',
				extDot: 'last'
				}]
		,
		coffee:
			project:
				files: [{
					expand: true,
					cwd: 'src/',
					src: ['**/*.coffee', '*.coffee'],
					dest: 'build/',
					ext: '.js',
					extDot: 'last'
				}]
		,
		watch:
			project:
				files: ['src/**/*', 'config.cson'],
				tasks: ['copy', 'coffee', 'autoprefixer']
		autoprefixer:
			project:
				files: [{
					expand: true,
					cwd: 'src/',
					src: ['**/*.css', '*.css'],
					dest: 'build/',
					ext: '.css',
					extDot: 'last'
				}]
	)

	grunt.loadNpmTasks 'grunt-contrib-copy'
	grunt.loadNpmTasks 'grunt-contrib-coffee'
	grunt.loadNpmTasks 'grunt-contrib-watch'
	grunt.loadNpmTasks 'grunt-autoprefixer'
	grunt.registerTask 'default', ['copy', 'coffee', 'autoprefixer', 'watch']

