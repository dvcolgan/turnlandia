from django.db import models
from django.db.models import Sum
from django.contrib.auth.models import *
from game.models import *

# Unit colors and then background colors
COLORS = [
    ('blue', '1E77B4', '7099B5'),
    ('orange', 'FF7F0D', 'E5AB75'),
    ('green', '2BA02B', '7AAF7A'),
    ('red', 'D62728', 'C37273'),
    ('purple', '9467BD', 'AD99C1'),
    ('brown', '8C564B', 'A38B86'),
    ('pink', 'E377C1', 'DAA8CA'),
    ('grey', '7F7F7F', 'A4A4A4'),
    ('yellow', 'BBBD21', 'CACB83'),
    ('teal', '17BECF', '77C5CD'),
]

PLAYER_NAMES = [
    ('Gandalf the White', 'Maiar'),
    ('Frodo Baggins', 'Shire Hobbits'),
    ('Elrond', 'Mirkwood Elves'),
    ('Durin Darkhammer', 'Moria Dwarves'),
    ('Ness', 'Eagleland'),
    ('Daphnes Nohansen Hyrule', 'Hylians'),
    ('Aragorn son of Arathorn', 'Gondorians'),
    ('Strong Bad', 'Strongbadia'),
    ('Captain Homestar', 'The Team'),
    ('T-Rex', 'Dinosaurs'),
    ('Refrigerator', 'Kitchen Appliances'),
    ('The Burger King', 'Fast Foodies'),
    ('Larry King Live', 'Interviewees'),
    ('King', 'Mimigas'),
    ('Luke Skywalker', 'The Rebel Alliance'),
    ('Darth Vader', 'The Empire'),
    ('Jean-Luc Picard', 'The Enterprise'),
    ('The Borg Queen', 'The Borg'),
    ('Bowser', 'Koopas'),
]

WORLD_NAMES = [
    'Atlantis',
    'Azeroth',
    'Camelot',
    'Narnia',
    'Hyrule',
    'Middle-earth',
    'The Neverhood',
    'Rapture',
    'Terabithia',
    'Kanto',
    'The Grand Line',
    'Tatooine',
    'Naboo',
    'Pandora',
    'Corneria',
    'Termina',
    'Xen',
    'City 17',
    'Tokyo',
    'Ithica',
    'Peru',
]



class Account(AbstractBaseUser, PermissionsMixin):

    username = models.CharField(max_length=255, unique=True)
    email = models.EmailField(blank=True)
    color = models.CharField(max_length=10, blank=True)
    leader_name = models.CharField(max_length=255, blank=True)
    people_name = models.CharField(max_length=255, blank=True)
    total_units = models.IntegerField(default=0)

    is_staff = models.BooleanField(default=False, help_text='Designates whether the user can log into this admin site.')
    is_active = models.BooleanField(default=True, help_text='Designates whether this user should be treated as active. Unselect this instead of deleting accounts.')

    date_joined = models.DateTimeField(default=timezone.now)

    objects = UserManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = []

    class Meta:
        verbose_name = 'account'
        verbose_name_plural = 'accounts'

    def __unicode__(self):
        return self.username

    def get_username(self):
        return self.username

    def get_short_name(self):
        return self.username

    def get_full_name(self):
        return self.username

    def email_user(self, subject, message, from_email=None):
        send_mail(subject, message, from_email, [self.email])


class Square(models.Model):
    x = models.IntegerField()
    y = models.IntegerField()
    owner = models.ForeignKey(Account, related_name='squares_owned', null=True, blank=True)
    resource_amount = models.IntegerField(default=0)
    wall_health = models.IntegerField(default=0)

    def __unicode__(self):
        return '(%d, %d)' % (self.x, self.y)


class UnitManager(models.Manager):
    def total_placed_units(self, owner):
        total = self.model.objects.filter(owner=owner).aggregate(total=Sum('amount'))['total']
        if total == None:
            return 0
        else:
            return total
        




class Unit(models.Model):
    owner = models.ForeignKey(Account, related_name='units')
    square = models.ForeignKey(Square, related_name='units')
    amount = models.IntegerField()
    last_turn_amount = models.IntegerField(default=0)

    objects = UnitManager()

    def __unicode__(self):
        return unicode(self.square)


class SettingManager(models.Manager):
    def get_current_day(self):
        return Setting.objects.get(name='Current Day').value
        


class Setting(models.Model):
    name = models.CharField(max_length=255)
    value = models.CharField(max_length=255)

    objects = SettingManager()

    def __unicode__(self):
        return '%s: %s' % (self.name, self.value)
