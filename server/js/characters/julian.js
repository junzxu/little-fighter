robot_schema = {
    info: {
        maxhp: 300,
        damage: 15,
        attackRange: 50,
        width: 80,
        height: 100,
        originSpeed: 1,
        sightRange: 200
    },
    spriteSheetInfo: {
        animations: {
            idle: {
                frames: [0, 1, 2, 3, 2],
                frequency: 10
            },
            run: {
                frames: [4, 5, 6, 7],
                frequency: 10
            },
            attack: {
                frames: [50, 51, 52, 53],
                next: "idle",
                frequency: 10
            },
            cast: {
                frames: [71, 72, 73, 74, 75, 76, 77, 78],
                next: "idle",
                frequency: 10
            },
            hurt: {
                frames: [41, 42, 43, 44],
                next: "idle",
                frequency: 10
            },
            die: {
                frames: [16, 15, 14, 14, 14],
                next: "lay",
                frequency: 10
            },
            lay: {
                frames: [14]
            },
            teleport: {
                frames: [60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70],
                next: "idle",
                frequency: 10
            }
        },
        images: ["assets/spritesheets/julian/julian.png", "assets/spritesheets/julian/Attack.png", "assets/spritesheets/julian/teleport.png", "assets/spritesheets/julian/cast.png"],
        frames: {
            height: 100,
            width: 80,
            regX: 40,
            regY: 40
        }
    }
}

module.exports = robot_schema