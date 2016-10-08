//
//  VK_API.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/17/16.
//  Copyright © 2016 com.example. All rights reserved.
//


import Foundation
import UIKit

class VK_API {
    
    static let _instance = VK_API()
    // Persisten Memory
    let defaults = UserDefaults.standard
    
    // Keys, tokens etc
    fileprivate let kClient_ID = "5633098"
    fileprivate let kFullOAuth = "https://oauth.vk.com/authorize?client_id=5633098&scope=offline,audio,wall&redirect_uri=http://yerker.freetzi.com&response_type=token"
    fileprivate let accessToken_KEY = "accessToken"
    fileprivate var kAccessToken = ""
    
    // Standard redirect_uri
    //https://oauth.vk.com/blank.html
    
    // Access token is returned in a url from the redirect_uri.
    // The url with the access token is retrieved in the App Delegate 
    //  when the app is reopened from the browser.
    func requestAccess() {
        let authURL: URL = URL(string: kFullOAuth)!
        UIApplication.shared.open(authURL, options: [:], completionHandler: nil)
    }
    
    func setAccesToken(_ accessToken: String, vc: UIViewController, callback: @escaping () -> ()) {
        self.kAccessToken = accessToken
        saveAccessToken()
        if (!isAccessGranted()) {
            let alertController = UIAlertController(title: "Failed to Login", message: "Access Not Granted", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in }
            alertController.addAction(OKAction)
            vc.present(alertController, animated: true) {
            }
        }
        callback()
    }
    
    // Check if kAccessToken in persistent memory is valid
    func isTokenValid(callback: @escaping (Bool) -> ()) {
        let audioSearch = "https://api.vk.com/method/audio.search?access_token=\(kAccessToken)"
        let request: URL = URL(string: audioSearch)!
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (returnData, response, error) -> Void in
            do {
                guard let data = returnData else {
                    print("ERROR: Returned data is nil")
                    return
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? JSON else {
                    print("ERROR: JSON is nil")
                    return
                }
                callback(Tokenizer._instance.isResponseValid(response: json))
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }).resume()
    }
    
    
    func searchAudios(searchFor: String, callback: @escaping (JSON) -> ()) {
        let searchParams = searchFor.components(separatedBy: " ")
        let param = searchParams.joined(separator: "+")
        var audioSearch = "https://api.vk.com/method/audio.search?access_token=\(kAccessToken)"
        
        if let russianParamsTOO = param.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            audioSearch = "\(audioSearch)&q=\(russianParamsTOO)"
        } else {
            audioSearch = "\(audioSearch)&q=\(param)"
        }
        
        let request: URL = URL(string: audioSearch)!
        let session = URLSession.shared
        session.dataTask(with: request, completionHandler: { (returnData, response, error) -> Void in
            do {
                guard let data = returnData else {
                    print("ERROR: Returned data is nil")
                    return
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? JSON else {
                    print("ERROR: JSON is nil")
                    return
                }
                callback(json)                
            } catch let error as NSError {
                print(error.debugDescription)
            }
        }).resume()
    }
    
}

// Persist Memory
extension VK_API {
    func saveAccessToken() {
        defaults.set(kAccessToken, forKey: accessToken_KEY)
    }
    
    func loadAccessToken() -> Bool {
        if let accessToken = defaults.string(forKey: accessToken_KEY) {
            kAccessToken = accessToken
            return true
        } else {
            kAccessToken = ""
            print("no token")
            return false
        }
    }
    
    func clearAccessToken() {
        kAccessToken = ""
    }
}

// Private Functions
extension VK_API {
    fileprivate func isAccessGranted() -> Bool {
        if (kAccessToken != "") {
            return true
        }
        return false
    }
}


