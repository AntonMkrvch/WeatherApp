//
//  WeatherCellData.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 20.03.23.
//

import UIKit

struct WeatherCellData {
    
    let mainDescription: String
    let temperature: String
    let weatherImage: UIImage?
    let date: String

    let hourlyData: [HourlyData]

    struct HourlyData {
        let time: String
        let weatherDesc: String
        let temperature: String
        let weatherIcon: UIImage?
    }
}
