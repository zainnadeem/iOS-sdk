//
//  NEWMFTMarker.swift
//  iOS.SDK
//
//  Created by Zain N. on 12/19/17.
//  Copyright © 2017 Mapfit. All rights reserved.
//

import Foundation
import TangramMap
import CoreLocation

/**
 `MFTMarker` A marker is an icon placed at a particular position on the map.
 */


@objc(MFTMarkerOptions)
public class MFTMarkerOptions : NSObject{
    //set width of the marker -- pixels
    public var width: Int
    //set height of the marker -- pixels
    public var height: Int
    //Marker for map options
    internal var marker: MFTMarker
   // Sets the draw order for the marker. The draw order is relative to other annotations. Note that higher values are drawn above lower ones.
    public var drawOrder: Int
    
    /**
     Sets the height for the marker icon.
     
     - parameter height: height of marker icon.
     */
    public func setHeight(height: Int){
        self.height = height
        marker.setStyle()
    }
    
    /**
     Sets the width for the marker icon.
     
     - parameter width: width of marker icon.
     */
    
    public func setWidth(width: Int){
        self.width = width
        marker.setStyle()
    }
    /**
     Sets the color for the marker icon.
     
     - parameter color: color of marker icon.
     */
    
    public func setDrawOrder(drawOrder: Int){
        marker.tgMarker?.drawOrder = drawOrder
        marker.setStyle()
    }
    /**
     Sets the color for the marker icon.
     
     - parameter color: color of marker icon.
     */

   
    //Default Init
    internal init(_ marker: MFTMarker) {
        height = 59
        width = 55
        drawOrder = 2000
        self.marker = marker
        super.init()
    }
}



@objc(MFTMarker)
public class MFTMarker : NSObject, MFTAnnotation {

    public var uuid: UUID
    public var mapView = MFTMapView()
    
    /**
     Title of Marker.
     */
    
    lazy public var title: String = ""
    
    /**
     First subtitle for Marker.
     */
    
    lazy public var subtitle1: String = ""
    
    /**
     Second subtitle for Marker.
     */
    
    lazy public var subtitle2: String = ""
    
    internal var subAnnotation: MFTAnnotation?
    
    internal var tgMarker: TGMarker?  {
        didSet {
            tgMarker?.visible = isVisible
            tgMarker?.point = TGGeoPoint(coordinate: position)
            
            setStyle()
        }
        
    }
    
    /**
     Options used to set style for marker.
     */
    
    
    public var markerOptions: MFTMarkerOptions? {
        didSet {
            setStyle()
        }
    }
    
    /**
     Initial style set for marker.
     */
    
    public var style: MFTAnnotationStyle {
        didSet {
            setStyle()
        }
    }
    
    /**
     Visibility of marker. Can only be changed by calling 'setVisibility(show: Bool)'.
     */
    
    public var isVisible: Bool
    

    /**
     Position of marker. Can only be changed by calling 'setPosition(position: CLLocationCoordinate2D)'.
     */

    public var position: CLLocationCoordinate2D
    
    
    /**
     Icon of marker. Can only be changed by calling one of the 'setIcon' methods.
     */
    public var icon: UIImage?

    /**
     Changes the coordinate of the marker.
     - parameter position: The coordinate of the marker.
     */

    private var workItem: DispatchWorkItem?
    
    public func setPosition(_ position: CLLocationCoordinate2D){
        self.position = position
        tgMarker?.point = TGGeoPoint(coordinate: position)
    }
    
    /**
     Returns the coordinate of the marker.
     - returns: The coordinate of the marker.
     */
    
    public func getPosition()->CLLocationCoordinate2D{
        return position
    }
    
    internal func getScreenPosition()->CGPoint {
        return self.mapView.mapView.lngLat(toScreenPosition: TGGeoPointMake(self.getPosition().longitude, self.getPosition().latitude))
    }
    
    /**
     Sets the icon image for the marker.
     - parameter image: image for marker icon.
     */
    public func setIcon(_ image: UIImage){
        workItem?.cancel()
        self.icon = image
        tgMarker?.icon = image
    }
    
    internal func showAnchor(){
        DispatchQueue.main.async {
            let anchor = UIImage(named: "anchor.png", in: Bundle.houseStylesBundle(), compatibleWith: nil)
            self.tgMarker?.icon = anchor!
        }
    }
    
    internal func restoreIcon(){
        DispatchQueue.main.async {
           
            guard let icon = self.icon else { return }
            self.tgMarker?.icon = icon
        }
    }
    
    /**
     Sets the icon image for the marker.
     - parameter urlString: URL for marker icon.
     */
    public func setIcon(_ urlString: String){
        workItem?.cancel()
        workItem = DispatchWorkItem { self.loadImage(urlString) }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: workItem!)
    }
    
    /**
     Sets the icon image for the marker.
     - parameter mapfitMarker: MapfitMarker that will be used for the marker icon.
     */
    public func setIcon(_ mapfitMarker: MFTMarkerImage){
        workItem?.cancel()
        workItem = DispatchWorkItem { self.loadImage(mapfitMarker.rawValue) }
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: workItem!)
     
    }


    //private function for loading image from URLString
    private func loadImage(_ imageString: String) {
        guard let url = URL(string: imageString) else { print("No link provided for image")
            return}
        DispatchQueue.global().async {
            guard let data = try? Data(contentsOf: url) else { print("No image located at this link")
                return
            }//make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
            DispatchQueue.main.async {
                
                if let image = UIImage(data: data) {
                    self.setIcon(image)
                }
                
            }
        }
    }
    
    /**
     Sets the style for the marker based on the markerOptions.
     */
   @objc public func setStyle() {
    guard let marker = tgMarker else { return }
    if let options = markerOptions {
        marker.stylingString = generateStyle(options)
    } else {
        marker.stylingString =  style.rawValue
    }
    
    }
    
    private func generateStyle(_ markerOptions: MFTMarkerOptions) -> String{
        return "{ style: 'sdk-point-overlay', anchor: top, color: 'white', size: [\(markerOptions.width)px, \(markerOptions.height)px], order: \(markerOptions.drawOrder), interactive: true, collide: false }"
    }
    
    /**
     Sets the visibility of the marker.
     parameter show: True or False value setting markers visibility.
     */
    
     @objc public func setVisibility(show: Bool) {
        tgMarker?.visible = show
    }
    
    @objc public func getVisibility()->Bool {
       return tgMarker?.visible ?? false
    }
    
   

    internal init(position: CLLocationCoordinate2D, mapView: MFTMapView) {
        self.position = position
        self.isVisible = true
        self.style = MFTAnnotationStyle.point
        self.uuid = UUID()
        self.mapView = mapView
        super.init()
        self.setIcon(.defaultLightTheme)
        self.markerOptions = MFTMarkerOptions(self)

        
    }
    
    internal init(address: String, mapView: MFTMapView) {
        self.position = CLLocationCoordinate2DMake(0.0, 0.0)
        self.isVisible = true
        self.style = MFTAnnotationStyle.point
        self.uuid = UUID()
        self.mapView = mapView
        super.init()
        self.setIcon(.defaultLightTheme)
        self.getPositionFromAddress(Address: address)
        self.markerOptions = MFTMarkerOptions(self)

    }

    internal init(position: CLLocationCoordinate2D, icon: MFTMarkerImage, mapView: MFTMapView) {
        self.position = position
        self.isVisible = true
        self.style = MFTAnnotationStyle.point
        self.uuid = UUID()
        self.mapView = mapView
        super.init()
        self.markerOptions = MFTMarkerOptions(self)
        self.setIcon(icon)

    }
    
    private func getPositionFromAddress(Address: String){
        MFTGeocoder.sharedInstance.geocode(address: Address, includeBuilding: true) { (addressesObject, error) in
            if error == nil {
                guard let addressObject = addressesObject else { return }

                if let entrances = addressObject[0].entrances {
                    guard let lat = entrances[0].lat else { return }
                    guard let lon = entrances[0].lng else { return }
                    self.setPosition(CLLocationCoordinate2DMake(lat, lon))
                }

                if let location = addressObject[0].location {
                    guard let lat = location.lat else { return }
                    guard let lon = location.lng else { return }
                    self.setPosition(CLLocationCoordinate2DMake(lat, lon))
                }
            
            }
        }

    }
}
    
    
    /**
     Animates the marker from its current coordinates to the ones given.
     
     - parameter coordinates: Coordinates to animate the marker to
     - parameter seconds: Duration in seconds of the animation.
     - parameter ease: Easing to use for animation.
     */
//    public func setPointEased(_ coordinates: TGGeoPoint, seconds: Float, easeType ease: TGEaseType) -> Bool {
//        tgMarker?.pointEased(coordinates, seconds: seconds, easeType: ease)
//        //TODO: Add error management back in here once we're doing it everywhere correctly.
//        return true
//
//    }
    

/**
 Default icons provided by Mapfit.
 */
    

public enum MFTMarkerImage : String {

    case defaultLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/default.png"
    case activeLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/active.png"
    case airportLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/airport.png"
    case artsLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/arts.png"
    case autoLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/auto.png"
    case financeLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/finance.png"
    case commercialLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/commercial.png"
    case cafeLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/cafe.png"
    case conferenceLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/conference.png"
    case sportsLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/sports.png"
    case educationLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/education.png"
    case marketLightTheme = "lhttps://cdn.mapfit.com/m1/assets/images/markers/pngs/ighttheme/market/png"
    case cookingLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/cooking.png"
    case gasLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/gas.png"
    case homegardenLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/homegarden.png"
    case hospitalLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/hospital.png"
    case hotelLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/hotel.png"
    case lawLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/law.png"
    case medicalLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/medical.png"
    case barLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/bar.png"
    case parkLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/park.png"
    case pharmacyLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/pharmacy.png"
    case communityLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/community.png"
    case religionLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/religion.png"
    case restaurantLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/restaurant.png"
    case shoppingLightTheme = "https://cdn.mapfit.com/m1/assets/images/markers/pngs/lighttheme/shopping.png"
    
}

