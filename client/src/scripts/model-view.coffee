Steam.ModelView = (_, _model) ->
  _compatibleFrames = node$ ''
  _compatibleFramesCount = node$ ''

  initialize = (model) ->
    _.requestModelAndCompatibleFrames model.key, (error, data) ->
      if error
        #TODO handle errors
      else
        #TODO typecheck
        unless isEmpty data.models
          aModel = head data.models
          _compatibleFrames createCompatibleFramesSection aModel.compatible_frames
          _compatibleFramesCount "(#{aModel.compatible_frames.length})"

  stringify = (value) ->
    if isArray value
      join value, ', '
    else
      value

  createDefinitionList = (data) ->
    [ dl, li, dt, dd ] = geyser.generate words '.y-summary .y-summary-item .y-summary-key .y-summary-value'

    dl map data, ([key, value]) ->
      li [ (dt key), (dd stringify value) ]

  # Summary section
  createSummarySection = (model) ->
    createDefinitionList [
      [ 'Response Column', model.response_column_name ]
      [ 'Model Category', model.model_category ]
      [ 'State', model.state ]
    ]

  # Parameters section
  createParametersSection = (model) ->
    parameters = [
      pairs model.critical_parameters
      pairs model.secondary_parameters
      pairs model.expert_parameters
    ]
    createDefinitionList flatten parameters, yes
  
  # Input columns section
  createInputColumnsSection = (model) ->
    rows = map model.input_column_names, (columnName) -> [ columnName ]

    #TODO duplicates logic in FrameView. Refactor.
    [ table, tbody, tr, td ] = geyser.generate words 'table.table.table-condensed.table-hover tbody tr td'
    table [
      tbody map rows, (row) ->
        tr map row, td
    ]


  createCompatibleFramesSection = (frames) ->
    headers = [
      'Dataset'
      'Columns'
    ]

    rows = map frames, (frame) ->
      [
        frame.key
        join frame.column_names, ', '
      ]

    #TODO duplicates logic in FrameView. Refactor.
    [ table, thead, tbody, tr, th, td ] = geyser.generate words 'table.table.table-condensed.table-hover thead tbody tr th td'

    table [
      thead [
        tr map headers, (header) ->
          th header
      ]
      tbody map rows, (row) ->
        tr map row, td
    ]

  loadCompatibleFrames = ->
    _.switchToFrames type: 'compatibleWithModel', modelKey: _model.key

  initialize _model
  
  data: _model
  key: _model.key
  title: _model.model_algorithm
  summary: createSummarySection _model
  parameters: createParametersSection _model
  inputColumns: createInputColumnsSection _model
  inputColumnsCount: "(#{_model.input_column_names.length})"
  compatibleFrames: _compatibleFrames
  compatibleFramesCount: _compatibleFramesCount
  loadCompatibleFrames: loadCompatibleFrames
  dispose: ->
  template: 'model-view'

