//
//  SignupViewController.swift
//  snote
//
//  Created by nevercry on 3/25/16.
//  Copyright © 2016 nevercry. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var conformPasswordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Buttons Action
    @IBAction func cancel(sender: UIButton) {
        // 取消注册
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
   
    @IBAction func login(sender: UIButton) {
        // 注册
    }
    
    func updateLoginButtonState() {
        loginButton.enabled = (usernameTextField.hasText() && passwordTextField.hasText() && conformPasswordTextField.hasText()) ? true : false
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
