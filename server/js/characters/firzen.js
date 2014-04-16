player_schema = {
    info: {
        maxhp: 100,
        damage: 15,
        attackRange: 70,
        width: 80,
        height: 80,
        originSpeed: 2
    },
    spriteSheetInfo: {
        animations: {
            idle: {
                frames: [0, 1, 2, 3, 2],
                frequency: 10
            },
            run: {
                frames: [20, 21, 22, 21],
                frequency: 10
            },
            attack: {
                frames: [10, 11, 12, 13, 14, 15, 16, 17],
                frequency: 10
            },
            cast: {
                frames: [70, 71, 72],
                frequency: 10
            },
            hurt: {
                frames: [53, 54, 55],
                frequency: 10
            },
            die: {
                frames: [30, 31, 32, 33, 34, 35, 34],
                next: "lay",
                frequency: 10
            },
            lay: {
                frames: [34]
            },
            idle_invisible: {
                frames: [73, 74, 75, 76, 75],
                frequency: 10
            },
            run_invisible: {
                frames: [93, 94, 95, 94],
                frequency: 10
            }
        },
        images: ["assets/spritesheets/firzen/firzen.png", "assets/spritesheets/firzen/firzen_cast.png"],
        frames: {
            height: 80,
            width: 80,
            regX: 40,
            regY: 40
        }
    }
}

module.exports = player_schema