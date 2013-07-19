from django.core.management.base import BaseCommand, CommandError
from game.models import *

class Command(BaseCommand):
    args = ''
    help = 'Run this command whenever the turn is over.'

    def handle(self, *args, **options):
        day_setting = Setting.objects.get(name='Current Day')
        day_setting.value = str(int(day_setting.value) + 1)
        day_setting.save()
        for square in Square.objects.all():

            # If you are the only one claiming this square, you get it
            if square.resource_amount > 0 and square.owner != None:
                found = False
                for unit in square.units.all():
                    if unit.owner == square.owner:
                        unit.amount += 1
                        square.resource_amount -= 1
                        unit.save()
                        square.save()
                        found = True
                        break
                if not found:
                    square.units.add(Unit(
                        owner=square.owner,
                        square=square,
                        amount = 1
                    ))
                    square.resource_amount -= 1
                    square.save()

            if square.units.count() == 1:
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
