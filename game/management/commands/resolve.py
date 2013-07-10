from django.core.management.base import BaseCommand, CommandError
from game.models import *

class Command(BaseCommand):
    args = ''
    help = 'Run this command whenever the turn is over.'

    def handle(self, *args, **options):
        day_setting = Setting.objects.get(name='Current Day')
        day_setting.value += 1
        day_setting.save()
        for square in Square.objects.all():
            if square.units.count() > 0:
                if square.units.count() == 1:
                    # If you are the only one claiming this square, you get it
                    square.owner = square.units.all()[0].owner
                    #square.units.all()[0].last_turn_amount = square.units.all()[0].amount
                    #square.units.all()[0].save()
                    square.save()
                #else:
                #    # Otherwise resolve the battle, current algorithm:
                #    # Find the largest unit amount
                #    # scale everyone else's units

                #    #4 vs 3
                #    #[1,1,1,1]
                #    #[.75,.75,.75,.75]
                    
                    

