item_schema = {
    info: {
        maxhp: 100,
        width: 50,
        height: 50,
        collisionHeight: 10,
        collisionWidth: 10
    },
    spriteSheetInfo: {
        animations: {
            idle: {
                frames: [0],
                frequency: 10
            },
            hurt: {
                frames: [0],
                next: "idle",
                frequency: 10
            }
        },
        images: ["assets/spritesheets/items/resize_health.png"],
        frames: {
            height: 50,
            width: 50,
            regX: 25,
            regY: 25
        }
    },
    gotHit: function(damage, direction) {
        //direction indicates where the hit come from
        this.state = "removed";
    },
    collisionHandler: function(o) {
        if (o.type == "player" || o.type == "robot") {
            o.hp += 10;
        }
        this.state = "removed";
    }
}

module.exports = item_schema