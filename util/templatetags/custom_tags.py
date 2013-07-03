from django import template
from django.conf import settings
from django.utils.safestring import mark_safe

register = template.Library()

@register.simple_tag
def setting(name):
    return getattr(settings, name, "")


#@register.filter
#def format_difference(value):
#    number = int(value)
#    if number > 0:
#        return mark_safe('<span style="color: green">+' + str(number) + '</span>')
#    elif number < 0:
#        return mark_safe('<span style="color: red">' + str(number) + '</span>')
#    else:
#        return mark_safe(str(number))
