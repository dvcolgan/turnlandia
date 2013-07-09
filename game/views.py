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
    player_count = Account.objects.count()
    return render(request, 'home.html', locals())

@login_required
def game(request):
    # The base template if used by itself has an ng-view in it
    return render(request, 'base.html', locals())

@login_required
def partials(request, folder, template_file):
    colors = COLORS
    return render(request, folder + '/' + template_file, locals())

@login_required
def angular_redirector(request, path):
    return HttpResponseRedirect('/game/#/' + path)


def create_account(request):
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
    if request.method == 'POST':
        form = SettingsForm(request.POST, instance=request.user)
        if form.is_valid():
            form.save()
            return HttpResponseRedirect(reverse('game'))
    else:
        form = SettingsForm(instance=request.user)

    return render(request, 'settings.html', locals())

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
        y = int(x)
        view_width = int(view_width)
        view_height = int(view_height)
    except:
        raise Http404

    if x > 10000 or x < -10000 or y > 10000 or y < -10000:
        return Response({
            'error': 'I really don\'t feel like fetching the map that far out.'
        }, status=status.HTTP_400_BAD_REQUEST)

    if view_width > 50 or view_height > 40:
        return Response({
            'error': 'Yo dog, you can\'t seriously have a screen that big.'
        }, status=status.HTTP_400_BAD_REQUEST)

    if view_width < 1 or view_height < 1:
        return Response({
            'error': 'What is this, a quantum computer?  Your screen size must be expressed in positive numbers.'
        }, status=status.HTTP_400_BAD_REQUEST)

    upper_x = x+(view_width/2)-1
    lower_x = x-(view_width/2)
    upper_y = y+(view_height/2)-1
    lower_y = y-(view_height/2)

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
        for this_y in range(lower_y, upper_y):
            for this_x in range(lower_x, upper_x):
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
        'x': x,
        'y': y,
        # TODO This will get more and more ineffecient as the number of players increases, not actually players visible, just all players
        'players_visible': AccountSerializer(Account.objects.all(), many=True).data,
        'units_remaining': request.user.total_units - Unit.objects.total_placed_units(request.user),
        'view_width': view_width,
        'view_height': view_height,
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
        serializer = UnitSerializer(unit)

        return Response({
            #'units_remaining': request.user.total_units - Unit.objects.count(),
            'units_remaining': request.user.total_units - Unit.objects.total_placed_units(request.user),
            'unit': serializer.data,
        })

    elif action == 'remove':
        unit = get_object_or_None(Unit, square=square, owner=request.user)
        if unit:
            unit.amount -= 1
            if unit.amount == 0:
                unit.delete()
                amount = 0
            else:
                unit.save()
                amount = unit.amount
            return Response({
                'amount': amount,
                'units_remaining': request.user.total_units - Unit.objects.total_placed_units(request.user),
            })
        else:
            return Response({
                'error': 'Unit does not exist there.'
            }, status=status.HTTP_400_BAD_REQUEST)

    elif action == 'initial':

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
                    Square.objects.get(x=x-1, y=y-1),
                    Square.objects.get(x=x+1, y=y+1),
                    Square.objects.get(x=x+1, y=y-1),
                    Square.objects.get(x=x-1, y=y+1),
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
            return Response({
                'units_remaining': 0,
                'units': Unit.objects.filter(owner=request.user),
            })
                        
        except:
            return Response({'error': 'Squares do not exist.'}, status=status.HTTP_400_BAD_REQUEST)


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
