# API取得，ハッシュ出力
# ある会社のテストで出た問題の回答コード
require 'net/http'
require 'json'
def gets_api(argv)

  uri = URI.parse("http://challenge-server.code-check.io/api/hash?q=#{argv}")

  json = Net::HTTP.get(uri)
  result = JSON.parse(json)
  puts result['hash']
end

gets_api(gets)
