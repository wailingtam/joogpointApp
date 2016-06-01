//
//  ViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 27/5/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Handle the text field's user input through delegate callbacks.
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.DismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard(){
        self.view.endEditing(true)
    }

//    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        self.view.endEditing(true)
//    }
    
    /*
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    */
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1
        
        // Try to find next responder
        if let nextResponder: UIResponder! = textField.superview!.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            
            if checkValidUsernameAndPassword() {
                userLogin(nil)
            }
        }
        // returning the value true indicates that the text field should respond to the user pressing the Return key by dismissing the keyboard
        return true
    }
    
    func checkValidUsernameAndPassword() -> Bool {
        // Disable the Log in button if any text field is empty.
        let usernameText = usernameTextField.text ?? ""
        let passwordText = passwordTextField.text ?? ""
        return !usernameText.isEmpty && !passwordText.isEmpty
    }
    
    
    // MARK: Actions
    
    @IBAction func userLogin(sender: UIButton?) {
        if checkValidUsernameAndPassword() {
            print("login🚀")
        }
    }
    
    @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.sourceViewController as? SignUpViewController {
//            
//        }
    }
    
 
    
}