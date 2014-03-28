object = require("./object.js")
player_schema = require("./player_schema.js")

class Player extends object
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
        @width = 80
        @height = 80
        @spriteSheetInfo = player_schema.spriteSheetInfo
        @magicSheetInfo = player_schema.magicSheetInfo


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
                @setState "attack"
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
            when "die"
                setTimeout ( => 
                    @rebirth()
                ), @animationTime()
            when "collided"
                setTimeout ( -> 
                    @idle()
                 ).bind(this), @animationTime()


    animationTime: (act = null) ->
        if act == null
            act = @state
        switch act
            when 'die'
                return 3000
            when 'collided'
                return 100
            else
                return null

    checkState: ->
        #["hurt","attack","disabled","collided"]
        if @state in ["disabled","collided","die","hurt"]
            false
        else
            true

################################################################
module.exports = Player
