@App.module "TestIframeApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Application

    initialize: (options) ->
      { iframe } = options

      config = App.request "app:config:entity"

      setConfig = ->
        iframe.setConfig(config)

      setConfig()

      @layout = @getLayoutView(iframe)

      @listenTo @layout, "browser:clicked", (browser, version) ->
        # iframe.switchToBrowser(browser, version)

      @listenTo @layout, "close:browser:clicked", ->
        # iframe.switchToBrowser()

      @listenTo iframe, "loaded", (cb, contentWindow, remoteIframe, options) ->
        ## once its loaded we receive the contentWindow
        ## we invoke the callback which tells our runner
        ## to run the specPath's suite
        cb(contentWindow, remoteIframe, options)

      @listenTo iframe, "load:spec:iframe", (cb, options) ->
        ## set the initial config values from
        ## our config entity which restores
        ## the default settings from cypress.json
        setConfig()

        @layout.loadIframe options, (contentWindow, remoteIframe) ->
          ## once the iframes are loaded we trigger this event
          ## which prevents forcing callbacks if we've navigated
          ## away from the page and we're already shut down
          iframe.trigger "loaded", cb, contentWindow, remoteIframe, options

      ## TODO MOVE ALL THESE EVENTS DIRECTLY
      ## INTO THE LAYOUTVIEW
      @listenTo iframe, "cannot:revert:dom", (init) ->
        @layout.cannotRevertDom(init)

      @listenTo iframe, "revert:dom", (dom, options) ->
        @layout.revertToDom dom, options

      @listenTo iframe, "highlight:el", (el, options) ->
        @layout.highlightEl el, options

      @listenTo iframe, "restore:dom", ->
        @layout.restoreDom()

      @listenTo @layout, "show", ->
        ## dont show the header in satelitte mode
        return if config.ui("satelitte")

        @headerView(iframe)

      @show @layout

    headerView: (iframe) ->
      headerView = @getHeaderView(iframe)
      @show headerView, region: @layout.headerRegion

    getHeaderView: (iframe) ->
      new Show.Header
        model: iframe

    getLayoutView: (iframe) ->
      new Show.Layout
        model: iframe