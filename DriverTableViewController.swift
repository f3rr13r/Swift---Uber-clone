//
//  DriverTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Harry Ferrier on 8/19/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit

// import Parse
import Parse


// make DriverTableViewController conform to the CLLocationManagerDelegate..
class DriverTableViewController: UITableViewController, CLLocationManagerDelegate {

    
    // Create a global instance of a CLLocationManager and initialise it be be empty for now..
    
    var locationManager = CLLocationManager()
    
    
    // Create two arrays to store username and location data for our users, and initialise them as empty arrays for now..
    
    var requestUsernames = [String]()
    
    var requestLocations = [CLLocationCoordinate2D]()
    
    
    // Create a userLocation variable of type CLLocationCoordinate2D and initialise it with latitude and longitude values of 0 and 0.
    
    var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    
    
    // Prepare for segue method which will handle outcome attached to various segues that can be deployed from this page..
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        // If it's the segue attached to logging the user out..
        
        if segue.identifier == "exitAppAsDriver" {
        
            // Do just that..log the user out.
            
            PFUser.logOut()
            
            
            // Hide the navigationController's navigation bar, otherwise it will display the navigationBar on the sign up log in page..
            
            navigationController?.navigationBar.isHidden = true
            
            
            // Stop the locationManager from continuing to update locations..
            
            locationManager.stopUpdatingLocation()
        
            
            
        // If it's the segue that shows the rider's location on a map..
            
        } else if segue.identifier == "showRiderLocationViewController" {
        
            
            // Create a access path into the RiderLocationViewController.
            
            if let destination = segue.destination as? RiderLocationViewController {
            
                // Established the indexPath number associated with the row that the user has clicked on in this page's table view.
                
                if let row = tableView.indexPathForSelectedRow?.row {
                
                    
                    // Assign the value of the requestLocation variable in the RiderLocationViewController to equal to the value stored in the requestLocations array at the indexPath of the row number that the user has clicked..
                    
                    destination.requestLocation = requestLocations[row]
                   
                    
                    // Assign the value of the requestUsername variable in the RiderLocationViewController to equal to the value stored in the requestUsernames array at the indexPath of the row number that the user has clicked..
                    
                    destination.requestUsername = requestUsernames[row]
                    
                }
            
            }
        
        }
        
    }
    
    
    
    // User clicked the logout button..
    
    @IBAction func logout(_ sender: AnyObject) {
        
        // Segue back to the sign up log in page..
        
        performSegue(withIdentifier: "exitAppAsDriver", sender: self)
        
    }
    
    
    
    
    // when the view loads...
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Assign preferred property values to the locationManager, specifying it's delegate and desiredAccuracy..
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request location Geo information for that device when the app is in use by the user.
        locationManager.requestWhenInUseAuthorization()
        
        // Start updatingLocations (handled in the didUpdateLocations method just below...)
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    
    // locationManager's 'didUpdateLocations' method which starts obtaining location information for the user's device...
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        // Attempt to access the device's manager property, it's location and more specificatally, the coordinates of it's location. If we can obtain location coordinate information succesfully...
        
        if let location = manager.location?.coordinate {
            
            // Set the userLocation value to be equal to that location constant established above..
            
            userLocation = location
            
            
            
            // Create a query on the class with the name "DriverLocation"
            
            let driverLocationQuery = PFQuery(className: "DriverLocation")
            
            
            // Specify the criteria that you want instances of data where the value assigned to the key "username" is equal to the username value of the device's current user..
            
            driverLocationQuery.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            
            // Attempt to find data which matches our criteria, handling the return outcomes in a closure...
            
            driverLocationQuery.findObjectsInBackground(block: { (objects, error) in
                
                
                // If data is returned that matches the criteria..
                
                if let driverLocations = objects {
                
                    
                    // Loop through that data...
                    
                        for driverLocation in driverLocations {
                    
                            
                            // Look to see if there is a value assigned to the key "location" which is of type PFGeoPoint, and whose latitude and longitude properties are equal to our current user's latitude and longitude values.. If there are...
                            
                            driverLocation["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        
                            // Delete the row (we do this to avoid duplication of data in our "DriverLocation" class.
                            
                            driverLocation.deleteInBackground()
                        
                    }
                
                }
                
                // Outside of the loop...
                
                // If it doesnt exist, create a new class with the name "Driver Location", if it does already exist, go into it..
                
                let driverLocation = PFObject(className: "DriverLocation")
                
                // Create a new data row inside the class, assigning the value for the key "username" to be equal to the username of the device's current user in the "User" class.
                
                driverLocation["username"] = PFUser.current()?.username
                
                // Also assign the value for the key "location" to be a PFGeoPoint which is created using the latitude and longitude values of our userLocation global variable.
                
                driverLocation["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                
                // Save these new values in the background...
                
                driverLocation.saveInBackground()
                
            })
            
            
            
            
            // Create another fresh query which queries on the class with the name "RiderRequest"
        
            let query = PFQuery(className: "RiderRequest")

            // Specify criteria for the query which takes values for the key "location" are near to our driver's current location, specified by it's latitude and longitude coordinates.
            
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
            
            // Limit the number of the results to 10 to save data..
            
            query.limit = 10
            
            
            
            // Attempt to find objects that match our criteria, and handle the potential outcomes in a closure..
            
            query.findObjectsInBackground(block: { (objects, error) in
                
                
                // If data is returned that matches our criteria...
                
                if let riderRequests = objects {
                    
                    
                    // Empty the global requestUsernames and requestLocations arrays to avoid duplication of information.
                    
                    self.requestUsernames.removeAll()
                    self.requestLocations.removeAll()
                
                    
                    // Loop through the data which has been returned...
                    
                    for riderRequester in riderRequests {
                        
                        
                        // If each of the looped cycle data has a value assigned to the key "username", and it is castable to type of String..
                        
                        if let username = riderRequester["username"] as? String {
                            
                            
                            // If the data does not already have a driver who has responded to their uber request...
                            
                            if riderRequester["driverResponded"] == nil {
                    
                                // Append the value of the username constant to the requestUsernames array.
                                
                                self.requestUsernames.append(username)
                            
                                
                                // And append the CLLocationCoordinate2D value to the requestUsernames array.
                                
                                self.requestLocations.append(CLLocationCoordinate2D(latitude: (riderRequester["location"] as AnyObject).latitude, longitude: (riderRequester["location"] as AnyObject).longitude))
                                
                                
                                // As these are being stored at identical indexPath in seperate arrays, we can always get correct associated data.
                                
                            }
                            
                        }
                    
                    }
                    
                    // Now that we have finished the loop and filled up the requestUsernames and requestLocations arrays accordingly..
                    
                    // Reload the data in the tableView...
                    
                    self.tableView.reloadData()
                
                    
                // If there wasn't any data returned which watched the criteria...
                
                } else {
                
                 //   print("No results")
                
                }
                
            })
        
        }
        
    }
    
    
    
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    // MARK: - Table view data source
    
    // NUMBER OF SECTIONS IN TABLE VIEW...

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // Hard code the number of sections in the tableView to be 1
        
        return 1
    }

    
    
    // NUMBER OF ROWS IN SECTION...
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Specify to the tableView that we would like the same number of rows in our table view as number of values in the requestUsernames array. (We could have easily used requestLocation.count as they will always have the same number of items in, but hey ho!)
        
        return requestUsernames.count
    }

    
    
    // CREATE THE CELL'S TO GO INSIDE OUR TABLE VIEW ROWS...
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // Create an cell and specify that we will be reusing the cell's with the reuserIdentifier "cell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        
        
        // ** Find distance between user location and request locations requestLocations[indexPath.row] **
        
        // Get the driver's location as a CLLocation using the latitude and longitude values from the global userLocation variable
        
        let driverCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        
        // Get the appropriate requested rider's location as a CLLocation by taking the latitude and longitude values stored at the same position as the indexPath number of the row which the user has clicked in the table view.
        
        let riderCLLocation = CLLocation(latitude: requestLocations[indexPath.row].latitude, longitude: requestLocations[indexPath.row].longitude)
        
        
        // Establish the distance between the driver and the rider who have requested an uber using the .distance method. Convert that figure into miles by dividing the figure by 1600.
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1600
        
        // Round the distance to two decimal points using the below equation...
        
        let roundedDistance = round(distance * 100) / 100
        
        
        // Set the cell's textLabel to display the name of the username at the identical indexPath of this row but inside the requestUsernames array and then concatenate the distance which the rider is away using the 'roundedDistance' variable value...
        
        cell.textLabel?.text = requestUsernames[indexPath.row] + " - \(roundedDistance)miles away"
        

        
        
        // Return the cell to satisfy the conditions of the function..
        return cell
    }


}
