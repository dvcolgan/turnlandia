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

    url(r'^api/sector/(?P<col>[0-9-]+)/(?P<row>[0-9-]+)/(?P<width>[0-9]+)/(?P<height>[0-9]+)/$', 'api_sector', name='api-sector'),

    url(r'^api/undo/(?P<action_id>\d+)/$', 'api_undo', name='api-undo'),

    url(r'^api/action/(?P<kind>move|attack|city|road)/(?P<src_col>[0-9-]+)/(?P<src_row>[0-9-]+)/$', 'api_action', name='api-action'),
    url(r'^api/action/(?P<kind>move|attack|city|road)/(?P<src_col>[0-9-]+)/(?P<src_row>[0-9-]+)/(?P<dest_col>[0-9-]+)/(?P<dest_row>[0-9-]+)/$', 'api_action', name='api-action'),

    #url(r'^api/move-unit/(?P<unit_id>\d+)/(?P<dest_col>[0-9-]+)/(?P<dest_row>[0-9-]+)/$', 'api_move_unit', name='api-move-unit'),

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
