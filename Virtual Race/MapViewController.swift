//
//  MapViewController.swift
//  Virtual Race
//
//  Created by Christopher Weaver on 9/2/16.
//  Copyright © 2016 Christopher Weaver. All rights reserved.
//

import Foundation
import MapKit
import CoreData
import CloudKit


class MapViewController: UIViewController, MKMapViewDelegate {
    
    var coords: [CLLocationCoordinate2D] = []
    
    var distance: Double?
    
    var match = Match!()
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var myProgressGraph: UIProgressView!
    
    @IBOutlet weak var oppProgressGraph: UIProgressView!
    
    @IBOutlet weak var totalDistanceLabel: UILabel!
    
    @IBOutlet weak var raceLengthLabel: UILabel!
    
    @IBOutlet weak var myDistanceNumber: UITextView!
    
    @IBOutlet weak var oppDistanceNumber: UITextView!
    
    @IBOutlet weak var myNameTextView: UITextView!
    
    @IBOutlet weak var oppNameTextView: UITextView!
    
    @IBAction func refreshButton(sender: AnyObject) {
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.removeOverlays(mapView.overlays)
        self.coords.removeAll()
        self.viewDidLoad()
    }
    
    func chooseRaceCourse(raceID: String) -> RaceCourses? {
        
        switch raceID {
            
        case "1":
        let NewYorktoLA = RaceCourses(startingLat: 40.7589, startingLong: -73.9851, endingLat: 34.0522, endingLong: -118.243683, startingTitle: "New York", endingTitle: "Los Angeles")
            return NewYorktoLA
        
        case "2":
            let ShermansMarch = RaceCourses(startingLat: 33.7490, startingLong: -84.3880, endingLat: 32.002512, endingLong: -81.153557, startingTitle: "Atlanta, GA", endingTitle: "Savannah, GA")
            return ShermansMarch
            
        case "3":
            let LibertyTrail = RaceCourses(startingLat: 39.9526, startingLong: -75.1652, endingLat: 38.9072, endingLong: -77.0369, startingTitle: "Philadelphia", endingTitle: "Washington D.C.")
            return LibertyTrail
            
        default:
            print("no race course was choosen in the switch")
        }
        
        return nil
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let raceCourse = chooseRaceCourse(self.match.raceLocation!)

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
 
        switch String(annotation.title!) {
              
            case String(raceCourse?.startingTitle):
                
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            case String(raceCourse?.endingTitle):
                
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            case String(self.match.myID):
            
                pinView!.image = UIImage(data: self.match.myAvatar!)
                pinView?.frame = (frame: CGRectMake(20, 30, 30, 30))
                pinView!.layer.borderWidth = 1.0
                pinView!.layer.masksToBounds = false
                pinView!.layer.borderColor = UIColor.whiteColor().CGColor
                pinView!.layer.cornerRadius = pinView!.frame.size.width/2
                pinView!.clipsToBounds = true
 
            case String(self.match.oppID):
                
                pinView!.image = UIImage(data: self.match.oppAvatar!)
                pinView?.frame = (frame: CGRectMake(20, 30, 30, 30))
                pinView!.layer.borderWidth = 1.0
                pinView!.layer.masksToBounds = false
                pinView!.layer.borderColor = UIColor.whiteColor().CGColor
                pinView!.layer.cornerRadius = pinView!.frame.size.width/2
                pinView!.clipsToBounds = true

            default:
                
                print("Unable to make map pin")
            }
        
        return pinView!
    }

    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.redColor()
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func processSinglePlayerDistance(startDate: String, date: NSDate, raceCourse: RaceCourses, completionHandler: (success: Bool) -> Void) {
        
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([.Day], fromDate: self.match.startDate!, toDate: date, options: [])
        
        let daysBetween = components.day + 1
        
        if self.match.myDistance as? Double >= self.distance {
            
            self.match.finished = true
            self.match.winner = self.match.myName
            self.match.myDistance = self.distance
            
            self.getFinishDate(startDate, distance: (self.match.myDistance as? Double)! / 1609.344) { (result) in
                
                if let result = result {
                    
                    self.match.myFinishDate = result
                    self.match.finishDate = result
                
                    self.delegate.stack?.context.performBlock{
                        self.delegate.stack?.save()
                    }
                }
            }
        }
        
        performUIUpdatesOnMain{
            
            print(self.match.startDate)
            print(date)
            
            if self.match.startDate!.compare(date) == NSComparisonResult.OrderedAscending {
                self.raceLengthLabel.text = "Day \(daysBetween) of the Race"
            } else {
                self.raceLengthLabel.text = "Race has not started yet"
            }
   
            self.totalDistanceLabel.text = "Race Distance: \(Double(round((100 * (self.distance! / 1609.344))) / 100)) miles"
            
            self.myNameTextView.text = self.match.myName
            
            self.myProgressGraph.progress = Float((self.match.myDistance as? Double)! / self.distance!)
            
            if self.match.myFinishDate == nil {
                
                self.myDistanceNumber.text = String("\(Double(round((100 * (self.match.myDistance as! Double / 1609.344))) / 100)) Miles")
                
            } else {
                
                self.myDistanceNumber.text = "Finish Date: \(self.match.myFinishDate!)"
            }
        }
        
        self.addPlayerToMap(self.match.myID!, userDistance: (self.match.myDistance as? Double)!, raceLocation: raceCourse)
        
        completionHandler(success: true)
    }
    
    func processMultiplayerDistance(record: CKRecord, completionHandler: (success: Bool) -> Void) {
        
        if self.match.oppDistance as? Double >= self.distance && self.match.myDistance as? Double >= self.distance {
            
            self.match.oppDistance = self.distance
            
            let myFinishDate = dateConverter(self.match.myFinishDate!)
            
            let oppFinishDate = dateConverter((record.objectForKey("finishDate") as! String))
            
            if myFinishDate.compare(oppFinishDate) == NSComparisonResult.OrderedAscending {
                
                record.setObject(self.match.winner, forKey: "winner")
                record.setObject(self.match.myFinishDate, forKey: "finishDate")
                
            } else if myFinishDate.compare(oppFinishDate) == NSComparisonResult.OrderedDescending {
                
                self.match.winner = self.match.oppName
                self.match.oppFinishDate = record.objectForKey("finishDate") as? String
                
            } else {
                
                self.match.winner = "tie"
                record.setObject("tie", forKey: "winner")
            }
            
        } else if self.match.winner == self.match.myName {
            
            let lastOppUpdate = record.objectForKey("u" + self.match.oppID!) as? NSDate
            
            if dateConverter(self.match.myFinishDate!).compare(lastOppUpdate!) == NSComparisonResult.OrderedAscending {
                
                record.setObject("true", forKey: "finished")
                record.setObject(self.match.winner, forKey: "winner")
                record.setObject(self.match.myFinishDate, forKey: "finishDate")
                
            } else {
                
                self.match.winner = "\(self.match.myName!) has finished, awaiting \(self.match.oppName!) to update before confirmation of victory"
            }
  
        } else if self.match.oppDistance as? Double >= self.distance {
            self.match.finished = true
            self.match.winner = self.match.oppName
            self.match.oppFinishDate = record.objectForKey("finishDate") as? String
            
        }
    
        let calculatedDistance = Double(round((100 * (self.match.oppDistance as! Double / 1609.344))) / 100)
        
        performUIUpdatesOnMain{
            
            self.oppNameTextView.text = self.match.oppName
            
            self.oppProgressGraph.progress = Float((self.match.oppDistance as? Double)! / self.distance!)
            
            if self.match.oppFinishDate == nil {
                self.oppDistanceNumber.text = String("\(Double(round((100 * (self.match.oppDistance as! Double / 1609.344))) / 100)) Miles")
            } else {
                self.oppDistanceNumber.text = "Finish Date: \(self.match.oppFinishDate!)"
            }
            
            self.oppDistanceNumber.hidden = false
            self.oppNameTextView.hidden = false
            self.oppProgressGraph.hidden = false
        }
        
        completionHandler(success: true)
    }
    
    
    override func viewDidLoad() {

        self.oppDistanceNumber.hidden = true
        
        self.oppNameTextView.hidden = true
        
        self.oppProgressGraph.hidden = true
        
        let date = NSDate()
        
        let raceCourse = chooseRaceCourse(self.match.raceLocation!)
        
        let startDate = formatDate(self.match.startDate!)
        
        self.drawMap(raceCourse!) { (success) in
            
                self.getDistance(startDate) { (result) in
                    
                    if self.match.startDate!.compare(date) == NSComparisonResult.OrderedDescending {
                        self.match.myDistance = 0.0
                    } else {
                        if let result = result {
                            self.match.myDistance = result
                        }
                    }
                    
                    self.processSinglePlayerDistance(startDate, date: date, raceCourse: raceCourse!) { (success) in
                        
                        if self.match.oppID != nil && self.match.oppID != self.match.myID {
                            
                            let defaultContainer = CKContainer.defaultContainer()
                            
                            let publicDB = defaultContainer.publicCloudDatabase
                            publicDB.fetchRecordWithID(self.match.recordID!) { (record, error) -> Void in
                                
                                guard let record = record else {
                                    
                                    self.displayAlert("We could not retrieve \(self.match.oppName!)'s information form the server at this time. Please make sure you are currently logged into your iCloud account")
                                    
                                    self.addPlayerToMap(self.match.oppID!, userDistance: (self.match.oppDistance as? Double)!, raceLocation: raceCourse!)
                                    
                                    return
                                }
                                
                                self.match.oppDistance = record.objectForKey("d" + self.match.oppID!) as? Double
                                
                                self.processMultiplayerDistance(record){ (success) in
                                    
                                    self.addPlayerToMap(self.match.oppID!, userDistance: (self.match.oppDistance as? Double)!, raceLocation: raceCourse!)
                                    
                                    
                                    record.setObject(date, forKey: "u" + self.match.myID!)
                                
                                    self.delegate.stack?.context.performBlock{
                                        self.delegate.stack?.save()
                                    }
                                
                                if isICloudContainerAvailable() {
                                    
                                    record.setObject(self.match.myDistance, forKey: "d" + self.match.myID!)
                                    
                                    publicDB.saveRecord(record) { (record, error) -> Void in
                                        guard let record = record else {
                                            print("Error saving record: ", error)
                                            return
                                        }
                                    }
                                    
                                } else {
                                    
                                    self.displayICloudError()
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    func getDistance(startDate: String, completionHandler: (result: Double?) -> Void) {
        
        let newDistance = RetrieveDistance()
        newDistance.getDistance(startDate){ (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "Access Token")
                    
                    let controller: LoginWebViewController
                    controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginWebViewController") as! LoginWebViewController
                    
                    performUIUpdatesOnMain{
                        self.presentViewController(controller, animated: false, completion: nil)
                    }
                    
                } else if error as? Int == 001 {
                    
                    self.displayAlert("No internet connection")
                    
                    completionHandler(result: nil)
                    
                }else {
                    
                    self.displayAlert("There was a problem accessing the fitbit servers. Unable to update your progress at this time")
                    
                    completionHandler(result: nil)
                }
                return
            }

            let finalDistance = result! * 1609.344
            
            completionHandler(result: finalDistance)
        }
    }
    
    func getFinishDate(startDate: String, distance: Double, completionHandler: (result: String?) -> Void) {
        
        let newDistance = RetrieveDistance()
        newDistance.getFinishDate(distance, date: startDate) { (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "Access Token")
                    
                    let controller: LoginWebViewController
                    controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginWebViewController") as! LoginWebViewController
                    
                    performUIUpdatesOnMain{
                        self.presentViewController(controller, animated: false, completion: nil)
                    }
                    
                } else if error as? Int == 001 {
                    
                    self.displayAlert("No internet connection")
                    
                    completionHandler(result: nil)
                    
                } else {
                    
                    self.displayAlert("There was a problem accessing the fitbit servers. Unable to update your progress at this time")
                    
                    completionHandler(result: nil)
                }
                
                return
            }

            completionHandler(result: result!)
        }
    }
    
    func drawMap(raceCourse: RaceCourses, completionHandler: (success: Bool) -> Void) {
        
        self.mapView.delegate = self
        
        let sourceLocation = CLLocationCoordinate2D(latitude: (raceCourse.startingLat), longitude: (raceCourse.startingLong))
        let destinationLocation = CLLocationCoordinate2D(latitude: (raceCourse.endingLat), longitude:(raceCourse.endingLong))
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = raceCourse.startingTitle
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = raceCourse.endingTitle
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .Automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculateDirectionsWithCompletionHandler {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    self.displayAlert(error.localizedDescription)
                }
                return
            }
            
            let route = response.routes[0]
        
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.AboveRoads)
            
            self.distance = route.distance
            
            var rect = route.polyline.boundingMapRect
           
            rect.size.width += 10000
            rect.origin.x += -5000
           
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            
            var coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.alloc(route.polyline.pointCount)
            route.polyline.getCoordinates(coordsPointer, range: NSMakeRange(0, route.polyline.pointCount))
            
            for i in 0..<route.polyline.pointCount {
                self.coords.append(coordsPointer[i])
            }
            completionHandler(success: true)
        }
    }

    func addPlayerToMap(userID: String, userDistance: Double, raceLocation: RaceCourses) {
        
        var currentDistance = 0.0
        
        var lastLocation = CLLocationCoordinate2D(latitude: raceLocation.startingLat, longitude: raceLocation.startingLong)
        
        for coordinate in self.coords {
            if currentDistance < userDistance {
                currentDistance += self.distance(lastLocation, to: coordinate)
                lastLocation = coordinate
            }
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = lastLocation
        annotation.title = userID
        
        performUIUpdatesOnMain{
        self.mapView.addAnnotation(annotation)
        }
    }
    
    func distance(from: CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> CLLocationDistance {
        
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        return from.distanceFromLocation(to)
    }
    
    
    func displayICloudError() {
        
        let iCloudAlert = UIAlertController(title: "Warning", message: "Your IOS device must be signed into an iCloud account to participate in multiplayer races. Exit the Virtual Race app > go to settings > sign into your iCloud > make sure Virtual Race has permission to use your iCloud account in the iCloud Drive settings. Virtual Race will not store any data on a user's personal iCloud accounts.", preferredStyle: UIAlertControllerStyle.Alert)
        
        iCloudAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
        performUIUpdatesOnMain{
            self.presentViewController(iCloudAlert, animated: true, completion: nil)
        }
    }
    
    func refreshToken() {
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "Access Token")
        
        let controller: LoginWebViewController
        controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginWebViewController") as! LoginWebViewController
        
        performUIUpdatesOnMain{
            self.presentViewController(controller, animated: false, completion: nil)
        }
    }
    
    func displayAlert(text: String) {
        
        let networkAlert = UIAlertController(title: "Warning", message: text, preferredStyle: UIAlertControllerStyle.Alert)
        
        networkAlert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        
        self.presentViewController(networkAlert, animated: true, completion: nil)
    }
}