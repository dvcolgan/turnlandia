from django.db import models
from django.db.models import Sum
from django.contrib.auth.models import *
from game.models import *
from util.functions import *
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



class Account(AbstractBaseUser, PermissionsMixin):

    username = models.CharField(max_length=255, unique=True)
    email = models.EmailField(blank=True)
    color = models.CharField(max_length=10, blank=True)
    leader_name = models.CharField(max_length=255, blank=True)
    people_name = models.CharField(max_length=255, blank=True)
    unplaced_units = models.IntegerField(default=0)

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


class SquareManager(models.Manager):
    # get the squares that encompass the coordinates given
    def get_region(self, col, row, width, height):

        # derived by black magic on a note card
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
                        batch.append(self.model(col=this_col, row=this_row))
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


class SquareOccupiedException(Exception):
    pass
class InvalidPlacementException(Exception):
    pass

class Square(models.Model):
    col = models.IntegerField()
    row = models.IntegerField()
    owner = models.ForeignKey(Account, related_name='squares_owned', null=True, blank=True)
    resource_amount = models.IntegerField(default=0)
    wall_health = models.IntegerField(default=0)

    objects = SquareManager()

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
                    unit.amount += 1
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
        if unit:
            self.resource_amount += unit.amount * 4
            self.save()
            unit.delete()

    def build_wall(self, account):
        unit = get_object_or_None(Unit, square=self, owner=account)
        if self.resource_amount == 0 and unit != None:
            self.wall_health += unit.amount * 2
            self.save()
            unit.delete()

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
                    if square.units.count() != 0 or square.wall_health != 0 or square.owner != None:
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
    def get_current_day(self):
        return Setting.objects.get(name='Current Day').value
        


class Setting(models.Model):
    name = models.CharField(max_length=255)
    value = models.CharField(max_length=255)

    objects = SettingManager()

    def __unicode__(self):
        return '%s: %s' % (self.name, self.value)
