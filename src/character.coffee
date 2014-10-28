class window.Character extends object
    constructor: (@id, @name, @type, @x, @y, @world) ->
        super(@id, @name, @type, @x, @y, @world)
        @cd
        @number
        @score
        @character

    init:() ->
        super
        #should load schema from database
        @faceDirection = "right"
        @attackRange = 50
        @isLocal = false
        @lastCast = 0

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
            @startCoolDown()
        @state = "cast"


    die: ->
        if @state != "die"
            if @character.currentAnimation != "die"
                @character.gotoAndPlay "die"
                @state = "die"
                

    idle: () ->
        @speed = 0
        @direction = "No"
        @state = "idle"
        animation = @animation
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


    startCoolDown: ->
        @lastCast = new Date().getTime()
        pnumber = "#player" + @number
        $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #cd').css("width", "0%")
        setTimeout ( =>
            pnumber = "#player" + @number
            $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #cd').css("width", "100%")
        ), @cd

    setCoolDown:(delta)->
        percent = Math.floor(100*(delta/@cd))
        pnumber = "#player" + @number
        $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #cd').css("width", percent+"%")
 
    setScore:(score)->
        pnumber = "#player" + @number
        text = "Score:" + score
        $('#hud > .row > ' + pnumber + ' > .row >#stats > .score > #playerScore').html(text)       

    update: (object) ->
        @animation = object.animation
        if @animation == "invisible"
            #handle player invisble
            if @isLocal == true
                @get().alpha = 0.5
            else
                @get().visible = false
        else
            if @isLocal == true
                @get().alpha = 1
            else
                @get().visible = true

        #update score
        if object.score != @score
            @setScore(object.score)

        #set cool down bar
        currentTime = new Date().getTime()
        deltaTime = currentTime - @lastCast
        if deltaTime < @cd
            @setCoolDown(deltaTime)

        #rebirth
        if @state == "die" and object.state != "die"
            #rebirth
            @character.x = object.x
            @character.y = object.y
            @hp = object.hp
            @setHPBar(@hp)

        switch object.state
            #update player animation
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
                @hp = object.hp
                @setHPBar(@hp)
            when 'attack'
                @attack()
            when 'cast'
                @cast()
            when 'idle'
                @idle()


