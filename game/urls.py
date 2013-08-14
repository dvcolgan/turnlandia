from django.conf.urls import patterns, include, url
from django.conf import settings
from rest_framework.generics import *
from game.models import *
from game.views import *

urlpatterns = patterns('game.views',
    url(r'^$', 'home', name='home'),
    url(r'^settings/$', 'settings', name='settings'),

    url(r'^game/$', 'game', name='game'),
    url(r'^messages/$', 'messages', name='messages'),

    url(r'^how-to-play/$', 'how_to_play', name='how-to-play'),

    #url(r'^api/account/$', ListCreateAPIView.as_view(serializer_class=AccountSerializer, model=Account), name='api-account'),
    #url(r'^api/account/(?P<pk>\d+)/$', RetrieveAPIView.as_view(serializer_class=AccountSerializer, model=Account), name='api-account'),
    #url(r'^api/account/exists/username/(?P<username>.+)/$', 'api_username_existence', name='api-username-existence'),
    #url(r'^api/account/exists/email/(?P<email>.+)/$', 'api_email_existence', name='api-email-existence'),

    url(r'^messages/compose/$', 'compose', name='compose'),
    
    #url(r'^api/game/$',
    #    ListCreateAPIView.as_view(
    #        serializer_class=GameSerializer,
    #        model=Game
    #    ),
    #    name='api-game'
    #),

    #url(r'^api/game/(?P<pk>\d+)/$',
    #    RetrieveUpdateDestroyAPIView.as_view(
    #        serializer_class=GameSerializer,
    #        model=Game
    #    ),
    #    name='api-game'
    #),

    #url(r'^api/game/(?P<pk>\d+)/$',
    #    RetrieveUpdateDestroyAPIView.as_view(
    #        serializer_class=GameSerializer,
    #        model=Game
    #    ),
    #    name='api-game'
    #),

    url(r'^api/sector/(?P<col>[0-9-]+)/(?P<row>[0-9-]+)/(?P<width>[0-9]+)/(?P<height>[0-9]+)/$', 'api_sector', name='api-sector'),

    url(r'^api/square/(?P<col>[0-9-]+)/(?P<row>[0-9-]+)/(?P<action>initial|place|remove|settle|give|wall)/$', 'api_square_unit_action', name='api-square-unit-action'),

    #url(r'^api/player/$',
    #    ListCreateAPIView.as_view(
    #        serializer_class=PlayerSerializer,
    #        model=Player
    #    ),
    #    name='api-player'
    #),

    #url(r'^api/player/(?P<pk>\d+)/$',
    #    RetrieveUpdateDestroyAPIView.as_view(
    #        serializer_class=PlayerSerializer,
    #        model=Player
    #    ),
    #    name='api-player'
    #),

    #url(r'^api/game/(?P<pk>\d+)/players/$', GamePlayersListAPIView.as_view(), name='api-players'),
)
