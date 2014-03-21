// Generated by CoffeeScript 1.7.1
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Character = (function(_super) {
    __extends(Character, _super);

    function Character(id, name, type, x, y, world) {
      this.id = id;
      this.name = name;
      this.type = type;
      this.x = x;
      this.y = y;
      this.world = world;
      Character.__super__.constructor.call(this, this.id, this.name, this.type, this.x, this.y, this.world);
      this.hp = 100;
      this.cd = 300;
      this.attackRange = 50;
      this.number;
      this.character;
      this.faceDirection = "right";
      this.init();
    }

    Character.prototype.init = function() {
      Character.__super__.init.apply(this, arguments);
      this.state = "idle";
      return this.direction = "No";
    };

    Character.prototype.build = function(spriteSheetInfo, magicSheetInfo) {
      this.spriteSheetInfo = spriteSheetInfo;
      this.magicSheetInfo = magicSheetInfo;
      this.SpriteSheet = new createjs.SpriteSheet(this.spriteSheetInfo);
      this.character = new createjs.BitmapAnimation(this.SpriteSheet);
      this.character.x = this.x;
      this.character.y = this.y;
      return this.character.gotoAndPlay("idle");
    };

    Character.prototype.addToWorld = function(world) {
      world.addPlayer(this);
      return this.world = world;
    };

    Character.prototype.get = function() {
      return this.character;
    };

    Character.prototype.changeFaceDirection = function(direction) {
      if (this.faceDirection === direction) {

      } else {
        this.faceDirection = direction;
        return this.get().scaleX = -this.get().scaleX;
      }
    };

    Character.prototype.run = function(direction) {
      if (this.character.currentAnimation !== "run") {
        this.character.gotoAndPlay("run");
      }
      this.direction = direction;
      if (direction === "left" || direction === "right") {
        this.changeFaceDirection(direction);
      }
      return this.state = "run";
    };

    Character.prototype.attack = function() {
      if (this.character.currentAnimation !== "attack") {
        return this.character.gotoAndPlay("attack");
      }
    };

    Character.prototype.cast = function() {
      if (this.character.currentAnimation !== "cast") {
        this.character.gotoAndPlay("cast");
      }
      return this.state = "cast";
    };

    Character.prototype.die = function() {
      if (this.state !== "die") {
        if (this.character.currentAnimation !== "die") {
          this.character.gotoAndPlay("die");
          this.state = "die";
          return this.world.get().removeChild(this.character);
        }
      }
    };

    Character.prototype.idle = function() {
      this.speed = 0;
      this.direction = "No";
      if (this.character.currentAnimation !== "idle") {
        this.character.gotoAndPlay("idle");
      }
      return this.state = "idle";
    };

    Character.prototype.gotHit = function(direction) {
      this.changeFaceDirection(direction);
      if (this.character.currentAnimation !== "hurt") {
        this.character.gotoAndPlay("hurt");
      }
      return this.state = "hurt";
    };

    Character.prototype.setHPBar = function(hp) {
      var pnumber;
      pnumber = "#player" + this.number;
      $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').css("width", hp + "%");
      return $('#hud > .row > ' + pnumber + ' > .row >#stats > .progress > #hp').html(hp);
    };

    Character.prototype.update = function(object) {
      switch (object.state) {
        case 'die':
          return this.die();
        case 'hurt':
          this.gotHit(object.direction);
          this.hp = object.hp;
          return this.setHPBar(this.hp);
        case 'run':
          this.run(object.direction);
          this.get().x = object.x;
          return this.get().y = object.y;
        case 'attack':
          return this.attack();
        case 'cast':
          return this.cast();
        case 'idle':
          if (this.state === "die") {
            this.character.x = object.x;
            this.character.y = object.y;
            this.world.get().addChild(this.character);
          }
          return this.idle();
      }
    };

    return Character;

  })(object);

}).call(this);
