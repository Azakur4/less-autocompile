{View, $, $$} = require 'atom-space-pen-views'

module.exports =
class LessCompilerView extends View
  @content: ->
    @div class: 'less-autocompile tool-panel panel-bottom hide', =>
      @div class: "inset-panel", =>
        @div class: "panel-heading no-border", =>
          @span class: 'inline-block pull-right loading loading-spinner-tiny hide'
          @span 'LESS AutoCompile'
        @div class: "panel-body padded hide"

  initialize: ->
    @timeout = null

    @panelHeading = @find('.panel-heading')
    @panelBody = @find('.panel-body')
    @panelLoading = @find('.loading')

    @panel = atom.workspace.addBottomPanel item: this

  # Tear down any state and detach
  destroy: ->
    @panel?.destroy()

  addMessagePanel: (icon, typeMessage, message) ->
    @panelHeading.removeClass 'no-border'

    @panelBody.removeClass('hide').append $$ ->
      @p =>
        @span class: "icon #{icon} text-#{typeMessage}", message

  showPanel: ->
    clearTimeout @timeout

    @panelHeading.addClass 'no-border'
    @panelBody.addClass('hide').empty()
    @panelLoading.removeClass 'hide'

    @removeClass 'hide'

  hidePanel: ->
    @panelLoading.addClass 'hide'

    @timeout = setTimeout =>
      @addClass 'hide'
      @panel?.destroy()
    , 3000
