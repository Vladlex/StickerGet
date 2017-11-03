import Foundation
import TelegramBotSDK
import SwiftyJSON

public struct JsonAsIs: JsonConvertible {
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
    }
}

let token = readToken(from: "Token")
let bot = TelegramBot(token: token)

extension TelegramBot {
    public func getStickerSet(name: String) -> JsonAsIs {
        return self.requestSync("getStickerSet", ["name":name])!
    }
}

while let update = bot.nextUpdateSync() {
    if let message = update.message, let from = message.from, let text = message.text {
        let stickerSetName = text
        let json: JsonAsIs = bot.getStickerSet(name: "Animalssd")
        bot.sendMessageAsync(chat_id: from.id,
                             text: "Hi \(from.first_name)! You said: \(text).\n")
    }
}

let errorDescription = bot.lastError?.debugDescription ?? "Unknown"

fatalError("Server stopped due to error: \(errorDescription)")
