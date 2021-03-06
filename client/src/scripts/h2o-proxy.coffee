Steam.H2OProxy = (_) ->

  composeUri = (uri, opts) ->
    if opts
      params = mapWithKey opts, (v, k) -> "#{k}=#{v}"
      uri + '?' + join params, '&'
    else
      uri

  request = (uri, opts, go) ->
    _.requestJSON (composeUri uri, opts), (error, result) ->
      if error
        #TODO error logging / retries, etc.
        console.error error, result
        go error, result
      else
        go error, result.data

  requestFrames = (go, opts) ->
    request '/2/Frames.json', opts, (error, result) ->
      if error
        go error, result
      else
        # Flatten response so that keys are attributes on the objects, 
        # and linked objects are direct refs instead of keys.
        { frames, models, metrics, response } = result
        for modelKey, model of models
          model.key = modelKey

        for frameKey, frame of frames
          frame.key = frameKey
          frame.compatible_models = map frame.compatible_models, (modelKey) ->
            models[modelKey]

        go error,
          response: response
          frames: values frames
          metrics: metrics

  requestModels = (go, opts) ->
    request '/2/Models.json', opts, (error, result) ->
      if error
        go error, result
      else
        # Flatten response so that keys are attributes on the objects, 
        # and linked objects are direct refs instead of keys.
        { frames, models, response } = result
        for frameKey, frame of frames
          frame.key = frameKey

        for modelKey, model of models
          model.key = modelKey
          model.compatible_frames = map model.compatible_frames, (frameKey) ->
            frames[frameKey]

        go error, response: response, models: values models

  link$ _.requestFrames, (go) -> requestFrames go
  link$ _.requestFramesAndCompatibleModels, (go) -> requestFrames go, find_compatible_models: yes
  link$ _.requestFrame, (key, go) -> requestFrames go, key: key
  link$ _.requestFrameAndCompatibleModels, (key, go) -> requestFrames go, key: key, find_compatible_models: yes
  link$ _.requestScoringOnFrame, (frameKey, modelKey, go) -> requestFrames go, key: frameKey, score_model: modelKey
  link$ _.requestModels, (go) -> requestModels go
  link$ _.requestModelsAndCompatibleFrames, (key, go) -> requestModels go, find_compatible_frames: yes
  link$ _.requestModel, (key, go) -> requestModels go, key: key
  link$ _.requestModelAndCompatibleFrames, (key, go) -> requestModels go, key: key, find_compatible_frames: yes



