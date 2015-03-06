{CompositeDisposable} = require 'event-kit'

lessCompilerProcess = null
lessCompileView = null
subscriptions = null

module.exports =
  activate: (state) ->
    LessCompilerProcess = require './less-compiler-process'
    lessCompilerProcess = new LessCompilerProcess()
    lessCompilerProcess.initialize()

    subscriptions = new CompositeDisposable
    subscriptions.add lessCompilerProcess.showPanel () ->
      LessCompileView = require './less-compiler-view'
      lessCompileView = new LessCompileView()
      lessCompileView.showPanel()

    subscriptions.add lessCompilerProcess.hidePanel () ->
      lessCompileView.hidePanel()

    subscriptions.add lessCompilerProcess.addMessage (data) ->
      lessCompileView.addMessagePanel(data.icon, data.typeMessage, data.message)


  deactivate: ->
    lessCompileView?.destroy()
    lessCompileView = null

    lessCompilerProcess?.destroy()
    lessCompilerProcess = null
