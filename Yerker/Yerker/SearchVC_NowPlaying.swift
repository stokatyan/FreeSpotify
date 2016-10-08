//
//  SearchVC_NowPlaying.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/27/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit
import AVFoundation

extension SearchVC {
    
    /* Observe current songs current track time and when it finishes playing
     * Update progress bar for current song
     * Handle loading UI
     * */
    fileprivate func addObservers() {
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: nil) { (cmTime) in
            self.currentTrackTime_LO.text = cmTime.seconds.getMinutesAndSeconds()
            if let totalTime = self.player.currentItem?.asset.duration.seconds {
                let progress = (cmTime.seconds / totalTime)
                self.trackProgress_PV.setProgress(Float(progress), animated: true)
                if (cmTime.seconds > 0) {
                    self.isSongLoaded_AI.isHidden = true
                    self.isSongLoaded_AI.stopAnimating()
                }
            }
            self.currentTrackTime = cmTime.seconds
            self.totalTrackTime_LO.text = self.player.currentItem?.asset.duration.seconds.getMinutesAndSeconds()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying),
                                                         name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                         object: player.currentItem)        
    }
    func playerDidFinishPlaying() {
        print("did Finish Playing")
        self.playNext()
    }
    
    /* Get album art on another queue if it exists */
    fileprivate func getAlbumArt(_ song: Song) {
        var artwork: UIImage?
        self.npAlbumArt_IV.image = UIImage(named: ImageKeys.artworkIcon)
        DispatchQueue.global(qos: .background).async {
            let playerItem = AVPlayerItem(url: song.getBestURL())
            let metadataList = playerItem.asset.metadata
            for item in metadataList {
                guard let key = item.commonKey, let value = item.value else{
                    continue
                }
                switch key {
                case "artwork" where value is NSData :
                    let imageData = (value as! NSData) as Data
                    if let image = UIImage(data: imageData)  {
                        artwork = image
                    }
                default:
                    continue
                }
            }
            DispatchQueue.main.async {
                if (artwork != nil) {
                    self.npAlbumArt_IV.image = artwork
                }
            }
        }

    }
    
    /* Plays song 
     * Updates UI and recently played History 
     * Adds observers */
    func playSong(_ song: Song, updateHistory: Bool = true) {
        if (updateHistory) {
            History._recentlyPlayed.add(songSelected)
        }
        setNowPlaying(song)
        player.removeTimeObserver(timeObserver)
        resetNowPlayingUI()
        
        DispatchQueue.global(qos: .background).async {
            self.player = AVPlayer(url: song.getBestURL())
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            self.player.playImmediately(atRate: 1)
            self.addObservers()
            
            DispatchQueue.main.async {

            }
        }
    }
    
    /* Gets next song (either random or serial) from current set of Songs 
     * Add previous song to recently played */
    func playNext() {
        let songs = MyMusic._instance.getMySongs()
        if (songs.count > 1) {
            let randomIndex = Int(arc4random_uniform(UInt32(songs.count)))
            let nextSong = songs[randomIndex]
            if (Song.isEqual(song1: nextSong, song2: songSelected)) {
                let newIndex = (randomIndex + 1) % songs.count
                playSong(songs[newIndex])
            } else {
                playSong(nextSong)
            }
        } else {
            playSong(songSelected)
        }
    }
    
    /* Pop song from recents and play it */
    func playRecent() {
        if let song = History._recentlyPlayed.getFromRecents() {
            playSong(song, updateHistory: false)
        } else {
            playSong(songSelected, updateHistory: false)
        }
    }
    
    fileprivate func resetNowPlayingUI() {
        self.trackProgress_PV.setProgress(0, animated: true)
        self.totalTrackTime_LO.text = "0:00"
        self.currentTrackTime_LO.text = "0:00"
        if (!songSelected.isLocal()) {
            self.isSongLoaded_AI.isHidden = false
            self.isSongLoaded_AI.startAnimating()
        }
    }
    
    fileprivate func setNowPlaying(_ song: Song) {
        songSelected = song
        
        nowPlayingTitle_LO.text = song.title
        nowPlayingArtist_LO.text = song.artist
        npPausePlay_BO.setImage(UIImage(named: ImageKeys.pauseButton), for: .normal)
        
        getAlbumArt(song)
    }

}
