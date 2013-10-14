from django.core.management.base import BaseCommand, CommandError
from game.models import *
import noise
from PIL import Image, ImageFilter, ImageOps

def hex_to_rgb(value):
    value = value.lstrip('#')
    lv = len(value)
    if lv == 1:
        v = int(value, 16)*17
        return v, v, v
    if lv == 3:
        return tuple(int(value[i:i+1], 16)*17 for i in range(0, 3))
    return tuple(int(value[i:i+lv/3], 16) for i in range(0, lv, lv/3))

def terrain_type_for_square(col, row):
    terrain_type = 'plains'

    frequency = 1.0/5
    forest_value = noise.pnoise2(col*frequency, row*frequency, 20)
    if forest_value < -0.05:
        terrain_type = 'forest'

    frequency_x = 1.0/30
    frequency_y = 1.0/40
    mountain_value = noise.pnoise2(col*frequency, row*frequency, 1)
    if mountain_value > 0.2:
        terrain_type = 'mountains'

    frequency_x = 1.0/60
    frequency_y = 1.0/45
    river_value = noise.pnoise2(col*frequency_x, row*frequency_y, 10, -0.3)
    if river_value < 0.04 and river_value > -0.04:
        terrain_type = 'water'

    frequency = 1.0/30
    lake_value = noise.pnoise2(col*frequency, row*frequency, 6)
    if lake_value < -0.2:
        terrain_type = 'water'

    return terrain_type


class Command(BaseCommand):
    args = ''
    help = 'Generate a png file of the visible world using Pillow'

    def handle(self, *args, **options):
        size = 200

        im = Image.new('RGB', (size*2, size*2), (255, 255, 255))

        for row in range(-size, size):
            for col in range(-size, size):
                terrain_type = terrain_type_for_square(col, row)
                color = 'white'
                if terrain_type == 'plains':
                    color = hex_to_rgb('#148743')
                if terrain_type == 'forest':
                    color = hex_to_rgb('#006000')
                if terrain_type == 'mountains':
                    color = hex_to_rgb('#A0A0A0')
                if terrain_type == 'water':
                    color = hex_to_rgb('#0060C0')
                im.putpixel((col+size, row+size), color)
            print 'row', row

        ## Generate forests
        #frequency = 1.0/5
        #forest_pixels = [[noise.pnoise2(x*frequency, y*frequency, 20) for x in range(-size/2, size/2)] for y in range(-size/2, size/2)]
        #for y, row in enumerate(forest_pixels):
        #    for x, noise_value in enumerate(row):
        #        if noise_value < -0.05:
        #            im.putpixel((x, y), (0, 110, 0))

        ## Generate mountains
        #frequency = 1.0/5
        #mountain_pixels = [[noise.pnoise2(x*frequency, y*frequency, 1) for x in range(-size/2, size/2)] for y in range(-size/2, size/2)]
        #for y, row in enumerate(mountain_pixels):
        #    for x, noise_value in enumerate(row):
        #        if noise_value > 0.2:
        #            value = int((noise_value + 0.5) * 255) - 30
        #            im.putpixel((x, y), (value, value, value))

        ## Generate rivers
        #frequency_x = 1.0/45
        #frequency_y = 1.0/30
        #river_pixels = [[noise.pnoise2(x*frequency_x, y*frequency_y, 10, -0.3) for x in range(-size/2, size/2)] for y in range(-size/2, size/2)]
        #for y, row in enumerate(river_pixels):
        #    for x, noise_value in enumerate(row):
        #        if noise_value < 0.04 and noise_value > -0.04:
        #            value = 195 + int(abs(noise_value) * 25 * 150)
        #            if value > 255: value = 255
        #            im.putpixel((x, y), (0, 0, value))

        ## Generate lakes
        #frequency = 1.0/20
        #lake_pixels = [[noise.pnoise2(x*frequency, y*frequency, 6) for x in range(-size/2, size/2)] for y in range(-size/2, size/2)]
        #for y, row in enumerate(lake_pixels):
        #    for x, noise_value in enumerate(row):
        #        if noise_value < -0.2:
        #            value = 35 + int((noise_value + 0.5) * 3.3333 * 220)
        #            im.putpixel((x, y), (0, 0, value))

        im.save('static/images/noise.png', 'PNG')
