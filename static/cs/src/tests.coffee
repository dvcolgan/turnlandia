test 'test getColRowFromHash', ->
    window.location.hash = '#/3/2/'
    deepEqual({col: 3, row: 2}, getColRowFromHash(), 'getColRowFromHash should get the col and row from the hash part of the url')

    window.location.hash = '#/-3/-2/'
    deepEqual({col: -3, row: -2}, getColRowFromHash(), 'negative coordinates')

    window.location.hash = '#'
    pos = getColRowFromHash()
    deepEqual({col: 0, row: 0}, getColRowFromHash(), 'getColRowFromHash should default to 0, 0 if there is no hash')
