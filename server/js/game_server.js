// Generated by CoffeeScript 1.7.1
(function() {
  var Game, Player, Server;

  Game = require("./game.js");

  Player = require("./character.js");

  Server = (function() {
    function Server(io) {
      this.io = io;
      this.util = require("util");
      this.games = [];
      this.game_count = 0;
      this.clients = [];
      this.init();
    }

    Server.prototype.init = function() {
      this.fake_latency = 0;
      this.local_time = 0;
      this._dt = new Date().getTime();
      return this._dte = new Date().getTime();
    };

    Server.prototype.findGame = function(client) {
      var joined;
      joined = false;
      if (this.game_count > 0 && client.gameid !== null) {
        joined = this.joinGame(client);
      }
      if (joined === false) {
        return this.createGame(client);
      }
    };

    Server.prototype.createGame = function(client) {
      var game, player;
      game = new Game(client.gameid, this.io);
      player = game.onNewPlayer(client);
      this.startGame(game.id);
      this.game_count += 1;
      this.games.push(game);
      client.emit('joined', {
        id: client.userid,
        gameid: client.gameid,
        world: game.world,
        character: player
      });
      return console.log("player " + client.userid + ' has joined game ' + client.gameid);
    };

    Server.prototype.joinGame = function(client) {
      var game, player, _i, _len, _ref;
      _ref = this.games;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        game = _ref[_i];
        if (game.id === client.gameid && game.player_count < game.max_player) {
          player = game.onNewPlayer(client);
          client.emit('joined', {
            id: client.userid,
            gameid: client.gameid,
            world: game.world,
            character: player
          });
          this.startGame(game);
          return true;
        }
      }
      return false;
    };

    Server.prototype.endGame = function(game_id, client_id) {
      var game, index, _i, _len, _ref;
      _ref = this.games;
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        game = _ref[index];
        if (game.id === game_id) {
          this.util.log('client ' + this.id + ' has disconnected');
          game.onRemovePlayer(client_id);
          if (game.player_count === 0) {
            this.games.splice(index, 1);
            this.game_count -= 1;
          }
          return true;
        }
      }
      return false;
    };

    Server.prototype.startGame = function(game) {
      if (game.active === true) {
        return;
      }
      if (game.player_count > game.min_player) {
        game.active = true;
        return game.startUpdate();
      }
    };

    Server.prototype.onUpdate = function(client, data) {
      var game;
      game = this.getGame(client.gameid);
      return game.handleInput(data);
    };

    Server.prototype.getGame = function(id) {
      var game, _i, _len, _ref;
      _ref = this.games;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        game = _ref[_i];
        if (game.id === id) {
          return game;
        }
      }
      return null;
    };

    Server.prototype.removeClient = function(target) {
      var client, index, _i, _len, _ref, _results;
      _ref = this.clients;
      _results = [];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        client = _ref[index];
        if (client.userid === target.userid) {
          _results.push(this.clients.splice(index, 1));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    return Server;

  })();

  module.exports = Server;

}).call(this);
