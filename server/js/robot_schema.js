robot_schema = {
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
            }
        },
        images: ["assets/spritesheets/julian/julian.png", "assets/spritesheets/julian/Attack.png"],
        frames: {
            height: 100,
            width: 80,
            regX: 40,
            regY: 40
        }
    },
    magicSheetInfo: {
        name: 'blue',
        animations: {
            cast: {
                frames: [20, 21, 22],
                frequency: 5
            }
        },
        images: ["assets/spritesheets/magic/magic.png"],
        frames: {
            height: 40,
            width: 40,
            regX: 20,
            regY: 20
        }
    }
}

module.exports = robot_schema