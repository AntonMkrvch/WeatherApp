//
//  WeatherDataRepository.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 17.03.23.
//

import Foundation
import RxSwift

protocol WeatherDataRepositoryProtocol {
    func getWeatherFor(city: City) -> Observable<WeatherModel>
}

enum City: String {
    case Paris
    case Berlin

    var coordinates: (Float, Float) {
        switch self {

        case .Paris:
            return (48.85, 2.35)
        case .Berlin:
            return (52.52, 13.40)
        }
    }
}

struct WeatherModel {

    let city: City
    let currentTemperature: Float
    let currentWeatherDesс: String
    let dayData: [DayData]

    var mainImage: UIImage? {
        switch city {
        case .Paris:
            return UIImage(named: "Paris-main-clear")
        case .Berlin:
            return UIImage(named: "Berlin-main-clear")
        }
    }
}

enum MainCondition: String {
    case thunderstorm = "Thunderstorm"
    case drizzle = "Drizzle"
    case rain = "Rain"
    case snow = "Snow"
    case mist = "Mist"
    case smoke = "Smoke"
    case haze = "Haze"
    case dust = "Dust"
    case fog = "Fog"
    case sand = "Sand"
    case ash = "Ash"
    case squall = "Squall"
    case tornado = "Tornado"
    case clear = "Clear"
    case clouds = "Clouds"

    var conditionImage: UIImage? {
        switch self {
        case .thunderstorm:
            return UIImage(named: "thunderstorm")
        case .drizzle:
            return UIImage(named: "drizzle")
        case .rain:
            return UIImage(named: "rain")
        case .snow:
            return UIImage(named: "snow")
        case .mist:
            return UIImage(named: "mist")
        case .smoke:
            return UIImage(named: "smoke")
        case .haze:
            return UIImage(named: "haze")
        case .dust:
            return UIImage(named: "dust")
        case .fog:
            return UIImage(named: "fog")
        case .sand:
            return UIImage(named: "sand")
        case .ash:
            return UIImage(named: "sand")
        case .squall:
            return UIImage(named: "squall")
        case .tornado:
            return UIImage(named: "tornado")
        case .clear:
            return UIImage(named: "clear")
        case .clouds:
            return UIImage(named: "clouds")
        }
    }

    var conditionIcon: UIImage? {
        switch self {

        case .thunderstorm:
            return UIImage(named: "thunderIcon")
        case .drizzle:
            return UIImage(named: "drizzleicon")
        case .rain:
            return UIImage(named: "rainIcon")
        case .snow:
            return UIImage(named: "snowIcon")
        case .mist:
            return UIImage(named: "mistIcon")
        case .smoke:
            return UIImage(named: "mistIcon")
        case .haze:
            return UIImage(named: "mistIcon")
        case .dust:
            return UIImage(named: "mistIcon")
        case .fog:
            return UIImage(named: "mistIcon")
        case .sand:
            return UIImage(named: "mistIcon")
        case .ash:
            return UIImage(named: "mistIcon")
        case .squall:
            return UIImage(named: "mistIcon")
        case .tornado:
            return UIImage(named: "mistIcon")
        case .clear:
            return UIImage(named: "clearIcon")
        case .clouds:
            return UIImage(named: "cloudsIcon")
        }
    }
}

struct WeatherCondition {
    let id: Int
    let main: MainCondition
    let conditionWithGroup: String
    //        let conditionIcon: UIImage
}

struct HourlyData {

    let timeStamp: Date
    let hourlyTemp: Float
    let weatherCondition: WeatherCondition
}

struct DayData {
    let date: Date
    let dayWeather: WeatherCondition
    let dayTemp: Float
    let hourlyData: [HourlyData]
}

extension Array {
    func sliced(by dateComponents: Set<Calendar.Component>, for key: KeyPath<Element, Date>) -> [Date: [Element]] {
        let initial: [Date: [Element]] = [:]
        let groupedByDateComponents = reduce(into: initial) { acc, cur in
            let components = Calendar.current.dateComponents(dateComponents, from: cur[keyPath: key])
            let date = Calendar.current.date(from: components)!
            let existing = acc[date] ?? []
            acc[date] = existing + [cur]
        }

        return groupedByDateComponents
    }
}

extension Array where Element == HourlyData {
    var closerToNoon: HourlyData? {
        let calendar = Calendar.current
        let timeSorted = self.sorted {
            abs(calendar.component(.hour, from: $0.timeStamp) - 15) < abs(calendar.component(.hour, from: $1.timeStamp) - 15)
        }
        return timeSorted.first
    }
}

class WeatherDataRepository: WeatherDataRepositoryProtocol {
    
    let weatherService: WeatherServiceProtocol

    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
    }

    func getWeatherFor(city: City) -> Observable<WeatherModel> {
        return weatherService.getWeatherFor(city: city)
    }
}
