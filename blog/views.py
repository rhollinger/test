from django.http import HttpResponse
from .models import Athlete, Race, Event
from django.http import HttpResponse, HttpResponseRedirect
from django.shortcuts import render, redirect
from django.template import loader


def home(request):
    template = loader.get_template('blog/home.html')
    context = {}
    context['athletes'] = Athlete.objects.filter(status='Active')[:8]
    context['races'] = Race.objects.filter(status='Published').order_by('-date')[:8]
    context['events'] = Event.objects.filter(status='Published').order_by('-created_at')[:4]
    return HttpResponse(template.render(context, request))