# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# https://doc.scrapy.org/en/latest/topics/items.html

import scrapy
from scrapy.loader.processors import *


def mysplit(info):
    return info.split('/')

class SpiderDoubanItem(scrapy.Item):
    # define the fields for your item here like:
    # Join 去掉列表中括号
    mMvName = scrapy.Field(output_processor=Join())
    mDirectors = scrapy.Field(output_processor=Join())
    mStarrings = scrapy.Field(output_processor=Join('/'))
    mTypes = scrapy.Field()
    mPlace = scrapy.Field(input_processor=MapCompose(str.strip),output_processor=Join())
    mLang = scrapy.Field(input_processor=MapCompose(str.strip),output_processor=Join())
    mAlias = scrapy.Field(input_processor=MapCompose(mysplit, str.strip), output_processor=Join('|'))
    mShowtimes = scrapy.Field()
    mRuntime = scrapy.Field()
    mScore = scrapy.Field(output_processor=Join())
    mVotes = scrapy.Field(output_processor=Join())
