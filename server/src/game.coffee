util =  require ("util")
Player = require("./character.js")
World = require("./world.js")

class Game
    constructor: (@id,@io)->
        @room = @id
        @objects = []
        @players = []
        @player_count = 0
        @min_player = 1
        @max_player = 4
        @state = "preparing"
        @init()


    init: ()->
        @world = new World("basic")

    start: ->
        game.state = "start"
        setTimeout @updateState, 16
        @io.sockets.in(@room).emit "start", {"gameid":@id}

    handleInput: (data) ->
    #handle data send by client
        player = getPlayerById(data.id)
        if player != null
            switch data.action
                when "run"
                    @onPlayerMove()
                when "attack"
                    @onPlayerAttack()
                when "cast"
                    @onPlayerCast()


############## event handler #######################
    onPlayerMove: (player) ->
        player.move()

    onPlayerAttack: (player) ->
        if player.attack()
            [target,distance] = @getNearestCharacter(player)
            if  target != null and distance < player.attackRange and player.faceDirection == player.realtiveDirection(target)
                target.gotHit(10, player.counterDirection(player.faceDirection))


    onPlayerCast: (player) ->
        if player.cast()
            bound = player.getRect()
            width = bound.x2-bound.x1
            x  = if (player.faceDirection == 'right') then player.x+ width  else player.x-width
            m = new Magic 'blue','magic', x, player.y, @world, player, @faceDirection
            @addObject m

    onRemovePlayer: (client)->
        id = client.userid
        player = @getPlayerById id
        if @removePlayer player
            @player_count -= 1
            client.broadcast.to(@room).emit "disconnect", {"id":id, "player":player}
            return true
        return false

    onNewPlayer: (client) ->
        # Create new player instance
        if @player_count >= @max_player
            return false
        bound = @world.getBound()
        x = Math.floor(Math.random() * bound.x2)
        y = Math.floor(Math.random() * bound.y2)
        id = client.userid
        player = new Player id, "firzen", "player", x, y, @world
        @player_count += 1
        @addPlayer player, @player_count
        client.broadcast.to(@room).emit "new player", {"id": id, "player": player}
        return true


#################################################
#physics update
    handle_collision: ->
        for player in @players
            @detectCollision(player)

    detectCollision: (object) ->
        rect1 = @getCollisionRect()
        for otherObject in @Objects()
          if object.id == otherObject.id
             continue
          rect2 = otherObject.getCollisionRect()
          if !((rect2.x2 < rect1.x1) || (rect2.x1 > rect1.x2 ) || (rect2.y1 > rect1.y2 ) || (rect2.y2 < rect1.y1))
            object.collisionHandler otherObject


#################################################
#player state update
    updateState: ->
        for object in @objects
            switch object.state
                when "collided"
                    object.moveStep(player.direction, 2)
                    break
                when "run"
                    object.moveStep()
                    detectCollision(object)
                when "removed"
                    @removeObject object
        @io.sockets.in(@room).emit "update", {id:data.id, x:data.x, y:data.y, dir:data.dir, state:data.state}


    getNearestCharacter: (character) ->
        distance = 100000
        index = 0
        target = null
        for player in @players
            if player.id == character.id
                continue
            d = Math.pow((character.x - player.x),2) + Math.pow((character.y - player.y),2)
            if d < distance
                distance = d
                target = player
        d = Math.sqrt(distance)
        [target,d]
#################################################
#member functions

    addPlayer: (player,number = 0) ->
        if @player_count < @max_player
            @objects.push player
            @players.push player
            player.number ?= number
            @player_count += 1
            if @player_count >= @min_player
                @start()
            return true
        return false


    addObject: (object) ->
        @objects.push object

    removeObject:(target) ->
        for object,index in @objects
            if object.id == target.id
                @objects.splice index,1
                return true
        return false

    removePlayer:(target) ->
        for player,index in @players
            if player.id == target.id
                @players.splice index,1
                @player_count -= 1
                return true
        return false

    getPlayers: ->
        return @players

    getObjects: ->
        return @objects

    getPlayerById: (id) ->
        for player in @players
            if player.id == id
                return player

    getNearestCharacter: (character) ->
        distance = 100000
        index = 0
        target = null
        for player in @players
            if player.id == character.id
                continue
            d = Math.pow((character.x - player.x),2) + Math.pow((character.y - player.y),2)
            if d < distance
                distance = d
                target = player
        d = Math.sqrt(distance)
        [target,d]

    getBound: ->
        #playing area
        return {"x1":0, "x2":@world.width, "y1":0, "y2":@world.height}

#####################################################
module.exports = Game