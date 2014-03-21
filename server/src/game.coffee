util =  require ("util")
Player = require("./character.js")
World = require("./world.js")
Magic = require("./magic.js")
UUID = require('node-uuid')

class Game
    constructor: (@id,@io)->
        @room = @id
        @player_count = 0
        @min_player = 1
        @max_player = 4
        @state = "preparing"
        @init()


    init: () ->
        @world = new World("basic")
        @objects = []
        @players = []
        # add a robot to game
        id = UUID()
        robot = new Player id, "Julian", "robot", 600, 300, @world
        @addPlayer robot

    start: ->
        @state = "start"
        setInterval @updateState.bind(@), 16  #60 fps
        @io.sockets.in(@room).emit "start", {"gameid":@id}


    handleInput: (data) ->
    #handle data send by client
        player = @getPlayerById(data.id)
        if player != null
            switch data.action
                when "run"
                    @onPlayerMove(player, data.dir)
                when "attack"
                    @onPlayerAttack(player)
                when "cast"
                    @onPlayerCast(player)
                when "keyup"
                    if player.state = "run"
                        player.idle()
                when "animationend"
                    @onAnimationend(player)


############## event handler #######################
    onPlayerMove: (player,dir) ->
        player.move(dir)

    onPlayerAttack: (player) ->
        console.log("received player attack of id" + player.id)
        if player.attack()
            [target,distance] = @getNearestCharacter(player)
            if  target != null and distance < player.attackRange and player.faceDirection == player.realtiveDirection(target)
                target.gotHit(10, player.counterDirection(player.faceDirection))


    onPlayerCast: (player) ->
        if player.cast()
            bound = player.getRect()
            width = bound.x2-bound.x1
            id = UUID()
            x  = if (player.faceDirection == 'right') then player.x+ width  else player.x-width
            m = new Magic id, 'blue', x, player.y, @world, player.id, player.faceDirection
            @addObject m

    onAnimationend:(player) ->
        switch player.state
            when 'die'
                player.setState 'idle'
                player.rebirth()
            else
                player.idle()

    onRemovePlayer: (client)->
        id = client.userid
        player = @getPlayerById id
        if @removePlayer player
            @player_count -= 1
            client.broadcast.to(@room).emit "player disconnect", {"id":id, "player":player}
            return true
        return false

    onNewPlayer: (client) ->
        # Create new player instance, return newly created player
        #notify other player a new player has joined
        if @player_count >= @max_player
            return null
        bound = @world.getBound()
        # x = Math.floor(Math.random() * bound.x2)
        # y = Math.floor(Math.random() * bound.y2)
        x = 100
        y = 300
        id = client.userid
        player = new Player id, "firzen", "player", x, y, @world
        @player_count += 1
        @addPlayer player, @player_count
        client.broadcast.to(@room).emit "new player", {"id": id, "player": player}
        return player

#################################################
#physics update
    handle_collision: ->
        for player in @players
            @detectCollision(player)

    detectCollision: (object) ->
        rect1 = object.getCollisionRect()
        for otherObject in @objects
          if object.id == otherObject.id
             continue
          rect2 = otherObject.getCollisionRect()
          if !((rect2.x2 < rect1.x1) || (rect2.x1 > rect1.x2 ) || (rect2.y1 > rect1.y2 ) || (rect2.y2 < rect1.y1))
            object.collisionHandler otherObject


#################################################
#player state update
    updateState: ->
        len = @objects.length - 1
        while len >= 0
            object = @objects[len]
            len -= 1
            if @is_outofBound(object)
                @removeObject object
            switch object.state
                when "collided"
                    object.moveStep()
                    break
                when "run"
                    object.moveStep()
                    # @detectCollision(object)
                    break
                when "removed"
                    @removeObject object
        @io.sockets.in(@room).emit "update", {objects: @objects}


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
        if target == null
            return false
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
        return null

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

    is_outofBound: (object) ->
        bound = @world.getBound()
        return object.x - object.width > bound['x2'] or object.x + object.width < 0 or object.y - object.height > bound['y2'] or object.y + object.height < 0

#####################################################
module.exports = Game