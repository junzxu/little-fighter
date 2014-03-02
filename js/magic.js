// Generated by CoffeeScript 1.7.1
(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Magic = (function(_super) {
    __extends(Magic, _super);

    function Magic(name, type, x, y, world, character, spriteSheetInfo, direction) {
      this.name = name;
      this.type = type;
      this.x = x;
      this.y = y;
      this.world = world;
      this.character = character;
      this.spriteSheetInfo = spriteSheetInfo;
      this.direction = direction;
      this.move = __bind(this.move, this);
      Magic.__super__.constructor.apply(this, arguments);
      this.magic;
    }

    Magic.prototype.init = function() {
      this.SpriteSheet = new createjs.SpriteSheet(this.spriteSheetInfo);
      this.magic = new createjs.BitmapAnimation(this.SpriteSheet);
      this.magic.x = this.x;
      this.magic.y = this.y;
      return this.speed = this.originSpeed;
    };

    Magic.prototype.cast = function() {
      console.log('cast magic on ' + this.direction);
      this.magic.addEventListener("tick", this.move);
      this.world.get().addChild(this.magic);
      return this.magic.gotoAndPlay("cast");
    };

    Magic.prototype.move = function(event) {
      var bound, magic;
      magic = event.target;
      bound = this.world.getBound();
      if (this.direction === "right") {
        magic.x += this.speed;
      } else {
        magic.x -= this.speed;
      }
      this.detectCollision();
      if (magic.x > bound['x2'] || magic.x < 0) {
        return this.world.get().removeChild(magic);
      }
    };

    Magic.prototype.collisionHandler = function(a, b) {
      b.gotHit(this.direction);
      console.log('hit player' + b.id);
      a.get().removeAllEventListeners();
      return a.world.get().removeChild(a.get());
    };

    Magic.prototype.get = function() {
      return this.magic;
    };

    return Magic;

  })(Object);

}).call(this);
