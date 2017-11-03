//
//  DonwloadedFile.swift
//  StickerGetPackageDescription
//
//  Created by Aleksei Gordeev on 03/11/2017.
//

import Foundation

public struct DownloadedFile {
    public let name: String
    public let data: Data
    
    public init(name: String, data: Data) {
        self.name = name
        self.data = data
    }
    
    public init?(url: URL) {
        let request = URLRequest.init(url: url)
        if let result = try? URLSession.shared.synchronousDataTask(request: request), let data = result.data {
            let name = url.lastPathComponent.isEmpty ? UUID.init().uuidString : url.lastPathComponent
            self = DownloadedFile.init(name: name, data: data)
        }
        else {
            return nil
        }
    }
}
