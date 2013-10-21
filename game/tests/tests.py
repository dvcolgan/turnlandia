from django.test import Client
from django.contrib.auth import authenticate, login
from game.models import *
from django.utils import simplejson
from nose.tools import *

import ipdb

#def post_json(relative_url, payload):
#    r = requests.post('http://localhost:8081' + relative_url, payload)
#    return r.json()




class TestSquare(object):
    @classmethod
    def setup_class(cls):
        # Create the squares by looking at them
        Square.objects.get_region(-10, -10, 20, 20)
        cls.account1 = Account.objects.create(people_name="p", color="#FF0000", username="a1", password="p", leader_name="l")
        cls.account2 = Account.objects.create(people_name="p", color="#00FF00", username="a2", password="p", leader_name="l")


    def test_initial_placement(self):

        center_square = Square.objects.get(col=0, row=0)
        center_square.initial_placement(self.account1)
        assert_equal(center_square.owner, self.account1, 'The placer should now own the squares')
        
        with assert_raises(SquareOccupiedException):
            center_square.initial_placement(self.account2)

    #def test_build_wall(self):
    #    # Place 4 resources
    #    center_square = Square.objects.get(col=0, row=0)
    #    center_square.resource_amount = 4
    #    center_square.owner = self.account1
    #    center_square.save()

    #    # Place 4 units
    #    self.account1.unplaced_units = 4
    #    self.account1.save()
    #    for i in range(4):
    #        center_square.place_unit(self.account1)

    #    center_square.build_wall(self.account1)
    #    assert_equals(center_square.wall_health, 0, 'A wall cannot be built on a resource.')




class TestModels(object):

    @classmethod
    def setup_class(cls):
        #cls.accounts = [
        #    Account(total_units=0, people_name="peons", leader_name="Darth Vader"   , color="#FF0000", email="testuser1@gmail.com", username="testuser1"), 
        #    Account(total_units=0, people_name="peons", leader_name="Han Solo"      , color="#00FF00", email="testuser2@gmail.com", username="testuser2"), 
        #    Account(total_units=0, people_name="peons", leader_name="Leah Skywalker", color="#0000FF", email="testuser3@gmail.com", username="testuser3"), 
        #    Account(total_units=0, people_name="peons", leader_name="Luke Skywalker", color="#FF00FF", email="testuser4@gmail.com", username="testuser4"), 
        #    Account(total_units=0, people_name="peons", leader_name="Chewbacca"     , color="#00FF00", email="testuser5@gmail.com", username="testuser5"), 
        #    Account(total_units=0, people_name="peons", leader_name="Bigs"          , color="#888800", email="testuser6@gmail.com", username="testuser6"), 
        #    Account(total_units=0, people_name="peons", leader_name="Wedge"         , color="#880088", email="testuser7@gmail.com", username="testuser7"), 
        #    Account(total_units=0, people_name="peons", leader_name="Jar Jar"       , color="#008888", email="testuser8@gmail.edu", username="testuser8"), 
        #    Account(total_units=0, people_name="peons", leader_name="Mace Windu"    , color="#8888FF", email="testuser9@gmail.com", username="testuser9"), 
        #    Account(total_units=0, people_name="peons", leader_name="Yoda"          , color="#FF8888", email="testuser10@gmail.com",username="testuser10"),
        #]
        #for account in cls.accounts:
        #    account.set_password('password')
        #cls.client = Client()
        #cls.client.login(username='testuser1',password='password')
        pass

    def get_json(self, url):
        response = self.client.get(url)
        return simplejson.loads(response.content)

    #def test_initial_placement(self):
    #    print 'starting initial placement'
    #    json = self.get_json('/api/sector/0/0/10/10/')

    #    self.assertEqual(len(json['players_visible']), 10, 'There should be 10 accounts created.')
    #    print 'finishing initial placement'

    #def test_creating_unseen_squares(self):
    #    print 'starting creating unseen'
    #    print 'finishing creating unseen'

    def test_get_region_create_squares(self):
        assert_equal(Square.objects.count(), 0, 'There should not be any squares yet.')
        squares = Square.objects.get_region(0, 0, 10, 10)
        assert_equal(Square.objects.count(), 100, 'There should now be 100 squares.')
        squares = Square.objects.get_region(1, 0, 10, 10)
        assert_equal(Square.objects.count(), 110, 'Overlapping calls to get_region should only create enough new squares.')
        Square.objects.all().delete()


    def test_get_region_returned_coords(self):
        squares = Square.objects.get_region(0, 0, 10, 10)

        assert_not_equal(squares.count(), 0)

        assert_equal(squares[0].col, 0)
        assert_equal(squares[0].row, 0)
        assert_equal(squares[squares.count()-1].col, 9)
        assert_equal(squares[squares.count()-1].row, 9)

        Square.objects.all().delete()
        

    def test_placement(self):
        pass
        #Square.objects.get_region(-10, -10, 20, 20)
        #account1 = Account.objects.create(people_name="p", color="#FF0000", username="a1", password="p", leader_name="l")
        #account2 = Account.objects.create(people_name="p", color="#00FF00", username="a2", password="p", leader_name="l")

        #center_square = Square.objects.get(col=0, row=0)
        #center_square.owner = account1



