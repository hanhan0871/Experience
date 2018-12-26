# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://doc.scrapy.org/en/latest/topics/item-pipeline.html
import pymongo
from pymongo import MongoClient, InsertOne

class SpiderDoubanPipeline(object):
    def process_item(self, item, spider):
        return item

class SpiderDoubanMogoDBPipeline(object):
    def open_spider(self, spider):
        # 连接数据库
        self.client = MongoClient()
        # 选择mvinfo库
        self.db = self.client.mvinfo

    def close_spider(self, spider):
        self.client.close()

    def process_item(self, item, spider):
        # 集合
        col = self.db.mDoubanInfo
        # 插入集合
        min = InsertOne(dict(item))
        col.bulk_write([min])
        return item