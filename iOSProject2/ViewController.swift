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
    var savedCitiesResponse: [Model] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loc = CLLocationManager()
        loc?.delegate = self
    }
    
    @IBAction func citiesButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "citiesSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "citiesSegue",
              let desination = segue.destination as? CityViewController else { return }
        desination.savedCitiesResponse = savedCitiesResponse
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        guard let cityName = searchTextField.text else { return }
        getWeatherFor(query: cityName) { weatherData, error in
            if let weatherData = weatherData {
                self.currentCityWeatherData = weatherData
                self.savedCitiesResponse.append(weatherData)
                self.updateUI()
                self.showAlert(text: cityName)
            }
        }
    }
    
    func showAlert(text: String) {
        DispatchQueue.main.async {
            let vc = UIAlertController(title: "City Added to City List", message: text, preferredStyle: .alert)
            let action = UIAlertAction(title: "ok", style: .default, handler: nil)
            vc.addAction(action)
            self.present(vc, animated: true, completion: nil)
        }
      }
    
    @IBAction func locationButtonTapped(_ sender: Any) {
        loc?.requestAlwaysAuthorization()
        
        guard let lat = loc?.location?.coordinate.latitude,
              let lon = loc?.location?.coordinate.longitude else { return }
        getWeatherFor(query: "\(lat),\(lon)") { weatherData, error in
            if let weatherData = weatherData {
                self.currentCityWeatherData = weatherData
                self.savedCitiesResponse.append(weatherData)
                self.updateUI()
                self.showAlert(text: self.currentCityWeatherData?.location?.name ?? "")
            }
        }
    }
    
    @IBAction func segmentControlChanged(_ sender: Any) {
        guard let segmentContol = sender as? UISegmentedControl,
              let currentCityWeatherData = currentCityWeatherData else { return }
        if segmentContol.selectedSegmentIndex == 0 {
            self.tempratureLabel.text = "\(currentCityWeatherData.current?.tempC ?? 0)"
        } else if segmentContol.selectedSegmentIndex == 1 {
            self.tempratureLabel.text = "\(currentCityWeatherData.current?.tempF ?? 0)"
        }
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
                    self.savedCitiesResponse.append(weatherData)
                    self.showAlert(text: self.currentCityWeatherData?.location?.name ?? "")
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
