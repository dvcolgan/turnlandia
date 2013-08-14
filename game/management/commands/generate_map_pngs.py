from django.core.management.base import BaseCommand, CommandError
from game.models import *
from settings import MIN_COL, MAX_COL, MIN_ROW, MAX_ROW, GRID_SIZE
from PIL import Image
from PIL import ImageDraw


def hex_to_rgb(value):
    value = value.lstrip('#')
    lv = len(value)
    if lv == 1:
        v = int(value, 16)*17
        return v, v, v
    if lv == 3:
        return tuple(int(value[i:i+1], 16)*17 for i in range(0, 3))
    return tuple(int(value[i:i+lv/3], 16) for i in range(0, lv, lv/3))

class Command(BaseCommand):
    args = ''
    help = 'Generate pngs of the board for zooming'

    def handle(self, *args, **options):
        squares = Square.objects.order_by('row', 'col')
        #first = squares[0]
        #last = squares[squares.count()-1]

        width = (MAX_COL - MIN_COL) * GRID_SIZE
        height = (MAX_ROW - MIN_ROW) * GRID_SIZE

        im = Image.new('RGB', (width, height), 'black')

        #color_dict = {}
        #for color in COLORS:
        #    color_dict[color[0]] = (color[1], color[2])

        #http://effbot.org/imagingbook/imagedraw.htm
        draw = ImageDraw.Draw(im)

        #for square in squares:
        #    if square.col < -20:
        #        continue
        #    if square.row < -20:
        #        continue
        #    if square.col > 20:
        #        continue
        #    if square.row > 20:
        #        continue
        #    print square.col, square.row
        #    if square.owner != None:
        #        fill_color = square.owner.color
        #    else:
        #        fill_color = '#ffffff'

        #    x1 = square.col*GRID_SIZE+width/2
        #    y1 = square.row*GRID_SIZE+height/2
        #    x2 = square.col*GRID_SIZE+GRID_SIZE+width/2
        #    y2 = square.row*GRID_SIZE+GRID_SIZE+height/2

        #    draw.rectangle(((x1, y1), (x2, y2)), fill=fill_color, outline='#cccccc')

        #    for i, unit in enumerate(square.units.all()):
        #        if i == 0:
        #            ax1 = x1 + GRID_SIZE/4 - GRID_SIZE/8
        #            ay1 = y1 + GRID_SIZE/4 - GRID_SIZE/8
        #            ax2 = x1 + GRID_SIZE/4 + GRID_SIZE/8
        #            ay2 = y1 + GRID_SIZE/4 + GRID_SIZE/8
        #        if i == 1:
        #            ax1 = x1 + 3*GRID_SIZE/4 - GRID_SIZE/8
        #            ay1 = y1 + 3*GRID_SIZE/4 - GRID_SIZE/8
        #            ax2 = x1 + GRID_SIZE/4 + GRID_SIZE/8
        #            ay2 = y1 + GRID_SIZE/4 + GRID_SIZE/8
        #        if i == 2:
        #            ax1 = x1 + 3*GRID_SIZE/4 - GRID_SIZE/8
        #            ay1 = y1 + 3*GRID_SIZE/4 - GRID_SIZE/8
        #            ax2 = x1 + 3*GRID_SIZE/4 + GRID_SIZE/8
        #            ay2 = y1 + 3*GRID_SIZE/4 + GRID_SIZE/8
        #        if i == 3:
        #            ax1 = x1 + GRID_SIZE/4 - GRID_SIZE/8
        #            ay1 = y1 + GRID_SIZE/4 - GRID_SIZE/8
        #            ax2 = x1 + 3*GRID_SIZE/4 + GRID_SIZE/8
        #            ay2 = y1 + 3*GRID_SIZE/4 + GRID_SIZE/8

        #        draw.arc(((ax1, ay1, ax2, ay2)), 0, 360, fill=unit.owner.color)

        draw.arc(((1000, 1000, 1200, 1200)), 0, 360, outline='#ffff88')
        im.save('static/images/minimap.png', 'PNG')
        print 'Saved full image'
