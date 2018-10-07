#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time     : 2018/9/26 21:41
# @Author   : Bruce Lee


from django import forms

from .models import Topic, Entry

class TopicForm(forms.ModelForm):
    class Meta:
        model = Topic
        fields = ['text']
        labels = {'text': ''}

class EntryForm(forms.ModelForm):
    class Meta:
        model = Entry
        fields = ['text']
        lables = {'text': ''}
        widgets = {'text': forms.Textarea(attrs={'cols': 80})}






