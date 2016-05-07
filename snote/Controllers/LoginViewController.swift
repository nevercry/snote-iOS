//
//  LoginViewController.swift
//  snote
//
//  Created by nevercry on 3/25/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit
import SwiftyJSON
import MBProgressHUD
import snoteShareCode

class LoginViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Buttons Action
    @IBAction func cancel(sender: UIButton) {
        // 取消登录
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func login(sender: AnyObject) {
        view.endEditing(true)
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        // 登录
        SnoteProvider.request(.Login(name: username, password: password), completion: { result in
            MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
            switch result {
            case let .Success(response):
                let json = JSON(data: response.data)
                do {
                    try response.filterSuccessfulStatusCodes()
                }
                catch {
                    if let errorMsg = json["message"].string {
                        self.alertViewShow("登录失败", andMessage: errorMsg)
                    } else {
                        print("error no sever message")
                        self.alertViewShow("error no sever message", andMessage: "error no sever message")
                    }
                    
                    return
                }
                
                if let token = json["token"].string {
                    SnoteUserDefaults.storeToken(token)
                    let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
                    appDelegate?.startTabBar()
                } else {
                    print(json["token"])
                }
            case let .Failure(error):
                print(error)
                self.alertViewShow("网络请求失败", andMessage: "请检查网络连接")
            }
        })
    }
    
    // MARK: - 更新登录按钮状态
    func updateLoginButtonState() {
        loginButton.enabled = (usernameTextField.hasText() && passwordTextField.hasText()) ? true : false
    }
    
    // MARK: - View LifeCycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(LoginViewController.updateLoginButtonState) , name: UITextFieldTextDidChangeNotification, object: nil)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - UITextFieldDelegate 
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
