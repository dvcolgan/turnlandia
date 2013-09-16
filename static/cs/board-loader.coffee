
class BoardLoader

    load_sector: (sector_x, sector_y) ->
        # Don't load the sector if it is beyond the current board extent
        if (sector_x > @max_sector_x or
        sector_x < @min_sector_x or
        sector_y > @max_sector_y or
        sector_y < @min_sector_y)
            return

        if sector_x not of @sectors
            @sectors[sector_x] = {}
        if sector_y not of @sectors[sector_x]
            $sector_dom_node = $('<div class="sector disable-select"></div>')
            @$dom_node.append($sector_dom_node)
            @sectors[sector_x][sector_y] = new Sector(@, $sector_dom_node, sector_x, sector_y, TB.sector_size)
        else
            @sectors[sector_x][sector_y].show()
    load_sector_of_point: (col, row) ->
        sector_x = Math.floor(col / TB.sector_size) * TB.sector_size
        sector_y = Math.floor(row / TB.sector_size) * TB.sector_size
        @load_sector(sector_x, sector_y)


    load_sectors_on_screen: ->
        sector_pixel_size = TB.sector_size * TB.grid_size
        sectors_wide  = Math.ceil(@get_view_width() / TB.sector_size / TB.grid_size)
        sectors_high = Math.ceil(@get_view_height() / TB.sector_size / TB.grid_size)

        for sector_col in [0..sectors_wide]
            for sector_row in [0..sectors_high]
                x = (Math.floor(@scroll.x / sector_pixel_size)) + sector_col
                y = (Math.floor(@scroll.y / sector_pixel_size)) + sector_row
                @load_sector(x, y)

    containing_sector_loaded: (col, row) ->
        sector_x = Math.floor(col / TB.sector_size) * TB.sector_size
        sector_y = Math.floor(row / TB.sector_size) * TB.sector_size
        return (sector_x of @sectors and sector_y of @sectors[sector_x])



