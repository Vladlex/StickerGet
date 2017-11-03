//
//  StickerSet.swift
//  StickerGetPackageDescription
//
//  Created by Aleksei Gordeev on 03/11/2017.
//

import Foundation
import SwiftyJSON
import TelegramBotSDK

public struct StickerSet: JsonConvertible {
    
    public var json: JSON
    
    public init(json: JSON) {
        self.json = json
        let stickerInfos = json["stickers"].json.array!
        self.sources = stickerInfos.map({ (stickerInfo) in
            let fileId = stickerInfo["file_id"].string!
            let size = stickerInfo["file_size"].int64!
            let emoji = stickerInfo["emoji"].string
            return StickerSource.init(fileId: fileId, size: size, emoji: emoji)
        })
        
    }
    
    public let sources: [StickerSource]
    
    public struct StickerSource {
        
        public var fileId: String
        
        public var size: Int64
        
        public var emoji: String? = nil
        
        public init(fileId: String, size: Int64, emoji: String? = nil) {
            self.fileId = fileId
            self.size = size
            self.emoji = emoji
        }
        
    }
    
}

public extension TelegramBot {
    
    public func downloadSticker(_ source: StickerSet.StickerSource, token: String, prefixesNameByEmoji: Bool = true) -> DownloadedFile? {
        guard let file = bot.getFileSync(file_id: source.fileId) else {
            return nil
        }
        let url = file.url(token: token)
        if var downloadedFile = DownloadedFile.init(url: url) {
            if prefixesNameByEmoji, let emoji = source.emoji {
                downloadedFile.name = emoji.appending(" ").appending(downloadedFile.name)
            }
            return downloadedFile
        }
        return nil
    }
    
}

public extension File {
    
    func url(token: String) -> URL {
        return URL.init(string: "https://api.telegram.org/file/bot\(token)/\(self.file_path!)")!
    }
}

