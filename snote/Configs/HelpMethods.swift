//
//  HelpMethods.swift
//  CreateBand
//
//  Created by nevercry on 12/25/15.
//  Copyright © 2015 nevercry. All rights reserved.
//

import UIKit

struct RegexHelper {
    let regex: NSRegularExpression?
    
    init(_ pattern: String) {
        do {
            regex = try NSRegularExpression.init(pattern: pattern, options: .CaseInsensitive)
        } catch {
            print("\(error)")
            regex = nil
        }
    }
    
    func match(input: String) -> Bool {
        if let matches = regex?.matchesInString(input, options: .ReportCompletion, range: NSMakeRange(0, input.characters.count)) {
            return matches.count > 0
        } else {
            return false
        }
    }
}


extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControlState) {
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor)
        CGContextFillRect(UIGraphicsGetCurrentContext(), CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, forState: forState)
    }
    
}

extension UIViewController {
    // 验证有效手机号
    func isValidMobile(mobile: String) -> Bool {
        let mobiePhoneRex = "^0?(13[0-9]|15[012356789]|17[0678]|18[0-9]|14[57])[0-9]{8}$"
        return RegexHelper.init(mobiePhoneRex).match(mobile)
    }
    
    // 验证有效用户名 4-20位 英文和数字组合
    func isValidUserName(userName: String) -> Bool {
        let userNameRex = "^[A-Za-z][A-Za-z0-9]{3,19}+$"
        return RegexHelper.init(userNameRex).match(userName)
    }
    
    func alertViewShow(title:String, andMessage message: String) {
        alerViewShow(title, andMessage: message, andHandler: nil)
    }
    
    func alerViewShow(title:String, andMessage message: String, andHandler handler: ((UIAlertAction) -> Void)?) {
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .Alert)
        let actionCancel = UIAlertAction.init(title: "确定", style: .Cancel, handler: handler)
        alertController.addAction(actionCancel)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        // 隐藏键盘
        if !isFirstResponder() {
            view.endEditing(true)
        }
    }
}

extension UIView {
    func cornerRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func bordeColor(color: UIColor) {
        self.layer.borderColor = color.CGColor
    }
    
    func bordeWidth(width: CGFloat) {
        self.layer.borderWidth = width
    }
}

struct DateHelper {
    func transToDate(dateString: String) -> NSDate {
        let dateFormater = NSDateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormater.dateFromString(dateString)!
    }
}



