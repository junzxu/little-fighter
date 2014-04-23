// Generated by CoffeeScript 1.7.1
(function() {
  window.Arena = (function() {
    function Arena(w, h, players) {
      this.w = w;
      this.h = h;
      this.players = players != null ? players : {};
      this.container = new createjs.Container();
      this.container.x = 0;
      this.container.y = 0;
      this.background = new createjs.Bitmap("assets/background/1.png");
      this.container.addChild(this.background);
      this.init();
    }

    Arena.prototype.init = function() {
      var p, _i, _len, _ref, _results;
      _ref = this.players;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        p = _ref[_i];
        console.log('add');
        _results.push(this.container.addChild(p.getPlayer()));
      }
      return _results;
    };

    Arena.prototype.setPosition = function(x, y) {
      this.container.x = x;
      return this.container.y = y;
    };

    Arena.prototype.addPlayer = function(player) {
      this.container.addChild(player.getPlayer());
      return this.players.push(player);
    };

    Arena.prototype.addToStage = function(stage) {
      return stage.addChild(this.container);
    };

    Arena.prototype.getPlayers = function() {
      return this.players;
    };

    Arena.prototype.getBound = function() {
      return {
        "x1": 0,
        "x2": this.background.image.width,
        "y1": 0,
        "y2": this.background.image.height
      };
    };

    return Arena;

  })();

}).call(this);
