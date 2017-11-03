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
        let stickerSetName = text
        if let set = bot.getStickerSet(name: stickerSetName) {
            let files: [File] = set.sources.firstAsArray.flatMap({ (source) in
                return bot.getFileSync(file_id: source.fileId)
            })
            let downloadedFiles: [DownloadedFile] = files.flatMap({ file in
                let url = file.url(token: token)
                return DownloadedFile.init(url: url)
            })
            let zipper = Zipper.init()
            guard let data = zipper.zip(files: downloadedFiles) else {
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
