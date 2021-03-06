//
//  SocialMediaViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 1/6/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Alamofire

class SocialMediaViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var facebookTextField: UITextField!
    @IBOutlet weak var twitterTextField: UITextField!
    @IBOutlet weak var spotifyTextField: UITextField!
    
    var profileUrl = ""
    var token = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        facebookTextField.delegate = self
        twitterTextField.delegate = self
        spotifyTextField.delegate = self
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SocialMediaViewController.DismissKeyboard))
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
        self.addBottomLineToTextField(facebookTextField)
        self.addBottomLineToTextField(twitterTextField)
        self.addBottomLineToTextField(spotifyTextField)
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
            saveSocialMedia(nil)
        }
        // returning the value true indicates that the text field should respond to the user pressing the Return key by dismissing the keyboard
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
    
    
    // MARK: Actions
    
    @IBAction func saveSocialMedia(sender: UIButton?) {
        let headers = [
            "Authorization": "Token " + token
        ]
        
        let parameters = [
            "facebook_username": facebookTextField.text!,
            "twitter_username": twitterTextField.text!,
            "spotify_username": spotifyTextField.text!
        ]
        
        Alamofire.request(.PATCH, profileUrl, headers: headers, parameters: parameters)
            .validate()
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }
    }
    

}
