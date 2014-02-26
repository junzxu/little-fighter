class window.Magic
    constructor: (@character, @magicSheetInfo, @direction, @x, @y, @stage, @arena) ->
        @id
        @magicSheet
        @magic
        @stage
        @arena
        @init()

    init:() ->
        @magicSheet = new createjs.SpriteSheet @magicSheetInfo
        @magic = new createjs.BitmapAnimation @magicSheet
        @magic.x = @x
        @magic.y = @y

    cast:() ->
        console.log('cast magic on '+@direction)
        @magic.addEventListener("tick", @move);
        @magic.addEventListener("tick", @hit);
        @arena.container.addChild @magic
        @magic.gotoAndPlay "cast"


    move: (event)=>
        magic = event.target
        bound = @arena.getBound()
        if @direction == "right"
            magic.x += 10
        else 
            magic.x -= 10
        if magic.x > bound['x2'] or magic.x < 0
            @arena.container.removeChild magic

    getRect: ->
        x1 = @magic.getBounds().x + @magic.x
        y1 = @magic.getBounds().y + @magic.y
        x2 = @magic.getBounds().x + @magic.x + @magic.getBounds().width
        y2 = @magic.getBounds().y + @magic.y + @magic.getBounds().height
        return {"x1":x1, "x2":x2, "y1":y1, "y2":y2}

    hit: (event) =>
        magic = event.target
        rect1 = {
          "x1": magic.getBounds().x + magic.x
          "y1": magic.getBounds().y + magic.y
          "x2": magic.getBounds().x + magic.x + magic.getBounds().width
          "y2": magic.getBounds().y + magic.y + magic.getBounds().height
        }
        console.log('magic at x1:'+rect1.x1 + ' y1:'+rect1.y1 + ' x2:'+rect1.x2+ ' y2:'+rect1.y2)
        for player in @arena.getPlayers()
          rect2 = player.getRect()
          console.log(player.id + 'at x1:'+rect2.x1 + ' y1:'+rect2.y1 + ' x2:'+rect2.x2+ ' y2:'+rect2.y2)
          if !((rect2.x2 < rect1.x1) || (rect2.x1 > rect1.x2 ) || (rect2.y1 > rect1.y2 ) || (rect2.y2 < rect1.y1))
            player.gotHit(@direction)
            console.log('hit player'+player.id)
            @arena.container.removeChild magic