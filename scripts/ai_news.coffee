# Description:
#   Yahoo!ニュースから「人工知能」のニュースを取得する
#
# Commands:
#   @shirachan news  - ITmedia上の「人工知能」のニュースを取得・表示します
#
# Notes:
#   test script

moment = require 'moment'
client = require 'cheerio-httpcli'

module.exports = (robot) ->
  key = 'news'

  robot.respond /(news|ニュース)/i, (msg) ->
    url = 'http://news.yahoo.co.jp/theme/0ffb04fc3583c8c77347/'
    firstArticleFlag = true
    firstLink = null

    client.fetch(url, {})
    .then (result) ->
      $ = result.$
      $('.detailFeed').find('li').each ->
        # リンクの取得
        link = $(this).find('a').attr('href')
        # "/thema/..."から始まる記事でないリンクであればcontinue
        return true unless /^http/.test(link)
        # 重複チェック(重複であればbreak)
        return false if _checkDuplicate(robot, redisKey, link)

        # 記事があった場合の最初の特殊処理
        if firstArticleFlag
          nowDatetime = _getNowDatetime()
          msg.send "#{nowDatetime}時点の「人工知能」のYahoo!ニュース更新分だよ！"
          firstLink = link
          firstArticleFlag = false
        msg.send link

      if firstLink
        _saveLink(robot, redisKey, firstLink)
      else
        nowDatetime = _getNowDatetime()
        msg.send "#{nowDatetime}時点の「人工知能」のYahoo!ニュース更新分はなかったよ！"

      _saveLink(robot, redisKey, firstLink) if firstLink

    .catch (err) ->
      msg.send "エラーになっちゃいました...\n#{err}\n"

  _checkDuplicate = (robot, link) ->
    savedLink = robot.brain.get(key)
    return if link is savedLink then true else false

  _getNowDatetime = ->
    return moment().format("M月D日HH時mm分")

  _saveLink = (robot, key, link) ->
    robot.brain.set(key, link)
    robot.brain.save()
