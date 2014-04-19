util =  require ("util")
Player = require("./character.js")
Robot = require("./robot.js")
World = require("./world.js")
Magic = require("./magic.js")
UUID = require('node-uuid')

class Game
    constructor: (@id,@io)->
        @room = @id
        @player_count = 0
        @min_player = 1
        @max_player = 4
        @active = false
        @init()


    init: () ->
        @world = new World("basic")
        @objects = []
        @players = []
        # add a robot to game
        id = UUID()
        robot = new Robot id, "julian", "robot", 500, 200, @world
        @addPlayer robot

    start: ->
        @active = true
        @updateID = setInterval @updateState.bind(@), 16  #60 fps
        @io.sockets.in(@room).emit "start", {"gameid": @id}

    end: ->
        clearInterval @updateID
        @world = null
        @objects = []
        @players = []

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
                    if player.state == "run"
                        player.idle()
                when "animationend"
                    @onAnimationend(player)


############## event handler #######################
    onPlayerMove: (player,dir) ->
        player.move(dir)

    onPlayerAttack: (player) ->
        if player.attack()
            [target,distance] = @getNearestCharacter(player)
            if  target != null and distance < player.attackRange and player.faceDirection == player.realtiveDirection(target)
                dir = player.faceDirection
                target.gotHit(player.damage, player.counterDirection(dir))


    onPlayerCast: (player) ->
        if player.cast()
            if player.type == "robot"
                bound = player.getRect()
                width = bound.x2-bound.x1
                id = UUID()
                x  = if (player.faceDirection == 'right') then bound.x2  else bound.x1
                m = new Magic id, player.magicInfo, x, player.y, @world, player.id, player.faceDirection
                setTimeout ( =>
                    if player.checkState()
                        @addObject m
                ).bind(this), player.animationTime("cast")  

    onAnimationend:(player) ->
        if player.state == "cast"
            id = UUID();
            player.magic(@, player,id)
        if player.state == "attack"
            #finish attack action will have more damage
            [target,distance] = @getNearestCharacter(player)
            if  target != null and distance < player.attackRange and player.faceDirection == player.realtiveDirection(target)
                dir = player.faceDirection
                target.gotHit(2*player.damage, player.counterDirection(dir))             
        player.idle()

    onRemovePlayer: (client_id)->
        player = @getPlayerById client_id
        if @removePlayer player
            @io.sockets.in(@room).emit "player disconnect", {"id": client_id , "player":player}
            return true
        return false

    onNewPlayer: (client) ->
        #Create new player instance, return newly created player
        #notify other player a new player has joined
        if @player_count >= @max_player
            return null
        bound = @world.getBound()
        x = 100
        y = 200
        id = client.userid
        player = new Player id, "firzen", "player", x, y, @world

        #pick a random magic for player
        magic_schema = require("./magics/invisible.js")
        player.magicSheetInfo = magic_schema.magicSheetInfo
        player.magicInfo = magic_schema.info
        player.magic =  magic_schema.magic
        player.cd = magic_schema.info.cd

        #add player to the game
        @addPlayer player, @player_count
        @io.sockets.in(@room).emit "new player", {"id": id, "player": player}
        return player

#################################################
#physics update
    handle_collision: ->
        for object in @objects
            if object.state != 'collided'
                @detectCollision(object)

    detectCollision: (object) ->
        rect1 = object.getCollisionRect()
        for otherObject in @objects
            if object.id == otherObject.id or otherObject.state == "die"
                continue
            if object.type == otherObject.type == "magic"
                continue
            rect2 = otherObject.getCollisionRect()
            if !((rect2.x2 < rect1.x1) || (rect2.x1 > rect1.x2 ) || (rect2.y1 > rect1.y2 ) || (rect2.y2 < rect1.y1))
                dir = object.counterDirection(object.direction)
                object.collisionHandler otherObject, dir


#################################################
#player state update
    updateState: ->
        object_status = []  #only send status data of objects
        len = @objects.length - 1
        while len >= 0
            object = @objects[len]
            len -= 1
            if @is_outofBound(object)
                @removeObject object
                continue
            if object.type == 'robot'
                object.update(@)
            switch object.state
                when "collided"
                    object.moveStep()
                    break
                when "run"
                    object.moveStep()
                    @detectCollision(object)
                    break
                when "cast"
                    @onPlayerCast(object)
                when "removed"
                    @removeObject object
                    continue
            object_status.push object.getStatus()
        @io.sockets.in(@room).emit "update", {objects: object_status}


#################################################
#member functions
    addPlayer: (player,number = 0) ->
        if @player_count < @max_player
            @objects.push player
            @players.push player
            player.number ?= number
            if player.type == "player"
                @player_count += 1
            if @player_count >= @min_player and @active == false
                @start()
            return true
        return false


    addObject: (object) ->
        @objects.push object

    addMagic:(id, info, x, y, world, characterID, faceDirection) ->
        #create a magic instance and add to game
        m = new Magic(id, info, x, y, world, characterID, faceDirection)
        @addObject(m)

    removeObject:(target) ->
        for object,index in @objects
            if object.id == target.id
                @objects.splice index,1
                @io.sockets.in(@room).emit "remove", {object: target}
                return true
        return false

    removePlayer:(target) ->
        if target == null
            return false
        @removeObject target
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
        distance = Infinity
        index = 0
        target = null
        for player in @players
            if player.id == character.id or player.animation == "invisible"
                continue
            d = character.distanceTo(player)
            if d < distance
                distance = d
                target = player
        [target,distance]

    getBound: ->
        #playing area
        return {"x1":0, "x2":@world.width, "y1":0, "y2":@world.height}

    is_outofBound: (object) ->
        bound = @world.getBound()
        return object.x - object.width > bound['x2'] or object.x + object.width < 0 or object.y - object.height > bound['y2'] or object.y + object.height < 0

#####################################################
module.exports = Game