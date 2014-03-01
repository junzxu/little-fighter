class window.Magic extends Object
    constructor: (@name,@type, @x, @y, @stage, @arena, @character, @spriteSheetInfo, @direction) ->
        super
        @magic

    init:() ->
        @SpriteSheet = new createjs.SpriteSheet @spriteSheetInfo
        @magic = new createjs.BitmapAnimation @SpriteSheet
        @magic.x = @x
        @magic.y = @y
        @speed = @originSpeed

    cast:() ->
        console.log('cast magic on '+@direction)
        @magic.addEventListener("tick", @move);
        @arena.container.addChild @magic
        @magic.gotoAndPlay "cast"


    move: (event)=>
        magic = event.target
        bound = @arena.getBound()
        if @direction == "right"
            magic.x += @speed
        else 
            magic.x -= @speed
        @detectCollision()
        if magic.x > bound['x2'] or magic.x < 0
            @arena.container.removeChild magic


    collisionHandler: (a,b)->
        b.gotHit(@direction)
        console.log('hit player'+b.id)
        a.get().removeAllEventListeners();
        a.arena.container.removeChild a.get()


    get: ->
        return @magic