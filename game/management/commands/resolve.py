from django.core.management.base import BaseCommand, CommandError
from game.models import *
import random

def parse_move(move_path):
    moves = [step.split(',') for step in move_path.split('|')]
    for move in moves:
        move[0] = int(move[0])
        move[1] = int(move[1])
    return moves

class Command(BaseCommand):
    args = ''
    help = 'Run this command when the game starts and whenever the turn is over.'

    def handle(self, *args, **options):
        turn = get_object_or_None(Setting, name='turn')

        current_turn = int(turn.value)

        for action in Action.objects.filter(turn=current_turn, kind='initial'):
            unit = get_object_or_None(Unit, col=action.col, row=action.row, owner=action.player)
            if unit == None:
                Unit.objects.create(
                    col=action.col,
                    row=action.row,
                    owner=action.player,
                    amount=1
                )
            else:
                unit.amount += 1
                unit.save()

        actions = Action.objects.filter(turn=current_turn, kind='move')
        moves = []
        for action in actions:
            if action.move_path != '':
                # Sometime figure out what to do if we have an invalid move here
                units = Unit.objects.filter(col=action.col, row=action.row, owner=action.player)
                for unit in units:
                    #moves.push(parse_move(action.move_path))
                    col, row = parse_move(action.move_path)[-1]
                    unit.col = col
                    unit.row = row
                    unit.save()

        actions = Action.objects.filter(turn=current_turn, kind='road')
        for action in actions:
            square = Square.objects.get(col=action.col, row=action.row)
            square.terrain_type = ROAD
            square.save()

        actions = Action.objects.filter(turn=current_turn, kind='tree')
        for action in actions:
            square = Square.objects.get(col=action.col, row=action.row)
            square.terrain_type = PLAINS
            action.player.wood += 1
            action.player.save()
            square.save()

        actions = Action.objects.filter(turn=current_turn, kind='recruit')
        for action in actions:
            unit = Unit.objects.get(col=action.col, row=action.row, owner=action.player)
            unit.amount += 1
            unit.save()

        # At some point only check the units around you, or this will quickly take forever
        #for i in range(6):
        #    for move in moves:
        #        for other_move in moves:
        #            if move is other_move: continue
        #            step1_col, step1_row = move[i]
        #            step2_col, step2_row = other_move[i]





            
                
                

        turn.value = str(current_turn + 1)
        turn.save()
        print 'It is now turn %d.' % current_turn

        print 'ALL DONE'

    def generate_units_from_resources(self):
        for square in Square.objects.all():

            # If the square is owned and has a resource, we will be generating a unit
            if square.resource_amount > 0 and square.owner != None:
                found = False
                for unit in square.units.all():
                    if unit.owner == square.owner:
                        square.resource_amount -= 1
                        # If there's a battle going on, place the unit on the square
                        if square.units.count() > 1:
                            unit.amount += 1
                            unit.save()
                        # Otherwise just put the unit into the unplaced units
                        else:
                            square.owner.unplaced_units += 1
                            square.owner.save()

                        square.save()
                        found = True
                        break
                if not found:
                    # There are no units on the square, so add a new one
                    square.owner.unplaced_units += 1
                    square.owner.save()
                    square.resource_amount -= 1
                    square.save()

    def resolve_battles(self):
        for square in Square.objects.all():
            units_list = list(square.units.all())
            while square.units.count() > 1:

                loser = random.choice(units_list)
                loser.amount -= 1
                if loser.amount == 0:
                    loser.delete()

            for unit in units_list:
                unit.save()

            # TODO make it so you can tell how many units each player lost

            #print 'On square (%d, %d), ' % (square.col, square.row),
            #for i, unit in enumerate(square.units.all()):
            #    if unit != winning_unit:
            #        print '%s loses (%d units, %.3f) ' % (unit.owner.leader_name, unit.amount, battle_scores[i]),
            #        unit.amount -= 1
            #        if unit.amount == 0:
            #            unit.delete()
            #            print
            #        else:
            #            unit.save()
            #    else:
            #        print '%s wins (%d units, %.3f) ' % (winning_unit.owner.leader_name, winning_unit.amount, battle_scores[winner_idx]),
            #print


    def assign_squares_ownership(self):
        for square in Square.objects.all():
            if square.units.count() == 1:
                square.owner = square.units.all()[0].owner
                square.save()
