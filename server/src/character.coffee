Object = require("./Object.js")

class Player extends Object
    constructor: (@id, @name, @type, @x, @y, @world) ->
        super(@name, @type, @x, @y, @world)
        @hp = 100
        @cd = 300
        @attackRange = 50
        @number
        @faceDirection = "right"

    init:() ->
        super
        #should load schema from database
        @state = "idle"
        @direction = "No"
        if @type == "robot"
            data = eval(robot_schema)
        else
            data = eval(player_schema)

        @spriteSheetInfo = data.spriteSheetInfo
        @magicSheetInfo = data.magicSheetInfo



    changeFaceDirection: (direction) ->
        if @faceDirection == direction
            return
        else
            @faceDirection = direction

    move: (direction) ->
        if @checkState()
            @setState "run"
            @speed = @originSpeed
            if direction in ["left","right"]
                @changeFaceDirection(direction)
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
            @changeFaceDirection direction
            @moveStep(direction)


    setState: (state) ->
        @state = state


    checkState: ->
        if @state in ["hurt","attack","disabled","collided"]
            false
        else
            true

################################################################
module.exports = Player
