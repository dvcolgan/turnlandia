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
        fields = ('id', 'username', 'color', 'leader_name', 'people_name', 'password', 'wood', 'food', 'ore', 'money')

class UnitSerializer(serializers.ModelSerializer):
    owner_color = serializers.Field(source='owner.color')
    class Meta:
        model = Unit

class SquareSerializer(serializers.ModelSerializer):
    # Base traversal cost before adding modifiers like roads or trees
    traversal_cost = serializers.Field(source='get_traversal_cost')
    class Meta:
        model = Square

class ActionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Action
        exclude = ('player', 'turn')
