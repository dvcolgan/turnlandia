from django.db import models
from django.db.models import Sum, Avg
from django.contrib.auth.models import *
from settings import SECTOR_SIZE
from util.functions import *
import re
import PIL
import noise
import math
import ipdb


class Trophy(models.Model):
    name = models.CharField(max_length=255)
    image_path = models.CharField(max_length=255)
    description = models.CharField(max_length=255)

    def __unicode__(self):
        return self.name



class AccountManager(BaseUserManager):

    def create_user(self, username, password=None, **extra_fields):
        """
        Creates and saves a User with the given username, email and password.
        """
        now = timezone.now()
        if not username:
            raise ValueError('The given username must be set')
        user = self.model(username=username,
                          is_staff=False, is_active=True, is_superuser=False,
                          last_login=now, date_joined=now, **extra_fields)

        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username, password, **extra_fields):
        u = self.create_user(username, password, **extra_fields)
        u.is_staff = True
        u.is_active = True
        u.is_superuser = True
        u.save(using=self._db)
        return u


class Account(AbstractBaseUser, PermissionsMixin):
    username = models.CharField(
        max_length=25,
        unique=True,
        help_text='25 chars max, letters, numbers and @/./+/-/_ characters',
        validators=[
            validators.RegexValidator(re.compile('^[\w.@+-]+$'), 'Usernames can be at most 25 characters and include letters, numbers and @ . + - _', 'invalid')
        ]
    )
    email = models.EmailField(blank=True)
    color = models.CharField(max_length=10, blank=True, validators=[
        validators.RegexValidator(re.compile('^#[0-9a-fA-F]{6}$'), 'Enter a valid color.', 'invalid')
    ])
    country_name = models.CharField(max_length=255, blank=True)
    leader_name = models.CharField(max_length=255, blank=True)
    people_name = models.CharField(max_length=255, blank=True)

    wood = models.PositiveIntegerField(default=0)
    food = models.PositiveIntegerField(default=0)
    ore = models.PositiveIntegerField(default=0)
    money = models.PositiveIntegerField(default=100)

    is_staff = models.BooleanField(default=False, help_text='Designates whether the user can log into this admin site.')
    is_active = models.BooleanField(default=True, help_text='Designates whether this user should be treated as active. Unselect this instead of deleting accounts.')

    date_joined = models.DateTimeField(default=timezone.now)

    objects = AccountManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']

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

    def get_empire_center(self):
        return [
            int(self.units.aggregate(Avg('col'))['col__avg'] or 0),
            int(self.units.aggregate(Avg('row'))['row__avg'] or 0),
        ]


class TrophyAwarding(models.Model):
    trophy = models.ForeignKey(Trophy, related_name='awardings')
    recipient = models.ForeignKey(Account, related_name='awardings')
    date_awarded = models.DateField(auto_now_add=True)
    reasoning = models.CharField(max_length=255)

    def __unicode__(self):
        return self.trophy.name


class SquareManager(models.Manager):

    def initialize(self):
        batch = []
        for this_row in range(-100, 100):
            print 'Added 200 squares to the batch', this_row
            for this_col in range(-100, 100):
                if get_object_or_None(self.model, col=this_col, row=this_row) == None:
                    new_square = self.model(
                        col=this_col,
                        row=this_row,
                        terrain_type=self.terrain_type_for_square(this_col, this_row)
                    )
                    batch.append(new_square)
        print 'Bulk creating squares'
        self.model.objects.bulk_create(batch)

    #TODO MAKE THIS NOT DUPLICATED EXACTLY MANN
    def get_region(self, col, row, width, height):
        upper_col = int(col + width)
        lower_col = int(col)
        upper_row = int(row + height)
        lower_row = int(row)

        return (self.model.objects.filter(col__lt=upper_col)
                                  .filter(col__gte=lower_col)
                                  .filter(row__lt=upper_row)
                                  .filter(row__gte=lower_row)
                                  .order_by('row', 'col'))


    # get the squares that encompass the coordinates given
    #def get_region(self, col, row, width, height):

    #    upper_col = int(col + width)
    #    lower_col = int(col)
    #    upper_row = int(row + height)
    #    lower_row = int(row)

    #    squares = (self.model.objects.filter(col__lt=upper_col)
    #                                 .filter(col__gte=lower_col)
    #                                 .filter(row__lt=upper_row)
    #                                 .filter(row__gte=lower_row))

    #    # If we have a duplication of squares, that is kind of a problem, but shouldn't happen.
    #    if squares.count() > width * height:
    #        raise Exception('The game has happened upon an inconsistent state.  Sorry about this.'
    #                    'The admin has been contacted and is fixing the problem as we speak.')

    #    # The common case will be that they all exist, so this expensive
    #    # operation won't happen very often.
    #    if squares.count() != width * height:
    #        # Nobody has gone out here yet, create the squares that don't exist
    #        square_batch = []
    #        tree_batch = []
    #        for this_row in range(lower_row, upper_row):
    #            for this_col in range(lower_col, upper_col):
    #                if get_object_or_None(self.model, col=this_col, row=this_row) == None:
    #                    new_square = self.model(
    #                        col=this_col,
    #                        row=this_row,
    #                        terrain_type=self.terrain_type_for_square(this_col, this_row)
    #                    )
    #                    if new_square.terrain_type == 'forest':
    #                        new_square.terrain_type = 'plains'
    #                        tree_batch.append(Tree(
    #                            col=this_col,
    #                            row=this_row
    #                        ))
    #                    square_batch.append(new_square)

    #        self.model.objects.bulk_create(square_batch)
    #        Tree.objects.bulk_create(tree_batch)

    #        print 'Created %d new squares' % len(square_batch)
    #        print 'and %d new trees' % len(tree_batch)

    #        # Fetch these all again
    #        squares = (self.model.objects.filter(col__lt=upper_col)
    #                                .filter(col__gte=lower_col)
    #                                .filter(row__lt=upper_row)
    #                                .filter(row__gte=lower_row))
    #        if squares.count() > width * height:
    #            raise Exception('The game has happened upon an inconsistent state after '
    #                        'trying to rectify the situation once already.  Sorry about this.'
    #                        'The admin has been contacted and is fixing the problem as we speak.')
    #    else:
    #        print 'All squares already created'

    #    squares = squares.order_by('row', 'col')

    #    return squares




    #def terrain_type_for_square(self, col, row):
    #    terrain_type = 'plains'

    #    frequency = 1.0/5
    #    forest_value = noise.pnoise2(col*frequency, row*frequency, 20)
    #    if forest_value < -0.05:
    #        terrain_type = 'forest'

    #    frequency = 1.0/5
    #    mountain_value = noise.pnoise2(col*frequency, row*frequency, 1)
    #    if mountain_value > 0.2:
    #        terrain_type = 'mountains'

    #    frequency_x = 1.0/45
    #    frequency_y = 1.0/30
    #    river_value = noise.pnoise2(col*frequency_x, row*frequency_y, 10, -0.3)
    #    if river_value < 0.04 and river_value > -0.04:
    #        terrain_type = 'water'

    #    frequency = 1.0/20
    #    lake_value = noise.pnoise2(col*frequency, row*frequency, 6)
    #    if lake_value < -0.2:
    #        terrain_type = 'water'

    #    return terrain_type

    def terrain_type_for_square(self, col, row):
        terrain_type = PLAINS

        frequency = 1.0/5
        forest_value = noise.pnoise2(col*frequency, row*frequency, 20)
        if forest_value < -0.05:
            terrain_type = FOREST

        frequency_x = 1.0/30
        frequency_y = 1.0/40
        mountain_value = noise.pnoise2(col*frequency, row*frequency, 1)
        if mountain_value > 0.2:
            terrain_type = MOUNTAINS

        frequency_x = 1.0/60
        frequency_y = 1.0/45
        river_value = noise.pnoise2(col*frequency_x, row*frequency_y, 10, -0.3)
        if river_value < 0.04 and river_value > -0.04:
            terrain_type = WATER

        frequency = 1.0/30
        lake_value = noise.pnoise2(col*frequency, row*frequency, 6)
        if lake_value < -0.2:
            terrain_type = WATER

        return terrain_type


class SquareOccupiedException(Exception):
    pass
class InvalidPlacementException(Exception):
    pass
class SquareDoesNotExistException(Exception):
    pass

PLAINS = 0
WATER = 1
MOUNTAINS = 2
FOREST = 3
ROAD = 4
CITY = 5
TERRAIN_TYPES = (
    (PLAINS, 'Plains'),
    (WATER, 'Water'),
    (MOUNTAINS, 'Mountains'),
    (FOREST, 'Forest'),
    (ROAD, 'Road'),
    (CITY, 'City'),
)

class Square(models.Model):
    col = models.IntegerField()
    row = models.IntegerField()
    terrain_type = models.IntegerField(choices=TERRAIN_TYPES)

    objects = SquareManager()

    def get_traversal_cost(self):
        if self.terrain_type == 'road':
            return 1
        if self.terrain_type == 'plains':
            return 2
        if self.terrain_type == 'water':
            return 0
        if self.terrain_type == 'mountains':
            return 0
        if self.terrain_type == 'forest':
            return 3
        if self.terrain_type == 'city':
            return 1

    def get_turn(self):
        return Setting.objects.get_integer('turn')

    def __unicode__(self):
        return '(%d, %d)' % (self.col, self.row)



class SettingManager(models.Manager):
    def get_integer(self, name):
        return int(Setting.objects.get(name=name).value)
    def get_string(self, name):
        return Setting.objects.get(name=name).value


class Setting(models.Model):
    name = models.CharField(max_length=255)
    value = models.CharField(max_length=255)

    objects = SettingManager()

    def __unicode__(self):
        return '%s: %s' % (self.name, self.value)


class Message(models.Model):
    sender = models.ForeignKey(Account, related_name='sent_messages')
    recipient = models.ForeignKey(Account, related_name='received_messages')
    subject = models.CharField(max_length=255)
    body = models.TextField()
    time_sent = models.DateTimeField(auto_now=True)


ACTION_KINDS = (
    ('initial', 'Initial Placement'),
    ('move', 'Move Units'),
    ('attack', 'Attack'),
    ('city', 'Build City'),
    ('road', 'Build Road'),
)
# Squares are more or less read only until the turn resolves, before that we deal with actions
class Action(models.Model):
    player = models.ForeignKey(Account, related_name='actions')
    turn = models.IntegerField()

    kind = models.CharField(max_length=30, choices=ACTION_KINDS)
    col = models.IntegerField()
    row = models.IntegerField()

    move_path = models.CharField(max_length=255, blank=True)

    timestamp = models.DateTimeField(auto_now_add=True)

    def __unicode__(self):
        return self.kind + ' ' + self.move_path

    def is_valid(self):
        return True
        #if any(self.kind in kind for kind in ACTION_KINDS):
        #    self.errors = 'Invalid action.'

        #src_square = get_object_or_None(Square, col=src_col, row=src_row)
        #dest_square = get_object_or_None(Square, col=dest_col, row=dest_row)
        #if src_square == None or dest_square == None:
        #    self.errors = 'Square does not exist.'
        #    return False

        #if action == 'move':
        #    if src_square.units.filter(owner=player).amount < self.amount:
        #        return False
        #    
        #elif action == 'attack':
        #    pass

        #elif action == 'city':
        #    pass

        return True






class UnitManager(models.Manager):

    def get_region(self, col, row, width, height):
        upper_col = int(col + width)
        lower_col = int(col)
        upper_row = int(row + height)
        lower_row = int(row)

        return (self.model.objects.filter(col__lt=upper_col)
                                  .filter(col__gte=lower_col)
                                  .filter(row__lt=upper_row)
                                  .filter(row__gte=lower_row)
                                  .order_by('row', 'col'))

class Unit(models.Model):
    col = models.IntegerField()
    row = models.IntegerField()
    owner = models.ForeignKey(Account, related_name='units')
    amount = models.IntegerField(default=0)

    objects = UnitManager()

    def __unicode__(self):
        return "(%d, %d) %s (%d)" % (self.col, self.row, self.owner, self.amount)




#------------



















"""

    def place_unit(self, account):
        if account.unplaced_units > 0:
            # Only allow placing on or adjacent to your own square
            can_place = False
            if self.owner == account:
                can_place = True

            else:
                square = get_object_or_None(Square, col=self.col-1, row=self.row)
                if square != None and square.owner == account:
                    can_place = True

                else:
                    square = get_object_or_None(Square, col=self.col+1, row=self.row)
                    if square != None and square.owner == account:
                        can_place = True

                    else:
                        square = get_object_or_None(Square, col=self.col, row=self.row-1)
                        if square != None and square.owner == account:
                            can_place = True

                        else:
                            square = get_object_or_None(Square, col=self.col, row=self.row+1)
                            if square != None and square.owner == account:
                                can_place = True

            if can_place:
                unit = get_object_or_None(Unit, square=self, owner=account)
                if unit:
                    if unit.amount < 20:
                        unit.amount += 1
                        unit.save()
                else:
                    unit = Unit(square=self, owner=account, amount=1)
                    unit.save()
                account.unplaced_units -= 1
                account.save()
            else:
                raise InvalidPlacementException()

    def remove_unit(self, account):
        unit = get_object_or_None(Unit, square=self, owner=account)
        if unit:
            unit.amount -= 1
            if unit.amount == 0:
                unit.delete()
            else:
                unit.save()
            account.unplaced_units += 1
            account.save()

    def settle_units(self, account):
        unit = get_object_or_None(Unit, square=self, owner=account)
        if unit and self.owner == account:
            self.resource_amount += 4
            self.save()
            unit.amount -= 1
            if unit.amount == 0:
                unit.delete()
            else:
                unit.save()

    #def build_wall(self, account):
    #    unit = get_object_or_None(Unit, square=self, owner=account)
    #    if unit != None:
    #        self.resource_amount = 0
    #        self.wall_health += 2
    #        self.save()
    #        unit.amount -= 1
    #        if unit.amount == 0:
    #            unit.delete()
    #        else:
    #            unit.save()

    def initial_placement(self, account):
        if Unit.objects.filter(owner=account).count() == 0 and Square.objects.filter(owner=account).count() == 0:

            # This needs to be made atomic, if it fails in the middle, it could be problematic
            placement = {
                8: [ self ],
                4: [
                    Square.objects.get(col=self.col-1, row=self.row),
                    Square.objects.get(col=self.col+1, row=self.row),
                    Square.objects.get(col=self.col,   row=self.row-1),
                    Square.objects.get(col=self.col,   row=self.row+1),
                ],
                2: [
                    Square.objects.get(col=self.col-1, row=self.row-1),
                    Square.objects.get(col=self.col+1, row=self.row+1),
                    Square.objects.get(col=self.col+1, row=self.row-1),
                    Square.objects.get(col=self.col-1, row=self.row+1),
                ],
                1: [
                    Square.objects.get(col=self.col,   row=self.row-2),
                    Square.objects.get(col=self.col,   row=self.row+2),
                    Square.objects.get(col=self.col+2, row=self.row),
                    Square.objects.get(col=self.col-2, row=self.row),
                ],
            }
            for count, squares in placement.iteritems():
                for square in squares:
                    if square.units.count() != 0 or square.owner != None:
                        raise SquareOccupiedException()
            # If there are no problems, create the units
            for count, squares in placement.iteritems():
                for square in squares:
                    Unit.objects.create(
                        owner=account,
                        square=square,
                        amount=count,
                    )
                    square.owner = account
                    square.save()
                    print 'creating unit'

"""
