Steam.Application = (_) ->

  Steam.ErrorMonitor _
  Steam.EventLog _
  Steam.Cache _
  Steam.LocalStorage _
  Steam.Xhr _
  Steam.H2OProxy _

  #update URL fragment generating new history record
  #_.route 'home'
  
  _view = Steam.MainView _

  Steam.Router _, Steam.Routes _

  context: _
  view: _view

