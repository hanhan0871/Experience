#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time     : 2018/7/31 22:42
# @Author   : Bruce Lee
import sys
import pygame
from pygame.sprite import Group

from settings import Settings
from ship import Ship
from alien import Alien
from game_stats import GameStats
from button import Button
from scoreboard import  Scoreboard
import game_functions as gf

def run_game():
    #初始化pygame、设置和屏幕对象
    pygame.init()
    ai_settings = Settings()
    screen = pygame.display.set_mode((ai_settings.screen_width, ai_settings.screen_height))
    pygame.display.set_caption("Alien Invasion")

    #设置背景色
    #bg_color = ai_settings.bg_color

    # 创建飞船, 子弹编组， 外星人编组
    ship = Ship(ai_settings, screen)

    # 创建子弹编组
    bullets = Group()

    # 创建外星人
    #alien = Alien(ai_settings, screen)
    aliens = Group()
    gf.create_fleet(ai_settings, screen, ship, aliens)

    # 创建统计实例
    #stats = GameStats(ai_settings)

    # 创建开始按钮
    play_button = Button(ai_settings, screen, "Play")

    # 创建存储游戏统计信息的实例， 及记分牌
    stats = GameStats(ai_settings)
    sb = Scoreboard(ai_settings, screen, stats)

    # 开始游戏的主循环
    while True:
        gf.check_events(ai_settings, screen, stats, sb, play_button, ship, aliens, bullets)

        if stats.game_active:
            ship.update()
            bullets.update()
            gf.update_bullets(ai_settings, screen, stats, sb, ship, aliens, bullets)
            gf.update_aliens(ai_settings, screen, stats, sb, ship, aliens, bullets)

        gf.update_screen(ai_settings, screen, stats, sb, ship, aliens, bullets, play_button)



run_game()


