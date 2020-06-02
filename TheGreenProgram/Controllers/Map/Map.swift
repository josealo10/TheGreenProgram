//
//  Copyright © 2018 Shin Yamamoto. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps


class Map: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    var signUpMode: Bool = false
    var urlLocation: String = "https://thegreenmarket.tk/api/accounts/location"
    let cartUrl: String = "https://thegreenmarket.tk/api/shopping-cart"
    var locationManager = CLLocationManager()
    var placesClient: GMSPlacesClient!
    
    var camera:GMSCameraPosition!
    var mapView:GMSMapView!
    
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    static var signUpMode = false
    
    //MARK:- Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        mapView = GMSMapView(frame: self.view.bounds)
        view.addSubview(mapView)
        setPinMap()
        checkLocationServices()
        placesClient = GMSPlacesClient.shared()
        configureSearch()
        configurateNavigationBar()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //MARK:-Functions
    func configureSearch(){
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self

        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.searchController = searchController

        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true

        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    
    func configurateNavigationBar(){
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primaryTextColor]
        navBarAppearance.backgroundColor = .colorPrimary
        navigationItem.standardAppearance = navBarAppearance
        navigationItem.scrollEdgeAppearance = navBarAppearance
    }
    
    @IBAction func confirmBtn(_ sender: Any) {
        let latitude = mapView.camera.target.latitude
        let longitude = mapView.camera.target.longitude
        let address = findAddres(latitude: latitude, longitude: longitude)
        
        if Map.signUpMode{
            Profile.latitude = latitude
            Profile.longitude = longitude
            Profile.address = address
            self.navigationController?.popViewController(animated: true)
        }
        else{
            if setAddress(latitude: latitude, longitude: longitude, address: address){
                Deals.locationHasChange = true
                Categories.locationHasChange = true
                self.navigationController?.popViewController(animated: true)
            }else{
                Alert.showDecitionAlert(
                    on: self,
                    with: "Must clean cart to change location",
                    message: "We don't deliver in the new location the products you have currently in your cart",
                    acceptTitle:"Clean cart",
                    acceptHandler: {
                        RequestManager().makeRequestWithBody(on:self, url: self.cartUrl, headers: [], params: [:], method: "DELETE", body: [:], withSemaphore: true)
                        let _ = self.setAddress(latitude: latitude, longitude: longitude, address: address)
                        self.navigationController?.popViewController(animated: true)
                    },
                    cancelTitle:"Cancel", cancelHandler: {})
            }
        }
    }
    
    func setPinMap(){
        let img = UIImageView()
        img.image = UIImage(systemName: "mappin")
        img.translatesAutoresizingMaskIntoConstraints = false
        img.contentMode = .scaleAspectFit
        view.addSubview(img)
        
        img.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -20).isActive = true
        img.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
        img.heightAnchor.constraint(equalToConstant: 40).isActive = true
        img.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
    }
    //MARK:- Requests
    func findAddres(latitude:Double, longitude:Double)->String{
        var address = ""
        let request = RequestManager().getRequest(
            url: "https://maps.googleapis.com/maps/api/geocode/json",
            headers: [],
            params: ["latlng":String(latitude) + "," + String(longitude),
                     "key":"AIzaSyAxBMhomUknxqnPM4MVlaLohCIXWCoUwUM"],
            method: "GET")
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(GeoResponse.self, from: data)
                    address = response.results?[0].formatted_address ?? "No address"
                    semaphore.signal()
                } catch {
                    print("Error al parcear",error)
                    semaphore.signal()
                }
            }
            if let error = error{
                DispatchQueue.main.async {
                    Alert.showBasicAlert(on: self, with: "Error", message: "\(error.localizedDescription)")
                }
                semaphore.signal()

            }
            }.resume()
        semaphore.wait()
        
        return address
    }
    
    func setAddress(latitude:Double, longitude:Double, address:String)->Bool{
        
        let request = RequestManager().getRequestWithBody(
            url: self.urlLocation,
            headers: [],
            params: [:],
            method: "PUT",
            body: [
                "latitude":String(latitude),
                "longitude": String(longitude),
                "address": address
            ])
        var flag = false
        let semaphore = DispatchSemaphore(value: 0)
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let str = String(data: data, encoding: .utf8)
                    print(str)
                    let response = try JSONDecoder().decode(LocationResponse.self, from: data)
                    flag = response.success ?? false
                    if flag {
                        Profile.latitude = latitude
                        Profile.longitude = longitude
                        Profile.address = address
                    }
                    semaphore.signal()
                } catch {
                    print("Error al parcear",error)
                    semaphore.signal()
                }
            }
            if let error = error{
                DispatchQueue.main.async {
                    Alert.showBasicAlert(on: self, with: "Error", message: "\(error.localizedDescription)")
                }
                semaphore.signal()

            }
            }.resume()
        semaphore.wait()
        
        return flag
    }
    
    func findCoordinates(placeID:String){
        var latitude:Double = 0
        var longitude:Double = 0
        
        let fields: GMSPlaceField = GMSPlaceField(rawValue:
          UInt(GMSPlaceField.placeID.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue))!
            
        placesClient?.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil, callback: {
          (place: GMSPlace?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
          }
          if let place = place {
            latitude = place.coordinate.latitude
            longitude = place.coordinate.longitude
            self.camera = GMSCameraPosition.camera(
                withLatitude: latitude,
                longitude: longitude,
                zoom: 16
            )
            self.mapView.camera = self.camera
          }
        })
    }
    
    //MARK:-Location stuff
    let regionInMeters: Double = 1000
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            Alert.showBasicAlert(on: self, with: "Location services off", message: "Please enable location services to use the app")
        }
    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            centerViewOnUserLocation()
        case .denied:
            Alert.showBasicAlert(on: self, with: "Enable permission", message: "Please go to settings to enable location")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            Alert.showBasicAlert(on: self, with: "Enable permission", message: "Please go to settings to enable location")
            break
        case .authorizedAlways:
            centerViewOnUserLocation()
        @unknown default:
            break
        }
    }
    
    func centerViewOnUserLocation() {
        locationManager.startUpdatingLocation()
        let location = CLLocationCoordinate2D(
            latitude: (locationManager.location?.coordinate.latitude)!,
            longitude: (locationManager.location?.coordinate.longitude)!)
        
        camera = GMSCameraPosition.camera(withTarget: location, zoom: 16)
        
        mapView.camera = camera
        mapView.isMyLocationEnabled = true
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationServices()
    }

}

// Handle the user's selection.
extension Map: GMSAutocompleteResultsViewControllerDelegate {
  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didAutocompleteWith place: GMSPlace) {
    searchController?.isActive = false
    // Do something with the selected place.
    findCoordinates(placeID: place.placeID ?? "")
  }

  func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didFailAutocompleteWithError error: Error){
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(forResultsController resultsController: GMSAutocompleteResultsViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}
