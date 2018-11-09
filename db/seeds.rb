user_1 = User.create(email: "test@example.com", password: "qazwsxedc")

message_1 = Message.create(content: 'Message content 1', user: user_1)
message_2 = Message.create(content: 'Message content 2', user: user_1)
message_3 = Message.create(content: 'Message content 3', user: user_1)
message_4 = Message.create(content: 'Message content 4', user: user_1)
message_5 = Message.create(content: 'Message content 5', user: user_1)

Comment.create(content: 'Cool comment 1', author: 'Jane One', message: message_1)
Comment.create(content: 'Cool comment 2', author: 'Jane Two', message: message_2)
Comment.create(content: 'Cool comment 3', author: 'Jane Three', message: message_3)
Comment.create(content: 'Cool comment 4', author: 'Jane Four', message: message_4)
Comment.create(content: 'Cool comment 5', author: 'Jane Five', message: message_5)
