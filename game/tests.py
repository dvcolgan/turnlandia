import requests
from django.test import LiveServerTestCase
from game.models import *
import ipdb

def get_json(relative_url):
    r = requests.get('http://localhost:8081' + relative_url)
    return r.json()
def post_json(relative_url, payload):
    r = requests.post('http://localhost:8081' + relative_url, payload)
    return r.json()


class TestGameAPI(LiveServerTestCase):
    def test_create_game(self):
        post_json('/api/game/', { 'world_name': 'Awesome Land' })
        game = get_json('/api/game/1/')
        self.assertEqual(game['world_name'], 'Awesome Land')

    def add_accounts(self):
        user_data = [
            { "email": "dvcolgan@gmail.com", "name": "davidscolgan", }, 
            { "email": "denaje@gmail.com", "name": "denaje", }, 
            { "email": "andrewneel@gmail.com", "name": "aneel", }, 
            { "email": "mikeshenry@gmail.com", "name": "macmash2", }, 
            { "email": "stettjawa@gmail.com", "name": "stett", }, 
            { "email": "kathylynncolgan@gmail.com", "name": "kathy", }, 
            { "email": "katielynncolgan@gmail.com", "name": "awesome", }, 
            { "email": "mrcolgan@taylor.edu", "name": "mark", }, 
            { "email": "benbyler@gmail.com", "name": "byler", }, 
            { "email": "madnovelist@gmail.com", "name": "madnovelist", }
        ]
        for user in user_data:
            user['password'] = 'password'
            post_json('/api/account/', user)

    def test_add_players(self):
        self.add_accounts()
        game = post_json('/api/game/', { 'world_name': 'Awesome Land' })
        accounts = get_json('/api/account/')
        for account in accounts:
            post_json('/api/player/', {
                'account': account['id'],
                'game': game['id'],
                'leader_name': 'The great and venerable ' + account['name'],
                'people_name': 'The people of ' + account['name'],
            })
        game = get_json('/api/game/1/')
        self.assertEqual(len(game['players']), 10, 'There should be 10 accounts created.')

