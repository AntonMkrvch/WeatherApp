//
//  WeatherModel.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 15.03.23.
//

import Foundation

struct OpenWeather3hForecastModel: Decodable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [WeatherValue]
    let city: CityWeatherData

    struct WeatherValue: Decodable {
        let dt: Int64
        let main: WeatherMain
        let weather: [WeatherDesc]
        let wind: WindData
        let clouds: CloudsData
        let rain: RainData?
        let sys: Sys
        let dt_txt: String


        struct RainData: Decodable {
            let rainChanceFor3h: Float

            enum CodingKeys: String, CodingKey {
                case rainChanceFor3h = "3h"
            }
        }

        struct Sys: Decodable  {
            let pod: String
        }

    }

    struct CityWeatherData: Decodable {
        let id: Int
        let name: String
        let coord: Coordinate
        let country: String
        let population: Int
        let timezone: Int
        let sunrise: Int
        let sunset: Int


    }

}

struct WeatherDesc: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}


struct Coordinate: Decodable {
    let lat: Float
    let lon: Float
}

struct WeatherMain: Decodable {
    let temp: Float
    let feels_like: Float
    let temp_min: Float
    let temp_max: Float
    let pressure: Int
    let sea_level: Int?
    let grnd_level: Int?
    let humidity: Int
    let temp_kf: Float?
}

struct WindData: Decodable {
    let speed: Float
    let deg: Int
    let gust: Float
}

struct CloudsData: Decodable {
    let all: Int
}


struct OpenWeatherCurrentModel: Decodable {

    struct RainData: Decodable {
        let rainChanceFor3h: Float

        enum CodingKeys: String, CodingKey {
            case rainChanceFor3h = "1h"
        }
    }
    
    let name: String
    let coord: Coordinate
    let weather: [WeatherDesc]
    let base: String
    let main: WeatherMain
    let visibility: Int
    let clouds: CloudsData?
    let rain: RainData?
    let dt: Date
}
