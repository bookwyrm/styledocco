(function() {
  var file, files, findit, fs, generateFile, getResourcePath, getSections, jade, key, langs, link, menu, mkdirp, optimist, options, parser, parts, path, readme, sections, sources, templateFile, writeFile, writeStaticFile, _, _i, _len;

  fs = require('fs');

  path = require('path');

  findit = require('findit');

  jade = require('jade');

  mkdirp = require('mkdirp');

  optimist = require('optimist');

  langs = require('./languages');

  parser = require('./parser');

  _ = require('./utils');

  options = optimist.usage('Usage: $0 [options] [INPUT]').describe('name', 'Name of the project').alias('n', 'name').demand('name').describe('out', 'Output directory').alias('o', 'out')["default"]('out', 'docs').describe('tmpl', 'Custom template directory')["default"]('tmpl', path.resolve(__dirname, '../resources/')).describe('overwrite', 'Overwrite existing files in target dir').boolean('overwrite').describe('preprocessor', 'Custom preprocessor command').argv;

  options["in"] = options._[0] || './';

  getResourcePath = function(fileName) {
    if (path.existsSync(path.join(options.tmpl, fileName))) {
      return path.join(options.tmpl, fileName);
    } else {
      return path.resolve(__dirname, path.join('../resources', fileName));
    }
  };

  templateFile = getResourcePath('docs.jade');

  getSections = function(filename) {
    var data, lang;
    lang = langs.getLanguage(filename);
    data = fs.readFileSync(filename, 'utf-8');
    if (lang != null) {
      return parser.makeSections(parser.extractBlocks(lang, data));
    } else {
      return parser.makeSections([
        {
          docs: data,
          code: ''
        }
      ]);
    }
  };

  generateFile = function(source, data) {
    var dest, lang, render;
    if (source.match(/readme/i)) source = 'index.html';
    dest = _.makeDestination(source);
    data.project = {
      name: options.name,
      menu: menu,
      root: _.buildRootPath(source)
    };
    render = function(data) {
      var html, template;
      template = fs.readFileSync(templateFile, 'utf-8');
      html = jade.compile(template, {
        filename: templateFile
      })(data);
      console.log("styledocco: " + source + " -> " + (path.join(options.out, dest)));
      return writeFile(dest, html);
    };
    if (langs.isSupported(source)) {
      lang = langs.getLanguage(source);
      return lang.compile(source, options.preprocessor, function(err, css) {
        if (err != null) throw err;
        data.css = css;
        return render(data);
      });
    } else {
      data.css = '';
      return render(data);
    }
  };

  writeFile = function(dest, contents) {
    dest = path.join(options.out, dest);
    mkdirp.sync(path.dirname(dest));
    return fs.writeFileSync(dest, contents);
  };

  sources = findit.sync(options["in"]);

  files = sources.filter(function(source) {
    if (source.match(/(\/|^)\.[^\.]/)) return false;
    if (source.match(/(\/|^)_.*\.s[ac]ss$/)) return false;
    if (!langs.isSupported(source)) return false;
    if (!fs.statSync(source).isFile()) return false;
    return true;
  }).sort();

  menu = {};

  for (_i = 0, _len = files.length; _i < _len; _i++) {
    file = files[_i];
    link = {
      name: path.basename(file, path.extname(file)),
      href: _.makeDestination(file)
    };
    parts = file.split('/').splice(1);
    key = parts.length > 1 ? parts[0] : './';
    if (menu[key] != null) {
      menu[key].push(link);
    } else {
      menu[key] = [link];
    }
  }

  readme = _.findFile(options["in"], /^readme/i) || _.findFile(process.cwd(), /^readme/i) || _.findFile(options.tmpl, /^readme/i) || path.resolve(__dirname, '../resources/README.md');

  sections = getSections(readme);

  mkdirp.sync(options.out);

  generateFile(readme, {
    menu: menu,
    sections: sections,
    title: '',
    description: ''
  });

  files.forEach(function(file) {
    sections = getSections(file);
    return generateFile(file, {
      menu: menu,
      sections: sections,
      title: file,
      description: ''
    });
  });

  writeStaticFile = function(fileName) {
    var outPath;
    outPath = path.join(options.out, fileName);
    if (options.overwrite || !path.existsSync(outPath)) {
      fs.writeFileSync(outPath, fs.readFileSync(getResourcePath(fileName), 'utf-8'));
      return console.log("styledocco: writing " + outPath);
    }
  };

  writeStaticFile('docs.css');

  writeStaticFile('docs.js');

}).call(this);
