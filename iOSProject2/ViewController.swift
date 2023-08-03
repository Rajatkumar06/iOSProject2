//
//  ViewController.swift
//  iOSProject2
//
//  Created by Rajat Kumar on 2023-08-02.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    
    var currentCityWeatherData: Model?
    var loc: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loc = CLLocationManager()
        loc?.delegate = self
    }
    
    @IBAction func citiesButtonTapped(_ sender: Any) {
        
    }
    
    
    
    @IBAction func searchButtonTapped(_ sender: Any) {
    }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        loc?.requestAlwaysAuthorization()
        
        guard let lat = loc?.location?.coordinate.latitude,
              let lon = loc?.location?.coordinate.longitude else { return }
        getWeatherFor(query: "\(lat),\(lon)") { weatherData, error in
            if let weatherData = weatherData {
                self.currentCityWeatherData = weatherData
                self.updateUI()
            }
        }
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
    }
    
    func updateUI() {
        guard let currentCityWeatherData = currentCityWeatherData else { return }
        DispatchQueue.main.async { [unowned self] in
            self.weatherConditionLabel.text = currentCityWeatherData.current?.condition?.text ?? ""
            self.tempratureLabel.text = "\(currentCityWeatherData.current?.tempC ?? 0)"
            self.cityName.text = currentCityWeatherData.location?.name ?? ""
            self.weatherImage.image = getImage(weatherCode: currentCityWeatherData.current?.condition?.code ?? 0)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse, .authorized:
            guard let lat = loc?.location?.coordinate.latitude,
                  let lon = loc?.location?.coordinate.longitude else { return }
            getWeatherFor(query: "\(lat),\(lon)") { weatherData, error in
                if let weatherData = weatherData {
                    self.currentCityWeatherData = weatherData
                    self.updateUI()
                }
            }
        @unknown default:
            break
        }
    }
    
    func getWeatherFor(query: String, completion: @escaping (Model?, Error?) -> () ) {
        guard let finalURL = URL(string: "https://api.weatherapi.com/v1/current.json?key=5edf7d31f2a74111b1c04630230308&q=\(query)&aqi=no".addingPercentEncoding(withAllowedCharacters:
                .urlFragmentAllowed)!) else { return }
        URLSession.shared.dataTask(with: finalURL, completionHandler: { data, response, error in
            guard let json = data else { return }
            do {
                let weatherResponse = try JSONDecoder().decode(Model.self, from: json)
                completion(weatherResponse, nil)
            } catch let error {
                completion(nil, error)
            }
        }).resume()
    }
}

func getImage(weatherCode: Int) -> UIImage? {
    switch weatherCode {
    case 1066, 1072, 1147, 1168, 1171, 1210, 1213, 1216:
        return UIImage(systemName: "snowflake")
    case 1006, 1030:
        return UIImage(systemName: "cloud.fill")
    case 1000:
        return UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.SymbolConfiguration.preferringMulticolor())
    case 1063, 1087, 1150, 1153, 1180, 1183, 1186, 1189:
        return UIImage(systemName: "cloud.bolt.rain.fill", withConfiguration: UIImage.SymbolConfiguration.preferringMulticolor())
    case 1003:
        return UIImage(systemName: "cloud.sun.fill", withConfiguration: UIImage.SymbolConfiguration.preferringMulticolor())
   
    case 1009, 1135:
        return UIImage(systemName: "smoke.fill", withConfiguration: UIImage.SymbolConfiguration.preferringMulticolor())
    default:
        return UIImage(systemName: "cloud.bolt.rain.fill", withConfiguration: UIImage.SymbolConfiguration.preferringMulticolor())
    }
}
