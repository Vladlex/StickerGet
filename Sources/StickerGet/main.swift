import Foundation
import TelegramBotSDK
import SwiftyJSON
import AppKit

let token = readToken(from: "Token")
let bot = TelegramBot(token: token)

extension TelegramBot {
    public func getStickerSet(name: String) -> StickerSet? {
        return self.requestSync("getStickerSet", ["name":name])
    }
}

extension Array {
    
    var firstAsArray: [Element] {
        if let first = self.first {
            return [first]
        }
        return []
    }
    
}

while let update = bot.nextUpdateSync() {
    if let message = update.message, let from = message.from, let text = message.text {
        let parts = text.components(separatedBy: .whitespacesAndNewlines)
        guard parts.count > 0 else {
            continue
        }
        
        var shouldAddEmojiToName = false
        if parts.count > 1 {
            let args = parts[1..<parts.count]
            if args.contains("-emoji") {
                shouldAddEmojiToName = true
            }
        }
        
        let stickerSetName = parts.first!
        if let set = bot.getStickerSet(name: stickerSetName) {
            
            let downloadedFiles: [DownloadedFile] = set.sources.flatMap({ (source) in
                return bot.downloadSticker(source, token: token, prefixesNameByEmoji: true)
            })
            
            let zipper = Zipper.init()
            guard let data = zipper.zip(files: downloadedFiles, name: stickerSetName) else {
                bot.sendMessageAsync(chat_id: from.id,
                                     text: "Fail to zip files")
                continue
            }
            let fileInfo = InputFile.init(filename: stickerSetName.appending(".zip"),
                                          data: data,
                                          mimeType: kUTTypeZipArchive as String)
            bot.sendDocumentAsync(chat_id: from.id, document: fileInfo)
        }
        else {
            bot.sendMessageAsync(chat_id: from.id,
                                 text: "Could not found sticker set named \(stickerSetName)")
        }
    }
}

let errorDescription = bot.lastError?.debugDescription ?? "Unknown"

fatalError("Server stopped due to error: \(errorDescription)")
