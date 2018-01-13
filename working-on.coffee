# Description:
#   Tell Hubot what you or someone else is working on so he can give out status updates when asked
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   i am working on <anything> - Set what you're working on
#   what is everyone working on? - Find out what everyone is working on
#   <slack-username> is working on <anything> - Set what someone else is working on

module.exports = (robot) ->

  robot.respond /(?:what\'s|what is|whats|what are) @?([\w .\-]+) working on(?:\?)?$/i, (msg) ->
    name = msg.match[1].trim()

    if name is "you"
      msg.send "I dunno, robot things I guess."
    else if name.toLowerCase() is robot.name.toLowerCase()
      msg.send "World domination!"
    else if name.match(/(everybody|everyone)/i)
      messageText = '';
      users = robot.brain.users()
      for k, u of users
          if u.workingon
              messageText += "#{u.name} is working on #{u.workingon}\n"
          else
              messageText += ""
      if messageText.trim() is "" then messageText = "Nobody told me a thing."
      msg.send messageText
    else
      users = robot.brain.usersForFuzzyName(name)
      if users.length is 1
        user = users[0]
        user.workingon = user.workingon or [ ]
        if user.workingon.length > 0
          msg.send "#{name} is working on #{user.workingon}."
        else
          msg.send "#{name} is slacking off."
      else if users.length > 1
        msg.send getAmbiguousUserText users
      else
        msg.send "#{name}? Who's that? I only understand usernames."

  robot.respond /(?:i\'m|i am|im) working on (.*)/i, (msg) ->
    name = msg.message.user.name
    user = robot.brain.userForName name

    if typeof user is 'object'
      user.workingon = msg.match[1]
      msg.send "Okay #{user.name}, got it."
    else if typeof user.length > 1
      msg.send "I found #{user.length} people named #{name}"
    else
      msg.send "I have never met #{name}"

  robot.respond /(.*) (?:is|are) working on (.*)/i, (msg) ->
    name = msg.match[1].trim()
    sender = msg.message.user.name.toLowerCase()

    if name is "you"
      msg.send "ok b0ss"
    else if name.toLowerCase() is robot.name.toLowerCase()
      msg.send "ok b0ss"
    else
      users = robot.brain.usersForFuzzyName(name)
      if users.length is 1
        user = users[0]
        user.workingon = msg.match[2].trim()
        msg.send "Okay #{sender}, got it."
      else if users.length > 1
        msg.send getAmbiguousUserText users
      else
        msg.send "#{name}? Who's that? I only understand usernames."
