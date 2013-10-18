from django.core.management.base import BaseCommand, CommandError
from game.models import *
import random
import time

class Command(BaseCommand):
    args = ''
    help = 'Run this command when the game starts and whenever the turn is over.'

    def handle(self, *args, **options):
        print 'ARE YOU SURE YOU WANT TO DELETE THE GAME?'
        time.sleep(1)
        print "I'm going to wait 10 seconds before doing so."
        for i in range(10):
            print "DESTROYING GAME IN %d SECONDS" % (10 - i)
            time.sleep(1)

        print 'DELETING EVERYTHING'
        Action.objects.all().delete()
        Setting.objects.all().delete()
        Square.objects.all().delete()
        Unit.objects.all().delete()

        print 'Setting up new game...'
        Setting.objects.create(name='turn', value='1')
        Square.objects.initialize()
        print 'Done!'

