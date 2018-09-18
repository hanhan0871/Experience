#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time     : 2018/8/5 21:41
# @Author   : Bruce Lee
import sys
import pygame
from pygame.sprite import Sprite

class Bullet(Sprite):
    """管理飞船子弹的子类"""

    def __init__(self, ai_settings, screen, ship):
        super(Bullet, self).__init__()
        self.screen = screen

        """在（0，0）处创建子弹"""
        self.rect = pygame.Rect(0, 0,
                                ai_settings.bullet_width,
                                ai_settings.bullet_height)
        self.rect.centerx = ship.rect.centerx
        self.rect.top = ship.rect.top

        self.y = float(self.rect.y)
        self.color = ai_settings.bullet_color
        self.speed_factor = ai_settings.bullet_speed_factor

    def update(self):
        """向上移动子弹"""
        self.y -= self.speed_factor
        self.rect.y = self.y

    def draw_bullet(self):
        pygame.draw.rect(self.screen, self.color, self.rect)
