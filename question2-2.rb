# ある会社のテストを受けたもの。20/1/5に記述
require 'mechanize'

agent = Mechanize.new # Mechanizeの初期化
page = agent.get("https://sarah30.com/%E3%82%AB%E3%83%AC%E3%83%BC?city=657") # リンク先からHTML情報を取得
genre = page.links.find { |l| l.href == "/#{l.text}"}.text # リンク一覧からジャンルを取得

# リンク一覧から都道府県を取得
prefecture = page.links.find { |l| /.+\?state=\d+$/.match(l.href) && !l.text.include?(genre)}.text

# リンク一覧から市区町村を取得
city = page.links.find { |l| /.+\?city=\d+$/.match(l.href) && !l.text.include?(genre)}.text

puts page.title # タイトルの表示
puts genre # ジャンルの表示
puts prefecture # 都道府県の表示
puts city # 市区町村の表示
