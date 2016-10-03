//
//  EditEstablishmentViewController.swift
//  joogpoint
//
//  Created by Wai Ling Tam on 24/9/16.
//  Copyright © 2016 Wai Ling Tam. All rights reserved.
//

import UIKit
import MapKit
import Locksmith
import Alamofire
import SwiftyJSON

class EditEstablishmentViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var postcodeTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var spotifyTextField: UITextField!
    @IBOutlet weak var lastfmTextField: UITextField!
    
    var establishment: Establishment? {
        didSet {
            configureView()
        }
    }
    
    func configureView() {
        if let establishmentProfile = establishment {
            if let name = nameTextField {
                name.text = establishmentProfile.title
            }
            if let address = addressTextField {
                address.text = establishmentProfile.address
            }
            if let postcode = postcodeTextField {
                postcode.text = establishmentProfile.postcode
            }
            if let city = cityTextField {
                city.text = establishmentProfile.city
            }
            if let country = countryTextField {
                country.text = establishmentProfile.country
            }
            if let spotify = spotifyTextField {
                spotify.text = establishmentProfile.spotify
            }
            if let lastfm = lastfmTextField {
                lastfm.text = establishmentProfile.lastfm

            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        nameTextField.delegate = self
        addressTextField.delegate = self
        postcodeTextField.delegate = self
        cityTextField.delegate = self
        countryTextField.delegate = self
        spotifyTextField.delegate = self
        lastfmTextField.delegate = self
        
        configureView()
        
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(EditEstablishmentViewController.DismissKeyboard))
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
        self.addBottomLineToTextField(nameTextField)
        self.addBottomLineToTextField(addressTextField)
        self.addBottomLineToTextField(postcodeTextField)
        self.addBottomLineToTextField(cityTextField)
        self.addBottomLineToTextField(countryTextField)
        self.addBottomLineToTextField(spotifyTextField)
        self.addBottomLineToTextField(lastfmTextField)
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
    
    func showAlert(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!) in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func checkValidFields() -> Bool {
        // Disable Sign up button if any text field is empty.
        let nameText = nameTextField.text ?? ""
        let addressText = addressTextField.text ?? ""
        let postcodeText = postcodeTextField.text ?? ""
        let cityText = cityTextField.text ?? ""
        let countryText = countryTextField.text ?? ""
        let spotifyText = spotifyTextField.text ?? ""
        let lastfmText = lastfmTextField.text ?? ""
        
        let textFieldsFilled = !nameText.isEmpty && !addressText.isEmpty && !postcodeText.isEmpty && !cityText.isEmpty && !countryText.isEmpty && !spotifyText.isEmpty && !lastfmText.isEmpty
        if (!textFieldsFilled) {
            showAlert("Edit profile error", message: "All fields are required.", buttonTitle: "Ok")
        }
        return textFieldsFilled
    }
    
    // MARK: - Action
    
    @IBAction func saveProfile(sender: UIButton?) {
        if checkValidFields() {
            let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
            
            let headers = [
                "Authorization": "Token " + (dictionary?["token"] as! String)
            ]
            
            let parameters = [
                "name": nameTextField.text!,
                "address": addressTextField.text!,
                "postcode": postcodeTextField.text!,
                "city": cityTextField.text!,
                "country": countryTextField.text!,
                "spotify_username": spotifyTextField.text!,
                "lastfm_username": lastfmTextField.text!
            ]
            
            Alamofire.request(.PATCH, establishment!.url, headers: headers, parameters: parameters)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
//                        if let data = response.result.value {
//                            print("Response: \(data)")
//                        }
                        let completionAlert = UIAlertController(title: "Edit profile successful", message: "Establishment profile updated!", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let confirmAction = UIAlertAction(title: "Ok", style: .Default) { (_) in
                            self.backToMyEstablishment(nil)
                        }
                        
                        completionAlert.addAction(confirmAction)
                        self.presentViewController(completionAlert, animated: true, completion: nil)
                        
                    case .Failure(let error):
                        print(error)
                    }
                    
            }
        }
    }
    
    @IBAction func addEstablishment(sender: UIButton) {
        if checkValidFields() {
            let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
            
            let headers = [
                "Authorization": "Token " + (dictionary?["token"] as! String)
            ]
            
            let parameters = [
                "name": nameTextField.text!,
                "address": addressTextField.text!,
                "postcode": postcodeTextField.text!,
                "city": cityTextField.text!,
                "country": countryTextField.text!,
                "spotify_username": spotifyTextField.text!,
                "lastfm_username": lastfmTextField.text!
            ]
            
            Alamofire.request(.POST, "https://joogpoint.herokuapp.com/establishments/", headers: headers, parameters: parameters)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
//                        if let data = response.result.value {
//                            print("Response: \(data)")
//                        }
                        let completionAlert = UIAlertController(title: "Establishment registration successful", message: "New establishment added.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let confirmAction = UIAlertAction(title: "Ok", style: .Default) { (_) in
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                        
                        completionAlert.addAction(confirmAction)
                        self.presentViewController(completionAlert, animated: true, completion: nil)
                        
                    case .Failure(let error):
                        print(error)
                    }
                    
            }
        }

    }
    
    @IBAction func removeEstablishment(sender: UIButton) {
        let alert = UIAlertController(title: "Remove establishment", message: "Are you completely sure?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let confirmAction = UIAlertAction(title: "Yes", style: .Default) { (_) in
            let dictionary = Locksmith.loadDataForUserAccount("myUserAccount")
            
            let headers = [
                "Authorization": "Token " + (dictionary?["token"] as! String)
            ]
            
            Alamofire.request(.DELETE, self.establishment!.url, headers: headers)
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .Success:
                        //                        if let data = response.result.value {
                        //                            print("Response: \(data)")
                        //                        }
                        
                        let completionAlert = UIAlertController(title: "Remove establishment", message: "Establishment deleted successfully.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        let confirmAction = UIAlertAction(title: "Ok", style: .Default) { (_) in
                            var viewControllers = self.navigationController?.viewControllers
                            viewControllers?.removeLast(2)
                            self.navigationController?.setViewControllers(viewControllers!, animated: true)
                        }
                        
                        completionAlert.addAction(confirmAction)
                        self.presentViewController(completionAlert, animated: true, completion: nil)
            
                    case .Failure(let error):
                        print(error)
                    }
            }
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (_) in }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Navigation
    
    @IBAction func backToMyEstablishment(sender: UIButton?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func backToMyJoogpoints(sender: UIButton?) {
        let alert = UIAlertController(title: "Establishment registration", message: "Are you sure you want to cancel the registration?", preferredStyle: UIAlertControllerStyle.Alert)
        
        let confirmAction = UIAlertAction(title: "Yes", style: .Default) { (_) in
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "No", style: .Cancel) { (_) in }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

}