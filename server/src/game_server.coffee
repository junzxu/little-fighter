Game = require("./game.js")

exports = module.exports = class Server
    constructor: (@io)->
        @util =  require ("util")
        @games = []
        @game_count = 0
        @players = []
        @init()


    init: ()->
        @fake_latency = 0;
        @local_time = 0;
        @_dt = new Date().getTime();
        @_dte = new Date().getTime();

    # Event handlers #################################################################################
    findGame: (player) ->
        joined = false
        if @game_count > 0
            joined = @joinGame(player)
        if joined  == false
            @createGame(player)


    createGame:(player) ->
        game = new Game player.gameid, @io
        game.addPlayer player
        @startGame(game.id)
        @game_count += 1
        @games.push game


    joinGame:(player) ->
        for game in @games
            if game.id == player.gameid and game.player_count < game.Max_players
                game.addPlayer player
                @startGame(game.id)
                return true
        return false


    endGame: (game_id, client_id)->
        for game,index in @games
            if game.id == game_id
                @util.log 'client ' + @id + ' has disconnected'
                game.removePlayer client_id
                if game.player_count == 0
                    @games.splice index,1
                    @game_count -= 1
                @io.sockets.emit "disconnect", {}
                return true
        return false


    startGame: (game_id) ->
        #we have enough players for a game
        game = @getGame(game_id)
        if game.active == true
            return
        if game.id == game_id and game.player_count > game.Min_players
            game.active = true
            game.startUpdate()



    onUpdate: (client,data) ->
        # Handle Input
        game = @getGame(client.gameid)
        game.handleInput(data)
        

    getGame: (id) ->
        for game in @games
            if game.id == id
                return game
        return null