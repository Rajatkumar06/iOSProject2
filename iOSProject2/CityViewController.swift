//
//  CityViewController.swift
//  iOSProject2
//
//  Created by Rajat Kumar on 2023-08-02.
//

import UIKit

class CityViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var listTableView: UITableView!
    var dataSource: [Model] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.delegate = self
        listTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let weather = dataSource[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityWeatherTableViewCell", for: indexPath) as? CityWeatherTableViewCell else { return UITableViewCell() }
        cell.name.text = (weather.location?.name ?? "") + " Temp: " + "\(weather.current?.tempC ?? 0) C"
        cell.imageVIew.image = getWeatherImage(weatherCode: weather.current?.condition?.code ?? 0)
        return cell
    }
}
