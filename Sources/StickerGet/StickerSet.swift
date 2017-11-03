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
            return StickerSource.init(fileId: fileId, size: size)
        })
        
    }
    
    public let sources: [StickerSource]
    
    public struct StickerSource {
        
        public var fileId: String
        
        public var size: Int64
        
        public init(fileId: String, size: Int64) {
            self.fileId = fileId
            self.size = size
        }
        
    }
    
}

public extension File {
    
    func url(token: String) -> URL {
        return URL.init(string: "https://api.telegram.org/file/bot\(token)/\(self.file_path!)")!
    }
}

