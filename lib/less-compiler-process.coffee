{Emitter} = require 'event-kit'

module.exports =
class LessCompilerProcess
  initialize: ->
    @inProgress = false
    @isPanelShow = false

    @emitter = new Emitter

    atom.commands.add 'atom-workspace', 'core:save': (e) =>
      if !@inProgress
        @compile atom.workspace.getActiveTextEditor()

  # Tear down any state and detach
  destroy: ->
    @detach()

  # Eventos
  showPanel: (callback) ->
    @emitter.on 'showPanel', callback

  hidePanel: (callback) ->
    @emitter.on 'hidePanel', callback

  addMessage: (callback) ->
    @emitter.on 'addMessage', callback

  compile: (editor) ->
    path = require 'path'

    if editor?
      filePath = editor.getUri()
      fileExt = path.extname filePath

      if fileExt == '.less'
        @compileLess filePath

  getParams: (filePath, callback) ->
    fs = require 'fs'
    path = require 'path'
    readline = require 'readline'

    params =
      file: filePath
      compress: false
      main: false
      out: false

    parse = (firstLine) =>
      firstLine.split(',').forEach (item) ->
        i = item.indexOf ':'

        if i < 0
          return

        key = item.substr(0, i).trim()
        match = /^\s*\/\/\s*(.+)/.exec(key);

        if match
          key = match[1]

        value = item.substr(i + 1).trim()

        params[key] = value

      if params.main isnt false
        params.main.split('|').forEach (item) =>
          @getParams path.resolve(path.dirname(filePath), item), callback
      else
        callback params

    if !fs.existsSync filePath
      @emitter.emit 'showPanel', {}
      @emitter.emit 'addMessage', {icon: '', typeMessage: 'error', message: "main: #{filePath} not exist"}
      @emitter.emit 'hidePanel', {}

      @inProgress = false
      return null

    rl = readline.createInterface
      input: fs.createReadStream filePath
      output: process.stdout
      terminal: false

    firstLine = null

    rl.on 'line', (line) ->
      if firstLine is null
        firstLine = line
        parse firstLine

  writeFile: (contents, newFile, newPath, callback) ->
    fs = require 'fs'
    mkdirp = require 'mkdirp'

    mkdirp newPath, (error) ->
      fs.writeFile newFile, contents, callback

  compileLess: (filePath) ->
    fs = require 'fs'
    less = require 'less'
    path = require 'path'

    compile = (params) =>
      if params.out is false
        return

      @inProgress = true

      if !@isPanelShow
        @isPanelShow = true
        @emitter.emit 'showPanel', {}

      parser = new less.Parser
        paths: [path.dirname path.resolve(params.file)]
        filename: path.basename params.file

      fs.readFile params.file, (error, data) =>
        parser.parse data.toString(), (error, tree) =>
          @emitter.emit 'addMessage', {icon: 'icon-file-text', typeMessage: 'info', message: filePath}

          try
            if error
              @inProgress = false
              @emitter.emit 'addMessage', {icon: '', typeMessage: 'error', message: "#{error.message} - index: #{error.index}, line: #{error.line}, file: #{error.filename}"}
            else
              css = tree.toCSS
                compress: params.compress

              newFile = path.resolve(path.dirname(params.file), params.out)
              newPath = path.dirname newFile

              @writeFile css, newFile, newPath, =>
                @inProgress = false
                @emitter.emit 'addMessage', {icon: 'icon-file-symlink-file', typeMessage: 'success', message: newFile}
          catch e
            @inProgress = false
            @emitter.emit 'addMessage', {icon: '', typeMessage: 'error', message: "#{e.message} - index: #{e.index}, line: #{e.line}, file: #{e.filename}"}

          if @isPanelShow
            @isPanelShow = false
            @emitter.emit 'hidePanel', {}

    @getParams filePath, (params) ->
      if params isnt null
        compile params
