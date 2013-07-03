from django.shortcuts import render, get_object_or_404
from django.db.models import F
from django.contrib import messages 
from django.http import HttpResponseRedirect, Http404, HttpResponse
from django.core.urlresolvers import reverse
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.contrib.auth.decorators import *
from django.shortcuts import _get_queryset
from game.models import *
from game.forms import *
from game.serializers import *
from rest_framework.generics import *

from django.utils import simplejson
import random
import math
import ipdb


def home(request):
    return render(request, 'home.html', locals())

def partials(request, template_file):
    colors = COLORS
    return render(request, 'partials/' + template_file, locals())

def angular_redirector(request, path):
    return HttpResponseRedirect('/#/' + path)

class AccountAPIView(RetrieveAPIView, ListAPIView):
    serializer_class = AccountSerializer
    model = Account

@api_view(['GET'])
def api_username_existence(request, username):
    taken = (get_object_or_None(Account, username=username) != None)
    return Response({ 'taken': taken })

@api_view(['GET'])
def api_email_existence(request, email):
    taken = (get_object_or_None(Account, email=email) != None)
    return Response({ 'taken': taken })

class GamePlayersListAPIView(ListAPIView):
    model = Player
    def get_queryset(self):
        return Player.objects.filter(game__pk=self.kwargs['pk'])

