from django import forms
from game.models import *

class GameForm(forms.ModelForm):
    class Meta:
        model = Game
        fields = ('world_name',)

class PlayerForm(forms.ModelForm):
    class Meta:
        model = Player
        fields = ('leader_name', 'people_name')
