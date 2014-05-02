object = require("./object.js")
robot_schema = require("./characters/julian.js")
magic_schema = require("./magics/death.js")

class Robot extends object
    constructor: (@id, @name, @type, @x, @y, @bound) ->
        super(@name, @type, @x, @y, @bound)
        @setupInfo(robot_schema.info)
        @hp = @maxhp
        @score = 0
        @number
        @username = "robot"
        @faceDirection = "left"
        @currentDestination = [@x,@y]
        @waitTime = 0
        @oldtime = new Date().getTime()


    init:() ->
        super
        #should load schema from database
        @spriteSheetInfo = robot_schema.spriteSheetInfo
        @magicSheetInfo = magic_schema.magicSheetInfo
        @magicInfo = magic_schema.info
        @cd = @magicInfo.cd


    move: (direction) ->
        if @checkState()
            @setState "run"
            @speed = @originSpeed
            @direction = direction
            @faceDirection = if direction in ["left","ul",'dl'] then "left" else "right" 
            @moveStep()
            return true
        return false


    attack: (target = null) ->
        if @checkState()
            @setState "attack"
            if @distanceTo(target) < @attackRange
                dir = @counterDirection(@faceDirection)
                target.gotHit(@damage, dir)
            return true
        return false


    cast: ->
        if @checkState() and @magicState == 'ready'
            @magicState = 'preparing'
            if @state != "cast"
                @setState "cast"
            setTimeout ( => 
                @magicState = "ready"
            ), @cd
            return true
        return false


    teleport: (x,y)->
        @state == "disabled"
        setTimeout ( => 
            @x = x
            @y = y
            @idle()
        ).bind(this), @animationTime("teleport")           

    rebirth: ->
        if @state != "die"
            return
        @idle()
        @x = @bound.x1 + Math.floor(Math.random() * (@bound.x2 - @bound.x1 - @width))
        @y = @bound.y1 + Math.floor(Math.random() * (@bound.y2 - @bound.y1 - @height))
        @hp = @maxhp


    idle: ->
        @state = 'idle'
        @speed = 0
        @direction = "No"

    gotHit: (damage,direction) ->
        #direction indicates where the hit come from
        if @state == "die"
            return
        @hp -= damage
        if @hp <= 0
            @setState 'die'
            @score -= 10
        else
            @setState 'hurt'
            @faceDirection = direction
            @moveStep(@counterDirection(direction))


    setState: (state, animation = null) ->
        @state = state
        if animation != null
            @animation = animation
        else
            if state not in ["idle","run"]
                @animation = state
        switch state
            when "idle"
                idle()
            when "run"
                return
            when "die"
                setTimeout ( => 
                    @rebirth()
                ).bind(this), @animationTime("die")                
            else
                setTimeout ( ->
                    if @hp > 0  
                        @idle()
                 ).bind(this), @animationTime()


    checkState: ->
        if @state in ["disabled","collided","die", "hurt", "attack"]
            return false
        else
            return true

    animationTime: (act = null) ->
        if act == null
            act = @state
        switch act
            when 'hurt'
                return 800
            when 'attack'
                return 1000
            when 'cast'
                return 1100
            when 'die'
                return 3000
            when 'collided'
                return 100
            when 'teleport'
                return 500
            else
                return null

    collisionHandler: (object, direction) ->
        #inherited from default method
        if object.name != "coin"
            @collide direction
        if object.state != "collided"
            object.collisionHandler @, @counterDirection(direction)

    getStatus: ->
        @info.x = @x
        @info.y = @y
        @info.state = @state
        @info.animation = @animation
        @info.direction = @direction
        @info.faceDirection = @faceDirection
        @info.hp = @hp
        @info.cd = @cd
        @info.score = @score
        return @info

################### ai component ###################################
    moveTo: (dest) =>
        @currentDestination = dest
        count = 0
        if @x < dest[0]
            count += 1
        if @x > dest[0]
            count += 2
        if @y < dest[1]
            count += 4
        if @y > dest[1]
            count += 8
        switch count
            when 1
                @direction = 'right'
            when 2
                @direction = 'left'
            when 4
                @direction = 'down'
            when 8
                @direction = 'up'
            when 5
                @direction = 'dr'
            when 6
                @direction = 'dl'
            when 9
                @direction = 'ur'
            when 10
                @direction = 'ul'
        @setState 'run'
        @speed = @originSpeed
        @faceDirection = if @direction in ["left","ul",'dl'] then "left" else "right" 


    wait:(time) ->
        #robot will be idle for a given time(ms)
        @idle()
        @waitTime = time
        @oldtime = new Date().getTime()

    randomWalk: ->
        time = new Date().getTime()
        if @state == "idle" and time - @oldtime < @waitTime
            return
        if not (Math.abs(@x - @currentDestination[0]) <= @originSpeed and Math.abs(@y - @currentDestination[1]) <= @originSpeed)
            @moveTo(@currentDestination)
        else
            x = @bound.x1 + Math.floor(Math.random() * (@bound.x2 - @bound.x1 - @width))
            y = @bound.y1 + Math.floor(Math.random() * (@bound.y2 - @bound.y1 - @height))
            @currentDestination = [x,y]
            @wait(2000)


    enemyInRange: (players) ->
        #return nearest enemy in sight range
        if @faceDirection == "right"
            sightRange = {"x1": @x, "x2": @x+@sightRange, "y1": @y-@sightRange/2, "y2":@y+@sightRange/2 }
        else
            sightRange = {"x1": @x-@sightRange, "x2": @x, "y1": @y - @sightRange/2, "y2":@y + @sightRange/2 }
        target = null
        distance = Infinity
        for player in players
            if player.id == @id or player.animation == "invisible"
                continue
            if player.inRange(sightRange)
                d = @distanceTo(player)
                if d < distance
                    target = player
                    distance = d
        return target


    goAttack: (target) ->
        #move to target then attack
        if @distanceTo(target) < @attackRange
            @attack(target)
        else
            if @distanceTo(target)>100 and Math.random() < 0.02
                @setState "cast"
            else
                @moveTo([target.x,target.y])

    update: (game)->
        if @state == 'hurt'
            #change target
            target = @enemyInRange(game.players)
            if target != null
                @currentDestination = [target.x,target.y]
        if @state == "cast"
            return
        if not @checkState()
            return
        target = @enemyInRange(game.players) #find target in sight
        if target == null
            #wait if not find any enemy
            @randomWalk()
        else
            @goAttack(target)

################################################################
module.exports = Robot
