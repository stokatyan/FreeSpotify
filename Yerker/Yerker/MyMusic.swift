//
//  MyMusic.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/19/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import Foundation
import UIKit

class MyMusic {
    static let _instance = MyMusic()
    
    fileprivate var m_songs = [Song]()
    fileprivate var m_pendingDownloads = [Song]()   // Queue of songs to be downloaded
    fileprivate var isDownloading = false
    
    fileprivate var downloadWorks = 0
    fileprivate var downloadThreshold = 5
    
    //  Adds song making sure there are no duplicates
    func addSong(_ song: Song) {
        if (!exists(song)) {
            m_songs.append(song)
        }
        if (!exists(song, isPendingDownload: true)) {
            m_pendingDownloads.append(song)
        }
    }
    
    //  Removes song iff song exists
    func removeSong(_ song: Song, isPendingDownload: Bool = false) {
        if (!isPendingDownload) {
            deleteSong(localUrl: song.getLocalURL())
            if let index = getIndex(song) {
                if (index < m_songs.count) {
                    m_songs.remove(at: index)
                }
            }
        } else {
            if let index = getIndex(song, isPendingDownload: true) {
                m_pendingDownloads.remove(at: index)
            }
        }
    }
    
    func printSongs() {
        for s in m_songs {
            s.printDetails()
        }
    }
    func getMySongs() -> [Song] {
        return m_songs
    }
    func getMyPendingDownloads() -> [Song] {
        return m_pendingDownloads
    }
    
    //  Returns true iff song exists
    func exists(_ song: Song, isPendingDownload: Bool = false) -> Bool {
        if (!isPendingDownload) {
            for s in m_songs {
                if (Song.isEqual(song1: s, song2: song)) {
                    return true
                }
            }
            return false
        }
        for s in m_pendingDownloads {
            if (Song.isEqual(song1: s, song2: song)) {
                return true
            }
        }
        return false
    }
    
    //  Returns the index of a given song index >= msongs.count if not in m_songs
    func getIndex(_ song: Song, isPendingDownload: Bool = false) -> Int? {
        var index = 0
        if (!isPendingDownload) {
            for s in m_songs {
                if (Song.isEqual(song1: s, song2: song)) {
                    return index
                }
                index += 1
            }
            return nil
        } else {
            for s in m_pendingDownloads {
                if (Song.isEqual(song1: s, song2: song)) {
                    return index
                }
                index += 1
            }
            return nil
        }
    }
    
    func incrementDownloadWorks() {
        downloadWorks += 1
    }
    func resetDownloadWorks() {
        downloadWorks = 0
    }
    func didDownloadWork() -> Bool {
        return (downloadWorks > downloadThreshold)
    }
    func setIsDownloading(_ isDownloading: Bool) {
        self.isDownloading = isDownloading
    }
    
}

//  Persistent Memory
extension MyMusic {
    
    func loadSongs()  {
        if let my_music = NSKeyedUnarchiver.unarchiveObject(withFile: Song.ArchiveURL.path) as? [Song] {
            m_songs = my_music
        } else {
            print("No Music Saved")
        }
        if let my_pendingDownloads = NSKeyedUnarchiver.unarchiveObject(withFile: Song.ArchivePendingDownloadsURL.path) as? [Song] {
            m_pendingDownloads = my_pendingDownloads
        }
    }
    
    func saveSongs() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(m_songs, toFile: Song.ArchiveURL.path)
        NSKeyedArchiver.archiveRootObject(m_pendingDownloads, toFile: Song.ArchivePendingDownloadsURL.path)
        if !isSuccessfulSave {
            print("Failed to save MyMusic state")
        }
    }
    
    func setSongsForDownload() {
        for song in m_songs {
            if (!song.isLocal()) {
                m_pendingDownloads.append(song)
            }
        }
    }
    
}

//  Local mp3 files
extension MyMusic {
    func download(url: URL, to localUrl: URL, delegate: SearchVC) {
        self.resetDownloadWorks()
        self.isDownloading = true
        delegate.session = URLSession(configuration: delegate.sessionConfig, delegate: delegate, delegateQueue: nil)
        let request = URLRequest(url: url)

        let task = delegate.session.downloadTask(with: request)
        task.resume()
    }
    
    // If a valid .mp3 was downloaded then coninue as usual.
    // If not then dont save the .mp3 and try to download the next song.
    //  Invalid downloads are moved to the end of the download queue.
    func downloadComplete(at location: URL) {
        if (didDownloadWork()) {
            let song = getMyPendingDownloads().first!
            do {
                try FileManager.default.moveItem(at: location, to: song.getLocalURL())
            } catch {
                print("error writing file")
            }
        } else {
            print("Failed to download!")
        }
        popFromPendingDownloads()
    }
    
    func downloadNext(delegate: SearchVC) {
        if (getMyPendingDownloads().count > 0
            && !self.isDownloading) {
            let song = getMyPendingDownloads().first!
            download(url: song.url, to: song.getLocalURL(), delegate: delegate)
        }
    }
    
    func deleteSong(localUrl: URL) -> Bool {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: localUrl)
        }
        catch _ as NSError {
            return false
        }
        return true
    }
    
    func isSongDownloading(_ song: Song) -> Bool {
        if (isDownloading && m_pendingDownloads.count > 0) {
            if (Song.isEqual(song1: song, song2: m_pendingDownloads.first!)) {
                return true
            }
        }
        return false
    }
    
    func popFromPendingDownloads() {
        self.isDownloading = false
        if (m_pendingDownloads.count > 0) {
            m_pendingDownloads.removeFirst()
        }
    }
    
    func setDownloadStatus(loadedAmount: Float) {
        if (getMyPendingDownloads().count > 0) {
            let song = getMyPendingDownloads().first!
            if let index = getIndex(song)  {
                m_songs[index].downloadStatus = loadedAmount
            }
        }
    }
    
}







