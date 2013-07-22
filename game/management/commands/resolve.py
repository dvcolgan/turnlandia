from django.core.management.base import BaseCommand, CommandError
from game.models import *
import random

class Command(BaseCommand):
    args = ''
    help = 'Run this command whenever the turn is over.'

    def handle(self, *args, **options):
        day_setting = Setting.objects.get(name='Current Day')
        day_setting.value = str(int(day_setting.value) + 1)
        day_setting.save()

        print 'Generating new units'
        self.generate_units_from_resources()

        print 'Attacking walls'
        self.attack_walls()

        print 'Resolving battles'
        self.resolve_battles()

        print 'Assigning squares\' ownership'
        self.assign_squares_ownership()

        print 'Reticulating splines'

        print 'ALL DONE'

    def generate_units_from_resources(self):
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
                    # There are no units on the square, so add a new one
                    square.units.add(Unit(
                        owner=square.owner,
                        square=square,
                        amount = 1
                    ))
                    square.resource_amount -= 1
                    square.save()

    def attack_walls(self):
        for square in Square.objects.all():
            if square.wall_health > 0 and square.units.count() > 0:
                for unit in square.units.all():
                    square.wall_health -= unit.amount
            square.save()


    def resolve_battles(self):
        for square in Square.objects.all():
            if square.units.count() > 1:
                largest = 0
                for unit in square.units.all():
                    if largest < unit.amount:
                        largest = unit.amount

                battle_scores = []
                for unit in square.units.all():
                    battle_scores.append(random.random() * unit.amount / largest)

                winner_idx = 0
                highest_score = 0
                for i, score in enumerate(battle_scores):
                    if score > highest_score:
                        highest_score = score
                        winner_idx = i

                winning_unit = square.units.all()[winner_idx]
                print 'On square (%d, %d), %s (%d units, %.3f) defeated ' % (square.col, square.row, unit.owner.leader_name, winning_unit.amount, battle_scores[winner_idx]),
                for i, unit in enumerate(square.units.all()):
                    if unit != winning_unit:
                        print ' %s (%d units, %.3f) ' % (unit.owner.leader_name, unit.amount, battle_scores[i]),
                        unit.delete()
                print


    def assign_squares_ownership(self):
        for square in Square.objects.all():
            if square.units.count() == 1:
                square.owner = square.units.all()[0].owner
                square.save()
