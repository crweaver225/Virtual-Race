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

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}

class MapViewController: ViewControllerMethods, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var myProgressGraph: UIProgressView!
    
    @IBOutlet weak var oppProgressGraph: UIProgressView!
    
    @IBOutlet weak var totalDistanceLabel: UILabel!
    
    @IBOutlet weak var raceLengthLabel: UILabel!
    
    @IBOutlet weak var myDistanceNumber: UITextView!
    
    @IBOutlet weak var oppDistanceNumber: UITextView!
    
    @IBOutlet weak var myNameTextView: UITextView!
    
    @IBOutlet weak var oppNameTextView: UITextView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func refreshButton(_ sender: AnyObject) {
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.removeOverlays(mapView.overlays)
        self.coords.removeAll()
        self.viewDidLoad()
    }
    
    var coords: [CLLocationCoordinate2D] = []
    
    var distance: Double?
    
    var match: Match!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        
        self.oppDistanceNumber.isHidden = true
        
        self.oppNameTextView.isHidden = true
        
        self.oppProgressGraph.isHidden = true
        
        self.myProgressGraph.isHidden = true
        
        self.activityIndicator.startAnimating()
        
        let date = Date()
        
        let raceCourse = chooseRaceCourse((self.match.raceLocation!))
        
        let startDate = formatDate(self.match.startDate!)
        
        self.drawMap(raceCourse!) { (success) in
            
            self.getDistance(startDate) { (result) in
                
                if self.match.startDate!.compare(date) == ComparisonResult.orderedDescending {
                    self.match.myDistance = 0.0
                } else {
                    if let result = result {
                        self.match.myDistance = result as NSNumber?
                    }
                }
                
                self.processSinglePlayerDistance(startDate, date: date, raceCourse: raceCourse!) { (success) in
                    
                    if self.match.oppID != nil && self.match.oppID != self.match.myID {
                        
                        let defaultContainer = CKContainer.default()
                        
                        let publicDB = defaultContainer.publicCloudDatabase
                        publicDB.fetch(withRecordID: self.match.recordID!) { (record, error) -> Void in
                            
                            guard let record = record else {
                                
                                self.displayAlert("We could not retrieve \(self.match.oppName!)'s information from the server at this time. Please make sure you are currently logged into your iCloud account")
                                
                                self.addPlayerToMap(self.match.oppID!, userDistance: (self.match.oppDistance as? Double)!, raceLocation: raceCourse!)
                                
                                return
                            }
                            
                            if self.match.startDate!.compare(date) == ComparisonResult.orderedDescending {
                                self.match.oppDistance = 0.0
                            } else {
                                if let result = result {
                                    if self.match.initializer == true {
                                        self.match.oppDistance = record.object(forKey: "racerDistance2") as! NSNumber?
                                    } else {
                                        self.match.oppDistance = record.object(forKey: "racerDistance1") as! NSNumber?
                                    }
                                }
                            }

                            self.processMultiplayerDistance(record, date: date){ (success) in
                                
                                self.addPlayerToMap(self.match.oppID!, userDistance: (self.match.oppDistance as? Double)!, raceLocation: raceCourse!)
                                
                                if self.match.initializer == true {
                                    record.setObject(date as CKRecordValue?, forKey: "racerUpdate1")
                                    record.setObject(self.match.myDistance, forKey: "racerDistance1")
                                    
                                } else {
                                    record.setObject(date as CKRecordValue?, forKey: "racerUpdate2")
                                    record.setObject(self.match.myDistance, forKey: "racerDistance2")
                                }
                                
                                self.delegate.stack?.context.perform{
                                    self.delegate.stack?.save()
                                }
                                
                                if isICloudContainerAvailable() {
                            
                                    publicDB.save(record, completionHandler: { (record, error) -> Void in
                                        guard let record = record else {
                                            print("Error saving record: ", error)
                                            return
                                        }
                                    }) 
                                    
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
    
    func processSinglePlayerDistance(_ startDate: String, date: Date, raceCourse: RaceCourses, completionHandler: (_ success: Bool) -> Void) {
        
        let calendar = Calendar.current
        
        let components = (calendar as NSCalendar).components(.day, from: self.match.startDate! as Date, to: date, options: [])
        
        let daysBetween = components.day! + 1
        
        if self.match.myDistance as? Double >= self.distance {
            
            self.match.finished = true
            
            self.match.myDistance = self.distance as NSNumber?
            
            if self.match.oppName == nil {
                self.match.winner = self.match.myName
            }
            
            self.getFinishDate(startDate, distance: (self.match.myDistance as? Double)! / 1609.344) { (result) in
                
                if let result = result {
                    
                    self.match.myFinishDate = result
                    self.match.finishDate = result
                    
                    let components2 = (calendar as NSCalendar).components(.day, from: self.match.startDate! as Date, to: (dateConverter(self.match.myFinishDate!)), options: [])
                    
                    let finishDate = components2.day! + 1
                
                    self.delegate.stack?.context.perform{
                        self.delegate.stack?.save()
                        self.myDistanceNumber.text = "Finished in \(finishDate) days"
                        
                        if self.match.oppID == nil {
                            self.raceLengthLabel.text = "The Race Lasted \(finishDate) Days"
                        }
                    }
                }
            }
        }
        
        performUIUpdatesOnMain{
            
            self.activityIndicator.stopAnimating()
            
            if self.match.startDate!.compare(date) == ComparisonResult.orderedAscending {
                if self.match.finished != true {
                    self.raceLengthLabel.text = "Day \(daysBetween) of the Race"
                } 
            }else {
                self.raceLengthLabel.text = "Race has not started yet"
            }
   
            self.totalDistanceLabel.text = "Race Distance: \(Double(round((100 * (self.distance! / 1609.344))) / 100)) miles"
            
            self.myNameTextView.text = self.match.myName
            
            self.myProgressGraph.isHidden = false
            
            self.myProgressGraph.progress = Float((self.match.myDistance as? Double)! / self.distance!)
            
            if self.match.myFinishDate == nil {
                
                self.myDistanceNumber.text = String("\(Double(round((100 * (self.match.myDistance as! Double / 1609.344))) / 100)) Miles")
                
            } else {
                
                self.myDistanceNumber.text = "Finished: \(self.match.myFinishDate!)"
            }
        }
        
        self.addPlayerToMap((self.match.myID!), userDistance: (self.match.myDistance as? Double)!, raceLocation: raceCourse)
        
        completionHandler(true)
    }
    
    func processMultiplayerDistance(_ record: CKRecord, date: Date, completionHandler: (_ success: Bool) -> Void) {
        
        let calendar = Calendar.current
        
        let components = (calendar as NSCalendar).components(.day, from: self.match.startDate! as Date, to: date, options: [])
        
        let daysBetween = components.day! + 1
        
        if self.match.oppDistance as? Double >= self.distance && self.match.myDistance as? Double >= self.distance {
            
            if self.match.oppFinishDate == nil {
                if match.initializer == true {
                    self.match.oppFinishDate = record.object(forKey: "racerUpdate2") as? String
                } else {
                    self.match.oppFinishDate = record.object(forKey: "racerUpdate1") as? String
                }
            }

            let components1 = (calendar as NSCalendar).components(.day, from: self.match.startDate! as Date, to: (dateConverter(self.match.myFinishDate!)), options: [])
            
            let components2 = (calendar as NSCalendar).components(.day, from: self.match.startDate! as Date, to: dateConverter(self.match.oppFinishDate!), options: [])
            
            let daysOfFinishedRace1 = components1.day! + 1
            
            let daysOfFinishedRace2 = components2.day! + 1
            
            self.match.oppDistance = self.distance as NSNumber?
            
            let myFinishDate = dateConverter(self.match.myFinishDate!)
            
            if myFinishDate.compare(dateConverter(self.match.oppFinishDate!)) == ComparisonResult.orderedAscending {
                
                record.setObject(self.match.myName as CKRecordValue?, forKey: "winner")
                record.setObject(self.match.myFinishDate as CKRecordValue?, forKey: "finishDate")
                
                performUIUpdatesOnMain {
                    self.raceLengthLabel.text = "The Race Lasted \(daysOfFinishedRace2) Days"
                }
                
                self.match.winner = self.match.myName
                
            } else if myFinishDate.compare(dateConverter(self.match.oppFinishDate!)) == ComparisonResult.orderedDescending {
                
                self.match.winner = self.match.oppName
                
                performUIUpdatesOnMain{
                    self.raceLengthLabel.text = "The Race Lasted \(daysOfFinishedRace1) Days"
                }
                
            } else {
                
                if self.match.winner != self.match.myName && self.match.winner != self.match.oppName {
                    
                    self.match.winner = "tie"
                    record.setObject("tie" as CKRecordValue?, forKey: "winner")
                
                    performUIUpdatesOnMain{
                        self.raceLengthLabel.text = "The Race Lasted \(daysOfFinishedRace1) Days"
                    }
                }
            }
            
        } else if self.match.myDistance as? Double >= self.distance && !(self.match.oppDistance as? Double >= self.distance) {
            
            performUIUpdatesOnMain{
                self.raceLengthLabel.text = "Day \(daysBetween) of the Race"
            }
            
            var lastOppUpdate = Date()
            
            if self.match.initializer == true {
                lastOppUpdate = record.object(forKey: "racerUpdate2") as! Date
            } else {
                lastOppUpdate = record.object(forKey: "racerUpdate1") as! Date
            }
            
            if dateConverter(self.match.myFinishDate!).compare(lastOppUpdate) == ComparisonResult.orderedAscending {
                
                record.setObject("true" as CKRecordValue?, forKey: "finished")
                record.setObject(self.match.myName as CKRecordValue?, forKey: "winner")
                record.setObject(self.match.myFinishDate as CKRecordValue?, forKey: "finishDate")

            } else {
                
                self.match.winner = "\(self.match.myName!) has finished, awaiting \(self.match.oppName!) to update before confirmation of victory"
            }
  
        } else if self.match.oppDistance as? Double >= self.distance && !(self.match.myDistance as? Double >= self.distance) {
            
            performUIUpdatesOnMain {
                self.raceLengthLabel.text = "Day \(daysBetween) of the Race"
            }
            
            self.match.finished = true
            self.match.winner = self.match.oppName
            self.match.oppFinishDate = record.object(forKey: "finishDate") as? String
            
        }
    
        performUIUpdatesOnMain{
            
            self.oppNameTextView.text = self.match.oppName
            
            self.oppProgressGraph.progress = Float((self.match.oppDistance as! Double) / self.distance!)
            
            if self.match.oppFinishDate == nil {
                self.oppDistanceNumber.text = String("\(Double(round((100 * (self.match.oppDistance as! Double / 1609.344))) / 100)) Miles")
                print(self.oppDistanceNumber.text)
            } else {
                let components2 = (calendar as NSCalendar).components(.day, from: self.match.startDate! as Date, to: (dateConverter(self.match.oppFinishDate!)), options: [])
                
                let daysOfFinishedRace2 = components2.day! + 1
                
                self.oppDistanceNumber.text = "Finished in \(daysOfFinishedRace2) days"
                
            }
            self.oppDistanceNumber.isHidden = false
            self.oppNameTextView.isHidden = false
            self.oppProgressGraph.isHidden = false
        }
        
        completionHandler(true)
    }
    
    func chooseRaceCourse(_ raceID: String) -> RaceCourses? {

        switch raceID {
            
        case "1":
            let NewYorktoLA = RaceCourses(startingLat: 40.7589, startingLong: -73.9851, endingLat: 34.0522, endingLong: -118.243683, startingTitle: "New York", endingTitle: "Los Angeles", distance: 4476461.0)
            return NewYorktoLA
            
        case "2":
            let CrossTownClassic = RaceCourses(startingLat: 41.8299, startingLong: -87.6338, endingLat: 41.9484, endingLong: -87.6553, startingTitle: "U.S. Cellular Field", endingTitle: "Wrigley Field", distance: 17970.0)
            return CrossTownClassic
            
        case "3":
            let LibertyTrail = RaceCourses(startingLat: 39.9526, startingLong: -75.1652, endingLat: 38.9072, endingLong: -77.0369, startingTitle: "Philadelphia", endingTitle: "Washington D.C.", distance: 224855.0)
            return LibertyTrail
        case "4":
            let mardiShuffle = RaceCourses(startingLat: 30.4583, startingLong: -91.1403, endingLat: 29.9511, endingLong: -90.0715, startingTitle: "Baton Rouge", endingTitle: "New Orleans", distance: 129181.0)
            return mardiShuffle
  
        default:
            print("no race course was choosen in the switch")
        }
        
        return nil
    }
    
    func getDistance(_ startDate: String, completionHandler: @escaping (_ result: Double?) -> Void) {
        
        let newDistance = RetrieveDistance()
        newDistance.getDistance(startDate){ (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    UserDefaults.standard.removeObject(forKey: "Access Token")
                    
                    let controller: MainPageViewController
                    controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                    
                    performUIUpdatesOnMain{
                        self.present(controller, animated: false, completion: nil)
                    }
                    
                } else if error as? Int == 001 {
                    
                    self.displayAlert("No internet connection")
                    
                    completionHandler(nil)
                    
                }else {
                    
                    self.displayAlert("There was a problem accessing the fitbit servers. Unable to update your progress at this time")
                    
                    completionHandler(nil)
                }
                return
            }

            let finalDistance = result! * 1609.344
            
            completionHandler(finalDistance)
        }
    }
    
    func getFinishDate(_ startDate: String, distance: Double, completionHandler: @escaping (_ result: String?) -> Void) {
        
        let newDistance = RetrieveDistance()
        newDistance.getFinishDate(distance, date: startDate) { (result, error) in
            
            guard (error == nil) else {
                
                if error as? Int == 401 {
                    
                    UserDefaults.standard.removeObject(forKey: "Access Token")
                    
                    let controller: MainPageViewController
                    controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
                    
                    performUIUpdatesOnMain{
                        self.present(controller, animated: false, completion: nil)
                    }
                    
                } else if error as? Int == 001 {
                    
                    self.displayAlert("No internet connection")
                    
                    completionHandler(nil)
                    
                } else {
                    
                    self.displayAlert("There was a problem accessing the fitbit servers. Unable to update your progress at this time")
                    
                    completionHandler(nil)
                }
                
                return
            }

            completionHandler(result!)
        }
    }
    
    func drawMap(_ raceCourse: RaceCourses, completionHandler: @escaping (_ success: Bool) -> Void) {
        
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
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    self.displayAlert(error.localizedDescription)
                }
                return
            }
            
            var route = MKRoute()
            
            for i in response.routes {
                if i.distance == self.chooseRaceCourse(self.match.raceLocation!)?.distance {
                    route = i
                    break
                } else {
                     route = response.routes[0]
                }
            }
            
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            self.distance = route.distance
            
            var rect = route.polyline.boundingMapRect
           
            rect.size.width += 10000
            rect.origin.x += -5000
           
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
            
            var coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: route.polyline.pointCount)
            route.polyline.getCoordinates(coordsPointer, range: NSMakeRange(0, route.polyline.pointCount))
            
            for i in 0..<route.polyline.pointCount {
                self.coords.append(coordsPointer[i])
            }
            completionHandler(true)
        }
    }

    func addPlayerToMap(_ userID: String, userDistance: Double, raceLocation: RaceCourses) {
        
        var currentDistance = 0.0
        
        var lastLocation = CLLocationCoordinate2D(latitude: raceLocation.startingLat, longitude: raceLocation.startingLong)
        
        for coordinate in self.coords {
            if currentDistance < userDistance {
                currentDistance += self.distance(lastLocation, to: coordinate)
                lastLocation = coordinate
            }
            else if currentDistance >= self.distance {
                print(currentDistance)
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
    
    func distance(_ from: CLLocationCoordinate2D, to:CLLocationCoordinate2D) -> CLLocationDistance {
        
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        
        return from.distance(from: to)
    }
    
    
    func displayICloudError() {
        
        let iCloudAlert = UIAlertController(title: "Warning", message: "Your IOS device must be signed into an iCloud account to participate in multiplayer races. Exit the Virtual Race app > go to settings > sign into your iCloud > make sure Virtual Race has permission to use your iCloud account in the iCloud Drive settings. Virtual Race will not store any data on a user's personal iCloud accounts.", preferredStyle: UIAlertControllerStyle.alert)
        
        iCloudAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        performUIUpdatesOnMain{
            self.present(iCloudAlert, animated: true, completion: nil)
        }
    }
    
    func refreshToken() {
        UserDefaults.standard.set(nil, forKey: "Access Token")
        
        let controller: MainPageViewController
        controller = self.storyboard!.instantiateViewController(withIdentifier: "MainPageViewController") as! MainPageViewController
        
        performUIUpdatesOnMain{
            self.present(controller, animated: false, completion: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let raceCourse = chooseRaceCourse((self.match.raceLocation!))
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        
        switch String(describing: annotation.title!) {
            
        case String(describing: raceCourse?.startingTitle):
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
        case String(describing: raceCourse?.endingTitle):
            
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
        case String(describing: self.match.myID):
            
            pinView!.image = UIImage(data: self.match.myAvatar! as! Data)
            pinView?.frame = (frame: CGRect(x: 20, y: 30, width: 30, height: 30))
            pinView!.layer.borderWidth = 1.0
            pinView!.layer.masksToBounds = false
            pinView!.layer.borderColor = UIColor.white.cgColor
            pinView!.layer.cornerRadius = pinView!.frame.size.width/2
            pinView!.clipsToBounds = true
            
        case String(describing: self.match.oppID):
            
            pinView!.image = UIImage(data: self.match.oppAvatar! as! Data)
            pinView?.frame = (frame: CGRect(x: 20, y: 30, width: 30, height: 30))
            pinView!.layer.borderWidth = 1.0
            pinView!.layer.masksToBounds = false
            pinView!.layer.borderColor = UIColor.white.cgColor
            pinView!.layer.cornerRadius = pinView!.frame.size.width/2
            pinView!.clipsToBounds = true
            
        default:
            print("Unable to make map pin")
        }
        
        return pinView!
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }

}
