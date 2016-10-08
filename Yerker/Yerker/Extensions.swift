//
//  Extensions.swift
//  Yerker
//
//  Created by Shant Tokatyan on 9/18/16.
//  Copyright © 2016 com.example. All rights reserved.
//

//import Foundation
import UIKit

@IBDesignable
class VKButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor {
        get {
            return self.borderColor
        }
        set {
            self.layer.borderColor = newValue.cgColor
            
        }
    }
}

@IBDesignable
class VKImageView: UIImageView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension Double {
    
    func getMinutesAndSeconds() -> String {
        let minutes = self / 60
        let seconds = self.truncatingRemainder(dividingBy: 60)
        if (seconds < 10) {
            return "\(Int(minutes)):0\(Int(seconds))"
        }
        return "\(Int(minutes)):\(Int(seconds))"
    }
    
}
