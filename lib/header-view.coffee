{View} = require 'atom-space-pen-views'

# The header view for the results view, allowing you to add/change connections or change the DB
module.exports =
class DataAtomView extends View
  @content: ->
    @header class: 'header results-header', =>
      @span 'Results for connection:', class: 'heading-title', outlet: 'title'
      @select outlet: 'connectionList', class: '', change: 'onConnectionSelected', =>
        @option 'Select connection...', value: '0', disabled: true
      @span 'Database:', class: 'db-label'
      @select outlet: 'databaseList', class: 'db-select', change: 'onDatabaseSelected', =>
        @option 'Select database...', value: '', disabled: true
      @button 'New Connection...', class: 'btn btn-default', click: 'onNewConnection', outlet: 'connectionBtn'
      @button 'Disconnect', class: 'btn btn-default', click: 'onDisconnect', outlet: 'disconnectBtn'
      @span
        class: 'heading-close icon-remove-close pull-right'
        outlet: 'closeButton'
        click: 'close'
      @div class: 'query-string', =>
        @span 'Query to execute:'
        @input outlet:'queryInput'
        @button 'Execute Query', class: 'btn btn-default', click: 'onExecuteQuery', outlet: 'executeBtn'
      @div class: 'file-executed', outlet: 'fileExecuted', =>
        @span 'Results of ?'

  close: ->
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'data-atom:toggle-results-view')

  initialize: ->
    @connectionList.disable()
    @databaseList.disable()
    @disconnectBtn.disable()
    @queryInput.disable()
    @executeBtn.disable()
    @fileExecuted.hide()

  onDatabaseSelected: (e) ->
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'data-atom:connection-changed')

  onConnectionSelected: (e) ->
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'data-atom:connection-changed')

  addConnection: (connectionName) ->
    @connectionList.append('<option value="' + connectionName + '">' + connectionName + '</option>')
    @connectionList.children("option[value='" + connectionName + "']").prop('selected', true)
    @connectionList.enable()
    @disconnectBtn.enable()

  addDbNames: (names) ->
    for c,i in @databaseList.children()
      if i > 0
        c.remove()

    for name in names
      @databaseList.append('<option value="' + name + '">' + name + '</option>')
    if names.length > 1
      @databaseList.enable()
      @queryInput.enable()
      @executeBtn.enable()
    else
      @databaseList.disable()
      @queryInput.disable()
      @executeBtn.disable()

  setSelectedDbName: (name) ->
    @databaseList.children("option[value='" + name + "']").prop('selected', true)

  setConnection: (connectionName) ->
    @connectionList.children("option[value='" + connectionName + "']").prop('selected', true)
    if connectionName == '0'
      @databaseList.disable()
      @queryInput.disable()
      @executeBtn.disable()
      @setSelectedDbName(connectionName)

  setQuery: (query) ->
    @queryInput.val(query)

  getSelectedConnection: ->
    @connectionList.children(":selected").attr('value')

  getSelectedDatabase: ->
    @databaseList.children(':selected').attr('value')

  getQuery: ->
    @queryInput.val()

  onNewConnection: ->
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'data-atom:new-connection')

  onDisconnect: ->
    # remove the connection from our list
    #@connectionList.children("option[value='" + connectionName + "']").prop('selected', true)
    @connectionList.children(":selected").remove()
    unless @connectionList.children().length > 1
      @disconnectBtn.disable()
      @connectionList.disable()
      @queryInput.disable()
      @executeBtn.disable()
    @connectionList.children("option[value='0']").prop('selected', true)
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'data-atom:disconnect')

  onExecuteQuery: ->
    atom.commands.dispatch(atom.views.getView(atom.workspace), 'data-atom:execute-query')