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
        @state = "idle"
        @direction = "No"
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

################################################################
module.exports = Player
