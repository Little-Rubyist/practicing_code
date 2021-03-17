require 'open-uri'
require 'nokogiri'

doc = Nokogiri::HTML(open('https://gamewith.jp/atsumori/article/show/193061'))
doc.css('.atumori_kaguichiran table tr').each do |tr|
  tr.search('td').each do |td|
    td.search('a').each do |a|
      @link = a.attributes['href'].value #家具のリンク先
      @id = a.attributes['href'].value[%r{https://gamewith.jp/atsumori/article/show/(.*)}, 1]
    end
    td.search('a noscript img').each do |img|
      @name = td.text # 名前
      @img = img.attributes['src'].value # 画像取得
    end
    @sell_price = tr.search('td')[1]&.text # 売値
  end
end