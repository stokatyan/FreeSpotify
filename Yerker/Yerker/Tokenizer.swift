//
//  Tokenizer.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/18/16.
//  Copyright © 2016 com.example. All rights reserved.
//

import Foundation

class Tokenizer {
    
    static let _instance = Tokenizer()
    
    fileprivate let kAccesToken = "access_token="
    fileprivate let kDelimeter = "&"
    
    fileprivate let jResponse = "response"
    fileprivate let jTitle = "title"
    fileprivate let jArtist = "artist"
    fileprivate let jURL = "url"
    fileprivate let jError = "error"
    
    func getAccessToken(urlString: String) -> String {
        let parsedURL : [String] = urlString.components(separatedBy: kAccesToken)
        var startOfAccessToken = ""
        if parsedURL.count < 2 {
            print("ERROR: Returned data is nil")
            return startOfAccessToken
        }
        startOfAccessToken = parsedURL[1]
        let accessToken = startOfAccessToken.components(separatedBy: kDelimeter)
        
        return (accessToken.first!)
    }
    
    func isResponseValid(response: JSON) -> Bool {
        guard let _: NSArray = response[jResponse] as? NSArray
            else {
                return false
        }
        return true
    }
    
    func getSongsFromResponse(response: JSON) -> [Song] {
        let searchResult = Tokenizer._instance.getResponse(json: response)
        var songs = [Song]()
        for res in searchResult {
            if let song = Tokenizer._instance.getSong(json: res) {
                songs.append(song)
            }
        }
        return songs
    }
    
}

/* Private Functions */
extension Tokenizer {
    fileprivate func getResponse(json: JSON) -> [JSON] {
        guard let response: NSArray = json[jResponse] as? NSArray
            else {
                print("FAILED")
                return [json]
        }
        var responseArray = [JSON]()
        for r in response {
            if let j = r as? JSON {
                responseArray.append(j)
            }
        }
        return responseArray
    }
    
    fileprivate func getSong(json: JSON) -> Song? {
        guard let artist = Tokenizer._instance.getArtist(json: json) else {
            return nil
        }
        guard let title = Tokenizer._instance.getTitle(json: json) else {
            return nil
        }
        guard let url = Tokenizer._instance.getURL(json: json) else {
            return nil
        }
        return Song(artist, title, url)
    }
    
    fileprivate func getArtist(json: JSON) -> String? {
        guard let artist = json[jArtist] as? String else {
            return nil
        }
        return artist
    }
    fileprivate func getTitle(json: JSON) -> String? {
        guard let title = json[jTitle] as? String else {
            return nil
        }
        return title
    }
    
    fileprivate func getURL(json: JSON) -> String? {
        guard let url = json[jURL] as? String else {
            return nil
        }
        return url
    }
}
