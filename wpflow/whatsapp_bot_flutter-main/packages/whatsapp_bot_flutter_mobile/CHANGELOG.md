## 2.1.1

- Bump whatsapp_bot_platform_interface

## 2.1.0

- Bump whatsapp_bot_platform_interface

## 2.0.4

- Bump whatsapp_bot_platform_interface

## 2.0.2

- fix downloadMedia

## 2.0.1

- add wpClient.conn
- add few group methods
- fix getChat,getMessages, getContacts
- minor fixes

## 2.0.0

- update to whatsapp_bot_platform_interface 1.0.0
- Breaking change: new way of listening to messages: client.on(WhatsappEvent.chat_new_message, (data) => print(data));
- add support for listening to multiple events
- fix delete message
- add option to send file name in sendFileMessage
- add more methods to WhatsappClient.chat

## 1.0.0

- use whatsapp_bot_platform_interface
- improved docs

## 0.0.1

- Initial version
