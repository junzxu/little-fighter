class window.Game
    init: ->
        @keysDown = {}
        @players = []
        @magics = {}  #store spritesheets info of all magics
        @player_count = 1
        @stageInit()
        @serverInit()
        @localPlayer = null
        createjs.Ticker.setFPS 60
        @ready = false  #if game has started

        @lastKeyPress = new Date()
        @addEventHandlers()


    # Server setup
    serverInit: () ->
        if @id == null
            q = "?name=" + @username
        else
            q = "?id=" + @id + "&name=" + @username
        connectURL = "localhost/" + q
        @socket = io.connect connectURL, {port: 3000, transports: ["websocket"],'force new connection': true }
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
        @socket.on "fail", @onConnectionFail.bind this
        @socket.on "joined", @gameSetup.bind this
        @socket.on "start", @gameStart.bind this
        @socket.on "update", @onUpdate.bind this
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
            if object.type == "magic"
                magic = @world.getObject(object.id)
                if magic == null
                    magicName = object.name
                    magicSheetInfo = @magics[magicName]
                    magic = new Magic object.id, object.name, object.x, object.y, @world, object.characterID, object.direction, magicSheetInfo
                else
                    magic.get().x = object.x
                    magic.get().y = object.y
        #change render order
            @world.get().sortChildren(@renderOrder)


    renderOrder:(obj1, obj2) ->
        #object near top get rendered first 
         if (obj1.y > obj2.y)
            return 1
         if (obj1.y < obj2.y)
            return -1
         return 0


    onRemove: (data) ->
        target = @world.getObject(data.object.id)
        if target != null
            @world.removeObject target

    # Connected to Server
    onConnected: (data) ->
        @userid = data.id
        @id = data.gameid
        console.log('client id is ' + @userid)
        console.log('game id is ' + @gameid)


    onConnectionFail: (data) ->
        console.log "connection failed"
        @socket.disconnect()
        imgURL = '/404'
        $('#hud').replaceWith('<div id="hud"></div>');
        $('#gameCanvas').replaceWith('<img id= "notfound" src=' + imgURL + ' />');


    gameSetup: (data) ->
        if data.gamestate
            @gameStart()
        @id = data.gameid
        @world.build(data.world)
        createjs.Ticker.addEventListener "tick", @world.stage
        #add local player
        character = @buildCharacter(data.character)
        @world.addPlayer character, @player_count
        @localPlayer = character
        @localPlayer.isLocal = true
        @localPlayer.username = @username
        @addPlayerUI(@localPlayer, @player_count)
        @player_count += 1
        console.log(character.name + ' has joined game')
        #add other players
        for player in data.players
            if player.id == @localPlayer.id
                continue
            character = @buildCharacter(player)
            @world.addPlayer character, @player_count
            @addPlayerUI(player, @player_count)
            @player_count += 1
            console.log(character.name + ' has joined game')

        createjs.Ticker.addEventListener "tick", ((evt) ->
        ).bind this

        window.addEventListener "keydown", ((e) ->
            @keysDown[e.keyCode] = true
        ).bind this

        window.addEventListener "keyup", ((e) ->
            @keysDown[e.keyCode] = false
            if (!@keysDown[Constant.KEYCODE_RIGHT] && !@keysDown[Constant.KEYCODE_LEFT] && !@keysDown[Constant.KEYCODE_UP] && !@keysDown[Constant.KEYCODE_DOWN])
                if @localPlayer.state == "run"
                    @socket.emit "update", {id:@userid, action:"keyup"}
        ).bind this

        @localPlayer.get().addEventListener "animationend", ((evt) =>
            switch @localPlayer.state
                when 'die'
                    break
                when 'disabled'
                    break
                when 'collided'
                    break
                when 'attack'
                    @socket.emit "update", {id:@userid, action:"animationend"}
                    @localPlayer.idle()
                when 'hurt'
                    @socket.emit "update", {id:@userid, action:"animationend"}
                    @localPlayer.idle()
                when 'cast'
                    @socket.emit "update", {id:@userid, action:"animationend"}
                    @localPlayer.idle()
                else
                    @localPlayer.idle()
        ).bind this


    gameStart:->
        @ready = true
        @world.get().removeChild @world.helpText


    onNewPlayer: (data) ->
        if @localPlayer == null
            return
        if not @world.playerExists data.id and data.id != @localPlayer.id
            console.log 'Add new player to stage ' + data.id
            player = @buildCharacter(data.player)
            @world.addPlayer player,@player_count
            @addPlayerUI(player, @player_count)
            @player_count += 1


    onPlayerDisconnect: (data) ->
        if (@world.playerExists data.id)
            console.log 'player:' + data.id + ' leave the game'
            @world.removeById data.id
            @player_count -= 1


    # This event is trigged every frame
    onTick: (e) ->
        # Check which key is been pressed
<<<<<<< HEAD
        if (@keysDown[Constant.KEYCODE_D])
            @localPlayer.run 'right'
            @socket.emit "update", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y, dir:"right"}

        if (@keysDown[Constant.KEYCODE_A])
            @localPlayer.run 'left'
            @socket.emit "update", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y, dir:"left"}

        if (@keysDown[Constant.KEYCODE_S])
            @socket.emit "update", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y, dir:"down"}
            @localPlayer.run 'down'

        if (@keysDown[Constant.KEYCODE_W])
            @socket.emit "update", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y, dir:"up"}
            @localPlayer.run 'up'

        if (@keysDown[Constant.KEYCODE_J])
            @localPlayer.attack()
            @socket.emit "attack", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y}

        if (@keysDown[Constant.KEYCODE_K])
            @localPlayer.cast()
            @socket.emit "magic", {id:@clientID, x:@localPlayer.x, y:@localPlayer.y}

=======
        if @checkState(@localPlayer)
            if @keysDown[Constant.KEYCODE_J]
                @socket.emit "update", {id:@userid, action:'attack'}
                @localPlayer.state = "attack"
                return
            if @keysDown[Constant.KEYCODE_K]
                @socket.emit "update", {id:@userid, action:'cast'}
                @localPlayer.state = "cast"
                return
            if @keysDown[Constant.KEYCODE_RIGHT] and @keysDown[Constant.KEYCODE_UP]
                @socket.emit "update", {id:@userid, action:'run', dir:'ur'}
                return
            if @keysDown[Constant.KEYCODE_LEFT] and @keysDown[Constant.KEYCODE_UP]
                @socket.emit "update", {id:@userid, action:'run', dir:'ul'}
                return
            if @keysDown[Constant.KEYCODE_RIGHT] and @keysDown[Constant.KEYCODE_DOWN]
                @socket.emit "update", {id:@userid, action:'run', dir:'dr'}
                return
            if @keysDown[Constant.KEYCODE_LEFT] and @keysDown[Constant.KEYCODE_DOWN]
                @socket.emit "update", {id:@userid, action:'run', dir:'dl'}
                return
            if @keysDown[Constant.KEYCODE_RIGHT]
                @socket.emit "update", {id:@userid, action:'run', dir:'right'}
                return
            if @keysDown[Constant.KEYCODE_LEFT]
                @socket.emit "update", {id:@userid, action:'run', dir:'left'}
                return
            if @keysDown[Constant.KEYCODE_UP]
                @socket.emit "update", {id:@userid, action:'run', dir:'up'}
                return
            if @keysDown[Constant.KEYCODE_DOWN]
                @socket.emit "update", {id:@userid, action:'run', dir:'down'}
                return
>>>>>>> dev

    onKeyDown: (e) ->
        @keysDown[e.keyCode] = true

    onKeyUp: (e) ->
        @keysDown[e.keyCode] = false


    # Member Functions #############################################################################
    is_outofBound: (object) ->
        bound = @world.getBound()
        return object.x > bound['x2'] or object.x < 0 or object.y > bound['y2'] or object.y < 0


    checkState:(player) ->
        if player == null or @ready == false
            return false
        if player.state in ['collided', 'disabled','hurt',"die"]
            return false
        return true

    buildCharacter: (object) =>
        character = new Character object.id, object.name, object.type, object.x, object.y , @world
        character.faceDirection = object.faceDirection
        character.maxhp = object.maxhp
        character.build(object.spriteSheetInfo, object.magicSheetInfo)
        # build magic book
        magicSheetInfo = object.magicSheetInfo
        magicName = object.magicInfo.name
        @magics[magicName] = magicSheetInfo
        return character

    addPlayerUI :(player,number) ->
        imgURL = '"assets/spritesheets/' + player.name + '/profile.png"'
        img = '<img src=' + imgURL + ' class="my-thumbnail"/>'
        pnumber = "#player" + number
        $('#hud > .row >' + pnumber + ' > .row >#stats >#name >h4').html(player.username)
        $('#hud > .row > ' + pnumber + ' > .row >#profile').append(img)
        $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').html(player.maxhp)     
