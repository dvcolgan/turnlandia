from django.core.management.base import BaseCommand, CommandError
from game.models import *

class Command(BaseCommand):
    args = ''
    help = 'Run this command whenever the turn is over.'

    def handle(self, *args, **options):
        for square in Square.objects.all():
            if square.units.count() > 0:
                if square.units.count() == 1:
                    # If you are the only one claiming this square, you get it
                    square.color = square.units.all()[0].color
                    square.units.all()[0].last_turn_amount = square.units.all()[0].amount
                    square.units.all()[0].save()
                    square.save()
                #else:
                #    # Otherwise resolve the battle, current algorithm:
                #    # Find the largest unit amount
                #    # scale everyone else's units

                #    #4 vs 3
                #    #[1,1,1,1]
                #    #[.75,.75,.75,.75]
                    
                    

