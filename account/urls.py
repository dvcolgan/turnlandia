from django.conf.urls import patterns, include, url
from django.conf import settings
from rest_framework.generics import *
from account.models import *
from account.views import *

urlpatterns = patterns('account.views',

    url(r'^api/account/$', ListCreateAPIView.as_view(serializer_class=AccountSerializer, model=Account), name='api-account'),
    url(r'^api/account/(?P<pk>\d+)/$', RetrieveAPIView.as_view(serializer_class=AccountSerializer, model=Account), name='api-account'),
    url(r'^api/account/exists/username/(?P<username>.+)/$', 'api_username_existence', name='api-username-existence'),
    url(r'^api/account/exists/email/(?P<email>.+)/$', 'api_email_existence', name='api-email-existence'),
)
