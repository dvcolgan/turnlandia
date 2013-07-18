ig.module(
    'game.board-square'
)
.requires(
    'impact.image'
    'impact.entity'
)
.defines =>

    @BoardSquare = ig.Entity.extend

        name: 'square'

        size: { x:42, y:42 }
        offset: { x:0, y:0 }

        animSheet: new ig.AnimationSheet('images/units.png', 42, 42)

        units: []

        init: (x, y, settings) ->
            @addAnim('0', 0.2, [0], true)
            @addAnim('1', 0.2, [1], true)
            @addAnim('2', 0.2, [2], true)
            @addAnim('3', 0.2, [3], true)
            @addAnim('4', 0.2, [4], true)

            @currentAnim = @anims['3']

            @parent(x, y, settings)

        draw: ->
            ctx = ig.system.context

            # Fill with the owner color
            ctx.fillStyle = @color or '#88899a'
            #ctx.fillStyle = '#00ffcc'
            ctx.fillRect(@pos.x - ig.game.screen.x, @pos.y - ig.game.screen.y, 42, 42)

            # Draw the grid over that
            ig.game.gridImage.draw(@pos.x - ig.game.screen.x, @pos.y - ig.game.screen.y)

            # Draw numbers
            xOffset = 16 - ig.game.screen.x
            yOffset = 12 - ig.game.screen.y
            if @wallHealth > 0
                ig.game.font.draw(@wallHealth, @pos.x + xOffset, @pos.y + yOffset)
            else if @resourceAmount > 0
                ig.game.font.draw(@resourceAmount, @pos.x + xOffset, @pos.y + yOffset)


            @parent()

    @Sector = ig.Entity.extend
        
