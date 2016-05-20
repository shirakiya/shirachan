# Description:
#   Pingを打つとPongを返します
#
# Commands:
#   @shirachan ping - ping & pong

module.exports = (robot) ->

  robot.respond /PING$/i, (msg) ->
    msg.send "いちいちうるさいねん!!!! あ？Ping？ かぁぁーめんどくさ...はいはいPong、Pong。これでええんやろ？"
