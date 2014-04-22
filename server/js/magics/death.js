magic_schema = {
    info: {
        name: 'death',
        damage: 30,
        cd: 500,
        originSpeed: 5,
        width: 62,
        height: 42
    },
    magicSheetInfo: {
        animations: {
            cast: {
                frames: [0, 3],
                frequency: 8
            }
        },
        images: ["assets/spritesheets/magic/death.png"],
        frames: {
            height: 42,
            width: 62,
            regX: 31,
            regY: 21
        }
    },
    magic: function(game, player, id) {
        bound = player.getRect();
        width = bound.x2 - bound.x1;
        x = player.faceDirection === 'right' ? bound.x2 : bound.x1;
        game.addMagic(id, player.magicInfo, x, player.y, this.world, player.id, player.faceDirection)
    }
}

module.exports = magic_schema