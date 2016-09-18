//
//  ViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 27/5/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Alamofire
import Locksmith
import SwiftyJSON
import MapKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

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
            userLogin(nil)
        }
        // returning the value true indicates that the text field should respond to the user pressing the Return key by dismissing the keyboard
        return true
    }
    
    func showAlert(message: String, buttonTitle: String) {
        let alert = UIAlertController(title: "Login error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!) in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func checkValidUsernameAndPassword() -> Bool {
        // Disable Log in button if any text field is empty.
        let usernameText = usernameTextField.text ?? ""
        let passwordText = passwordTextField.text ?? ""
        if (usernameText.isEmpty || passwordText.isEmpty) {
            showAlert("All fields are required.", buttonTitle: "Ok")
        }
        return !usernameText.isEmpty && !passwordText.isEmpty
    }
    
    
    // MARK: Actions
    
    @IBAction func userLogin(sender: UIButton?) {
        if checkValidUsernameAndPassword() {
            Alamofire.request(.POST, "https://joogpoint.herokuapp.com/login/", parameters: ["username": usernameTextField.text!, "password": passwordTextField.text!])
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        if let data = response.result.value {
                            let json = JSON(data)
                            let token = json["token"].stringValue
                            do {
                                try Locksmith.updateData(["token": token], forUserAccount: "myUserAccount")
                            }
                            catch {
                            }
                            
                            // check if saved (remove later)
                            let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
                            print(dictionary?["token"] as! String)
                            
                            print("login🚀")
                            
                            self.performSegueWithIdentifier("LoginSuccessful", sender: self)
                            
                        }
                    case .Failure(_):
                        var alertMessage = ""
                        if let data = response.data {
                            let errorMessage = String(data: data, encoding: NSUTF8StringEncoding)!
                            if errorMessage.rangeOfString("Unable to log in with provided credentials.") != nil {                            alertMessage = "Incorrect username or password."
                            }
                            // TODO: Deal with other errors
                        }
                        self.showAlert(alertMessage, buttonTitle: "Try again")
                    }
            }
        }
    }
    
    @IBAction func unwindToLogin(sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.sourceViewController as? SignUpViewController {            
//        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoginSuccessful" {
            
            let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
            
            let headers = [
                "Authorization": "Token " + (dictionary?["token"] as! String)
            ]
            
            Alamofire.request(.GET, "https://joogpoint.herokuapp.com/profiles/me/", headers: headers)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        if let data = response.result.value {
                            let json = JSON(data)

                            let defaults = NSUserDefaults.standardUserDefaults()
                            
                            let userProfile = UserProfile(url: json["url"].string!, username: json["user"]["username"].string!, checkedIn: String(json["user"]["checked_in"].array!.count), voted: String(json["user"]["voted"].array!.count), requested: String(json["user"]["requested"].array!.count), spotifyUsername: json["spotify_username"].string!, facebookUsername: json["facebook_username"].string!, twitterUsername: json["twitter_username"].string!, favArtists: json["fav_artists"].string!, favGenres: json["fav_genres"].string!)
                            
                            let encodedData = NSKeyedArchiver.archivedDataWithRootObject(userProfile)
                            defaults.setObject(encodedData, forKey: "user_profile")

                            defaults.synchronize()
                        }
                        
                    case .Failure(let error):
                        print(error)
                    }
                }
        }
    }

}