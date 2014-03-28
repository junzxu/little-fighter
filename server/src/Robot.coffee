object = require("./object.js")
robot_schema = require("./robot_schema.js")

class Robot extends object
    constructor: (@id, @name, @type, @x, @y, @world) ->
        super(@name, @type, @x, @y, @world)
        @hp = 100
        @cd = 300
        @damage = 15
        @attackRange = 50
        @sightRange = 150
        @originSpeed = 1
        @number
        @faceDirection = "right"
        @currentDestination = [@x,@y]
        @waitTime = 0
        @oldtime = new Date().getTime()


    init:() ->
        super
        #should load schema from database
        @width = 80
        @height = 80
        @spriteSheetInfo = robot_schema.spriteSheetInfo
        @magicSheetInfo = robot_schema.magicSheetInfo


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


    rebirth: ->
        if @state != "die"
            return
        @idle()
        bound = @world.getBound()
        @x = Math.floor(Math.random() * bound.x2)
        @y = Math.floor(Math.random() * bound.y2)
        @hp = 100


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
        else
            @setState 'hurt'
            @faceDirection = direction
            @moveStep(@counterDirection(direction))


    setState: (state) ->
        @state = state
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
                return 1500
            when 'cast'
                return 500
            when 'die'
                return 3000
            when 'collided'
                return 100
            else
                return null

################### ai component ###################################
    moveTo: (dest = null)->
        if dest != null
            @currentDestination = dest
        @setState 'run'
        @speed = @originSpeed
        count = 0
        if @x < @currentDestination[0]
            count += 1
        else
            count += 2
        if @y < @currentDestination[1]
            count += 4
        else
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
            bound = @world.getBound()
            x = Math.floor(Math.random() * (bound.x2 - @width/2))
            y = Math.floor(Math.random() * (bound.y2 - @height/2))
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
            if player.id == @id
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
            @moveTo([target.x,target.y])

    update: (game)->
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
