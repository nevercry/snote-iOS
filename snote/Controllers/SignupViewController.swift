//
//  SignupViewController.swift
//  snote
//
//  Created by nevercry on 3/25/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftyJSON

class SignupViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var conformPasswordTextField: UITextField!
    @IBOutlet weak var signupButton: UIButton!
    
    // MARK: - Buttons Action
    @IBAction func cancel(sender: UIButton) {
        // 取消注册
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
   
    @IBAction func signup(sender: UIButton) {
        view.endEditing(true)
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let conformPassword = conformPasswordTextField.text!
        // 检查一下用户名是否符合规则
        if !isValidUserName(username) {
            alertViewShow("该用户名无法注册", andMessage: "请更换用户名重新注册")
            return
        }
        
        // 检查一下密码是否相同
        if conformPassword != password {
            alertViewShow("两次输入的密码不同", andMessage: "请重新输入正确的密码")
            return
        }
        
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        SnoteProvider.request(.CreateUser(name: username,passwod: password), completion: { result in
            switch result {
            case let .Success(response):
                let json = JSON(data: response.data)
                do {
                    try response.filterSuccessfulStatusCodes()
                }
                catch {
                    if let errorMsg = json["message"].string {
                        self.alertViewShow("注册失败", andMessage: errorMsg)
                    } else {
                        print("error no sever message")
                    }
                    
                    return
                }
                
                if let token = json["token"].string {
                    SnoteUserDefaults.storeToken(token)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                    let rootViewController = storyboard.instantiateViewControllerWithIdentifier("TabBarController")
                    UIApplication.sharedApplication().delegate!.window!!.rootViewController = rootViewController
                } else {
                    print(json["token"])
                }
            case let .Failure(error):
                print(error)
            }
        })        
    }
    
    func updateLoginButtonState() {
        signupButton.enabled = (usernameTextField.hasText() && passwordTextField.hasText() && conformPasswordTextField.hasText()) ? true : false
    }

    // MARK: - View LifeCycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignupViewController().updateLoginButtonState), name: UITextFieldTextDidChangeNotification, object: nil)
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
