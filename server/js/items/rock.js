item_schema = {
    info: {
        maxhp: 300,
        width: 100,
        height: 100,
        collisionHeight: 10,
        collisionWidth: 10
    },
    spriteSheetInfo: {
        animations: {
            idle: {
                frames: [0, 0, 0],
                frequency: 10
            },
            run: {
                frames: [0, 1, 2],
                frequency: 20
            },
            hurt: {
                frames: [0, 0, 0],
                next: "idle",
                frequency: 20
            }
        },
        images: ["assets/spritesheets/items/rock.png"],
        frames: {
            height: 50,
            width: 55,
            regX: 27,
            regY: 25
        }
    }
}

module.exports = item_schema