from django.conf.urls import patterns, include, url
from django.conf import settings
from rest_framework.generics import *
from game.models import *
from game.views import *

urlpatterns = patterns('game.views',
    url(r'^$', 'home', name='home'),
    url(r'^settings/$', 'settings', name='settings'),
    url(r'^irc/$', 'irc', name='irc'),

    url(r'^game/$', 'game', name='game'),
    url(r'^messages/$', 'messages', name='messages'),

    url(r'^create-account/$', 'create_account', name='create-account'),

    url(r'^profile/$', 'profile', name='profile'),
    url(r'^profile/(?P<account_id>\d+)/$', 'profile', name='profile'),

    url(r'^how-to-play/$', 'how_to_play', name='how-to-play'),

    #url(r'^api/account/$', ListCreateAPIView.as_view(serializer_class=AccountSerializer, model=Account), name='api-account'),
    #url(r'^api/account/(?P<pk>\d+)/$', RetrieveAPIView.as_view(serializer_class=AccountSerializer, model=Account), name='api-account'),
    #url(r'^api/account/exists/username/(?P<username>.+)/$', 'api_username_existence', name='api-username-existence'),
    #url(r'^api/account/exists/email/(?P<email>.+)/$', 'api_email_existence', name='api-email-existence'),

    url(r'^messages/compose/$', 'compose', name='compose'),

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

    url(r'^api/squares/(?P<col>[0-9-]+)/(?P<row>[0-9-]+)/(?P<width>[0-9]+)/(?P<height>[0-9]+)/$', 'api_squares', name='api-squares'),
    url(r'^api/squares/(?P<col>[0-9-]+)/(?P<row>[0-9-]+)/(?P<width>[0-9]+)/(?P<height>[0-9]+)/(?P<exclude_squares>nosquares)/$', 'api_squares', name='api-squares'),

    url(r'^api/undo/$', 'api_undo', name='api-undo'),

    url(r'^api/action/$', 'api_action', name='api-action'),

    url(r'^api/initial-load/$', 'api_initial_load', name='api-initial-load'),

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
