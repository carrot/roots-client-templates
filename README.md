Roots Client Templates
======================

[![npm](http://img.shields.io/npm/v/client-templates.svg?style=flat)](https://badge.fury.io/js/client-templates) [![tests](http://img.shields.io/travis/carrot/roots-client-templates/master.svg?style=flat)](https://travis-ci.org/carrot/roots-client-templates) [![coverage](http://img.shields.io/coveralls/carrot/roots-client-templates.svg?style=flat)](https://coveralls.io/r/carrot/roots-client-templates) [![dependencies](http://img.shields.io/gemnasium/carrot/roots-client-templates.svg?style=flat)](https://gemnasium.com/carrot/roots-client-templates)

Roots client templates allow templates that compile to html to be precompiled into javascript functions to be used on the client side.

> **Note:** This project is in early development, and versioning is a little different. [Read this](http://markup.im/#q4_cRZ1Q) for more details.

### Installation

- make sure you are in your roots project directory
- `npm install client-templates --save`
- modify your `app.coffee` file to include the extension, as such

  ```coffee
  ClientTemplates = require('client-templates')

  module.exports =
    extensions: [ClientTemplates(
      base: "templates/", # required
      pattern: "*.jade", # defaults to **
      out: "js/templates.js" # defaults to js/templates.js
    )]

    # everything else...
  ```

### Usage

This extension uses [accord](https://github.com/jenius/accord) for compilation and includes support for [these languages](https://github.com/jenius/accord#languages-supporting-precompile). If you try to use it with an unsupported language, you will get an error and the compile will not complete.

The example provided in the installation section is the minimum required to get things going. In this case it will look for a folder called `templates` at the root, and precompile any `.jade` file in that folder, outputting all the templates to `js/templates.js` in your public folder. Now let's look over the full range of available options.

This extension also exposes a view helper function (`client_templates`) that when called will render the script into your templates automatically. Here's how it could be used in jade:

```jade
p here's my great view
!= client_templates() //- outputs <script src='js/templates.js'></script>
```

### Options

##### name
This will be the name your templates are exposed as. If you are using commonjs or amd, it will be the name of the module, if neither, it will be attached to `window` as this name. Default is `templates`.

##### path
A [minimatch](https://github.com/isaacs/minimatch)-compatible string pointing to one or more files to be precompiled.

##### out
Where you want to output your templates to in your `public` folder (or whatever you have set `output` to in the roots settings). Default is `js/templates.js`

##### extract
If `false` in addition to being precompiled, templates are compiled normally as html files. Default is `true`.

##### concat
If `true`, the precompiled templates are concatenated into a single file with helpers at the top, wrapped with a [umd] wrapper, and each template is exported on an object with they key being the name of the file (minus extension). If false, each template is exported with a umd wrapper as it's own file as expected, and the helper functions (required to render templates) are exported alone in a file with the name decided by what you pass as `out`. Default is `true`.

### License & Contributing

- Details on the license [can be found here](LICENSE.md)
- Details on running tests and contributing [can be found here](contributing.md)
