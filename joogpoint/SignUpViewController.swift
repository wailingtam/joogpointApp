//
//  SignUpViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 30/5/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SignUpViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        repeatPasswordTextField.delegate = self

        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.DismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard(){
        self.view.endEditing(true)
    }
    
    private func addBottomLineToTextField(textField : UITextField) {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.init(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0).CGColor
        border.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height)
        border.borderWidth = borderWidth
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        self.addBottomLineToTextField(usernameTextField)
        self.addBottomLineToTextField(emailTextField)
        self.addBottomLineToTextField(passwordTextField)
        self.addBottomLineToTextField(repeatPasswordTextField)
    }
    
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
            userSignUp(nil)
        }
        // returning the value true indicates that the text field should respond to the user pressing the Return key by dismissing the keyboard
        return true
    }
    
    func showAlert(message: String, buttonTitle: String) {
        let alert = UIAlertController(title: "Sign up error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!) in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func checkValidFields() -> Bool {
        // Disable Sign up button if any text field is empty.
        let usernameText = usernameTextField.text ?? ""
        let emailText = emailTextField.text ?? ""
        let passwordText = passwordTextField.text ?? ""
        let repeatPasswordText = repeatPasswordTextField.text ?? ""
        
        let textFieldsFilled = !usernameText.isEmpty && !emailText.isEmpty && !passwordText.isEmpty && !repeatPasswordText.isEmpty
        if (!textFieldsFilled) {
            showAlert("All fields are required.", buttonTitle: "Ok")
        }
        else if (passwordText != repeatPasswordText) {
            showAlert("The passwords don't match.", buttonTitle: "Ok")
        }
        return textFieldsFilled && passwordText == repeatPasswordText
    }
    
    
    // MARK: Actions
    
    var profileUrl = "";
    var token = "";
    
    @IBAction func userSignUp(sender: UIButton?) {
        if checkValidFields() {
            Alamofire.request(.POST, "https://joogpoint.herokuapp.com/users/", parameters: ["username": usernameTextField.text!, "email": emailTextField.text!, "password": passwordTextField.text!])
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        if let data = response.result.value {
                            let json = JSON(data)
                            self.profileUrl = json["user_profile"].stringValue
                            let index = self.profileUrl.startIndex.advancedBy(4)
                            self.profileUrl.insert("s", atIndex: index)
                            print("JSON: \(data)")
                            
                            Alamofire.request(.POST, "https://joogpoint.herokuapp.com/api-token-auth/", parameters: ["username": self.usernameTextField.text!, "password": self.passwordTextField.text!])
                                .validate()
                                .responseJSON { response in
                                    switch response.result {
                                    case .Success:
                                        if let data = response.result.value {
                                            let json = JSON(data)
                                            self.token = json["token"].stringValue
                                            print(self.token)
                                            self.performSegueWithIdentifier("AddSocialMedia", sender: self)
                                        }
                                    case .Failure(let error):
                                        print(error)
                                    }
                            }
                        }
                    case .Failure(let error):
                        print(error)
                        var alertMessage = ""
                        if let data = response.data {
                            let errorMessage = String(data: data, encoding: NSUTF8StringEncoding)!
                            if errorMessage.rangeOfString("A user with that username already exists.") != nil {                            alertMessage = "This username is already taken."
                            }
                        }
                        self.showAlert(alertMessage, buttonTitle: "Ok")
                    }
                }
        }
    }
    
    
    // MARK: - Navigation
    
    @IBAction func backToLogin(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        /*if finishSignUpButton === sender {
         
         }*/
        
        if segue.identifier == "AddSocialMedia" {
            // Nothing really to do here, since it won't be fired unless
            // shouldPerformSegueWithIdentifier() says it's ok. In a real app,
            // this is where you'd pass data to the success view controller.
            let nextViewController = segue.destinationViewController as! SocialMediaViewController
            nextViewController.profileUrl = profileUrl
            nextViewController.token = token
        }
    }
    
}
