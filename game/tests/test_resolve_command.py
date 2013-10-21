from django.test import Client, TestCase
from django.contrib.auth import authenticate, login
from game.models import *
from django.utils import simplejson
from nose.tools import *

import ipdb


class TestResolveCommand(TestCase):

    def create_small_board_with_account(self, superflat=False):
        self.account = Account.objects.create(
            username="a1", password="p",
            email='a@a.co', color="#FF0000")
        Square.objects.initialize(10, 10, superflat)

    def make_action(self, kind, col, row, move_path=''):
        Action.objects.create(player=self.account,
            col=col, row=row, kind=kind, turn=1, move_path=move_path)

    def test_resolve_initial_placement_single_unit(self):
        self.create_small_board_with_account()
        self.make_action('initial', 0, 0)
        Action.objects.resolve_initial_placements(1)
        assert_equal(Unit.objects.get().amount, 1)

    def test_resolve_initial_placement_multiple_units(self):
        self.create_small_board_with_account()
        [self.make_action('initial', 0, 0) for i in range(4)]
        Action.objects.resolve_initial_placements(1)
        assert_equal(Unit.objects.get().amount, 4)

    def test_resolve_move_units_single(self):
        self.create_small_board_with_account(superflat=True)
        Unit.objects.create(col=0, row=0, owner=self.account, amount=1)
        self.make_action('move', 0, 0, '1,0|1,1|2,1')
        Action.objects.resolve_move_units(1)
        assert_equal(Unit.objects.get(col=2, row=1).amount, 1)

    def test_resolve_move_units_merge_two(self):
        self.create_small_board_with_account(superflat=True)
        Unit.objects.create(col=-1, row=-1, owner=self.account, amount=1)
        Unit.objects.create(col=1, row=1, owner=self.account, amount=1)
        self.make_action('move', -1, -1, '-1,0|0,0')
        self.make_action('move', 1, 1, '1,0|0,0')
        Action.objects.resolve_move_units(1)
        assert_equal(Unit.objects.get(col=0, row=0).amount, 2)

    def test_resolve_build_roads(self):
        Action.objects.resolve_build_roads(1)

    def test_resolve_clear_forests(self):
        Action.objects.resolve_clear_forests(1)

    def test_resolve_recruit_units(self):
        Action.objects.resolve_recruit_units(1)
