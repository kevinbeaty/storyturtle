fs            = require 'fs'
package       = require './package'
{compile}     = require 'coffee-script'

# Built file header.
task 'build', 'rebuild the merged script for inclusion in the browser', ->
  header = """
    /**
     * #{package.name} v#{package.version}
     * #{package.homepage}
     *
     * Copyright 2012, #{package.author}
     * License: #{(license.type for license in package.licenses).join ' '}
     */
  """
  code = ''
  for name in ['config', 'feature', 'parser', 'storyturtle']
    src = ""+fs.readFileSync "src/#{name}.coffee"
    compiled = compile src, bare:true
    code += """ 
      require.#{name} = (function() {
        var exports = {};
        #{compiled}
        return exports;
      })();
    """
  code = """
    (function(root) {
      function require(path){ return require[/(\\w+)\\.?.*$/.exec(path)[1]]; }
      #{code}
    }(this));
  """
  unless process.env.MINIFY is 'false'
    {parser, uglify} = require 'uglify-js'
    code = uglify.gen_code uglify.ast_squeeze uglify.ast_mangle parser.parse code
  builddir = process.env.BUILDDIR or './build'
  buildfile = "#{builddir}/#{package.name}-#{package.version}.js"
  fs.writeFile buildfile, header + '\n' + code
