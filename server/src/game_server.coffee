Game = require("./game.js")
Player = require("./character.js")

class Server
    constructor: (@io)->
        @util =  require ("util")
        @games = []
        @game_count = 0
        @clients = []
        @init()


    init: ()->
        @fake_latency = 0;
        @local_time = 0;
        @_dt = new Date().getTime()
        @_dte = new Date().getTime()

    # Event handlers #################################################################################
    findGame: (client) ->
        joined = false
        if @game_count > 0 and client.gameid != null
            joined = @joinGame(client)
        if joined  == false
            @createGame(client)


    createGame:(client) ->
        game = new Game client.gameid, @io
        player = game.onNewPlayer(client) #create a game character and add to player list
        @startGame(game.id)
        @game_count += 1
        @games.push game
        #tell client they have joined a game
        client.emit 'joined', { id: client.userid, gameid: client.gameid, world: game.world, character:player, players:game.players}
        console.log("player " + client.userid + ' has joined game ' +  client.gameid)


    joinGame:(client) ->
        for game in @games
            if game.id == client.gameid and game.player_count < game.max_player
                player = game.onNewPlayer(client)
                #tell client they have joined a game
                client.emit 'joined', { id: client.userid, gameid: client.gameid, world: game.world, character: player, players:game.players}
                @startGame(game)
                return true
        return false


    endGame: (game_id, client_id)->
        for game,index in @games
            if game.id == game_id
                @util.log 'client ' + client_id + ' has disconnected'
                game.onRemovePlayer client_id
                @util.log 'remaining players:' + game.player_count
                if game.player_count == 0  #no player in the game, so we destroy the game
                    game.end()
                    @games.splice index,1
                    @game_count -= 1
                    @util.log 'game ' + game_id + ' destroyed'
                return true
        return false


    startGame: (game) ->
        #we have enough players for a game
        if game.active == true
            return
        if game.player_count > game.min_player
            game.active = true
            game.start()



    onUpdate: (client,data) ->
        # Handle Input
        game = @getGame(client.gameid)
        game.handleInput(data)
        

    getGame: (id) ->
        for game in @games
            if game.id == id
                return game
        return null

    removeClient: (target) ->
        for client,index in @clients
            if client.userid == target.userid
                @clients.splice index,1
                return
#####################################################
module.exports = Server