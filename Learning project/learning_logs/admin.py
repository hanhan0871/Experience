from django.contrib import admin

# Register your models here.
# -*- coding: utf-8 -*-

from learning_logs.models import Topic,Entry

# 让django通过管理网站管理模型
admin.site.register(Topic)
admin.site.register(Entry)
