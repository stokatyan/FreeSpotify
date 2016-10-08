//
//  History.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/28/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import Foundation

class History {
    static let _recentlyPlayed = History()
    fileprivate var h_recents = [Song]()
    
    /* Add a song to history iff it is locally saved
     * Recent History can be most 20 songs */
    func add(_ song: Song) {
        if (song.isLocal()) {
            h_recents.append(song)
        }
        if (h_recents.count > 20) {
            h_recents.removeFirst()
        }
    }
    
    func clearAll() {
        h_recents.removeAll()
    }
    
    /* Get and (optionaly) remove song from history */
    func getFromRecents(_ shouldPop: Bool = true) -> Song? {
        if (isRecentsEmpty()) {
            return nil
        }
        if (shouldPop) {
            return h_recents.removeLast()
        } else {
            return h_recents.last
        }
    }
    
    
    fileprivate func isRecentsEmpty() -> Bool {
        if (h_recents.count == 0) {
            return true
        }
        return false
    }
    

}
