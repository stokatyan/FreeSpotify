//
//  Song.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/18/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import Foundation

class Song: NSObject, NSCoding {
    
    static let blank = Song("", "", "")
    
    //  MARK: Properties
    
    let artist: String
    let title: String
    let url: URL
    var downloadStatus: Float = 0
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("songs")
    static let ArchivePendingDownloadsURL = DocumentsDirectory.appendingPathComponent("pendingDownloads")
    
    //  MARK: Persistent Memory
    
    init(_ artist: String, _ title: String, _ url: String) {
        self.artist = artist
        self.title = title
        if let u: URL = URL(string: url) {
            self.url = u
        } else {
            self.url = URL(string: "http://yerker.freetzi.com/")!
        }
        
        super.init()
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let artist = aDecoder.decodeObject(forKey: SongKeys.artist) as! String
        let title = aDecoder.decodeObject(forKey: SongKeys.title) as! String
        let url = aDecoder.decodeObject(forKey: SongKeys.url) as! String

        self.init(artist, title, url)
    }
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.artist, forKey: SongKeys.artist)
        aCoder.encode(self.title, forKey: SongKeys.title)
        aCoder.encode(self.url.absoluteString, forKey: SongKeys.url)
    }
    
    //  MARK:
    
    func printDetails() {
        print("Artist: \(artist)")
        print("Title: \(title)")
        print("URL: \(url)")
    }
    
    static func isEqual(song1: Song, song2: Song) -> Bool {
        if (song1.getLocalURL() == song2.getLocalURL()) {
            return true
        }
        return false
    }
    
    func getLocalFileName() -> String {
        var localFileName = artist + "_" + title + ".mp3"
        localFileName = localFileName.replacingOccurrences(of: " ", with: "_")
        return localFileName
    }
    
    func getLocalURL() -> URL {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        let localURL = URL(fileURLWithPath: "\(docsDir)/\(getLocalFileName())")
        return localURL
    }
    
    //  Return local url if it exist in memory, else stream the song from remote url
    func getBestURL() -> URL {
        if (isLocal()) {
            return getLocalURL()
        } else {
            return self.url
        }
    }
    
    func isLocal() -> Bool  {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true)
        let docsDir = dirPaths[0] as String
        let localURL: URL? = URL(string: "\(docsDir)/\(getLocalFileName())")
        guard let localURL_string = (localURL?.absoluteString)
            else {
                return false
        }
        if (FileManager.default.fileExists(atPath: localURL_string)) {
            return true
        }
        return false
    }
 
}




