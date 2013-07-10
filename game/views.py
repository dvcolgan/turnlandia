from django.shortcuts import render, get_object_or_404
from django.db.models import F
from django.contrib import messages 
from django.http import HttpResponseRedirect, Http404, HttpResponse
from django.core.urlresolvers import reverse
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.contrib.auth.decorators import *
from django.shortcuts import _get_queryset
from game.models import *
from game.serializers import *
from game.forms import *
from util.functions import *
from django.contrib.auth import authenticate, login

from rest_framework.generics import *
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from django.utils import simplejson
import random
import math
import ipdb

import datetime

def home(request):
    day_counter = Setting.objects.get_current_day()
    player_count = Account.objects.count()
    return render(request, 'home.html', locals())


def create_account(request):
    day_counter = Setting.objects.get_current_day()
    player_count = Account.objects.count()
    if request.method == 'POST':
        form = CreateAccountForm(request.POST)
        if form.is_valid():
            form.save()
            account = authenticate(username=request.POST['username'],
                                    password=request.POST['password1'])
            login(request, account)

            #send_templated_mail(
            #    template_name='registration-confirmation',
            #    from_email=settings.ADMIN_EMAIL_SENDER,
            #    recipient_list=[account.email],
            #    context={
            #        'domain': settings.SITE_DOMAIN,
            #        'account': account,
            #    })
            return HttpResponseRedirect(reverse('settings'))

    else:
        form = CreateAccountForm()
    return render(request, 'create-account.html', locals())

@login_required
def settings(request):
    day_counter = Setting.objects.get_current_day()
    player_count = Account.objects.count()
    if request.method == 'POST':
        form = SettingsForm(request.POST, instance=request.user)
        if form.is_valid():
            form.save()
            return HttpResponseRedirect(reverse('game'))
    else:
        form = SettingsForm(instance=request.user)

    return render(request, 'settings.html', locals())

@login_required
def game(request):
    day_counter = Setting.objects.get_current_day()
    player_count = Account.objects.count()
    return render(request, 'game.html', locals())

class AccountAPIView(RetrieveAPIView, ListAPIView):
    permission_classes = (IsAuthenticated,)
    serializer_class = AccountSerializer
    model = Account

@login_required
@api_view(['GET'])
def api_username_existence(request, username):
    taken = (get_object_or_None(Account, username=username) != None)
    return Response({ 'taken': taken })

@login_required
@api_view(['GET'])
def api_email_existence(request, email):
    taken = (get_object_or_None(Account, email=email) != None)
    return Response({ 'taken': taken })

@login_required
@api_view(['GET'])
def api_sector(request, x, y, view_width, view_height):
    try:
        x = int(x)
        y = int(y)
        view_width = int(view_width)
        view_height = int(view_height)
    except:
        raise Http404

    # TODO a lot of this function can be computed on the turn change and then cached, do this if we get a bunch of traffic

    if x > 10000 or x < -10000 or y > 10000 or y < -10000:
        return Response({
            'error': 'I really don\'t feel like fetching the map that far out.'
        }, status=status.HTTP_400_BAD_REQUEST)

    if view_width > 100 or view_height > 70:
        return Response({
            'error': 'Yo dog, you can\'t seriously have a screen that big.  If you do, let the admin know though and I\'ll increase the max screen size.'
        }, status=status.HTTP_400_BAD_REQUEST)

    if view_width < 1 or view_height < 1:
        return Response({
            'error': 'What is this, a quantum computer?  Your screen size must be expressed in positive numbers.'
        }, status=status.HTTP_400_BAD_REQUEST)


    # derived by black magic on a note card
    upper_x = int(math.floor(view_width/2.0-0.25))+x
    lower_x = int(math.ceil(-view_width/2.0-0.25))+x
    upper_y = int(math.floor(view_height/2.0-0.25))+y
    lower_y = int(math.ceil(-view_height/2.0-0.25))+y

    squares = (Square.objects.filter(x__lte=upper_x)
                             .filter(x__gte=lower_x)
                             .filter(y__lte=upper_y)
                             .filter(y__gte=lower_y))

    # If we have a duplication of squares, that is kind of a problem, but shouldn't happen.
    if squares.count() > view_width * view_height:
        return Response({
            'error': 'The game has happened upon an inconsistent state.  Sorry about this.'
                     'The admin has been contacted and is fixing the problem as we speak.'
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    # The common case will be that they all exist, so this expensive
    # operation won't happen very often.
    if squares.count() != view_width * view_height:
        # Nobody has gone out here yet, create the squares that don't exist
        batch = []
        for this_y in range(lower_y, upper_y+1):
            for this_x in range(lower_x, upper_x+1):
                if get_object_or_None(Square, x=this_x, y=this_y) == None:
                    batch.append(Square(x=this_x, y=this_y))
        Square.objects.bulk_create(batch)
        print 'Created %d new squares' % len(batch)

        # Fetch these all again
        squares = (Square.objects.filter(x__lte=upper_x)
                                 .filter(x__gte=lower_x)
                                 .filter(y__lte=upper_y)
                                 .filter(y__gte=lower_y))
        if squares.count() > view_width * view_height:
            return Response({
                'error': 'The game has happened upon an inconsistent state after '
                         'trying to rectify the situation once already.  Sorry about this.'
                         'The admin has been contacted and is fixing the problem as we speak.'
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    else:
        print 'All squares already created'

    squares = squares.order_by('y', 'x')

    return Response({
        # TODO This will get more and more ineffecient as the number of players increases, not actually players visible, just all players
        'players_visible': AccountSerializer(Account.objects.all(), many=True).data,
        'total_units': request.user.total_units,
        #TODO this appears once elsewhere.  make it a function
        'is_initial': (request.user.total_units == 0 and Square.objects.filter(owner=request.user).count() == 0),
        'units_placed': Unit.objects.total_placed_units(request.user),
        'squares': SquareSerializer(squares, many=True).data,
    })
    
@login_required
@api_view(['POST'])
def api_square_unit_action(request, x, y, action):
    try:
        x = int(x)
        y = int(y)
    except:
        raise Http404

    square = get_object_or_None(Square, x=x, y=y)
    if square == None:
        return Response({
            'error': 'Square does not exist.  Load the page first to generate the square.',
        }, status=status.HTTP_400_BAD_REQUEST)


    if action == 'place':
        unit = get_object_or_None(Unit, square=square, owner=request.user)
        if unit:
            unit.amount += 1
        else:
            unit = Unit(square=square, owner=request.user, amount=1)
        unit.save()
        request.user.total_units -= 1
        request.user.save()
        return Response({})

    elif action == 'remove':
        unit = get_object_or_None(Unit, square=square, owner=request.user)
        if unit:
            unit.amount -= 1
            if unit.amount == 0:
                unit.delete()
            else:
                unit.save()
            request.user.total_units -= 1
            request.user.save()

        return Response({})

    elif action == 'settle':
        unit = get_object_or_None(Unit, square=square, owner=request.user)
        if unit:
            square.resource_amount += unit.amount * 4
            square.save()
            unit.delete()
            request.user.total_units -= unit.amount * 4
            request.user.save()

        return Response({})

    elif action == 'wall':
        unit = get_object_or_None(Unit, square=square, owner=request.user)
        if unit:
            square.wall_health += unit.amount * 2
            square.save()
            unit.delete()
            request.user.total_units -= unit.amount * 2
            request.user.save()

        return Response({})


    elif action == 'initial':
        if request.user.total_units == 0 and Square.objects.filter(owner=request.user).count() == 0:

            try:
                # This needs to be made atomic, if it fails in the middle, it could be problematic
                placement = {
                    8: [
                        Square.objects.get(x=x, y=y),
                    ],
                    4: [
                        Square.objects.get(x=x-1, y=y),
                        Square.objects.get(x=x+1, y=y),
                        Square.objects.get(x=x,   y=y-1),
                        Square.objects.get(x=x,   y=y+1),
                    ],
                    2: [
                        Square.objects.get(x=x-1, y=y-1),
                        Square.objects.get(x=x+1, y=y+1),
                        Square.objects.get(x=x+1, y=y-1),
                        Square.objects.get(x=x-1, y=y+1),
                    ],
                    1: [
                        Square.objects.get(x=x,   y=y-2),
                        Square.objects.get(x=x,   y=y+2),
                        Square.objects.get(x=x+2, y=y),
                        Square.objects.get(x=x-2, y=y),
                    ],
                }
                for count, squares in placement.iteritems():
                    for square in squares:
                        if square.units.count() != 0:
                            return Response({'error': 'There is already a unit there.'}, status=status.HTTP_400_BAD_REQUEST)
                # If there are no problems, create the units
                for count, squares in placement.iteritems():
                    for square in squares:
                        Unit.objects.create(
                            owner=request.user,
                            square=square,
                            amount=count,
                        )
                        print 'creating unit'
                request.user.total_units = 36
                request.user.save()
                return Response({})
                            
            except:
                return Response({'error': 'Squares do not exist.'}, status=status.HTTP_400_BAD_REQUEST)
        else:
            return Response({'error': 'You can only do an initial placement if you have no units or squares.'}, status=status.HTTP_400_BAD_REQUEST)


    else:
        return Response({'error': 'Invalid action.'}, status=status.HTTP_400_BAD_REQUEST)


        


#class GamePlayersListAPIView(ListAPIView):
#    model = Player
#    def get_queryset(self):
#        return Player.objects.filter(game__pk=self.kwargs['pk'])
#
#class GamePlayersListAPIView(ListAPIView):
#    model = Player
#    def get_queryset(self):
#        return Player.objects.filter(game__pk=self.kwargs['pk'])
