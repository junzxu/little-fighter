class Server
    constructor: ()->
        @util =  require ("util")
        @io = require("socket.io")
        @Character = require("../js/character.js").Character

        @players = []
        @init()


    init: ()->
        @socket = @io.listen 8000
        @socket.configure ()->
            this.set "transports", ["websocket"]
            this.set "log level", 2
        @setEventHandlers()

    # Member functions #################################################################################
    removePlayer: (id) ->
        for key, p in @players
            if p.id == id
                    @players.splice(key, 1)

    setEventHandlers: () ->
        @socket.sockets.on "connection", @onSocketConnection.bind this


    # Event handlers #################################################################################
    onSocketConnection: (client) ->
        @util.log client.id
        client.emit "client id", {id:client.id}

        # Send the client its ID
        client.on "new player", @onNewPlayer.bind this
        client.on "disconnect", @onSocketDisconnect.bind this
        client.on "update", @onSocketUpdate.bind this
        client.on "attack", @onPlayerAttack.bind this

        # Send the existing players to the client
        for player in @players
                client.emit "new player", {id: player.id, x:player.x, y:player.y}
                @util.log 'emitting existing player:' + player.id

    onPlayerAttack: (data) ->
        @util.log 'attacking ' + data.id + 'at position: ' + data.x + ',' + data.y
        # A dumb collision detection
        for player in @players
            if  player.id != data.id
                @util.log 'got hit'

    onSocketDisconnect: (client)->
        @util.log 'client ' + @id + ' has disconnected'
        @removePlayer(client.id)
        @socket.sockets.emit "disconnect", {}

    onNewPlayer: (data) ->
        @util.log 'New Player:' +  data.id + '--- Location:' + data.x + ',' + data.y
        # Create new player instance
        @players.push {id:data.id, x:data.x, y:data.y, hp:100}
        @socket.sockets.emit "new player", {id: data.id, x:data.x, y:data.y}

    onSocketUpdate: (data) ->
        @util.log "update: id:" + data.id + " x:" + data.x + " y:" + data.y
        # Broadcast all updates
        @socket.sockets.emit "update", {id:data.id, x:data.x, y:data.y, dir:data.dir, state:data.state}

gameServer = new Server
