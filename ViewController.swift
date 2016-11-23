/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    // Hook up IBOutlets for UI Elements for use within code.
    
    @IBOutlet weak var signupEmailAddressTextField: UITextField!
    @IBOutlet weak var signupEmailAddressTextFieldValid: UIImageView!
    
    @IBOutlet weak var signupPasswordTextField: UITextField!
    @IBOutlet weak var signupPasswordTextFieldValid: UIImageView!
    

    @IBOutlet weak var isDriver: UISwitch!
    @IBOutlet weak var signupButton: UIButton!
    
    
    @IBOutlet weak var loginEmailAddressTextField: UITextField!
    @IBOutlet weak var loginEmailAddressTextFieldValid: UIImageView!
    
    
    @IBOutlet weak var loginPasswordTextField: UITextField!
    @IBOutlet weak var loginPasswordTextFieldValid: UIImageView!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
    // Global variables for use within methods in this ViewController class.
    
    let activityIndicator = UIActivityIndicatorView()
    var storedButtonTitle = ""
    
    
    
    // Watch for changes in the signupEmailAddressTextField to see if the user has a value in it or not. Also run the generic 'checkUserTextField' method.
    
    @IBAction func emailAddressEditingChanged(_ sender: AnyObject) {
        
        if signupEmailAddressTextField.text != "" {
            
            // Present tick in box..
            
            signupEmailAddressTextFieldValid.isHidden = false
                
            checkUserTextFields()
            
        } else {
            
            // Hide tick in box..
            
            signupEmailAddressTextFieldValid.isHidden = true
                
            checkUserTextFields()
        
        }
        
    }
    
    
    
    // Watch for changes in the signupPasswordTextField to see if the user has a value in it or not. Also run the generic 'checkUserTextField' method.
    
    @IBAction func passwordAddressEditingChanged(_ sender: AnyObject) {
        
        if signupPasswordTextField.text != "" {
        
            // Present tick in box..
            
            signupPasswordTextFieldValid.isHidden = false
            
            checkUserTextFields()
        
        } else {
            
            // Hide tick in box..
        
            signupPasswordTextFieldValid.isHidden = true
            
            checkUserTextFields()
        
        }
        
    }
    
    
    
    // Watch for changes in the loginEmailAddressTextField to see if the user has a value in it or not. Also run the generic 'checkUserTextField' method.
    
    @IBAction func loginEmailAddressValueChanged(_ sender: AnyObject) {
        
        if loginEmailAddressTextField.text != "" {
        
            // Present tick in box..
            
            loginEmailAddressTextFieldValid.isHidden = false
                
            checkUserTextFields()
            
        } else {
            
            // Hide tick in box..
            
            loginEmailAddressTextFieldValid.isHidden = true
                
            checkUserTextFields()
        
        }
        
    }
    
    
    // Watch for changes in the loginPasswordTextField to see if the user has a value in it or not. Also run the generic 'checkUserTextField' method.
    
    
    @IBAction func loginPasswordAddressValueChanged(_ sender: AnyObject) {
        
        if loginPasswordTextField.text != "" {
        
            // Present tick in box..
            
            loginPasswordTextFieldValid.isHidden = false
            
            checkUserTextFields()
            
        } else {
            
            // Hide tick in box..
        
            loginPasswordTextFieldValid.isHidden = true
            
            checkUserTextFields()
        
        }
        
        
    }
    
    
    
    
    // User clicks SIGN UP button...
    
    @IBAction func signup(_ sender: AnyObject) {
        
        // Run showActivityIndicator method which will put an activity indicator in the signUp button and stop the user interacting with the app.
        
        showActivityIndicator(button: sender as! UIButton)
        
        
        // Assign the new user up using the values inputted in the email and password text fields..
        
        let user = PFUser()
        
        user.username = signupEmailAddressTextField.text
        user.password = signupPasswordTextField.text
        
        
        // Also specify whether they are signing up as a driver or a rider..
        
        user["isDriver"] = isDriver.isOn
        
        
        
        // Attempt to sign the user up to the Parse server, handling the returning outcomes in a closure...
        
        user.signUpInBackground { (success, error) in
            
            
            // Whatever the outcome, we want the activity indicator to stop..
            
            self.hideActivityIndicator(button: sender as! UIButton)
            
            
            // If the sign up was successful...
            
            if success {
            
               // print("Successfully signed up user")
                
                
                // Find the value that the newly signed up user set to the "isDriver" key value pair..
                
                if let isDriver = PFUser.current()?["isDriver"] as? Bool {
                
                    // If they specified that they are signing up as a driver.
                    
                    if isDriver {
                    
                        
                        // Segue the user over to the driver side of the app.
                        
                        self.performSegue(withIdentifier: "enterAppAsDriver", sender: self)
                   
                    // If they specified that they are signing up as a rider..
                        
                    } else {
                    
                        // Segue the user over to the rider side of the app.
                        
                        self.performSegue(withIdentifier: "enterAppAsRider", sender: self)
                    
                    }
                
                }
                
                
            // However, if the sign up was not successful..
            
            } else {
            
                // If a coherent error was identified..
                
                if let error = error {
                
                    // Show user localised error description 
                    self.displayAlert(title: "Error", message: "\(error.localizedDescription)")
                    self.signupEmailAddressTextField.text = ""
                    self.signupPasswordTextField.text = ""
                    self.signupEmailAddressTextFieldValid.isHidden = true
                    self.signupPasswordTextFieldValid.isHidden = true
                    
                } else {
                
                    // Unknown error: Please try again later
                    self.displayAlert(title: "Unknown Error", message: "Please try again later")
                    self.signupEmailAddressTextField.text = ""
                    self.signupPasswordTextField.text = ""
                    self.signupEmailAddressTextFieldValid.isHidden = true
                    self.signupPasswordTextFieldValid.isHidden = true
                
                }
            
            }
            
        }
        
    }
    
    
    
    
    // User clicks LOG IN button...
    
    @IBAction func login(_ sender: AnyObject) {
        
        
        // Check that the login email text field and login password text fields are not blank (not necessary as this is checked in the 'checkUserTextFields' method..
        
        if loginEmailAddressTextField.text != "" && loginPasswordTextField.text != "" {
            
            
            
            // Show an activity indicator in the log in button..
            
            showActivityIndicator(button: sender as! UIButton)
            
        
            // Attempt to log the user in with the details entered in the email and password text fields, handling the various return outcomes in a closure.....
            
            PFUser.logInWithUsername(inBackground: loginEmailAddressTextField.text!, password: loginPasswordTextField.text!, block: { (user, error) in
                
                
                // Whatever the outcome, stop the activity indicator and allow the user to interact with the app once more.
                
                self.hideActivityIndicator(button: sender as! UIButton)
                
                
                // If there is a user that matches the details input by the user..
                
                if let user = user {
                
                 //   print("\(user.username!) logged in successfully")
                    
                    
                    // Check if the user's "isDriver" key value pair specifies that they signed up as a driver or a rider...
                    
                    if let isADriver = user["isDriver"] as? Bool {
                    
                        
                        // If they did sign up as a driver..
                        
                        if isADriver {
                            
                            // Segue them to the driver side of the app.
                        
                            self.performSegue(withIdentifier: "enterAppAsDriver", sender: self)
                        
                        // If they signed up as a rider..
                            
                        } else {
                        
                            
                            // Segue them to the rider side of the app.
                            
                            self.performSegue(withIdentifier: "enterAppAsRider", sender: self)
                        
                        }
                    
                    }
                
                    
                // If there was no user found in the database which matches the values input by the user...
                    
                } else {
                
                    // If a coherent error is established..
                    
                    if let error = error {
                    
                        // display an alert to the user which explains the error.
                        
                        self.displayAlert(title: "Error", message: "\(error.localizedDescription)")
                        self.loginEmailAddressTextField.text = ""
                        self.loginPasswordTextField.text = ""
                        self.loginEmailAddressTextFieldValid.isHidden = true
                        self.loginPasswordTextFieldValid.isHidden = true
                    
                    // If no coherent error was established..
                        
                    } else {
                    
                        // display an alert to the user which asks them to try again later..
                        
                        self.displayAlert(title: "Unknown Error", message: "Please try again later")
                        self.loginEmailAddressTextField.text = ""
                        self.loginPasswordTextField.text = ""
                        self.loginEmailAddressTextFieldValid.isHidden = true
                        self.loginPasswordTextFieldValid.isHidden = true
                        
                    }
                    
                }
                
            })
            
        
        }
        
    }
    
    
    
    // checkUserTextFields method which only enables the appropriate sign up or log in button if both of their accompanying user textFields are filled with values..
    
    func checkUserTextFields() {
    
        
        // Check sign up first...
        
        if (signupEmailAddressTextField.text != "" && signupPasswordTextField.text != "") {
        
            signupButton.isEnabled = true
            signupButton.alpha = 1.0
            
        } else {
        
            signupButton.isEnabled = false
            signupButton.alpha = 0.5
        
        }
        
        
        // Check log in...
            
        if (loginEmailAddressTextField.text != "" && loginPasswordTextField.text != "") {
        
            loginButton.isEnabled = true
            loginButton.alpha = 1.0
        
        } else {
        
            loginButton.isEnabled = false
            loginButton.alpha = 0.5
            
        
        }
    
    }
    
    
    
    // diplayAlert method which creates a generic alert to the user which uses the input of the title and message parameters to display the alert title and message.
    
    func displayAlert(title: String, message: String) {
    
        // If you want your alert view to handle segues and other commands when buttons are clicked then you could opt for the UIAlertController class instead, adding 'action' to it..
        
        let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        
        alert.show()
    
    }
    
    
    
    
    // showActivityIndicator method which takes a button as a parameter...
    
    func showActivityIndicator(button: UIButton) {
        
        // Set the value of the global storedButtonTitle variable to the currentTitle of the button that has been pressed..
        
        storedButtonTitle = button.currentTitle!
        
        
        // Set the frame of the activityIndicator to appear in the center of the button that has been pressed.
        
        activityIndicator.frame = CGRect(x: 60, y: -10, width: 50, height: 50)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .white
        
        activityIndicator.startAnimating()
        
        button.setTitle("", for: .normal)
        
        // ignore User Interaction Events so that they task can be carried out without interference by the user..
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Add the activityIndicator to the button in question..
        
        button.addSubview(activityIndicator)
    
    }
    
    
    
    
    // hide activity indicator which takes a button as a parametere...
    
    func hideActivityIndicator(button: UIButton) {
    
        activityIndicator.stopAnimating()
        
        
        // allow the user to interact with the app once more..
        
        UIApplication.shared.endIgnoringInteractionEvents()
        
        // Once the activity indicator animation has been removed from the button in question, use the value of the 'storedButtonTitle' global variable to set the button's title once more..
        
        button.setTitle(storedButtonTitle, for: .normal)
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    
    
    
    // View Did Appear...
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        // If the current user on this app has a value attached to the "isDriver" key value pair (if there is, then they must have already signed up to be able to have a value.
        
        
        if let isADriver = PFUser.current()?["isDriver"] as? Bool {
        
            // If that value is "true"
            
            if isADriver {
            
                
                // Automatically segue the user to the driver side of the app.
                
                performSegue(withIdentifier: "enterAppAsDriver", sender: self)
           
                
            // If the value is false (therefore they have signed up as a rider)
                
            } else {
            
                // Automatically segue the user to the rider side of the app.
                
                performSegue(withIdentifier: "enterAppAsRider", sender: self)
            
            }
        
        }
        
    }
    
    
    
    // Set up some styling ahead of the app appearing..
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Hide the ticks from all of the text fields initially..
        
        signupEmailAddressTextFieldValid.isHidden = true
        signupPasswordTextFieldValid.isHidden = true
        
        loginEmailAddressTextFieldValid.isHidden = true
        loginPasswordTextFieldValid.isHidden = true
        
        // round off the edges on the corners..
        
        signupButton.layer.cornerRadius = 5.0
        loginButton.layer.cornerRadius = 5.0
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}















