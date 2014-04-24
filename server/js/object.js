// Generated by CoffeeScript 1.7.1
(function() {
  var object,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  object = (function() {
    function object(name, type, x, y, bound) {
      this.name = name;
      this.type = type;
      this.x = x;
      this.y = y;
      this.bound = bound;
      this.moveStep = __bind(this.moveStep, this);
      this.id;
      this.type;
      this.spriteSheetInfo;
      this.magicState = "ready";
      this.init();
    }

    object.prototype.init = function() {
      this.state = "idle";
      this.animation = "idle";
      this.direction = "No";
      this.width;
      this.height;
      this.maxhp = 100;
      this.hp = this.maxhp;
      this.mass = 1;
      this.speed = 0;
      this.originSpeed = 0;
      this.collisionHeight = 20;
      return this.collisionWidth = 30;
    };

    object.prototype.setupInfo = function(info) {
      var k, v;
      for (k in info) {
        v = info[k];
        Object.defineProperty(this, k, {
          enumerable: true,
          configurable: true,
          writable: true,
          value: v
        });
      }
      return this.info = {
        'id': this.id,
        'name': this.name,
        'type': this.type,
        'width': this.width,
        'height': this.height,
        'originSpeed': this.originSpeed,
        'maxhp': this.maxhp
      };
    };

    object.prototype.counterDirection = function(direction) {
      switch (direction) {
        case "right":
          return "left";
          break;
        case "left":
          return "right";
          break;
        case "up":
          return "down";
          break;
        case "down":
          return "up";
          break;
        case "ur":
          return "dl";
        case "ul":
          return "dr";
        case "dr":
          return "ul";
        case "dl":
          return "ur";
        case "No":
          return "No";
      }
    };

    object.prototype.reverseDirection = function() {
      return this.direction = this.counterDirection(this.direction);
    };

    object.prototype.moveStep = function(direction, speed) {
      if (direction == null) {
        direction = null;
      }
      if (speed == null) {
        speed = null;
      }
      if (direction === null) {
        direction = this.direction;
      }
      if (speed === null) {
        speed = this.speed;
      }
      switch (direction) {
        case "no":
          break;
        case "left":
          this.direction = "left";
          if (this.x - speed > this.bound['x1']) {
            return this.x -= speed;
          } else {
            return this.x += speed;
          }
          break;
        case "right":
          this.direction = "right";
          if (this.x + speed < this.bound['x2']) {
            return this.x += speed;
          } else {
            return this.x -= speed;
          }
          break;
        case "down":
          this.direction = "down";
          if (this.y + speed < this.bound['y2']) {
            return this.y += speed;
          } else {
            return this.y -= speed;
          }
          break;
        case "up":
          this.direction = "up";
          if (this.y - speed > this.bound['y1']) {
            return this.y -= speed;
          } else {
            return this.y += speed;
          }
          break;
        case "ur":
          this.direction = "ur";
          if (this.y - speed > this.bound['y1']) {
            this.y -= speed;
          }
          if (this.x + speed < this.bound['x2']) {
            return this.x += speed;
          }
          break;
        case "ul":
          this.direction = "ul";
          if (this.y - speed > this.bound['y1']) {
            this.y -= speed;
          }
          if (this.x - speed > this.bound['x1']) {
            return this.x -= speed;
          }
          break;
        case "dr":
          this.direction = "dr";
          if (this.y + speed < this.bound['y2']) {
            this.y += speed;
          }
          if (this.x + speed < this.bound['x2']) {
            return this.x += speed;
          }
          break;
        case "dl":
          this.direction = "dl";
          if (this.y + speed < this.bound['y2']) {
            this.y += speed;
          }
          if (this.x - speed > this.bound['x1']) {
            return this.x -= speed;
          }
      }
    };

    object.prototype.moveTo = function(x, y) {
      if (x > this.bound['x1'] && x < this.bound['x2'] && y > this.bound['y1'] && y < this.bound['y2']) {
        this.x = x;
        return this.y = y;
      } else {
        return console.log('invalid coordinates: (' + x + ',' + y + ')');
      }
    };

    object.prototype.getRect = function() {
      var x1, x2, y1, y2;
      x1 = this.x - this.width / 2;
      y1 = this.y - this.height / 2;
      x2 = this.x + this.width / 2;
      y2 = this.y + this.height / 2;
      return {
        "x1": x1,
        "x2": x2,
        "y1": y1,
        "y2": y2
      };
    };

    object.prototype.getCollisionRect = function() {
      var x1, x2, y1, y2;
      x1 = this.x - this.width / 2 + this.collisionWidth;
      y1 = this.y - this.height / 2 + this.collisionHeight;
      x2 = this.x + this.width / 2 - this.collisionWidth;
      y2 = this.y + this.height / 2 - this.collisionHeight;
      return {
        "x1": x1,
        "x2": x2,
        "y1": y1,
        "y2": y2
      };
    };

    object.prototype.gotHit = function(direction) {
      return console.log("got hit");
    };

    object.prototype.realtiveDirection = function(object) {
      if (object.x < this.x) {
        return "left";
      }
      if (object.x >= this.x) {
        return "right";
      }
    };

    object.prototype.getStatus = function() {
      this.info.x = this.x;
      this.info.y = this.y;
      this.info.state = this.state;
      this.info.direction = this.direction;
      this.info.hp = this.hp;
      this.info.animation = this.animation;
      return this.info;
    };

    object.prototype.collide = function(direction) {
      if (this.direction === "No") {
        this.direction = direction;
        this.moveStep(direction, 10);
      } else {
        this.reverseDirection();
        this.moveStep();
      }
      this.speed = 2;
      return this.setState('collided');
    };

    object.prototype.collisionHandler = function(object, direction) {
      this.collide(direction);
      if (object.state !== "collided") {
        return object.collisionHandler(this, this.counterDirection(direction));
      }
    };

    object.prototype.distanceTo = function(object) {
      var d, squared;
      if (object === null) {
        return Infinity;
      }
      squared = Math.pow(this.x - object.x, 2) + Math.pow(this.y - object.y, 2);
      d = Math.sqrt(squared);
      return d;
    };

    object.prototype.inRange = function(bound) {
      if ((this.x < bound.x1) || (this.x > bound.x2) || (this.y > bound.y2) || (this.y < bound.y1)) {
        return false;
      } else {
        return true;
      }
    };

    return object;

  })();

  module.exports = object;

}).call(this);
