//
//  RiderLocationViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Harry Ferrier on 8/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

// Import Parse and MapKit.
import Parse
import MapKit


// Specify that the RiderLocationViewController class will conform to the MKMapViewDelegate..
class RiderLocationViewController: UIViewController, MKMapViewDelegate {
    
    
    // Hook up the UIElements as IBOutlets for use within the code..

    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var acceptRequestButton: UIButton!
    
    
    // Create a global requestLocation variable of type CLLocationCoordinate2D. Initialise it with latitude and longitude values of 0 and 0
    
    var requestLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // Create a global requestUsername variable and initialize it to an empty string.
    
    var requestUsername = ""
    
    // ** THESE TWO VARIABLES WILL HAVE THEIR VALUES ASSIGNED DETERMINED ON WHICH ROW THE USER CLICKS IN THE DRIVER TABLE VIEW CONTROLLER. ** - See Line 73 in the DriverTableViewController.swift file..
    
    
    
    
    
    // Accept request button pressed by device user...
    
    @IBAction func acceptRequest(_ sender: AnyObject) {
        
        
        // Create a query of the class with the name "RiderRequest"
        
        let query = PFQuery(className: "RiderRequest")
        
        
        // Specifiy criteria which the query results should meet. We are looking for data associated with row whose "username" value is equal to value currently assigned to the global requestUsername variable (this is determined by which row the user clicks on in the driver table view controller).
        
        query.whereKey("username", equalTo: requestUsername)
        
        
        // Attempt to find objects that match this criteria, and handle the returning outcomes in a closure...
        
        query.findObjectsInBackground { (objects, error) in
            
            
            // If data is returned that matches the specified criteria...
            
            if let riderRequests = objects {
            
                
                // Loop through the data...
                
                for riderRequester in riderRequests {
                
                    
                    // Set a value to the "driverResponded" key which is equal to the username of the device's current user.
                    
                    riderRequester["driverResponded"] = PFUser.current()?.username
                    
                    
                    // Save this change to the Parse database..
                    
                    riderRequester.saveInBackground()
                    
                    
                    
                    // Set up an instance of CLLocation for use withe CLGeocoder below, using the requestLocation's latitude and longitude values to get the rider's location.
                    
                    let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                    
                    
                    // Use CLGeocoder 'reverseGeocodeLocation' method to get the rider's location as an address, and handle the potential return outcomes in a closure...
                    
                    CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                        
                        
                        // If we were successfully able to reverseGeocode the rider's location...
                        
                        if let placemarks = placemarks {
                        
                            
                            // And if it has data assigned to it...(which should be returned as an array of placemarks)
                            
                            if placemarks.count > 0 {
                            
                                
                                // Grab the placemark value at indexPath 0 from the placemarks array..
                                
                                let mkPlacemark = MKPlacemark(placemark: placemarks[0])
                                
                                
                                // Convert it to a mapType...
                                
                                let mapItem = MKMapItem(placemark: mkPlacemark)
                                
                                
                                // Set the mapItem's name as equal to the value of the requestUsername variable. This will be used to get directions on apple maps...
                                
                                mapItem.name = self.requestUsername
                                
                                
                                
                                // Creat a launch options constant whose value is a dictionary with a key of: MKLaunchOptionsDirectionsModeKey, and whose associated value us an MKLaunchOptionsDirectionsMode 'Driving'..
                                
                                // As you can probably guess, these specifies that when apple maps is opened, it will show a sat nav which factors in that the travel type will be driving..
                                
                                let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                
                                
                                // Finally, open in maps method, with the launchOptions specified above..
                                
                                mapItem.openInMaps(launchOptions: launchOptions)
                                
                            
                            }
                        
                        }
                        
                    })
                    
                
                }
            
            }
            
        }
        
    }
    
    
    
    // When the view loads...

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // We want to show the user's location using the blue dot...
        
        map.showsUserLocation = true
        
        
        
        // Put the driver's location on the map, using the normal technique below...
        
        let coordinate = requestLocation
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        map.setRegion(region, animated: true)
        
        
        
        
        // Create an annotation which will show the location of the rider who the driver has accepted the request from..
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        
        annotation.title = requestUsername
        
        map.addAnnotation(annotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
