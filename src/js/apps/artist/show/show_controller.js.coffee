@Kodi.module "ArtistApp.Show", (Show, App, Backbone, Marionette, $, _) ->

  class Show.Controller extends App.Controllers.Base

    ## The Artist page.
    initialize: (options) ->
      id = parseInt options.id
      artist = App.request "artist:entity", id
      ## Fetch the artist
      App.execute "when:entity:fetched", artist, =>
        ## Get the layout.
        @layout = @getLayoutView artist
        ## Ensure background removed when we leave.
        @listenTo @layout, "destroy", =>
          App.execute "images:fanart:set", 'none'
        ## Listen to the show of our layout.
        @listenTo @layout, "show", =>
          @getMusic id
          @getDetailsLayoutView artist
        ## Add the layout to content.
        App.regionContent.show @layout

    ## Get the base layout
    getLayoutView: (artist) ->
      new Show.PageLayout
        model: artist

    ## Build the details layout.
    getDetailsLayoutView: (artist) ->
      headerLayout = new Show.HeaderLayout model: artist
      @listenTo headerLayout, "show", =>
        teaser = new Show.ArtistTeaser model: artist
        detail = new Show.Details model: artist
        headerLayout.regionSide.show teaser
        headerLayout.regionMeta.show detail
      @layout.regionHeader.show headerLayout

    ## Get a list of all the music for this artist parsed into albums.
    getMusic: (id) ->
      options =
        filter: {artistid: id}
      ## Get all the songs and parse them into sepetate album collections.
      songs = App.request "song:filtered:entities", options
      App.execute "when:entity:fetched", songs, =>
        songsCollections = App.request "song:albumparse:entities", songs
        albumsCollection = App.request "albums:withsongs:view", songsCollections
        @layout.regionContent.show albumsCollection

