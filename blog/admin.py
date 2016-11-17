from django.contrib import admin

#from tasks.models import Transfer
from .models import Athlete
from .models import Event
from .models import Race

admin.site.register(Athlete)
admin.site.register(Event)
admin.site.register(Race)
