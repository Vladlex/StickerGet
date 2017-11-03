//
//  Zipper.swift
//  StickerGetPackageDescription
//
//  Created by Aleksei Gordeev on 04/11/2017.
//

import Foundation
import PerfectZip

public class Zipper {
    
    public init() {
        
    }
    
    public func zip(files: [DownloadedFile]) -> Data? {
        let supportFolder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let taskId = UUID.init().uuidString
        let folder = supportFolder.appendingPathComponent(taskId, isDirectory: true)
        try! FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
        files.forEach { (file) in
            try! file.data.write(to: folder.appendingPathComponent(file.name, isDirectory: false))
        }
        defer {
            try! FileManager.default.removeItem(at: folder)
        }
        let zip = Zip.init()
        let zipUrl = supportFolder.appendingPathComponent(taskId, isDirectory: false).appendingPathExtension("zip")
        let status = zip.zipFiles(paths: [folder.path], zipFilePath: zipUrl.path, overwrite: true, password: nil)
        
        if status == .ZipSuccess {
            let data = try! Data.init(contentsOf: zipUrl)
            return data
        }
        return nil
    }
}
