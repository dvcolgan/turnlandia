ig.module(
    'game.unit'
)
.requires(
    'impact.entity'
)
.defines =>

    @Unit = ig.Entity.extend

        name: 'unit'

        size: { x:20, y:20 }
        offset: { x:0, y:0 }

        animSheet: new ig.AnimationSheet('images/unit.png', 20, 20)

        init: (x, y, settings) ->
            @addAnim('idle', 0.2, [0])

            @parent(x, y, settings)


