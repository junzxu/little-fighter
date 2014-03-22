class window.Character extends object
    constructor: (@id, @name, @type, @x, @y, @world) ->
        super(@id, @name, @type, @x, @y, @world)
        @hp = 100
        @cd = 300
        @attackRange = 50
        @number
        @character
        @faceDirection = "right"
        @init()

    init:() ->
        super
        #should load schema from database
        @state = "idle"
        @direction = "No"


    build:(spriteSheetInfo, magicSheetInfo) ->
        @spriteSheetInfo = spriteSheetInfo
        @magicSheetInfo = magicSheetInfo
        @SpriteSheet = new createjs.SpriteSheet @spriteSheetInfo
        @character = new createjs.BitmapAnimation @SpriteSheet
        @character.x = @x
        @character.y = @y
        @character.gotoAndPlay "idle"



    addToWorld: (world) ->
        world.addPlayer @
        @world = world

    get: ->
        return @character

    changeFaceDirection: (direction) ->
        if @faceDirection == direction
            return
        else
            @faceDirection = direction
            @get().scaleX = -@get().scaleX

    run: (direction) ->
        if (@character.currentAnimation != "run")
            @character.gotoAndPlay "run"
        @direction = direction
        if direction in ["left","right"]
            @changeFaceDirection(direction)
        @state = "run"


    attack: ->
        if @character.currentAnimation != "attack"
            @character.gotoAndPlay "attack"


    cast: ->
        if @character.currentAnimation != "cast"
            @character.gotoAndPlay "cast"
        @state = "cast"

    die: ->
        if @state != "die"
            if @character.currentAnimation != "die"
                @character.gotoAndPlay "die"
                @state = "die"
                @world.get().removeChild @character

    idle: ->
        @speed = 0
        @direction = "No"
        @state = "idle"
        if (@character.currentAnimation != "idle")
            @character.gotoAndPlay "idle"

    gotHit: (direction) ->
        #direction indicates where the hit come from
        @changeFaceDirection direction
        if @character.currentAnimation != "hurt"
            @character.gotoAndPlay "hurt"
        @state = "hurt"


    setHPBar: (hp) ->
         pnumber = "#player" + @number
         $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').css("width", hp+"%")
         $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').html(hp)

 
    update: (object) ->
        switch object.state
            when 'die'
                @setHPBar(0)
                @die()
            when 'hurt'
                @gotHit(object.direction)
                @hp = object.hp
                @setHPBar(@hp)
            when 'run'
                @run(object.direction)
                @get().x = object.x
                @get().y = object.y
            when 'collided'
                @get().x = object.x
                @get().y = object.y
            when 'attack'
                @attack()
            when 'cast'
                @cast()
            when 'idle'
                if @state == "die"
                    @character.x = object.x
                    @character.y = object.y
                    @hp = object.hp
                    @setHPBar(@hp)
                    @world.get().addChild @character
                @idle()


