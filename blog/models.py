from __future__ import unicode_literals

from django.db import models
from django.contrib.auth.models import User

# Create your models here.

class Athlete(models.Model):
    first_name = models.CharField(max_length=200)
    last_name = models.CharField(max_length=200)
    dob = models.DateField()
    racing_since = models.DateField()
    location = models.CharField(max_length=100)
    favorite_race = models.CharField(max_length=200)
    image = models.BinaryField(blank=True, null=True)
    ACTIVE = 'Active'
    INACTIVE = 'Inactive'
    DELETED = 'Deleted'
    STATUS_CHOICES = (
        (ACTIVE, 'Active'),
        (INACTIVE, 'Inactive'),
    )
    status = models.CharField(max_length=200, choices=STATUS_CHOICES, default=INACTIVE)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted_at = models.DateTimeField(blank=True, null=True)
    def __str__(self):
        return "{} {}".format(self.first_name, self.last_name)
    def age(self):
        import datetime
        dob = self.dob
        tod = datetime.date.today()
        my_age = (tod.year - dob.year) - int((tod.month, tod.day) < (dob.month, dob.day))
        return my_age


class Event(models.Model):
    title = models.CharField(max_length=200)
    content = models.CharField(max_length=2000)
    author = models.ForeignKey(User, null=True, blank=True, on_delete=models.SET_NULL)
    date = models.DateField()
    image = models.BinaryField(blank=True, null=True)
    BACKLOG = 'Backlog'
    PUBLISHED = 'Published'
    DELETED = 'Deleted'
    STATUS_CHOICES = (
        (BACKLOG, 'Backlog'),
        (PUBLISHED, 'Published'),
        (DELETED, 'Deleted'),
    )
    status = models.CharField(max_length=200, choices=STATUS_CHOICES, default=BACKLOG)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted_at = models.DateTimeField(blank=True, null=True)
    def __str__(self):
        return self.title
    
class Race(models.Model):
    title = models.CharField(max_length=200)
    content = models.CharField(max_length=2000)
    author = models.ForeignKey(User, null=True, blank=True, on_delete=models.SET_NULL)
    athletes = models.CharField(max_length=2000)
    date = models.DateField()
    image = models.BinaryField(blank=True, null=True)
    BACKLOG = 'Backlog'
    PUBLISHED = 'Published'
    DELETED = 'Deleted'
    STATUS_CHOICES = (
        (BACKLOG, 'Backlog'),
        (PUBLISHED, 'Published'),
        (DELETED, 'Deleted'),
    )
    status = models.CharField(max_length=200, choices=STATUS_CHOICES, default=BACKLOG)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted_at = models.DateTimeField(blank=True, null=True)
    def __str__(self):
        return self.title
    
    
    
