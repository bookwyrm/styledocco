fs   = require 'fs'
path = require 'path'
findit   = require 'findit'
jade     = require 'jade'
mkdirp   = require 'mkdirp'
optimist = require 'optimist'
langs  = require './languages'
parser = require './parser'
_      = require './utils'

options = optimist
  .usage('Usage: $0 [options] [INPUT]')
  .describe('name', 'Name of the project').alias('n', 'name').demand('name')
  .describe('out', 'Output directory').alias('o', 'out').default('out', 'docs')
  .describe('tmpl', 'Custom template directory').default('tmpl', path.resolve(__dirname, '../resources/'))
  .describe('overwrite', 'Overwrite existing files in target dir').boolean('overwrite')
  .describe('preprocessor', 'Custom preprocessor command')
  .argv
options.in = options._[0] or './'

getResourcePath = (fileName) ->
  if path.existsSync path.join options.tmpl, fileName
    path.join options.tmpl, fileName
  else
    path.resolve __dirname, path.join '../resources', fileName

templateFile = getResourcePath 'docs.jade'

# Get sections of matching doc/code blocks.
getSections = (filename) ->
  lang = langs.getLanguage filename
  data = fs.readFileSync filename, 'utf-8'
  if lang?
    parser.makeSections parser.extractBlocks lang, data
  else
    parser.makeSections [{ docs: data, code: '' }]

# Generate the HTML document and write to file.
generateFile = (source, data) ->
  source = 'index.html' if source.match /readme/i
  dest = _.makeDestination source
  data.project = {
    name: options.name
    menu
    root: _.buildRootPath source
  }
  render = (data) ->
    template = fs.readFileSync templateFile, 'utf-8'
    html = jade.compile(template, filename: templateFile)(data)
    console.log "styledocco: #{source} -> #{path.join options.out, dest}"
    writeFile dest, html
  if langs.isSupported source
    # Run source through suitable CSS preprocessor.
    lang = langs.getLanguage source
    lang.compile source, options.preprocessor, (err, css) ->
      throw err if err?
      data.css = css
      render data
  else
    data.css = ''
    render data

# Write a file to the output dir.
writeFile = (dest, contents) ->
  dest = path.join options.out, dest
  mkdirp.sync path.dirname dest
  fs.writeFileSync dest, contents

# Get all files from input (directory).
sources = findit.sync options.in

# Filter out unsupported file types.
files = sources.
  filter((source) ->
    return false if source.match /(\/|^)\.[^\.]/ # No hidden files.
    return false if source.match /(\/|^)_.*\.s[ac]ss$/ # No SASS partials.
    return false unless langs.isSupported source # Only supported file types.
    return false unless fs.statSync(source).isFile() # Files only.
    return true
  ).sort()

# Make `link` objects for the menu.
menu = {}
for file in files
  link =
    name: path.basename(file, path.extname file)
    href: _.makeDestination file
  parts = file.split('/').splice(1)
  key = if parts.length > 1 then parts[0] else './'
  if menu[key]?
    menu[key].push link
  else
    menu[key] = [ link ]

# Look for a README file and generate an index.html.
readme = _.findFile(options.in, /^readme/i) \
      or _.findFile(process.cwd(), /^readme/i) \
      or _.findFile(options.tmpl, /^readme/i) \
      or path.resolve(__dirname, '../resources/README.md')

sections = getSections readme

# Make sure that specified output directory exists.
mkdirp.sync options.out

generateFile readme, { menu, sections, title: '', description: '' }

# Generate documentation files.
files.forEach (file) ->
  sections = getSections file
  generateFile file, { menu, sections, title: file, description: '' }

# Write static files to output directory.
writeStaticFile = (fileName) ->
  outPath = path.join options.out, fileName
  if options.overwrite or not path.existsSync outPath
    fs.writeFileSync outPath, fs.readFileSync getResourcePath(fileName), 'utf-8'
    console.log "styledocco: writing #{outPath}"

writeStaticFile 'docs.css'
writeStaticFile 'docs.js'
