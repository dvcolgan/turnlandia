from django.conf.urls import patterns, include, url
from django.contrib import admin
from django.core.urlresolvers import reverse
from django.conf import settings
from django.views.generic import TemplateView

#from library.forms import *

admin.autodiscover()

urlpatterns = patterns('',
    url(r'^admin/', include(admin.site.urls)),

    url(r'', include('game.urls')),

    url(r'^requiretest/', TemplateView.as_view(template_name='requiretest.html'), name='requiretest'),
    url(r'^login/$', 'django.contrib.auth.views.login', {
        'template_name': 'login.html',
    }, 'login'),

    url(r'^api-auth/', include('rest_framework.urls', namespace='rest_framework')),

    url(r'^password-change/$', 'django.contrib.auth.views.password_change', {
        'template_name': 'password_change.html',
    }, 'password_change'),

    url(r'^password-reset/$', 'django.contrib.auth.views.password_reset', {
        'template_name': 'password_change.html',
    }, 'password_reset'),

    url(r'^logout/$', 'django.contrib.auth.views.logout_then_login', name='logout'),

    url(r'', include('django.contrib.auth.urls')),

)

if settings.DEBUG:
    urlpatterns += patterns('',
    (r'^media/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.MEDIA_ROOT}),
)
