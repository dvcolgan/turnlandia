from django.db import models
from django.db.models import Sum
from django.contrib.auth.models import *
from settings import SECTOR_SIZE
from util.functions import *
import PIL
import noise
import math
import ipdb

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


class Trophy(models.Model):
    name = models.CharField(max_length=255)
    image_path = models.CharField(max_length=255)
    description = models.CharField(max_length=255)

    def __unicode__(self):
        return self.name

class Account(AbstractBaseUser, PermissionsMixin):
    username = models.CharField(max_length=255, unique=True)
    email = models.EmailField(blank=True)
    color = models.CharField(max_length=10, blank=True)
    leader_name = models.CharField(max_length=255, blank=True)
    people_name = models.CharField(max_length=255, blank=True)
    unplaced_units = models.IntegerField(default=0)

    wood = models.PositiveIntegerField(default=0)
    food = models.PositiveIntegerField(default=0)
    ore = models.PositiveIntegerField(default=0)
    money = models.PositiveIntegerField(default=100)

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


class TrophyAwarding(models.Model):
    trophy = models.ForeignKey(Trophy, related_name='awardings')
    recipient = models.ForeignKey(Account, related_name='awardings')
    date_awarded = models.DateField(auto_now_add=True)
    reasoning = models.CharField(max_length=255)

    def __unicode__(self):
        return self.trophy.name


class SquareManager(models.Manager):

    # get the squares that encompass the coordinates given
    def get_region(self, col, row, width, height):

        upper_col = int(col + width)
        lower_col = int(col)
        upper_row = int(row + height)
        lower_row = int(row)

        squares = (self.model.objects.filter(col__lt=upper_col)
                                     .filter(col__gte=lower_col)
                                     .filter(row__lt=upper_row)
                                     .filter(row__gte=lower_row))

        # If we have a duplication of squares, that is kind of a problem, but shouldn't happen.
        if squares.count() > width * height:
            raise Exception('The game has happened upon an inconsistent state.  Sorry about this.'
                        'The admin has been contacted and is fixing the problem as we speak.')

        # The common case will be that they all exist, so this expensive
        # operation won't happen very often.
        if squares.count() != width * height:
            # Nobody has gone out here yet, create the squares that don't exist
            batch = []
            for this_row in range(lower_row, upper_row):
                for this_col in range(lower_col, upper_col):
                    if get_object_or_None(self.model, col=this_col, row=this_row) == None:
                        batch.append(self.generate_unsaved_square(this_col, this_row))
            self.model.objects.bulk_create(batch)
            print 'Created %d new squares' % len(batch)

            # Fetch these all again
            squares = (self.model.objects.filter(col__lt=upper_col)
                                    .filter(col__gte=lower_col)
                                    .filter(row__lt=upper_row)
                                    .filter(row__gte=lower_row))
            if squares.count() > width * height:
                raise Exception('The game has happened upon an inconsistent state after '
                            'trying to rectify the situation once already.  Sorry about this.'
                            'The admin has been contacted and is fixing the problem as we speak.')
        else:
            print 'All squares already created'

        squares = squares.order_by('row', 'col')

        return squares


    def generate_unsaved_square(self, col, row):
        this_terrain = self.terrain_type_for_square(col, row)

        north = self.terrain_type_for_square(col, row-1) == this_terrain
        south = self.terrain_type_for_square(col, row+1) == this_terrain
        east = self.terrain_type_for_square(col+1, row) == this_terrain
        west = self.terrain_type_for_square(col-1, row) == this_terrain

        north_east = self.terrain_type_for_square(col+1, row-1) == this_terrain
        north_west = self.terrain_type_for_square(col-1, row-1) == this_terrain
        south_east = self.terrain_type_for_square(col+1, row+1) == this_terrain
        south_west = self.terrain_type_for_square(col-1, row+1) == this_terrain

        if     west and     north_west and     north: north_west_tile_24 = 4
        if     west and not north_west and     north: north_west_tile_24 = 14
        if     west and     north_west and not north: north_west_tile_24 = 2
        if     west and not north_west and not north: north_west_tile_24 = 2
        if not west and     north_west and     north: north_west_tile_24 = 12
        if not west and not north_west and     north: north_west_tile_24 = 12
        if not west and     north_west and not north: north_west_tile_24 = 0
        if not west and not north_west and not north: north_west_tile_24 = 0

        if     east and     north_east and     north: north_east_tile_24 = 5
        if     east and not north_east and     north: north_east_tile_24 = 13
        if     east and     north_east and not north: north_east_tile_24 = 1
        if     east and not north_east and not north: north_east_tile_24 = 1
        if not east and     north_east and     north: north_east_tile_24 = 15
        if not east and not north_east and     north: north_east_tile_24 = 15
        if not east and     north_east and not north: north_east_tile_24 = 3
        if not east and not north_east and not north: north_east_tile_24 = 3

        if     west and     south_west and     south: south_west_tile_24 = 10
        if     west and not south_west and     south: south_west_tile_24 = 8
        if     west and     south_west and not south: south_west_tile_24 = 20
        if     west and not south_west and not south: south_west_tile_24 = 20
        if not west and     south_west and     south: south_west_tile_24 = 6
        if not west and not south_west and     south: south_west_tile_24 = 6
        if not west and     south_west and not south: south_west_tile_24 = 18
        if not west and not south_west and not south: south_west_tile_24 = 18

        if     east and     south_east and     south: south_east_tile_24 = 11
        if     east and not south_east and     south: south_east_tile_24 = 7
        if     east and     south_east and not south: south_east_tile_24 = 19
        if     east and not south_east and not south: south_east_tile_24 = 19
        if not east and     south_east and     south: south_east_tile_24 = 9
        if not east and not south_east and     south: south_east_tile_24 = 9
        if not east and     south_east and not south: south_east_tile_24 = 21
        if not east and not south_east and not south: south_east_tile_24 = 21

        return self.model(
            col=col,
            row=row,
            terrain_type=this_terrain,
            north_west_tile_24=north_west_tile_24,
            north_east_tile_24=north_east_tile_24,
            south_west_tile_24=south_west_tile_24,
            south_east_tile_24=south_east_tile_24,
        )


    def terrain_type_for_square(self, col, row):
        terrain_type = 'plains'

        frequency = 1.0/5
        forest_value = noise.pnoise2(col*frequency, row*frequency, 20)
        if forest_value < -0.05:
            terrain_type = 'forest'

        frequency = 1.0/5
        mountain_value = noise.pnoise2(col*frequency, row*frequency, 1)
        if mountain_value > 0.2:
            terrain_type = 'mountains'

        frequency_x = 1.0/45
        frequency_y = 1.0/30
        river_value = noise.pnoise2(col*frequency_x, row*frequency_y, 10, -0.3)
        if river_value < 0.04 and river_value > -0.04:
            terrain_type = 'water'

        frequency = 1.0/20
        lake_value = noise.pnoise2(col*frequency, row*frequency, 6)
        if lake_value < -0.2:
            terrain_type = 'water'

        return terrain_type


TILES48 = [
    ['arrow-west-end', 'arrow-south-end', 'arrow-east-end', 'arrow-north-end'],
    ['arrow-south-east', 'arrow-north-east', 'arrow-north-west', 'arrow-south-west'],
    ['arrow-start-east', 'arrow-start-north', 'arrow-start-west', 'arrow-start-south'],
    ['arrow-west-east', 'arrow-north-south', 'under-construction', 'arrow-north-end'],
    ['arrow-west-end', 'arrow-south-end', 'arrow-east-end', 'arrow-north-end'],
    ['arrow-west-end', 'arrow-south-end', 'arrow-east-end', 'arrow-north-end'],
    ['arrow-west-end', 'arrow-south-end', 'arrow-east-end', 'arrow-north-end'],
    ['arrow-west-end', 'arrow-south-end', 'arrow-east-end', 'arrow-north-end'],
]


class SquareOccupiedException(Exception):
    pass
class InvalidPlacementException(Exception):
    pass
class SquareDoesNotExistException(Exception):
    pass


class Square(models.Model):
    TERRAIN_TYPES = (
        ('plains', 'Plains'),
        ('water', 'Water'),
        ('mountains', 'Mountains'),
        ('forest', 'Forest'),
        ('road', 'Road'),
    )
    col = models.IntegerField()
    row = models.IntegerField()
    owner = models.ForeignKey(Account, related_name='squares_owned', null=True, blank=True)
    resource_amount = models.IntegerField(default=0)
    wall_health = models.IntegerField(default=0)
    terrain_type = models.CharField(max_length=20, choices=TERRAIN_TYPES)

    north_west_tile_24 = models.IntegerField(null=True, blank=True)
    north_east_tile_24 = models.IntegerField(null=True, blank=True)
    south_west_tile_24 = models.IntegerField(null=True, blank=True)
    south_east_tile_24 = models.IntegerField(null=True, blank=True)
    tile_48 = models.IntegerField(null=True, blank=True)

    #has_road = models.BooleanField(default=False)
    #has_city = models.BooleanField(default=False)

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



    def __unicode__(self):
        return '(%d, %d)' % (self.col, self.row)


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
    ('move', 'Move Units'),
    ('attack', 'Attack'),
    ('city', 'Build City'),
    ('road', 'Build Road'),
)
# Squares are more or less read only until the turn resolves, before that we deal with actions
class Action(models.Model):
    player = models.ForeignKey(Account, related_name='moves')
    turn = models.IntegerField()

    kind = models.CharField(max_length=30, choices=ACTION_KINDS)

    # Also used for the location you are wanting to place a building
    src_col = models.IntegerField()
    src_row = models.IntegerField()

    # Used only for moving units
    dest_col = models.IntegerField()
    dest_row = models.IntegerField()
    timestamp = models.DateTimeField(auto_now_add=True)

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

