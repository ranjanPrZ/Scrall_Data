require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require './crawl_model.rb'


class WbCrawler
  def self.crawled_response
    Nokogiri::HTML(URI.open('https://magento-test.finology.com.my/breathe-easy-tank.html'))
  end

  def self.create_db_table
    db = SQLite3::Database.open 'crawled_db.db'
    db.execute "CREATE TABLE IF NOT EXISTS Crawled_data(Id INTEGER PRIMARY KEY, Name TEXT, Price REAL, Description TEXT, Extra_information TEXT)"
    db.execute "CREATE TABLE IF NOT EXISTS Related_prod(Id INTEGER PRIMARY KEY, Name TEXT, Price REAL)"
    db.close
  end

  def self.extra_info_string(arrs)
    arrs.map{|arr|
      if arr.length >2
        key,*value = arr
        "#{key}:#{value.join('')}"
      else
        "#{arr.first}:#{arr.last}"
      end
    }.join(' |')
  end

  def self.crawl
    response = crawled_response
    name = response.css('div.page-title-wrapper.product').css('h1.page-title').css('span.base').text
    price = response.css('div.product-info-price').children()[0].children().css('span.price').text
    description = response.css('div.product.info.detailed').css('div.product.data.items').css('div#description.data.item.content').css('div.description').css('div.value').children().map(&:text).delete_if{|x| x=="\n"}.join('')
    extra_info = response.css('div#additional.data.item.content').css('table#product-attribute-specs-table.data.table.additional-attributes').css('tbody').css('tr').map(&:text).map{|arr| arr.split(' ')}

    CrawledModel.create('Crawled_data',name, price, description, extra_info_string(extra_info))
  end
  
  def self.related_product
    response = crawled_response
    response.css('div.block-content.content').css('div.products.wrapper.grid.products-grid.products-related').css('ol.product-items').children().map do |item|
      part = item.css('div.product-item-info').children().css('div.product-item-details').children()
      name = part.css('a.product-item-link').text()
      if name.length > 0
	price = part.css('span.normal-price').css('span.price-container').children().css('span.price').text()
	CrawledModel.create('Related_prod', name.strip, price)
      end
    end
  end

end #Class

#====== To create database and table =======
#p WbCrawler.create_db_table


#====== To crawl data and store it in Carwled data table =======
p WbCrawler.crawl

#====== To Crawl data and store it in related product table ========
p WbCrawler.related_product

