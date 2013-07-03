from django.db import models
from django.contrib.auth.models import *


class AccountManager(BaseUserManager):

    def create_user(self, email, password=None, **extra_fields):
        now = timezone.now()
        email = AccountManager.normalize_email(email)
        account = self.model(email=email,
                          is_staff=False, is_active=True, is_superuser=False,
                          last_login=now, date_joined=now, **extra_fields)

        account.set_password(password)
        account.save(using=self._db)
        return account

    def create_superuser(self, email, password, **extra_fields):
        u = self.create_user(email, password, **extra_fields)
        u.is_staff = True
        u.is_active = True
        u.is_superuser = True
        u.save(using=self._db)
        return u



# at some point use http://django-social-auth.readthedocs.org/en/latest/intro.html
class Account(AbstractBaseUser):

    username = models.CharField(max_length=255, unique=True)
    email = models.EmailField(unique=True)

    is_staff = models.BooleanField(default=False,
        help_text='Designates whether the user can log into this admin site.')
    is_active = models.BooleanField(default=True,
        help_text='Designates whether this user should be treated as '
                    'active. Unselect this instead of deleting accounts.')
    is_superuser = models.BooleanField(default=False,
        help_text='Designates that this user has all permissions without '
                    'explicitly assigning them.')
    date_joined = models.DateTimeField(default=timezone.now)
    groups = models.ManyToManyField(Group, verbose_name='groups',
        blank=True, help_text='The groups this user belongs to. A user will '
                                'get all permissions granted to each of '
                                'his/her group.')
    user_permissions = models.ManyToManyField(Permission,
        verbose_name='user permissions', blank=True,
        help_text='Specific permissions for this user.')

    objects = AccountManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = ['email']


    class Meta:
        verbose_name = 'account'
        verbose_name_plural = 'accounts'

    def __unicode__(self):
        return self.username + ' (' + self.email + ')'

    def get_username(self):
        return self.username

    def get_short_name(self):
        return self.username

    def get_full_name(self):
        return self.username

    def get_group_permissions(self, obj=None):
        permissions = set()
        for backend in auth.get_backends():
            if hasattr(backend, "get_group_permissions"):
                if obj is not None:
                    permissions.update(backend.get_group_permissions(self,
                                                                     obj))
                else:
                    permissions.update(backend.get_group_permissions(self))
        return permissions

    def get_all_permissions(self, obj=None):
        return _user_get_all_permissions(self, obj)

    def has_perm(self, perm, obj=None):
        # Active superusers have all permissions.
        if self.is_active and self.is_superuser:
            return True

        # Otherwise we need to check the backends.
        return _user_has_perm(self, perm, obj)

    def has_perms(self, perm_list, obj=None):
        for perm in perm_list:
            if not self.has_perm(perm, obj):
                return False
        return True

    def has_module_perms(self, app_label):
        # Active superusers have all permissions.
        if self.is_active and self.is_superuser:
            return True

        return _user_has_module_perms(self, app_label)

    def email_user(self, subject, message, from_email=None):
        send_mail(subject, message, from_email, [self.email])
