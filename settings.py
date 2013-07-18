import os
import socket

PROJECT_DIR = os.path.dirname(__file__)

DEBUG = True
TEMPLATE_DEBUG = DEBUG

ADMINS = (
    ('David Colgan', 'dvcolgan@gmail.com'),
)

MANAGERS = ADMINS

HOSTNAME = socket.gethostname()
FILEPATH = os.path.abspath(__file__)

DEBUG = True
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': 'turnbased',
        'TEST_NAME': 'turnbased_test',
        'USER': 'dcolgan',
        'PASSWORD': '',
        'HOST': '',
        'PORT': '',
    }
}
SITE_DOMAIN = 'localhost:8000'
SERVER = 'local'
# Print emails to stdout if we are local
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'


#POSTMARK_API_KEY = '16666bca-f5be-4bd9-8bde-6b3dd27b9f7a'
#
#SERVER_EMAIL = 'update@conferam.com'
#EMAIL_HOST = 'smtp.postmarkapp.com'
#EMAIL_PORT = 25
#EMAIL_HOST_USER = POSTMARK_API_KEY
#EMAIL_HOST_PASSWORD = POSTMARK_API_KEY
#EMAIL_USE_TLS = True
#
#ADMIN_EMAIL_SENDER = SERVER_EMAIL
#DEFAULT_FROM_EMAIL = SERVER_EMAIL

#TEMPLATED_EMAIL_TEMPLATE_DIR = 'email/'
#TEMPLATED_EMAIL_FILE_EXTENSION = 'html'

TIME_ZONE = 'America/New_York'
LANGUAGE_CODE = 'en-us'
SITE_ID = 1

USE_I18N = False
USE_L10N = True
USE_TZ = True

MEDIA_ROOT = os.path.join(PROJECT_DIR, 'media')
MEDIA_URL = '/media/'
STATIC_ROOT = os.path.join(PROJECT_DIR, 'site-static')
STATIC_URL = '/static/'


AUTH_USER_MODEL = 'game.Account'
LOGIN_URL = '/login/'
LOGIN_REDIRECT_URL = '/game/'
LOGOUT_URL = '/logout/'

STATICFILES_DIRS = (
    os.path.join(PROJECT_DIR, "static"),
)

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
)

SECRET_KEY = 'ifk&ab3#tl!mrkkb476b0xj=wm&y+jwas!#)ysfgq9rin$8_x3'

TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
)

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'urls'

WSGI_APPLICATION = 'wsgi.application'

PROJECT_ROOT = os.path.abspath(os.path.dirname(__file__))
TEMPLATE_DIRS = (
    os.path.join(PROJECT_ROOT, "templates"),
)

ALLOWED_HOSTS = ['localhost']

PASSWORD_HASHERS = (
    'django.contrib.auth.hashers.BCryptPasswordHasher',
    'django.contrib.auth.hashers.PBKDF2PasswordHasher',
    'django.contrib.auth.hashers.PBKDF2SHA1PasswordHasher',
    'django.contrib.auth.hashers.SHA1PasswordHasher',
    'django.contrib.auth.hashers.MD5PasswordHasher',
    'django.contrib.auth.hashers.CryptPasswordHasher',
)

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.staticfiles',
    'django.contrib.messages',
    'django.contrib.admin',
    'widget_tweaks',
    'rest_framework',
    'util',
    'game',
    'django_nose',
    'south',
)

SOUTH_TESTS_MIGRATE = False
SKIP_SOUTH_TESTS = True
TEST_RUNNER = 'django_nose.NoseTestSuiteRunner'

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        }
    },
    'handlers': {
        'mail_admins': {
            'level': 'ERROR',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler'
        }
    },
    'loggers': {
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
    }
}

#ignore the following error when using ipython:
#/django/db/backends/sqlite3/base.py:50: RuntimeWarning:
#SQLite received a naive datetime (2012-11-02 11:20:15.156506) while time zone support is active.

import warnings
import exceptions
warnings.filterwarnings("ignore", category=exceptions.RuntimeWarning, module='django.db.backends.sqlite3.base', lineno=53)

import sys
if 'test' in sys.argv:
    DATABASES['default'] = {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': 'turnbased_test'
    }
    # Greatly speed up password hashing
    PASSWORD_HASHERS = (
        'django.contrib.auth.hashers.MD5PasswordHasher',
    )
