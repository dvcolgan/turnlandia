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
from settings import MIN_SECTOR_X, MAX_SECTOR_X, MIN_SECTOR_Y, MAX_SECTOR_Y, SECTOR_SIZE, GRID_SIZE

from django.utils import simplejson
import random
import math
import ipdb

import datetime

def home(request):
    if request.user.is_authenticated():
        return HttpResponseRedirect(reverse('game'))
    day_counter = Setting.objects.get_current_day()
    player_count = Account.objects.count()
    return render(request, 'home.html', locals())

def how_to_play(request):
    day_counter = Setting.objects.get_current_day()
    player_count = Account.objects.count()

    if request.user.color == '' or request.user.leader_name == '' or request.user.people_name == '':
        next_link = reverse('settings')
    else:
        next_link = reverse('game')
    return render(request, 'how-to-play.html', locals())

def profile(request, account_id=None):
    if account_id == None:
        this_account = request.user
    else:
        this_account = get_object_or_404(Account, pk=account_id)

    awardings = this_account.awardings.all()
    return render(request, 'profile.html', locals())

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
            return HttpResponseRedirect(reverse('how-to-play'))

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

    needs = []
    if request.user.color == '':
        needs.append('color=1')
    if request.user.leader_name == '':
        needs.append('leader_name=1')
    if request.user.people_name == '':
        needs.append('people_name=1')

    if len(needs) > 0:
        return HttpResponseRedirect(reverse('settings') + '?' + '&'.join(needs))

    return render(request, 'game.html', locals())



@login_required
def messages(request):
    day_counter = Setting.objects.get_current_day()
    player_count = Account.objects.count()
    sent_messages = Message.objects.filter(sender=request.user)
    received_messages = Message.objects.filter(recipient=request.user)
    return render(request, 'messages.html', locals())

@login_required
def compose(request):
    day_counter = Setting.objects.get_current_day()
    player_count = Account.objects.count()

    if request.method == 'POST':
        form = SendMessageForm(request.POST)
        form.instance.sender = request.user
        if form.is_valid():
            form.save()
            return HttpResponseRedirect(reverse('messages'))
    else:
        form = SendMessageForm()
    return render(request, 'compose.html', locals())


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
def api_sector(request, col, row, width, height):
    try:
        col = int(col)
        row = int(row)
        width = int(width)
        height = int(height)
    except:
        raise Http404

    # TODO a lot of this function can be computed on the turn change and then cached, do this if we get a bunch of traffic
    # TODO make this instead limit it to a few screens beyond where the furthest person is
    if (col > MAX_SECTOR_X * SECTOR_SIZE or
       col < MIN_SECTOR_X * SECTOR_SIZE or
       row > MAX_SECTOR_Y * SECTOR_SIZE or
       row < MIN_SECTOR_Y * SECTOR_SIZE):
        return Response({
            'error': 'I really don\'t feel like fetching the map that far out.'
        }, status=status.HTTP_400_BAD_REQUEST)

    if width > 200 or height > 200:
        return Response({
            'error': 'Yo dog, you can\'t seriously have a screen that big.  If you do, let the admin know though and I\'ll increase the max screen size.'
        }, status=status.HTTP_400_BAD_REQUEST)

    if width < 1 or height < 1:
        return Response({
            'error': 'What is this, a quantum computer?  Your screen size must be expressed in positive numbers.'
        }, status=status.HTTP_400_BAD_REQUEST)

    squares = Square.objects.get_region(col, row, width, height)

    is_initial = (
        Unit.objects.filter(owner=request.user).count() == 0 and
        Square.objects.filter(owner=request.user).count() == 0
    )

    return Response(SquareSerializer(squares, many=True).data)

@login_required
@api_view(['GET'])
def api_initial_load(request):
    current_turn = Setting.objects.get_current_day()

    moves = Move.objects.filter(player=request.user).filter(turn=current_turn)

    return Response({
        'board_consts': {
            'min_sector_x': MIN_SECTOR_X,
            'max_sector_x': MAX_SECTOR_X,
            'min_sector_y': MIN_SECTOR_Y,
            'max_sector_y': MAX_SECTOR_Y,
            'sector_size': SECTOR_SIZE,
            'grid_size': GRID_SIZE,
        },
        'moves': MoveSerializer(moves, many=True).data,
        'account': AccountSerializer(request.user).data,
    })
    
@login_required
@api_view(['POST'])
def api_square_unit_action(request, src_col, src_row, dest_col, dest_row, kind, amount):
    try:
        src_col = int(src_col)
        src_row = int(src_row)
        dest_col = int(dest_col)
        dest_row = int(dest_row)
    except:
        raise Http404

    new_move = Move(
        player=request.user,
        turn=int(Setting.objects.get(name='Current Day')),
        src_col=src_col,
        src_row=src_row,
        dest_col=dest_col,
        dest_row=dest_row,
        kind=kind,
        amount=amount
    )

    if new_move.is_valid():
        new_move.save()
    else:
        return Response({'error': new_move.error}, status=status.HTTP_400_BAD_REQUEST)

        


    #if action == 'place':
    #    try:
    #        square.place_unit(request.user)
    #        return Response({})
    #    except InvalidPlacementException:
    #        return Response({'error': 'You can only place units on a square you own or adjacent to a square you own.'}, status=status.HTTP_400_BAD_REQUEST)

    #elif action == 'remove':
    #    square.remove_unit(request.user)
    #    return Response({})

    #elif action == 'settle':
    #    square.settle_units(request.user)
    #    return Response({})

    ##elif action == 'wall':
    ##    square.build_wall(request.user)
    ##    return Response({})

    #elif action == 'initial':
    #    try:
    #        square.initial_placement(request.user)
    #        return Response({})
    #    except SquareOccupiedException:
    #        return Response({'error': 'Your placement is too close to another player.'}, status=status.HTTP_400_BAD_REQUEST)


        


#class GamePlayersListAPIView(ListAPIView):
#    model = Player
#    def get_queryset(self):
#        return Player.objects.filter(game__pk=self.kwargs['pk'])
#
#class GamePlayersListAPIView(ListAPIView):
#    model = Player
#    def get_queryset(self):
#        return Player.objects.filter(game__pk=self.kwargs['pk'])
