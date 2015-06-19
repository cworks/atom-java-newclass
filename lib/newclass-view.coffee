{$, $$, View, TextEditorView} = require 'atom-space-pen-views'
fs = require 'fs'
path = require 'path'
mkdirp = require 'mkdirp'
touch = require 'touch'

module.exports =
class NewclassView extends View
    PATH_SEPARATOR: ","
    newclassView: null

    # config options for this tool
    @config:
        createSrcMainJava:
            type: 'boolean'
            default: true
        createSrcMainTest:
            type: 'boolean'
            default: true
        unitTestOnEndsWithTest:
            type: 'boolean'
            default: true
        unitTestOnStartsWithTest:
            type: 'boolean'
            default: true
        createFileInstantly:
            type: 'boolean'
            default: true

    @activate: (state) ->
        @newclassView = new NewclassView(state.newclassViewState)

    @deactivate: ->
        @newclassView.detach()

    @content: (params) ->
        @div class: 'java-newclass', =>
            @p outlet:'message', class:'icon icon-file-add', "Enter the path for the new file/directory. Directories end with a '" + path.sep + "'."
            @subview 'miniEditor', new TextEditorView({mini:true})
            @ul class: 'list-group', outlet: 'directoryList'

    @detaching: false,

    initialize: (serializeState) ->
        atom.commands.add 'atom-workspace', 'newclass:toggle', => @toggle()
        @miniEditor.getModel().setPlaceholderText(path.join('path','to','file.txt'));
        atom.commands.add @element,
            'core:confirm': => @confirm()
            'core:cancel': => @detach()

    confirm: ->
        console.log('confirmed homes!')

    attach: ->
        @suggestPath()
        @previouslyFocusedElement = $(':focus')
        @panel = atom.workspace.addModalPanel(item: this)
        @miniEditor.on 'focusout', => @detach() unless @detaching
        @miniEditor.focus()

        consumeKeypress = (ev) => ev.preventDefault(); ev.stopPropagation()

        # populate directory listing live
        @miniEditor.getModel().onDidChange => @update()
        # consume keydown event from holding down the Tab key
        @miniEditor.on 'keydown', (ev) => if ev.keyCode is 9 then consumeKeypress ev
        # handle tab completion
        @keyUpListener = @miniEditor.on 'keyup', (ev) =>
            if ev.keyCode is 9
            else if ev.keyCode is 8
                                                
        console.log('attach')

    detach: ->
        return unless @hasParent()
        console.log('detach, release some resources dawg')

    toggle: ->
        if @hasParent()
            @detach()
        else
            @attach()
