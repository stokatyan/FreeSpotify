//
//  SeachVC_Selectors.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/19/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit
import AVFoundation

//  Actions
extension SearchVC {
    
    func displayLibrary() {
        searchResults_TV.reloadData()
    }
    
    func displaySearch() {
        searchResults_TV.reloadData()
    }
    
    /* Called by addOrRemoveSong() & UITableviewDelegate
     * Get the songs that are currently being displayed */
    func getSongsInScope() -> [Song] {
        let selectedtItemTag = tabBar_Outlet.selectedItem!.tag
        switch selectedtItemTag {
        case 0:
            return MyMusic._instance.getMySongs()
        case 1:
            return songsFromSearch
        default:
            return songsFromSearch
        }
    }
    
    func safeReloadTableView() {
        let queue = DispatchQueue(label: "q1")
        queue.async {
            DispatchQueue.main.async {
                self.searchResults_TV.reloadData()
            }
        }
    }
    
    func search() {
        tabBar_Outlet.selectedItem = search_TabBarItem
        if (search_TextFieldOutlet.text != "") {
            if let search = search_TextFieldOutlet.text {
                VK_API._instance.searchAudios(searchFor: search, callback: { (json) in
                    let songs = Tokenizer._instance.getSongsFromResponse(response: json)
                    if (songs.count > 0) {
                        self.url = (songs.first?.url)!
                        self.songsFromSearch = songs
                        let queue = DispatchQueue(label: "q1")
                        queue.async {
                            DispatchQueue.main.async {
                                self.searchResults_TV.reloadData()
                            }
                        }
                    } else {
                        print("no songs found")
                    }
                })
            } else {
                print("search field is nil")
            }
        }
    }
    
}

//  Setup functions
extension SearchVC {
    
    func setupVC() {
        player = AVPlayer(url: url)
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: nil)
        { (cmTime) in}
        setupUI()
        tabBar_Outlet.selectedItem = tabBar_Outlet.items?.last
    }
    
    fileprivate func setupUI() {
        searchResults_TV.delegate = self
        searchResults_TV.dataSource = self
        search_TextFieldOutlet.delegate = self
        tabBar_Outlet.delegate = self
        isSongLoaded_AI.isHidden = true
        setupSearchResult_TV()
    }
    
    fileprivate func setupSearchResult_TV() {
        searchResults_TV.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        searchResults_TV.layer.cornerRadius = 3
        searchResults_TV.register(UINib(nibName: "Song_TVCell", bundle: nil), forCellReuseIdentifier: "Song_TVCell")
    }
}

//  Selectors
extension SearchVC {
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /* Called by button on Song_TVCell
     * Add songs localy
     * Removes song from local memory if it is already added */
    func addOrRemoveSong(_ sender: AnyObject) {
        if let button = sender as? UIButton {
            if let tag = sender.tag {
                let song = getSongsInScope()[tag]
                let exists = MyMusic._instance.exists(song)
                if (exists) {
                    removeSongHelper(song)
                    button.setImage(UIImage(named: ImageKeys.addButton), for: .normal)
                } else {
                    MyMusic._instance.addSong(song)
                    MyMusic._instance.downloadNext(delegate: self)
                    button.setImage(UIImage(named: ImageKeys.removeButton), for: .normal)
                }
            }
        }
        MyMusic._instance.saveSongs()
        searchResults_TV.reloadData()
    }
    
    /* Called by addOrRemoveSong(: )
     * Removes given song, and stops downloading song
     * Resets download session if song was being downloaded */
    fileprivate func removeSongHelper(_ song: Song) {
        let isDownloading = MyMusic._instance.isSongDownloading(song)
        if (!isDownloading) {
            MyMusic._instance.removeSong(song)
            MyMusic._instance.removeSong(song, isPendingDownload: true)
        } else {
            session.invalidateAndCancel()
            MyMusic._instance.setIsDownloading(false)
            MyMusic._instance.removeSong(song)
            MyMusic._instance.removeSong(song, isPendingDownload: true)
            MyMusic._instance.downloadNext(delegate: self)
        }
    }
}

