//
//  HomeVC.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/18/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit
import AVFoundation

class SearchVC: UIViewController {
    
    var url: URL = URL(string: "google.com")!
    var player: AVPlayer!
    var songsFromSearch = [Song]()
    var songSelected = Song.blank
    var currentTrackTime: Double = 0
    var timeObserver: Any!
    var endObserver: Any!
    
    let sessionConfig = URLSessionConfiguration.default
    var session = URLSession()
    
    // Search, Tableview, and  Tab bar
    @IBOutlet weak var search_TextFieldOutlet: UITextField!
    @IBOutlet weak var searchResults_TV: UITableView!
    @IBOutlet weak var search_ButtonOutlet: VKButton!
    @IBOutlet weak var tabBar_Outlet: UITabBar!
    @IBOutlet weak var library_TabBarItem: UITabBarItem!
    @IBOutlet weak var search_TabBarItem: UITabBarItem!
    
    // Now playing bar UI
    @IBOutlet weak var nowPlayingTitle_LO: UILabel!
    @IBOutlet weak var nowPlayingArtist_LO: UILabel!
    @IBOutlet weak var npPausePlay_BO: UIButton!

    @IBOutlet weak var npAlbumArt_IV: UIImageView!
    @IBOutlet weak var trackProgress_PV: UIProgressView!
    @IBOutlet weak var currentTrackTime_LO: UILabel!
    @IBOutlet weak var totalTrackTime_LO: UILabel!
    @IBOutlet weak var isSongLoaded_AI: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
        MyMusic._instance.loadSongs()
        MyMusic._instance.setSongsForDownload()
        MyMusic._instance.downloadNext(delegate: self)
        npPausePlay_BO.tag = 0
        tabBar_Outlet.selectedItem = library_TabBarItem
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // catch changes to status
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(player.currentTime())
        
    }

    //  MARK: IBActions
    
    @IBAction func search_ButtonAction(_ sender: AnyObject) {
        dismissKeyboard()
        search()
    }
    
    @IBAction func npPausePlay_BA(_ sender: AnyObject) {
        if (npPausePlay_BO.tag == 0) {
            npPausePlay_BO.tag = 1
            player.pause()
            sender.setImage(UIImage(named: ImageKeys.playButton), for: .normal)
        } else {
            npPausePlay_BO.tag = 0
            player.play()
            sender.setImage(UIImage(named: ImageKeys.pauseButton), for: .normal)
        }
    }
    
    @IBAction func npNext_BA(_ sender: AnyObject) {
        playNext()
    }
    
    @IBAction func npReplay_BA(_ sender: AnyObject) {
        playRecent()
    }
    
    @IBAction func getNewToken_BA(_ sender: AnyObject) {
        VK_API._instance.requestAccess()
    }
    
}


