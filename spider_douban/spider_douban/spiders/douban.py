# -*- coding: utf-8 -*-
import scrapy
from scrapy import Request
import re
from ..items import SpiderDoubanItem
from scrapy.loader import ItemLoader


class DoubanSpider(scrapy.Spider):
    name = 'douban'
    # allowed_domains = ['https://movie.douban.com/top250/']
    start_urls = ['https://movie.douban.com/top250//']

    def parse(self, response):
        lista = response.xpath('//div[@class="hd"]/a')
        baseurl = 'https://movie.douban.com/top250'
        for a in lista:
            href = a.xpath('@href').extract()[0]
            mvname = a.xpath('span[1]/text()').extract()[0]
            dinfo = {'mvname': mvname}
            yield Request(href, meta=dinfo, callback=self.details_parse)

        nexturl = response.xpath('//link[@rel="next"]/@href').extract()
        if nexturl:
            nexturl = nexturl[0]
            req_url = baseurl + nexturl
            yield  Request(req_url, callback=self.parse)

    def getInfoByRe(self, instr, restr):

        m = re.search(restr, instr, re.S)

        if m:
            info = m.groups()[0]
        else:
            info = ""

        return info

    """ 使用reponse.xpath方法过滤 """
    def details_sparse(self, response):
        item = SpiderDoubanItem()

        directors = response.xpath('//a[@rel="v:directedBy"]/text()').extract()
        item['mDirectors'] = ''.join(directors)

        starrinngs =  response.xpath('//a[@rel="v:starring"]/text()').extract()
        item['mStarrings'] = starrinngs

        types = response.xpath('//span[@property="v:genre"]/text()').extract()
        item['mTypes'] = types

        # 正则表达式的使用
        showplace = self.getInfoByRe(response.text, r'制片国家/地区:</span>(.+?)<br/>')
        item['mPlace'] = showplace
        lang = self.getInfoByRe(response.text, r'语言:</span>(.+?)<br/>')
        item['mLang'] = lang
        alia = self.getInfoByRe(response.text, r'又名:</span>(.+?)<br/>')
        item['mAlias'] = alia

        showtime = response.xpath('//span[@property="v:initialReleaseDate"]/text()').extract()
        item['mShowtimes'] = showtime

        runtime = response.xpath('//span[@property="v:runtime"]/text()').extract()
        item['mRuntime'] = runtime

        return item

    """ 使用itemloader方法简化代码复杂度 """
    def details_parse(self, response):

        dinfo = response.meta
        print(dinfo['mvname'])
        iteml = ItemLoader(item=SpiderDoubanItem(), response=response)

        # 使用add_xpath 方法替代response.xpath方法
        iteml.add_value('mMvName', dinfo['mvname'])
        iteml.add_xpath('mDirectors', '//a[@rel="v:directedBy"]/text()')
        iteml.add_xpath('mStarrings', '//a[@rel="v:starring"]/text()')
        iteml.add_xpath('mTypes', '//span[@property="v:genre"]/text()')
        iteml.add_xpath('mShowtimes', '//span[@property="v:initialReleaseDate"]/text()')
        iteml.add_xpath('mRuntime', '//span[@property="v:runtime"]/text()')

        # 正则部分使用add_value方法
        showplace = self.getInfoByRe(response.text, r'制片国家/地区:</span>(.+?)<br/>')
        iteml.add_value('mPlace', showplace)
        lang = self.getInfoByRe(response.text, r'语言:</span>(.+?)<br/>')
        iteml.add_value('mLang', lang)
        alias = self.getInfoByRe(response.text, r'又名:</span>(.+?)<br/>')
        iteml.add_value('mAlias', alias)
        iteml.add_xpath('mScore', '//strong[@property="v:average"]/text()')
        iteml.add_xpath('mVotes', '//span[@property="v:votes"]/text()')

        return iteml.load_item()