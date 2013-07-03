from django.shortcuts import render, get_object_or_404
from django.db.models import F
from django.contrib import messages 
from django.http import HttpResponseRedirect, Http404, HttpResponse
from django.core.urlresolvers import reverse
from django.core.paginator import Paginator, EmptyPage, PageNotAnInteger
from django.contrib.auth.decorators import *
from account.models import *
from account.serializers import *
from util.functions import *

from rest_framework.generics import *
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from django.utils import simplejson
import random
import math
import ipdb

def home(request):
    return render(request, 'home.html', locals())

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
