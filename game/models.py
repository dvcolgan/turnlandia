from django.db import models
from account.models import *

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

class AccountManager(BaseUserManager):

    def create_user(self, email, password=None, **extra_fields):
        now = timezone.now()
        email = AccountManager.normalize_email(email)
        account = self.model(email=email,
                          is_staff=False, is_active=True, is_superuser=False,
                          last_login=now, date_joined=now, **extra_fields)

        account.set_password(password)
        account.save(using=self._db)
        return account

    def create_superuser(self, email, password, **extra_fields):
        u = self.create_user(email, password, **extra_fields)
        u.is_staff = True
        u.is_active = True
        u.is_superuser = True
        u.save(using=self._db)
        return u


class Account(AbstractBaseUser):

    username = models.CharField(max_length=255, unique=True)
    email = models.EmailField(unique=True)

    is_staff = models.BooleanField(default=False,
        help_text='Designates whether the user can log into this admin site.')
    is_active = models.BooleanField(default=True,
        help_text='Designates whether this user should be treated as '
                    'active. Unselect this instead of deleting accounts.')
    is_superuser = models.BooleanField(default=False,
        help_text='Designates that this user has all permissions without '
                    'explicitly assigning them.')
    date_joined = models.DateTimeField(default=timezone.now)

    objects = AccountManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']


    class Meta:
        verbose_name = 'account'
        verbose_name_plural = 'accounts'

    def __unicode__(self):
        return self.username + ' (' + self.email + ')'

    def get_username(self):
        return self.username

    def get_short_name(self):
        return self.username

    def get_full_name(self):
        return self.username

    def email_user(self, subject, message, from_email=None):
        send_mail(subject, message, from_email, [self.email])



class Game(models.Model):
    world_name = models.CharField(max_length=255)
    started = models.BooleanField(default=False)

    def __unicode__(self):
        return self.world_name

# We need to be able to view the whole world at a very high level view, sort of like google maps
# But then be able to zoom in closely to a 48x48px square size grid
# Currently we don't support zooming in and out otherwise
# A sector is 100x100
class Sector(models.Model):
    



# Represents an account that has joined a game and stores data for that player applicable only for this game
class Player(models.Model):
    account = models.ForeignKey(Account, related_name='players')
    #game = models.ForeignKey(Game, related_name='players')
    color = models.CharField(max_length=10)
    leader_name = models.CharField(max_length=255)
    people_name = models.CharField(max_length=255)

class Square(models.Model):
    x = models.IntegerField()
    y = models.IntegerField()
    owner = models.ForeignKey(Player, related_name='squares_owned')

class Unit(models.Model):
    player = models.ForeignKey(Player, related_name='units')
    game = models.ForeignKey(Game, related_name='units')
    x = models.IntegerField()
    y = models.IntegerField()


