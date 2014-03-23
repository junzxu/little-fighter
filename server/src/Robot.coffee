object = require("./object.js")
robot_schema = require("./robot_schema.js")

class Robot extends object
    constructor: (@id, @name, @type, @x, @y, @world) ->
        super(@name, @type, @x, @y, @world)
        @hp = 100
        @cd = 300
        @damage = 15
        @attackRange = 50
        @number
        @faceDirection = "right"

    init:() ->
        super
        #should load schema from database
        @state = "idle"
        @direction = "No"
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


    attack: ->
        if @checkState()
            if @state != "attack"
                @state = "attack"
                return true
        return false


    cast: ->
        if @checkState() and @magicState == 'ready'
            @magicState = 'preparing'
            if @state != "cast"
                @state = "cast"
            setTimeout ( => 
                @magicState = "ready"
            ), @cd
            return true
        return false


    rebirth: ->
        @setState "idle"
        bound = @world.getBound()
        @x = Math.floor(Math.random() * bound.x2)
        @y = Math.floor(Math.random() * bound.y2)
        @hp = 100


    idle: ->
        @setState 'idle'
        @speed = 0
        @direction = "No"

    gotHit: (damage,direction) ->
        #direction indicates where the hit come from
        console.log('current hp: ' + @hp)
        @hp -= damage
        if @hp <= 0
            @setState 'die'
            setTimeout ( => 
                @rebirth()
            ), 3000
        else
            @setState 'hurt'
            @faceDirection = direction
            @moveStep(@counterDirection(direction))


    setState: (state) ->
        @state = state


    checkState: ->
        #["hurt","attack","disabled","collided"]
        if @state in ["disabled","collided"]
            false
        else
            true

    animationTime: (act = null) ->
        if act == null
            act = @state
        switch act
            when 'hurt'
                return 200
            when 'attack'
                return 500
            when 'cast'
                return 500
            else
                return null
################################################################
module.exports = Robot
