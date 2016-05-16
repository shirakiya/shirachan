# Description:
#   ITmediaから「人工知能」のニュースを取得する
#
# Commands:
#   @shirachan news  - ITmedia上の「人工知能」のニュースを取得・表示します
#
# Notes:
#   made for 

moment = require 'moment'
client = require 'cheerio-httpcli'

module.exports = (robot) ->
  key = 'news'

  robot.respond /(news|ニュース)/i, (msg) ->
    url = 'http://www.itmedia.co.jp/keywords/ai.html'
    firstArticleFlag = true
    firstLink = null

    client.fetch(url, {})
    .then (result) ->
      $ = result.$
      $('.newsart').each ->
        # リンクの取得
        link = $(this).find('a').attr('href')
        # 重複チェック(重複であればbreak)
        return false if _checkDuplicate(robot, link)

        # 記事があった場合の最初の特殊処理
        if firstArticleFlag
          nowDatetime = moment().format("M月D日HH時mm分")
          msg.send "#{nowDatetime}時点の「人工知能」のニュース更新分だよ！\n"
          firstLink = link
          firstArticleFlag = false
        msg.send link

      _saveLink(robot, firstLink) if firstLink
    .catch (err) ->
      msg.send "エラーになっちゃいました...\n#{err}\n"

  _checkDuplicate = (robot, link) ->
    savedLink = robot.brain.get(key)
    return if link is savedLink then true else false

  _saveLink = (robot, link) ->
    robot.brain.set(key, link)
    robot.brain.save()
