//
//  Song_TVCell.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/18/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import UIKit

class Song_TVCell: UITableViewCell {

    @IBOutlet weak var playButton: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var downloadStatus_PV: UIProgressView!
    @IBOutlet weak var storedLocal_IV: UIImageView!
    
    static func setSelection(_ cell: Song_TVCell, isSelected: Bool) {
        if (isSelected) {
            cell.contentView.backgroundColor = Color.selectedTVC
        } else {
            cell.contentView.backgroundColor = Color.defaultTVC
        }
    }
    
    static func setDownloadState(_ cell: Song_TVCell, songs: [Song], index: Int) {
        if (index < songs.count) {
            if (MyMusic._instance.exists(songs[index])) {
                cell.addButton.setImage(UIImage(named: ImageKeys.removeButton), for: .normal)
            } else {
                cell.addButton.setImage(UIImage(named: ImageKeys.addButton), for: .normal)
            }
            
            if (!MyMusic._instance.exists(songs[index], isPendingDownload: true)) {
                cell.downloadStatus_PV.isHidden = true
            } else {
                cell.downloadStatus_PV.isHidden = false
                cell.downloadStatus_PV.progress = songs[index].downloadStatus
            }
            
            if (songs[index].isLocal()) {
                cell.downloadStatus_PV.isHidden = true
                cell.storedLocal_IV.isHidden = false
            } else {
                cell.storedLocal_IV.isHidden = true
            }
            
        }
    }
    
}
