class window.Character extends object
    constructor: (@id, @name, @type, @x, @y, @world) ->
        super(@id, @name, @type, @x, @y, @world)
        @maxhp
        @hp
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
        @character.name = @name
        @character.x = @x
        @character.y = @y
        if @faceDirection == 'left'
            @get().scaleX = -@get().scaleX
        @character.gotoAndPlay "idle"



    addToWorld: (world) ->
        world.addPlayer @
        @world = world

    get: ->
        return @character

    changeFaceDirection: (direction) ->
        #direction is left or right
        if @faceDirection == direction
            return
        else
            @faceDirection = direction
            @get().scaleX = -@get().scaleX

    run: (direction) ->
        if (@character.currentAnimation != "run")
            @character.gotoAndPlay "run"
        @direction = direction
        @state = "run"


    attack: ->
        if @character.currentAnimation != "attack"
            @character.gotoAndPlay "attack"
        @state = "attack"


    cast: ->
        if @character.currentAnimation != "cast"
            @character.gotoAndPlay "cast"
        @state = "cast"

    die: ->
        if @state != "die"
            if @character.currentAnimation != "die"
                @character.gotoAndPlay "die"
                @state = "die"
                

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


    setHPBar: (hp) =>
         pnumber = "#player" + @number
         percent = 100*(hp/@maxhp)
         $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').css("width", percent+"%")
         $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').html(hp)

 
    update: (object) ->
        if @state == "die" and object.state != "die"
            @character.x = object.x
            @character.y = object.y
            @hp = object.hp
            @setHPBar(@hp)
            # @world.get().addChild @character
        switch object.state
            when 'die'
                @setHPBar(0)
                @die()
            when 'hurt'
                @gotHit(object.faceDirection)
                @hp = object.hp
                @setHPBar(@hp)
            when 'run'
                @changeFaceDirection(object.faceDirection)
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
                @idle()


