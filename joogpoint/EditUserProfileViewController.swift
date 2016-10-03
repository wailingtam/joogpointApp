//
//  EditUserProfileViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 25/9/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import Locksmith
import Alamofire
import SwiftyJSON

class EditUserProfileViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var spotifyTextField: UITextField!
    @IBOutlet weak var facebookTextField: UITextField!
    @IBOutlet weak var twitterTextField: UITextField!
    @IBOutlet weak var favArtistsTextView: UITextView!
    @IBOutlet weak var favGenresTextView: UITextView!
    
    var profileUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        facebookTextField.delegate = self
        twitterTextField.delegate = self
        spotifyTextField.delegate = self
        
        favArtistsTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        favArtistsTextView.layer.borderWidth = 1.0
        favArtistsTextView.layer.cornerRadius = 5
        
        favGenresTextView.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).CGColor
        favGenresTextView.layer.borderWidth = 1.0
        favGenresTextView.layer.cornerRadius = 5
        
        loadProfile()
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditUserProfileViewController.DismissKeyboard))
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
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1
        
        // Try to find next responder
        if let nextResponder: UIResponder! = textField.superview!.superview!.superview!.viewWithTag(nextTag) {
            nextResponder.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        // returning the value true indicates that the text field should respond to the user pressing the Return key by dismissing the keyboard
        return true
    }

    func loadProfile() {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        if let data = defaults.objectForKey("user_profile") as? NSData {
            let savedUserProfile = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! UserProfile
            print(savedUserProfile.url)
            facebookTextField.text = savedUserProfile.facebookUsername
            spotifyTextField.text = savedUserProfile.spotifyUsername
            twitterTextField.text = savedUserProfile.twitterUsername
            favArtistsTextView.text = savedUserProfile.favArtists
            favGenresTextView.text = savedUserProfile.favGenres
            
            profileUrl = savedUserProfile.url
        }
        
    }
    
    @IBAction func saveProfile(sender: UIButton) {
        
        self.DismissKeyboard()
        
        let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
        
        let headers = [
            "Authorization": "Token " + (dictionary?["token"] as! String)
        ]
        
        let parameters = [
            "facebook_username": facebookTextField.text!,
            "twitter_username": twitterTextField.text!,
            "spotify_username": spotifyTextField.text!,
            "fav_artists": favArtistsTextView.text!,
            "fav_genres": favGenresTextView.text!
        ]
        
        Alamofire.request(.PATCH, self.profileUrl!, headers: headers, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    if let data = response.result.value {
                        let json = JSON(data)
                        
                        var pUrl = json["url"].string!
                        let index = pUrl.startIndex.advancedBy(4)
                        pUrl.insert("s", atIndex: index)
                        
                        let userProfile = UserProfile(url: pUrl, username: json["user"]["username"].string!, email: json["user"]["email"].string!, checkedIn: String(json["user"]["checked_in"].array!.count), voted: String(json["user"]["voted"].array!.count), requested: String(json["user"]["requested"].array!.count), myEstablishments: json["user"]["owner_of"].array!.count, spotifyUsername: json["spotify_username"].string!, facebookUsername: json["facebook_username"].string!, twitterUsername: json["twitter_username"].string!, favArtists: json["fav_artists"].string!, favGenres: json["fav_genres"].string!)
                        
                        let defaults = NSUserDefaults.standardUserDefaults()
                        
                        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(userProfile)
                        defaults.removeObjectForKey("user_profile")
                        defaults.setObject(encodedData, forKey: "user_profile")
                        
                        defaults.synchronize()
                        
                        let completionAlert = UIAlertController(title: "Edit profile successful", message: "You profile has been updated!", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let confirmAction = UIAlertAction(title: "Ok", style: .Default) { (_) in
                            self.backToUserProfile(nil)
                        }
                        
                        completionAlert.addAction(confirmAction)
                        self.presentViewController(completionAlert, animated: true, completion: nil)

                    }
                    
                case .Failure(let error):
                    print(error)
                }
        }
    }
    
    
    @IBAction func backToUserProfile(sender: UIButton?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
