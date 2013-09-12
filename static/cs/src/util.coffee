class Util
    @calculate_distance: (x1, y1, x2, y2) ->
        Math.sqrt((x2 - x1)*(x2 - x1) + (y2 - y1)*(y2 - y1))

    @random_choice: (collection) ->
        collection[Math.floor(Math.random()*collection.length)]


