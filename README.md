```
 _______ __         __        _____
|     __|  |_.--.--|  |-----.|     \-----.----.----.-----.
|__     |   _|  |  |  |  -__||  --  | _  |  __|  __|  _  |
|_______|____|___  |__|_____||_____/_____|____|____|_____|
             |_____|
```

StyleDocco generates documentation and style guide documents from your stylesheets.

Stylesheet comments will be parsed through [Markdown](http://en.wikipedia.org/wiki/Markdown) and displayed in a generated HTML document. You can write code examples prefixed with 4 spaces or between [code fences](http://github.github.com/github-flavored-markdown/) (<code>```</code>) in your comments, and StyleDocco both renders the HTML and shows the code example.

An important philosophy of StyleDocco is to introduce as little custom syntax as possible, maintaining the stylesheet comments readable and useful even without StyleDocco.


Suggestions, feature requests and bug reports are very welcome, either at [GitHub](https://github.com/jacobrask/styledocco/issues) or on Twitter ([@jacobrask](https://twitter.com/jacobrask)).


## Installation

StyleDocco requires [Node.js](http://nodejs.org). After installing Node.js, run

    npm install -g styledocco

or check out this repository.

StyleDocco is free software, released under the [MIT license](https://raw.github.com/jacobrask/styledocco/master/LICENSE).


## Usage

`styledocco [options] [INPUT]`

StyleDocco will automatically compile any SASS, SCSS, Less or Stylus files before they are applied to the page. You can also enter a custom preprocessor command if you want to pass custom parameters to the preprocessor.

If your project includes a `README` file, it will be used as the base for an `index.html`. StyleDocco will also add some default styles to your documentation, but they are easy to modify to make it fit with your project.

### Options

 * `--name`, `-n`      Name of the project *(required)*
 * `--out`, `-o`       Output directory *(default: "docs")*
 * `--resources`, `-s` Directory with files to customize the documentation output (docs.jade, docs.css and docs.js). StyleDocco defaults will be used for any required file not found in this directory. *(optional)*
 * `--preprocessor`    Custom preprocessor command. *(optional)* (ex: `--preprocessor "scss --load-path=deps/"`)
 * `--include`         Prepend specified CSS file to the documentation stylesheet. *(optional)* (ex: `--include mysite.css`)
 * `--verbose`         Show log messages when generating the documentation. *(default: false)*
 *                     Directory containing the stylesheets to document.

### Usage examples

Generate documentation for *My Project* in the `docs` folder, from the files in the `css` directory.

`styledocco -n "My Project" css`

Generate documentation for *My Project* in the `mydocs` folder, from source files in the `styles` folder. Use the Less binary in `~/bin/lessc`.

`styledocco -n "My Project" -o mydocs -s mydocs --preprocessor "~/bin/lessc" styles`


## Syntax examples

    /* Provides extra visual weight and identifies the primary action in a set of buttons.

        <button class="btn primary">Primary</button> */
    .btn.primary {
        background: blue;
        color: white;
    }

Would display the description, a rendered button as well as the example HTML code. The CSS will be included in the `style` element of the document.

See the `examples` folder for more in-depth examples.

### Tips and tricks

 * Put some whitespace before a comment block to exclude it from the documentation.
 * Horizontal rules (`-----`, `* * *`, etc) will automatically create a new section in the documentation.

## Acknowledgements

A lot of the heavy lifting in StyleDocco is done by the excellent [Marked](https://github.com/chjj/marked) module by Christopher Jeffrey. The original [Docco](https://github.com/jashkenas/docco) by Jeremy Ashkenas and [Knyle Style Sheets](https://github.com/kneath/kss) have also been sources of inspiration for StyleDocco.
