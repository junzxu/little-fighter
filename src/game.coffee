class window.Game
    init: ->
        @keysDown = {}
        @players = []
        @player_count = 1
        @stageInit()
        @serverInit()
        @localPlayer = null

        createjs.Ticker.setFPS 60
        @ready = false

        @lastKeyPress = new Date()
        @addEventHandlers()


    # Server setup
    serverInit: () ->
        @socket = io.connect "http://localhost", {port: 3000, transports: ["websocket"]}
        console.log('\t connected to server')


    # Stage setup
    stageInit: () ->
        # Setup Stage
        console.log('\t stage init...')
        canvas = document.getElementById("gameCanvas")
        bar = document.getElementById("hud")
        @world = new World canvas, bar
        console.log('\t stage completed')


    addEventHandlers: () ->
        @socket.on "connected", @onConnected.bind this
        @socket.on "joined", @gameSetup.bind this
        @socket.on "update", @onUpdate.bind this
        @socket.on "start", @gameStart.bind this
        @socket.on "remove", @onRemove.bind this
        @socket.on "new player", @onNewPlayer.bind this
        @socket.on "player disconnect", @onPlayerDisconnect.bind this
        createjs.Ticker.addEventListener "tick", @onTick.bind this
        # createjs.Ticker.addEventListener "tick", @world.detectCollision.bind @world

    # update game from server data
    onUpdate: (data) ->
        for object in data.objects          
            if object.type in ["player","robot"]
                player = @world.getPlayer(object.id)
                if player != null
                    player.update(object)
                else
                    #create a new character
                    character = @buildCharacter(object)
                    console.log(character)
                    @world.addPlayer character, @player_count
                    @player_count += 1
            if object.type == "magic"
                magic = @world.getObject(object.id)
                if magic == null
                    magic = new Magic object.id, object.name, object.x, object.y, @world, object.characterID, object.direction, object.magicSheetInfo
                else
                    magic.get().x = object.x
                    magic.get().y = object.y

    onRemove: (data) ->
        target = @world.getObject(data.object.id)
        if target != null
            @world.removeObject target

    # Connected to Server
    onConnected: (data) ->
        @id = data.id
        @gameid = data.gameid
        console.log('client id is ' + @id)
        console.log('game id is ' + data.gameid)


    gameStart: (data) ->
        console.log("receive game started")


    gameSetup: (data) ->
        console.log('\t player ' + @id + ' has joined game');
        @gameid = data.gameid
        @world.build(data.world)
        createjs.Ticker.addEventListener "tick", @world.stage
        character = @buildCharacter(data.character)
        console.log(character)
        @world.addPlayer character, @player_count
        @player_count += 1

        @localPlayer = character
        createjs.Ticker.addEventListener "tick", ((evt) ->
        ).bind this

        window.addEventListener "keydown", ((e) ->
            @keysDown[e.keyCode] = true
        ).bind this

        window.addEventListener "keyup", ((e) ->
            @keysDown[e.keyCode] = false
            if (!@keysDown[Constant.KEYCODE_RIGHT] && !@keysDown[Constant.KEYCODE_LEFT] && !@keysDown[Constant.KEYCODE_UP] && !@keysDown[Constant.KEYCODE_DOWN])
                if (@localPlayer.get().currentAnimation == "run")
                    # player.character.gotoAndPlay 'idle'
                    @socket.emit "update", {id:@id, action:"keyup"}
        ).bind this

        @localPlayer.get().addEventListener "animationend", ((evt) =>
            switch @localPlayer.state
                when 'die'
                    @socket.emit "update", {id:@id, action:"animationend"}
                    break
                when 'disabled'
                    break
                when 'collided'
                    break
                when 'attack'
                    @socket.emit "update", {id:@id, action:"animationend"}
                    @localPlayer.idle()
                when 'hurt'
                    @socket.emit "update", {id:@id, action:"animationend"}
                    @localPlayer.idle()
                when 'cast'
                    @socket.emit "update", {id:@id, action:"animationend"}
                    @localPlayer.idle()
                else
                    @localPlayer.idle()
        ).bind this

    onNewPlayer: (data) ->
        if !(@playerExists data.id)
            console.log 'Add new player to stage ' + data.id
            player = @buildCharacter(data.player)
            @world.addPlayer player,@player_count
            # @addPlayerUI(@player_count)
            @player_count += 1


    onPlayerDisconnect: (data) ->
        if (@world.playerExists data.id)
            console.log 'player:' + data.id + ' leave the game'
            @world.removePlayer player
            @player_count -= 1


    # This event is trigged every frame
    onTick: (e) ->
        # Check which key is been pressed
        if @checkState(@localPlayer)
            if @keysDown[Constant.KEYCODE_J]
                @socket.emit "update", {id:@id, action:'attack'}
                @localPlayer.state = "attack"
                return
            if @keysDown[Constant.KEYCODE_K]
                @socket.emit "update", {id:@id, action:'cast'}
                @localPlayer.state = "cast"
                return
            if @keysDown[Constant.KEYCODE_RIGHT]
                @socket.emit "update", {id:@id, action:'run', dir:'right'}
                return
            if @keysDown[Constant.KEYCODE_LEFT]
                @socket.emit "update", {id:@id, action:'run', dir:'left'}
                return
            if @keysDown[Constant.KEYCODE_UP]
                @socket.emit "update", {id:@id, action:'run', dir:'up'}
                return
            if @keysDown[Constant.KEYCODE_DOWN]
                @socket.emit "update", {id:@id, action:'run', dir:'down'}
                return

    onKeyDown: (e) ->
        @keysDown[e.keyCode] = true

    onKeyUp: (e) ->
        @keysDown[e.keyCode] = false


    # Member Functions #############################################################################
    is_outofBound: (object) ->
        bound = @world.getBound()
        return object.x > bound['x2'] or object.x < 0 or object.y > bound['y2'] or object.y < 0

    # addPlayerUI: (number) ->


    checkState:(player) ->
        if player == null
            return false
        if player.state in ['collided', 'disabled','hurt','attack']
            return false
        return true

    buildCharacter: (object) =>
        character = new Character object.id, object.name, object.type, object.x, object.y , @world
        character.build(object.spriteSheetInfo, object.magicSheetInfo)
        return character