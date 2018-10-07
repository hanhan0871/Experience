from django.db import models
from django.contrib.auth.models import User

# Create your models here.
# -*- coding: utf-8 -*-

class Topic(models.Model):
    """用户学习的主题"""
    text = models.CharField(max_length = 200)

    # 每当用户新建主题，自动设置当前日期和时间
    date_added = models.DateTimeField(auto_now_add=True)

    # 建立到模型User的外键关系
    owner = models.ForeignKey(User)

    def __str__(self):
        """返回模型的字符串"""
        return self.text


class Entry(models.Model):
    """ 学习到的有关某个主题的具体知识 """
    topic = models.ForeignKey(Topic)
    text = models.TextField()
    date_added = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = 'entries'

    def __str__(self):
        if len(self.text) < 50:
            return self.text
        else:
            return self.text[:50] + '...'


