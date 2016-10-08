//
//  SearchVC_Delegates.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/18/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return getSongsInScope().count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Song_TVCell", for: indexPath) as! Song_TVCell
        let _songs = getSongsInScope()
        let _song = _songs[indexPath.row]
        cell.title?.text = _song.title
        cell.artist?.text = _song.artist
        
        cell.addButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(addOrRemoveSong), for: .touchUpInside)
        
        let selected = Song.isEqual(song1: _song, song2: songSelected)
        Song_TVCell.setSelection(cell, isSelected: selected)
        Song_TVCell.setDownloadState(cell, songs: _songs, index: indexPath.row)
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        History._recentlyPlayed.clearAll()
        let song = getSongsInScope()[indexPath.row]
        playSong(song)
        let cell = tableView.cellForRow(at: indexPath) as? Song_TVCell
        Song_TVCell.setSelection(cell!, isSelected: true)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? Song_TVCell {
            Song_TVCell.setSelection(cell, isSelected: false)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
}

extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        search()
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentCharacterCount = textField.text?.characters.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.characters.count - range.length
        return newLength < 35
    }
}

extension SearchVC: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag {
        case 0:
            displayLibrary()
        case 1:
            displaySearch()
        default:
            break
        }
    }
}

extension SearchVC: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        MyMusic._instance.downloadComplete(at: location)
        MyMusic._instance.saveSongs()
        session.invalidateAndCancel()
        MyMusic._instance.downloadNext(delegate: self)
        self.safeReloadTableView()        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64 ) {
        let loadedAmount: Float = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        MyMusic._instance.setDownloadStatus(loadedAmount: loadedAmount)
        MyMusic._instance.incrementDownloadWorks()
        self.safeReloadTableView()
    }

}


