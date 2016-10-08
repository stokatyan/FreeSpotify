//
//  ViewController.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/17/16.
//  Copyright © 2016 com.example. All rights reserved.
//

/*  TOP SECRET... =]
 **/

import UIKit

typealias JSON = [String: AnyObject]

class ViewController: UIViewController {
    
    @IBOutlet weak var activityInd_outlet: UIActivityIndicatorView!
    @IBOutlet weak var loginStatus_labelOutlet: UILabel!
    @IBOutlet weak var login_buttonOutlet: VKButton!
    @IBOutlet weak var offline_buttonOutlet: VKButton!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        login_buttonOutlet.isHidden = true
        activityInd_outlet.startAnimating()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewDidAppear(_ animated: Bool) {
        if (VK_API._instance.loadAccessToken()) {
            VK_API._instance.isTokenValid(callback: { (isTokenValid) in
                if (isTokenValid) {
                    let queue = DispatchQueue(label: "q1")
                    queue.async {
                        DispatchQueue.main.async {
                            let home: SearchVC = self.storyboard!.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
                            self.present(home, animated: true, completion: nil)
                        }
                    }
                } else {
                    self.displayLoginButton()
                }
            })
        } else {
            displayLoginButton()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func login_buttonAction(_ sender: AnyObject) {
        VK_API._instance.requestAccess()
    }

    @IBAction func offline_buttonAction(_ sender: AnyObject) {
        let home: SearchVC = self.storyboard!.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
        self.present(home, animated: true, completion: nil)
    }
    
    
    
    func displayLoginButton() {
        login_buttonOutlet.isHidden = false
        offline_buttonOutlet.isHidden = false
        activityInd_outlet.stopAnimating()
        activityInd_outlet.isHidden = true
        loginStatus_labelOutlet.isHidden = true
        
    }
    


}

