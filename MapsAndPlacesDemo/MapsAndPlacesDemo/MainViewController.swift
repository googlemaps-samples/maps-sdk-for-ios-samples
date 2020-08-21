/* Copyright (c) 2020 Google Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import GoogleMaps
import GoogleMapsUtils
import GooglePlaces
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialActionSheet
import MaterialComponents.MaterialBanner
import MaterialComponents.MaterialCards
import MaterialComponents.MaterialSnackbar


/// This struct contains the current location in terms of coordinates and place id
struct CoordinateAndPlaceID {
    private var coord = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
    private var pid: String = "ChIJP3Sa8ziYEmsRUKgyFmh9AQM"
    
    /// Updates the coordinates and pid to a new location
    ///
    /// - Parameters:
    ///   - newCoord: The new coordinates.
    ///   - newPid: The PID associated with the new location.
    mutating func updateIdentifier(newCoord: CLLocationCoordinate2D, newPID: String) {
        coord = newCoord
        pid = newPID
    }
    
    /// Getter method for the coordinates
    func getCoord() -> CLLocationCoordinate2D {
        return coord
    }
    
    /// Getter method for the PID
    func getPID() -> String {
        return pid
    }
}

class GoogleDemoApplicationsMainViewController:
    UIViewController,
    CLLocationManagerDelegate,
    GMUClusterManagerDelegate
{
    /// A view bar that holds the search bar
    @IBOutlet weak var searchView: UIView!
    
    /// The top bar which contains the title and buttons
    @IBOutlet weak var topBar: UIView!
    
    /// Dark mode button and properties; may change depending on the device
    private var darkIconXOffset: CGFloat = 50
    private var darkIconDim: CGFloat = 50
    @IBOutlet weak var darkModeButton: UIButton!
    
    /// Clears all the feature generated markers on the screen
    @IBOutlet weak var clearAllButton: UIButton!
    
    /// The initial zoom value; any change here is universal, so no need to look for zoom values when the app is booted
    private let initialZoom: Float = 10.0
    
    /// Indicates if the traffic map can be seen
    private var trafficToggle = false
    
    /// Indicates if indoor maps should be enabled
    private var indoorToggle = false
    
    /// If on, only one toggle may be on at a time; the offsets set the location of the indicator
    private var independentToggle = false
    
    /// Indicates if the map should be in dark mode
    private var darkModeToggle = false
    
    /// Indicates if the heat map should appear
    private var heatMapToggle = false
            
    /// Switches between a marker and an image
    private var imageOn = false
    
    /// Locks  to combat conflicting features
    private var locked = false
    
    /// The heat map,  its data set, and other color setup
    private let heatMapLayer: GMUHeatmapTileLayer = GMUHeatmapTileLayer()
    private var heatMapPoints = [GMUWeightedLatLng]()
    private let gradientColors = [UIColor.green, UIColor.red]
    private let gradientStartheatMapPoints = [NSNumber(0.2), NSNumber(1.0)]
    
    /// Requests access to the user's location
    private let locationManager = CLLocationManager()
    
    /// The general overlay controller for overlay-related features
    private var overlayController = OverlayController()
    
    /// The outlet to call methods in LocationImageGenerator
    private let locationImageController = LocationImageGenerator()
        
    /// Places client to get data on the iPhone's current location
    private let placesClient: GMSPlacesClient = GMSPlacesClient.shared()
    
    /// The cluster manager for the nearby recommendations feature; clusters icons to reduce clutter
    private var clusterManager: GMUClusterManager!
    
    /// Indepedent features indicator and properies; may change depending on the device
    private let independentIndicator = UIImageView(image: UIImage(systemName: "1.magnifyingglass"))
    private var indicatorXOffset: CGFloat = 57
    private var indicatorYOffset: CGFloat = 851
    private var indicatorDim: CGFloat = 20
    
    /// The zoom of the camera
    private var zoom: Float = 10.0
    
    // The maximum zoom value; useful for indoor maps
    private let maximumZoom: Float = 20.0
    
    /// Sets up the identifier that contains information on where the map should go to
    private var mapsIdentifier = CoordinateAndPlaceID()
    
    /// When the user selects indoor toggle, the map goes to the interior of Sydney Opera House as default
    private let sydneyOperaHouseCoord = CLLocationCoordinate2D(
        latitude: -33.856689,
        longitude: 151.21526
    )
    private let sydneOperaHousePID: String = "ChIJ3S-JXmauEmsRUcIaWtf4MzE"
    
    /// The search bar and autocomplete screen view controller
    private var resultsViewController: GMSAutocompleteResultsViewController?
    private var searchController: UISearchController?
    private var resultView: UITextView?
    
    /// Map setup variables
    private var camera: GMSCameraPosition!
    private var mapView: GMSMapView!
    private var marker: GMSMarker = GMSMarker()
    
    /// Simple UI elements
    @IBOutlet weak private var scene: UIView!
    @IBOutlet weak private var welcomeLabel: UILabel!
    private var clearWidth: CGFloat = 100
    private var clearHeight: CGFloat = 50
    
    /// The map theme (dark mode or light mode); initially set to light mode
    private var mapTheme = MapThemes.lightThemeId
    
    /// Marker storage arrays
    private var nearbyLocationMarkers = [GMSMarker]()
    private var nearbyLocationIDs = [String]()
    private var nearbyLocationImages = [Bool]()
    
    /// Material design elements for UI
    private var actionSheet = MDCActionSheetController(title: "", message: "")
    private let optionsButton = MDCFloatingButton()
    private let zoomInButton = MDCFloatingButton()
    private let zoomOutButton = MDCFloatingButton()
    private let currentLocButton = MDCFloatingButton()
    private let infoButton = MDCFloatingButton()
    private let warningMessage = MDCSnackbarMessage()
    
    // MARK: View controller lifecycle methods

    /// Sets up the initial screen
    override func viewDidLoad() {
        super.viewDidLoad()
        requestAuthorization()
        zoom = initialZoom
        
        // Sets up the map, buttons, and screen
        refreshMap(newLoc: true)
        refreshButtons()
        refreshScreen()
        
        // Heatmap preprocessing, so we don't need to do it whenever it is toggled
        heatMapLayer.map = mapView
        executeHeatMap()
        
        updateActionMenu()
        setUpCluster()
    }
    
    /// Adds the buttons to the MDC action menu
    private func updateActionMenu() {
        let tempText = independentToggle ? "Multiple" : "Independent"
        let independence = MDCActionSheetAction(title: "Show " + tempText + " Features", image: nil, handler: { Void in
            if !self.lockedSnackbar() {
                self.independentToggle = !self.independentToggle
                if self.independentToggle {
                    self.toggleOff()
                }
                self.refreshButtons()
                self.refreshMap(newLoc: false, darkModeSwitch: true)
                self.updateActionMenu()
            }
        })
        let traffic = MDCActionSheetAction(title: "Toggle Traffic Overlay", image: nil, handler: { Void in
            if !self.lockedSnackbar() {
                let darkModeTemp = self.darkModeToggle
                let trafficTemp = self.trafficToggle
                if self.independentToggle {
                    self.toggleOff()
                }
                self.trafficToggle = !trafficTemp
                self.refreshMap(newLoc: false, darkModeSwitch: self.independentToggle && darkModeTemp)
                self.refreshButtons()
            }
        })
        let indoor = MDCActionSheetAction(title: "Toggle Indoor Map", image: nil, handler: { Void in
            if !self.lockedSnackbar() {
                let darkModeTemp = self.darkModeToggle
                let indoorTemp = self.indoorToggle
                if self.independentToggle {
                    self.toggleOff()
                }
                self.indoorToggle = !indoorTemp
                if self.indoorToggle {
                    self.mapsIdentifier.updateIdentifier(
                        newCoord: self.sydneyOperaHouseCoord,
                        newPID: self.sydneOperaHousePID
                    )
                    self.zoom = self.maximumZoom
                }
                self.refreshMap(newLoc: self.indoorToggle, darkModeSwitch: self.independentToggle
                    && darkModeTemp ? true : false)
                self.refreshButtons()
            }
        })
        let likely = MDCActionSheetAction(title: "Show Place Likelihoods", image: nil, handler: { Void in
            if !self.lockedSnackbar() {
                self.findLikelihoods()
            }
        })
        let panorama = MDCActionSheetAction(title: "Show Panoramic View", image: nil, handler: { Void in
            if !self.lockedSnackbar() {
                self.openPanorama()
            }
        })
        let heatMap = MDCActionSheetAction(title: "Toggle Heat Map", image: nil, handler: { Void in
            let heatMapTemp = self.heatMapToggle
            if !self.lockedSnackbar() {
                if self.independentToggle {
                    self.toggleOff()
                }
                self.heatMapToggle = !heatMapTemp
                if self.heatMapToggle {
                    self.heatMapLayer.weightedData = self.heatMapPoints
                    self.heatMapLayer.map = self.mapView
                    self.zoom = 2
                } else {
                    self.heatMapLayer.weightedData = []
                    self.heatMapLayer.map = nil
                }
                self.refreshButtons()
                self.refreshMap(newLoc: false, darkModeSwitch: true)
            }
        })
        let actions: NSMutableArray = [independence, traffic, indoor, panorama, likely, heatMap]
        actionSheet = MDCActionSheetController(title: "", message: "")
        for a in actions {
            actionSheet.addAction(a as! MDCActionSheetAction)
        }
        refreshScreen()
    }
    
    /// Requests the user's location
    private func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: Features for methods and their helper functions
    
    /// Displays a snackbar message if the screen is locked and does nothing otherwise
    ///
    /// - Returns: whether or not the screen is locked
   private func lockedSnackbar() -> Bool {
       if (locked) {
           warningMessage.text = "Please turn off conflicting features first."
           MDCSnackbarManager.show(warningMessage)
       }
       return locked
   }
    
    /// Zooms in when the cluster icons are clicked
    ///
    /// - Parameters:
    ///   - clusterManager: The cluster manager that is being used.
    ///   - cluster: The cluster that was clicked.
    private func clusterManager(
        clusterManager: GMUClusterManager,
        didTapCluster cluster: GMUCluster
    ) {
        let newCamera = GMSCameraPosition.camera(
            withTarget: cluster.position,
            zoom: mapView.camera.zoom + 1
        )
        let update = GMSCameraUpdate.setCamera(newCamera)
        mapView.moveCamera(update)
    }
    
    /// Setup the cluster manager for the nearby recommendations feature
    private func setUpCluster() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(
            mapView: mapView,
            clusterIconGenerator: iconGenerator
        )
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setDelegate(self, mapDelegate: self)
        clusterManager.clearItems()
        for m in nearbyLocationMarkers {
            clusterManager.add(
                POIItem(
                    position: CLLocationCoordinate2DMake(m.position.latitude, m.position.longitude)
                )
            )
        }
    }
    
    /// Parses the dataset and then adds the data to the array; the array is the weighted data for the heatmap
    private func executeHeatMap() {
        do {
            guard let path = Bundle.main.url(forResource: "dataset", withExtension: "json") else {
                print("Data set path error")
                return
            }
            let data = try Data(contentsOf: path)
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            guard let object = json as? [[String: Any]] else {
                print("Could not read the JSON file or file is empty")
                return
            }
            for item in object {
                // Given the way the code parses through the json file, the lat and long can be
                // retrieved via item like a dictionary
                let lat = item["lat"] as? CLLocationDegrees ?? 0.0
                let lng = item["lng"] as? CLLocationDegrees ?? 0.0
                
                // Creates a weighted coordinate for that lat and long; a weighted coordinate is
                // how the heatmap gets different colors
                let coords = GMUWeightedLatLng(
                    coordinate: CLLocationCoordinate2DMake(lat, lng),
                    intensity: 1.0
                )
                heatMapPoints.append(coords)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Activates system-wide dark mode (cloud based)
    ///
    /// - Parameter sender: The UIButton that, when pressed, triggers this function.
    @objc func darkModeActivate(sender: UIButton!) {
        if locked {
            warningMessage.text = "Please turn off conflicting features first."
            MDCSnackbarManager.show(self.warningMessage)
            return
        }
        let tempToggle: Bool = !darkModeToggle
        if independentToggle {
            toggleOff()
        }
        darkModeToggle = tempToggle
        refreshMap(newLoc: false, darkModeSwitch: true)
        refreshScreen()
        refreshButtons()
    }
    
    /// Clears all icon images and overlays
    ///
    /// - Parameter sender: The UIButton that, when pressed, triggers this function.
    @objc func clearAll(sender: UIButton!) {
        if locked {
            warningMessage.text = "Please turn off conflicting features first."
            MDCSnackbarManager.show(self.warningMessage)
            return
        }
        nearbyLocationMarkers.forEach { $0.map = nil }
        nearbyLocationMarkers.removeAll()
        nearbyLocationIDs.removeAll()
        overlayController.clear()
        clusterManager.clearItems()
        refreshButtons()
    }
    
    /// Turns off all toggles and clears the heatmap dataset
    private func toggleOff() {
        trafficToggle = false
        indoorToggle = false
        darkModeToggle = false
        heatMapToggle = false
        heatMapLayer.weightedData = []
        heatMapLayer.map = nil
    }
        
    /// Displays icons and images for elements in the placeLikelihoodList
    private func findLikelihoods() {
        nearbyLocationMarkers.forEach {
            $0.map = nil
        }
        nearbyLocationMarkers.removeAll()
        nearbyLocationIDs.removeAll()
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            guard error == nil else {
                print("Current place error: \(error?.localizedDescription ?? "")")
                return
            }
            guard let placeLikelihoodList = placeLikelihoodList else {
                print("The placeLikelihoodList is possibly nil")
                return
            }
            var counter = 0
            var first = true
            for loc in placeLikelihoodList.likelihoods {
                
                // Need to skip the first element because the first element is the location of the
                // purple marker; the others should be red
                if first {
                    first = false
                    continue
                }
                let temp = GMSMarker()
                temp.position = CLLocationCoordinate2D(
                    latitude: loc.place.coordinate.latitude,
                    longitude: loc.place.coordinate.longitude
                )
                self.nearbyLocationMarkers.append(temp)
                self.nearbyLocationIDs.append(loc.place.placeID!)
                self.nearbyLocationImages.append(false)
            }
            
            // Adds the marker to the cluster manager
            for locationMarker in self.nearbyLocationMarkers {
                locationMarker.map = self.mapView
                self.locationImageController.viewImage(
                    placeId: self.nearbyLocationIDs[counter],
                    localMarker: locationMarker,
                    imageView: UIImageView(),
                    tapped: false
                )
                counter += 1
                self.clusterManager.add(POIItem(
                    position: CLLocationCoordinate2DMake(
                        locationMarker.position.latitude,
                        locationMarker.position.longitude
                    )
                    )
                )
            }
            
            // Zooms in the current location
            self.placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
                guard error == nil && placeLikelihoodList != nil else {
                    print("Current place error: \(error?.localizedDescription ?? "")")
                    return
                }
                guard let place = placeLikelihoodList?.likelihoods.first?.place else {
                    print("Most likely place is possibly nil")
                    return
                }
                self.mapsIdentifier.updateIdentifier(
                    newCoord: CLLocationCoordinate2D(
                        latitude: place.coordinate.latitude,
                        longitude: place.coordinate.longitude
                    ),
                    newPID: place.placeID ?? self.sydneOperaHousePID
                )
                self.zoom = 20
                self.refreshMap(newLoc: true)
                self.refreshButtons()
                self.refreshScreen()
            })
        })
        definesPresentationContext = true
    }
    
    /// General function that takes in a list of markers and sets them to given visibility
    ///
    /// - Parameters:
    ///   - visible: A boolean value that determines if a marker should be shown on the map or not.
    ///   - list: The list of icons to apply visibility to.
    private func iconVisibility(visible: Bool, list: [GMSMarker]) {
        for marker in list {
            marker.map = visible ? mapView : nil
        }
        if !visible && nearbyLocationImages.count > 0 {
            for index in 0...nearbyLocationImages.count - 1 {
                nearbyLocationImages[index] = false
            }
        }
    }
        
    /// Opens up the StreetViewController for panorama viewing
    private func openPanorama() {
        // There shouldn't be the need for an optional for vc, as this is hardcoded to depict
        // StreetViewController
        let vc = storyboard?.instantiateViewController(identifier: "s_vc") as! StreetViewController
        vc.setValues(newCoord: mapsIdentifier.getCoord())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // MARK: App refresh methods; ensures toggles, color schemes, etc are correct
    
    /// Changes the colors of the buttons, search bar, action sheet, and search results view controller (depending on whether or not
    /// dark mode is on) and adds the search bar to the screen
    private func refreshScreen() {
        if independentToggle {
            independentIndicator.isHidden = false
            independentIndicator.frame = CGRect(
                x: view.frame.size.width * 0.9,
                y: view.frame.size.height * 0.05,
                width: indicatorDim,
                height: indicatorDim
            )
            independentIndicator.tintColor = darkModeToggle ? .white : .red
            view.addSubview(independentIndicator)
        } else {
            independentIndicator.isHidden = true
        }
        
        view.addSubview(searchView)

        // Sets up the search bar and results view controller
        view.backgroundColor = darkModeToggle ? .darkGray : .white
        scene.backgroundColor = darkModeToggle ? .darkGray : .white
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        searchController?.searchBar.sizeToFit()
        definesPresentationContext = true
        searchView.addSubview((searchController?.searchBar)!)
        searchController?.searchBar.sizeToFit()
        
        // Changes the results view controller and search bar to be the right color
        resultsViewController?.tableCellSeparatorColor = darkModeToggle ? .black : .white
        resultsViewController?.tableCellBackgroundColor = darkModeToggle ? .black : .white
        resultsViewController?.primaryTextHighlightColor = darkModeToggle ? .white : .black
        resultsViewController?.primaryTextColor = darkModeToggle ? .white : .black
        resultsViewController?.secondaryTextColor = darkModeToggle ? .white : .black
        searchController?.searchBar.barTintColor = darkModeToggle ? .black : .white
        searchController?.searchBar.tintColor = darkModeToggle ? .white : .black
        searchController?.searchBar.backgroundColor = darkModeToggle ? .black : .white
        
        guard let tf = searchController?.searchBar.value(forKey: "searchField") as? UITextField else {
            print("Text field is nil")
            return
        }
        tf.textColor = darkModeToggle ? .white : .black
        
        // Sets other view elements to the right colors
        welcomeLabel.textColor = darkModeToggle ? .white : .black
        view.backgroundColor = darkModeToggle ? .black : .white
        actionSheet.actionTextColor = darkModeToggle ? .white : .black
        actionSheet.actionTintColor = darkModeToggle ? .black : .white
        actionSheet.backgroundColor = darkModeToggle ? .black : .white
        actionSheet.headerDividerColor = darkModeToggle ? .black : .white
        actionSheet.rippleColor = darkModeToggle ? .black : .white
        actionSheet.titleTextColor = darkModeToggle ? .white : .black
        actionSheet.messageTextColor = darkModeToggle ? .white : .black
        
        topBar.backgroundColor = darkModeToggle ? .black : .white
        topBar.tintColor = darkModeToggle ? .black : .white
    }
    
    /// Sets up the functionality and location of the FABs
    private func refreshButtons() {
        darkModeButton.setImage(
            UIImage(systemName: darkModeToggle ? "sun.min.fill" : "moon.stars.fill"),
            for: .normal
        )
        darkModeButton.tintColor = darkModeToggle ? .yellow : .blue
        darkModeButton.addTarget(self, action: #selector(darkModeActivate), for: .touchUpInside)
        darkModeButton.removeFromSuperview()
        topBar.addSubview(darkModeButton)
        darkModeButton.frame = CGRect(
            x: 0,
            y: view.frame.size.height * 0.028,
            width: darkIconDim,
            height: darkIconDim
        )
        topBar.addSubview(clearAllButton)
        clearAllButton.frame = CGRect(
            x: darkIconDim / 2,
            y: view.frame.size.height * 0.028,
            width: darkIconDim,
            height: darkIconDim
        )
        topBar.bringSubviewToFront(clearAllButton)
        welcomeLabel.frame = CGRect(
            x: 0,
            y: view.frame.size.height * 0.028,
            width: view.frame.size.width,
            height: darkIconDim
        )
        clearAllButton.tintColor = .blue
        clearAllButton.isHidden = nearbyLocationMarkers.count == 0
        clearAllButton.addTarget(self, action: #selector(clearAll), for: .touchUpInside)
        
        let buttons = [optionsButton, zoomOutButton, zoomInButton, currentLocButton, infoButton]
        let iconImages = ["gear", "minus", "plus", "location", "info"]
        optionsButton.addTarget(
            self,
            action: #selector(optionsButtonTapped(optionsButton:)),
            for: .touchUpInside
        )
        zoomInButton.addTarget(
            self,
            action: #selector(zoomInButtonTapped(zoomInButton:)),
            for: .touchUpInside
        )
        zoomOutButton.addTarget(
            self,
            action: #selector(zoomOutButtonTapped(zoomOutButton:)),
            for: .touchUpInside
        )
        currentLocButton.addTarget(
            self,
            action: #selector(goToCurrent(currentLocButton:)),
            for: .touchUpInside
        )
        infoButton.addTarget(
            self,
            action: #selector(infoButtonTapped(infoButton:)),
            for: .touchUpInside
        )
        
        // The x-coordinate of the FABs are constant. They are located at 0.85 times the width of
        // the width of view controller (which will change depending on the device) OR 0.1 times
        // the width if we are viewing in indoor mode, since the right hand side contains indoor
        // floor level loggles. The y-coordinate of the bottom-most button (options) will be
        // located at 0.9 times the height of the view controller. To find the y-coordinate of the
        // next button, decrement the y-coordinate by 0.07 times the height of the view controller.
        // This value was found via trial/error.
        var ycoord: Double = Double(self.view.frame.size.height) * 0.9
        let xcoord: Double = Double(self.view.frame.size.width)
            * (indoorToggle && zoom > 16.0 ? -0.8 : 0.8)
        var index: Int = 0
        for button in buttons {
            button.isHidden = false
            button.backgroundColor = darkModeToggle ? .darkGray : .white
            button.setElevation(ShadowElevation(rawValue: 6), for: .normal)
            button.removeFromSuperview()
            view.addSubview(button)
            view.bringSubviewToFront(button)
            button.auto(view: view, xcoord: xcoord, ycoord: ycoord)
            button.setImage(UIImage(systemName: iconImages[index]), for: .normal)
            ycoord -= 0.16 * Double(self.view.frame.size.height)
            index += 1
        }
        //clearAllButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        darkModeButton.isHidden = false
    }
    
    /// Refreshes the map, allowing changes activated by the toggle to be seen
    ///
    /// - Parameters:
    ///   - newLoc: A value that indicates whether or not our map is going to a new location.
    ///   - darkModeSwitch: A value that indicates if we need to flip the theme of the map.
    private func refreshMap(newLoc: Bool, darkModeSwitch: Bool = false) {
        if newLoc {
            imageOn = false
            marker.icon = UIImage(systemName: "button_my_location.png")
            marker.icon = GMSMarker.markerImage(with: .blue)
        }
        switch darkModeToggle {
        case true:
            mapTheme = MapThemes.darkThemeId
        default:
            mapTheme = MapThemes.lightThemeId
        }
        let mapID = GMSMapID(identifier: mapTheme)
        camera = GMSCameraPosition.camera(
            withLatitude: mapsIdentifier.getCoord().latitude,
            longitude: mapsIdentifier.getCoord().longitude,
            zoom: zoom
        )
        
        // This piece of code ensures the map is only reset if needed, as each map reset takes a
        // few seconds and looks bad
        if newLoc {
            isNewLocation()
        }
        
        // Also needs to reset the map if the dark mode toggle is changed, due to a new mapID
        if darkModeSwitch {
            mapView = GMSMapView(frame: self.view.frame, mapID: mapID, camera: camera)
        }
        
        iconVisibility(visible: zoom > 18, list: nearbyLocationMarkers)
        mapView.delegate = self
        mapView.settings.setAllGesturesEnabled(!locked)
        scene.addSubview(mapView)
        view.addSubview(topBar)
        view.sendSubviewToBack(topBar)
        view.sendSubviewToBack(scene)
        
        // Sets the heapmap to appear on the map, but unless the heatmap feature is on, it has no
        // data so it looks empty
        heatMapLayer.map = mapView
        heatMapLayer.gradient = GMUGradient(
            colors: gradientColors,
            startPoints: gradientStartheatMapPoints,
            colorMapSize: 256
        )
        
        mapView.isTrafficEnabled = trafficToggle
        mapView.isIndoorEnabled = indoorToggle
        mapView.isBuildingsEnabled = true
        mapView.isMyLocationEnabled = true
        marker.position = mapsIdentifier.getCoord()
        marker.map = mapView
        resultsViewController?.dismiss(animated: true, completion: nil)
        searchController?.title = ""
        setUpCluster()
    }
    
    /// Animates to the new location or initializes a new mapView
    private func isNewLocation() {
        if mapView == nil {
            mapView = GMSMapView(
                frame: self.view.frame,
                mapID: GMSMapID(identifier: MapThemes.lightThemeId),
                camera: camera
            )
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // MARK: Material Design Floating Action Button trigger functions
    
    /// Opens the Material Design Action Menu that contains some of the features and toggles
    ///
    /// - Parameter optionsButton: The MDCFloatingButton that, when pressed, triggers this function.
    @objc private func optionsButtonTapped(optionsButton: MDCFloatingButton) {
        optionsButton.collapse(true) {
            optionsButton.expand(true, completion: nil)
        }
        present(actionSheet, animated: true, completion: nil)
    }
        
    /// Zooms in and changes zoom variable
    ///
    /// - Parameter zoomInButton: The MDCFloatingButton that, when pressed, triggers this function.
    @objc private func zoomInButtonTapped(zoomInButton: MDCFloatingButton) {
        zoomInButton.collapse(true) {
            zoomInButton.expand(true, completion: nil)
        }
        let zoomCamera = GMSCameraUpdate.zoom(by: locked ? 0.5 : 2.0)
        mapView.moveCamera(zoomCamera)
        zoom = min(mapView.camera.zoom, maximumZoom)
        refreshButtons()
        refreshMap(newLoc: false)
        refreshScreen()
    }
    
    /// Zooms out and changes zoom variable
    ///
    /// - Parameter zoomOutButton: The MDCFloatingButton that, when pressed, triggers this function.
    @objc private func zoomOutButtonTapped(zoomOutButton: MDCFloatingButton) {
        zoomOutButton.collapse(true) {
            zoomOutButton.expand(true, completion: nil)
        }
        let zoomCamera = GMSCameraUpdate.zoom(by: locked ? -0.5 : -2.0)
        mapView.moveCamera(zoomCamera)
        zoom = max(mapView.camera.zoom, 0)
        refreshButtons()
        refreshMap(newLoc: false)
        refreshScreen()
    }
    
    /// Moves the view to the phone's current location
    ///
    /// - Parameter currentLocButton: The MDCFloatingButton that, when pressed, triggers this function.
    @objc private func goToCurrent(currentLocButton: MDCFloatingButton) {
        currentLocButton.collapse(true) {
            currentLocButton.expand(true, completion: nil)
        }
        if locked {
            warningMessage.text = "Please turn off conflicting features first."
            MDCSnackbarManager.show(self.warningMessage)
            return
        }
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            guard error == nil else {
                print("Some error occured: \(error?.localizedDescription ?? "")")
                return
            }
            guard placeLikelihoodList != nil else {
                print("No likely locations: \(error?.localizedDescription ?? "")")
                return
            }
            guard placeLikelihoodList?.likelihoods.first != nil else {
                print("No current place.")
                return
            }
            let place = placeLikelihoodList?.likelihoods.first?.place
            guard place != nil else {
                print("The current place doesn't exist: \(error?.localizedDescription ?? "")")
                return
            }
            self.mapsIdentifier.updateIdentifier(
                newCoord: CLLocationCoordinate2D(
                    latitude: Double(place?.coordinate.latitude ?? 0.0),
                    longitude: Double(place?.coordinate.longitude ?? 0.0)
                ),
                newPID: place?.placeID ?? "None"
            )
            self.refreshMap(newLoc: true)
            self.refreshScreen()
        })
        refreshButtons()
    }
    
    /// Brings up the information view feature
    ///
    /// - Parameter infoButton: The MDCFloatingButton that, when pressed, triggers this function.
    @objc private func infoButtonTapped(infoButton: MDCFloatingButton) {
        infoButton.collapse(true) {
            infoButton.expand(true, completion: nil)
        }
        
        // Like other features, you should not be able access this feature while locked
        if locked {
            warningMessage.text = "Please turn off conflicting features first."
            MDCSnackbarManager.show(warningMessage)
            return
        }
        
        // popOverVC is a temporary storyboard element that I used to present the
        // PopUpViewController the popOverVC needs to send over proper values as well
        let popOverVC = storyboard?.instantiateViewController(withIdentifier: "popup_vc")
            as! PopUpViewController
        popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        popOverVC.update(
            newCoord: mapsIdentifier.getCoord(),
            newPid: mapsIdentifier.getPID(),
            setDarkMode: darkModeToggle
        )
        self.present(popOverVC, animated: true)
    }
}

// MARK: Various helpful extensions

/// Extension for the search view controller and results view controller that deals with user interaction
extension GoogleDemoApplicationsMainViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    /// Changes currentLat and currentLong to reflect the chosen location
    ///
    /// - Parameter place: A GMSPlace identifier of the new location.
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didAutocompleteWith place: GMSPlace) {
        mapsIdentifier.updateIdentifier(
            newCoord: CLLocationCoordinate2D(
                latitude: place.coordinate.latitude,
                longitude: place.coordinate.longitude
            ),
            newPID: place.placeID ?? sydneOperaHousePID
        )
        refreshMap(newLoc: true)
    }
    
    /// Default error message
    ///
    /// - Parameter error: The error that occured.
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                         didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
}

/// Allows the location icons to be clicked
extension GoogleDemoApplicationsMainViewController: GMSMapViewDelegate {
    
    /// Triggers when the user clicks on the marker, starts a query for the image's location
    ///
    /// - Parameter marker: The marker that was clicked.
    /// - Returns: A boolean that indicates everything went well without error
    @objc(mapView:didTapMarker:) func mapView(_: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.position.latitude == mapsIdentifier.getCoord().latitude
            && marker.position.longitude == mapsIdentifier.getCoord().longitude {
            if !imageOn {
                imageOn = true
                locationImageController.viewImage(
                    placeId: mapsIdentifier.getPID(),
                    localMarker: marker,
                    imageView: UIImageView()
                )
            } else {
                marker.icon = UIImage(systemName: "button_my_location.png")
                marker.icon = GMSMarker.markerImage(with: .blue)
                imageOn = false
            }
        } else {
            var index = 0
            for mark in nearbyLocationMarkers {
                if mark.position.latitude == marker.position.latitude
                    && mark.position.longitude == marker.position.longitude {
                    break
                }
                index += 1
            }
            if nearbyLocationImages[index] {
                nearbyLocationImages[index] = false
                marker.icon = UIImage(systemName: "button_my_location.png")
                marker.icon = GMSMarker.markerImage(with: .red)
            } else {
                /*for i in 0...nearbyLocationMarkers.count - 1 {
                    if i == index {
                        continue
                    }
                    nearbyLocationMarkers[i].icon = UIImage(systemName: "button_my_location.png")
                    nearbyLocationMarkers[i].icon = GMSMarker.markerImage(with: .red)
                }*/
                nearbyLocationImages[index] = true
                locationImageController.viewImage(
                    placeId: nearbyLocationIDs[index],
                    localMarker: marker,
                    imageView: UIImageView()
                )
            }
        }
        return true
    }
}
