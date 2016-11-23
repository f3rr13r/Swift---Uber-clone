//
//  HomePageViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Harry Ferrier on 8/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse


// Import MapKit for use with the map...
import MapKit

// Attach the MKMapView and CLLocationManager delegates...

class HomePageViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // Hook up IBOutlets for the page's UIElements for use within the code..
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var driverNameLabel: UILabel!
    @IBOutlet weak var driverDistanceLabel: UILabel!
    @IBOutlet weak var requestUberButton: UIButton!

    // Create a global instance of a CLLocationManager()
    
    var locationManager = CLLocationManager()
    
    // Create a userLocation variable of type 'CLLocationCoordinate2D'. As we must initialise this, we should set an initial latitude and longitude values of 0 and 0...
    
    var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    
    // Create boolean variables 'riderRequestActive' and 'driverOnTheWay' to estblish the state of whether the user has requested an uber, and whether the request has been picked up by a driver...
    
    var riderRequestActive = true
    
    var driverOnTheWay = false

    
    
    
   
    
    
    // Logout button pressed...
    
    @IBAction func logout(_ sender: AnyObject) {
        
        // Segue the user back to the sign up log in page...
        
        performSegue(withIdentifier: "exitAppAsRider", sender: self)
        
    }
    
    
    // Prepare for segue method...
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        // if the segue about to be performed is the 'exitAppAsRider' segue...
        
        if segue.identifier == "exitAppAsRider" {
            
            
            // Stop the locationManager from continuing to updating the user location..
            
            locationManager.stopUpdatingLocation()
            
            // Log the current user out..
            
            PFUser.logOut()
            
        }
        
    }
    
        
    
    
    
    // RequestUber button pressed by user...
    
    @IBAction func requestUber(_ sender: AnyObject) {
        
        
        // if riderRequestActive boolean is set to true, and therefore the the user does not already have a request being processed..
        
        if riderRequestActive {
        
            // Set the title for the requestUberButton to be 'Request Uber'
            
            requestUberButton.setTitle("REQUEST uber", for: .normal)
            
            // The user has pressed the button, and so now has a request sent to the drivers. As users cannot have two requests at any one time, the state of their 'riderRequestActive' should be changed to false..
            
            riderRequestActive = false
            
            
            // Create a query instance, querying the database for a class with the name "RiderRequest"
            
            let query = PFQuery(className: "RiderRequest")
            
            
            // Specify the conditions of the query to look for values for the key "username" within the "RiderRequest" class, and specifically values that match the "username" of the device's current user.
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            
            
            // Attempt to find results that match our criteria, and handle the respective return outcomes with a closure...
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                // If there is any data returned which matches our criteria...
                
                if let riderRequests = objects {
                
                    /// Loop through all the data objects returned...
                    
                    for riderRequest in riderRequests {
                
                        // Deleting each one as you go...
                        
                        riderRequest.deleteInBackground()
                        
                        // Why? Because we do not want to duplicate values within our database..We will re-add a new rider request in below..
                    
                    }
                
                }
                
            })
        
        // Now that there are no values which match the criteria we are looking for...as if they did previously exist, we just deleted them.
            
        } else {
        
        
            // ** NOTE - For userLocation detailing and information, go to the 'didUpdateLocations' method (Line - 187)
            
            // We check to see if the userLocation (which is a CLLocationCoordinate2D) has values for latitude and longitude which are not zero (therefore the device has determined the user's locations and replaced the variable's initial 0 and 0 values with the user's latitude and longitue coordinate values.
            
            // If we have got the user's actual location...
            
            if userLocation.latitude != 0 && userLocation.longitude != 0 {
                
                // Set the riderRequestActive boolean value to be true <---- CHECK LEGITIMACY OF THIS CALL. SHOULD IT BE RIDER REQUEST ACTIVE TO FALSE AS WHEN USE CLICKED THE BUTTON, THEY DID SO TO REQUEST AN UBER (so cannot request a second one)
                
                riderRequestActive = true
                
                
                // Set the requestUberButton's title to CANCEL uber..
                
                self.requestUberButton.setTitle("CANCEL uber", for: .normal)
                
                
                // Create a new class in the server database named "RiderRequest"
                
                let riderRequest = PFObject(className: "RiderRequest")
            
                // Create two key value pairs inside the class: Username with a value of the device's current user's username.
                //                                            : Location which is a PFGeoPoint which takes the values of the userLocation's
                //                                              latitude and longitude properties.
                
                riderRequest["username"] = PFUser.current()?.username
                riderRequest["location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
                
                // Attempt to save these new key values pairs inside the newly formed "RiderRequest" class, handling the potential return outcomes with a closure...
                
                riderRequest.saveInBackground(block: { (success, error) in
                    
                    
                    // If these values are successfully saved...
                    
                    if success {
                        
                      //  print("Succesfully called an Uber")
                    
                        
                    // If there was an error when attempting to save the new values..
                        
                    } else {
                        
                        // Change the button's title back to 'request uber'
                        
                        self.requestUberButton.setTitle("REQUEST uber", for: .normal)
                        
                        // Set the riderRequestActive value back to false (as there is no request active)
                        
                        self.riderRequestActive = false
                    
                        // Display an error message to the user, telling them that there was an error trying to request an uber..
                        
                        self.displayAlert(title: "Error calling Uber", message: "\(error?.localizedDescription)")
                    
                    }
                    
                })
            
                
            // If we have not yet asked the user for their location permissions and have managed to suucessfully obtain their device's location..
            
            } else {
            
                // Tell the user that we could not call an uber as we do not know where the user is..
                
                displayAlert(title: "Could not call uber", message: "Cannot detect your location")
            
            }
            
        }
        
    }
    
    
    
    // didUpdateLocations locationManager method which will establish the location of our user's device..
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Attempt to access the device's manager property, it's location and more specificatally, the coordinates of it's location. If we can obtain location coordinate information succesfully...
        
        if let location = manager.location?.coordinate {
            
            // Set the user's location to be a CLLocationCoordinate2D which is formed from the latitude and longitude properties of the location constant created above..
            
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            // If no driver has taken on our user's request/ or if they have not yet made a request (hence not having a driver coming anyway)..
            
            if driverOnTheWay == false {
                
                
                // Create a region for the mapView to display the user's current location, specifying the center as the user's location, and the span of the map being 0.01 coordinate points between the left and right sides of the screen, and the top and bottom side s of the device screen.
                
                let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                
                // Now that we have our region, display it on our screen's map..
                
                self.mapView.setRegion(region, animated: true)
                
            }
            
            
            
            // Create a PFquery on the class with the name "RiderRequest"
            
            let query = PFQuery(className: "RiderRequest")
            
            
            // Look for our device's current user's row inside the class by searching for the "username" value being equal to our current user's username..
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            
            
            // Attempt to find this information and return it with a closure, handling the various return outcomes accordingly..
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                
                // If we are successfully able to get data back which matches our criteria...
                
                if let riderRequests = objects {
                    
                    // Loop through each instance of the data returned
                    
                    for riderRequest in riderRequests {
                        
                        // Create a new key value pair for the class named "location" and set it's value to be a PFGeoPoint which is made up from the currenUser's location's latitude and longitude property values..
                        
                        riderRequest["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        
                        // Save this new data to the database in the background..
                        
                        riderRequest.saveInBackground()
                        
                    }
                    
                }
                
            })
            
            
        }
        
        // If the user has already requested an Uber..
        
        if riderRequestActive == true {
            
            
            // Create a query on the class with the name "RiderRequests"
            
            let query = PFQuery(className: "RiderRequest")
            
            // Look for our device's current user's row inside the class by searching for the "username" value being equal to our current user's username..
            
            query.whereKey("username", equalTo: (PFUser.current()?.username!)!)
            
            
            // Attempt to find this information and return it with a closure, handling the various return outcomes accordingly..
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                // If data is returned successfully which matches our criteria...
                
                if let riderRequests = objects {
                    
                    // Loop through that data...
                    
                    for riderRequester in riderRequests {
                        
                        // If any of the data looped through has a value assigned to a key within the row named "driverResponded"..
                        
                        if let driverUsername = riderRequester["driverResponded"] {
                            
                            
                            // Create another query, this time on the class with the name "DriverLocation"
                            
                            let query = PFQuery(className: "DriverLocation")
                            
                            // Search to see if there is a value assigned to the "DriverLocation" class's "username" key which has the same value as the value of the driverUsername constant created above..
                            
                            query.whereKey("username", equalTo: driverUsername)
                            
                            // Attempt to find this information and return it with a closure, handling the various return outcomes accordingly..
                            
                            query.findObjectsInBackground(block: { (objects, error) in
                                
                                // If there is any data returned which matches our criteria...
                                
                                if let driverLocations = objects {
                                    
                                    // Loop through the returned data...
                                    
                                    for driverLocationObject in driverLocations {
                                        
                                        
                                        // If there is a value assigned to the "location" key in the row that the data has looped through, and it is castable to a type of PFGeoPoint, and if so then store that value to a constant named driverLocation.
                                        
                                        if let driverLocation = driverLocationObject["location"] as? PFGeoPoint {
                                            
                                            
                                            // Change the value of the global 'driverOnTheWay' boolean value to be true..
                                            
                                            self.driverOnTheWay = true
                                            
                                            
                                            // Create an instance of the CLLocation class, which takes the latitude and longitude of the PFGeoPoint 'driverLocation' constant..
                                            
                                            let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            
                                            // Create another instance of the CLLoction class, this time for the user's location, which takes the latitude and longitude of the global userLocation variable.
                                            
                                            let riderCLLocation = CLLocation(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                                            
                                            
                                            // Calculate the distance between the location of the device's current user and that driver who has accepted their rider request.....We want this value to be in miles, so we divide the value by 1600 (1600 metres in a mile)
                                            
                                            let distance = riderCLLocation.distance(from: driverCLLocation) / 1600
                                            
                                            // In order to reduce the value to 2 decimal points, we use the round method on the distance (which is timesed by 100). Then we divide that rounded figure by 100 to get our number.
                                            
                                            let roundedDistance = round(distance * 100) / 100
                                            
                                            
                                            // Display the driver's name and distance away in a label on the device's screen.
                                            
                                            self.driverNameLabel.text = "\(driverLocationObject["username"]!)"
                                            self.driverNameLabel.isHidden = false
                                            
                                            self.driverDistanceLabel.text = "\(roundedDistance) miles away..."
                                            self.driverDistanceLabel.isHidden = false
                                            
                                            
                                            
                                            // Create a latDelta and lonDelta which takes the distance between driver and the device's current user, times taht figure by 2 and add 0.005 points (so that the map zoom will always be appropriately set to be able to see both the driver and user's positions on the map, regardless of distance)..
                                            
                                            let latDelta = abs(driverLocation.latitude - self.userLocation.latitude) * 2 + 0.005
                                            let lonDelta = abs(driverLocation.longitude - self.userLocation.longitude) * 2 + 0.005
                                            
                                            
                                            // Create a region using the device's current user's location coordinates, and a view span which is set using the latDelta and lonDelta values above..
                                            
                                            let region = MKCoordinateRegion(center: self.userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                            
                                            
                                            // To avoid duplications, we will then remove all previous annotations from the map.
                                            
                                            self.mapView.removeAnnotations(self.mapView.annotations)
                                            
                                            // Set the map's display region..
                                            
                                            self.mapView.setRegion(region, animated: true)
                                            
                                            
                                            // Create a point annotation to show the driver's location..
                                            
                                            let driverLocationAnnotation = MKPointAnnotation()
                                            
                                            // Set it's location coordinate to be the driver's coordinate, specified from the driverLocation's latitude and longitude values.
                                            
                                            driverLocationAnnotation.coordinate = CLLocationCoordinate2D(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                            
                                            
                                            // Add that annotation to the map.
                                            
                                            self.mapView.addAnnotation(driverLocationAnnotation)
                                            
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            })
                            
                        }
                        
                    }
                    
                }
                
            })
            
        }
        
    }

    
    
    
    
  //  displayAlert method to be used in order to handle and display errors to the user..
    
    func displayAlert(title: String, message: String) {
        
        // If you want your alert view to handle segues and other commands when buttons are clicked then you could opt for the UIAlertController class instead, adding 'action' to it..
        
        let alert = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        
        alert.show()
        
    }
    
    
    
    
    // When the view loads,...
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Set up the preferences of the global locationManager variable, setting it's delegate, it's desired Acuuracy..
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Asking the user for permission to obtain location information about them when they are using the app..
        
        locationManager.requestWhenInUseAuthorization()
        
        // If they allow it, startUpdating the device's location using the didUpdateLocations method above (Line 224)
        locationManager.startUpdatingLocation()
        
        // Set the map's showsUserLocation's property to be true. This will display the user's current location as a blue dot..
        
        mapView.showsUserLocation = true
        
        
        
        // Create a query on the class with the name "RiderRequest"
        
        let query = PFQuery(className: "RiderRequest")
        
        // Look for any instances that feature our device's current user by searching for value's for the key "username" that are equal to our device current user's username..
        
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        
        // Attempt to find results that match our criteria, handling the result outcomes in a closure..
        
        query.findObjectsInBackground(block: { (objects, error) in
            
            
            // If there are objects returned that match our criteria..
            
            if let objects = objects {
                
                // If there are more than none...
                
                if objects.count > 0 {
                    
                    // Change the riderRequestActive property to true which will prevent the user from being able to request more than 1 user at any time.
                
                    self.riderRequestActive = true
                
                    // Change the requestUberButton's title to 'CANCEL Uber'. They will have to cancel their current uber request before they can request a new one..
                    
                    self.requestUberButton.setTitle("CANCEL uber", for: .normal)
                    
                }
                
            }
            
        })
        
    }
    
    
    
    
    /* -- FUNCTION FOR CHANGING ICON OF PIN - TODO: FIX THIS SO THAT IT WORKS AND DISPLAYS A CAR IMAGE INSTEAD OF THE RED PIN.
     
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let reuseId = "prius-icon"
        
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView?.image = UIImage(named:"prius-icon")
            anView?.canShowCallout = true
        }
        else {
            anView?.annotation = annotation
        }
        
        return anView
    }
 */

    

 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}











