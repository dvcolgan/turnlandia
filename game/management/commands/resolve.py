from django.core.management.base import BaseCommand, CommandError
from game.models import *
from django.db import transaction
import random


class Command(BaseCommand):
    args = ''
    help = 'Run this command when the game starts and whenever the turn is over.'

    @transaction.commit_on_success
    def handle(self, *args, **options):
        current_turn = Setting.objects.get_integer('turn')

        print 'Placing initial units'
        Action.objects.resolve_initial_placements(current_turn)

        print 'Moving units'
        Action.objects.resolve_move_units(current_turn)

        print 'Building roads'
        Action.objects.resolve_build_roads(current_turn)

        print 'Clearing forests'
        Action.objects.resolve_clear_forests(current_turn)

        print 'Recruiting new units'
        Action.objects.resolve_recruit_units(current_turn)

        current_turn += 1
        turn = Setting.objects.set('turn', current_turn)
        print 'It is now turn %d.' % current_turn

        print 'ALL DONE'

