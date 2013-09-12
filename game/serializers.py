from rest_framework import serializers
from django import forms
from django.contrib.auth.hashers import make_password
from game.models import *


HIDDEN_PASSWORD_STRING = 'hashed and salted'
 
# Thanks to https://groups.google.com/d/msg/django-rest-framework/abMsDCYbBRg/d2orqUUdTqsJ
class PasswordField(serializers.CharField):
    """Special field to update a password field."""
    widget = forms.widgets.PasswordInput
    
    def from_native(self, value):
        """Hash if new value sent, else retrieve current password"""
        if value == HIDDEN_PASSWORD_STRING or value == '':
            return self.parent.object.password
        else:
            return make_password(value)

    def to_native(self, value):
        """Hide hashed-password in API display"""
        return HIDDEN_PASSWORD_STRING

class AccountSerializer(serializers.ModelSerializer):
    password = PasswordField()
    class Meta:
        model = Account
        fields = ('id', 'username', 'color', 'leader_name', 'people_name', 'unplaced_units', 'password')

class UnitSerializer(serializers.ModelSerializer):
    owner_color = serializers.Field(source='owner.color')
    class Meta:
        model = Unit

class SquareSerializer(serializers.ModelSerializer):
    owner_color = serializers.Field(source='owner.color')
    owner_username = serializers.Field(source='owner.username')
    owner_leader_name = serializers.Field(source='owner.leader_name')
    owner_people_name = serializers.Field(source='owner.people_name')
    traversal_cost = serializers.Field(source='get_traversal_cost')
    units = UnitSerializer()
    class Meta:
        model = Square

class ActionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Action



#class PlayerSerializer(serializers.ModelSerializer):
#    name = serializers.Field(source='account.name')
#    class Meta:
#        model = Player
#
#class GameSerializer(serializers.ModelSerializer):
#    players = PlayerSerializer(many=True, required=False)
#    class Meta:
#        model = Game
