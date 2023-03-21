//
//  OpenWeatherService.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 15.03.23.
//

import Foundation
import RxSwift

protocol WeatherServiceProtocol {
    func getWeatherFor(city: City) -> Observable<WeatherModel>
}

enum WeatherParseError: Error {
    case missingData
}

class OpenWeatherService: WeatherServiceProtocol {

    static let apiKey = "1bf7bdc62b3b9caf1d5c5958d4088e12"
    let networkService: NetworkService

    init(networkService: NetworkService) {
        self.networkService = networkService
    }

    func getWeatherFor(long: Float, lat: Float) -> Observable<WeatherModel> {
        let forecastData = networkService.getWeatherBy(longitude: long, latitude: lat, apiKey: Self.apiKey)
        let currentData = networkService.getCurrentWeather(longitude: long, latitude: lat, apiKey: Self.apiKey)


        return Observable.zip(forecastData.asObservable(), currentData.asObservable())
            .map { forecast, current in
                let city = City(rawValue: current.name) ?? .Paris
                let temp = current.main.temp
                let weatherDesc = current.weather.description

                let hourlyData = try forecast.list.map { listValue in
                    guard let conditionData = listValue.weather.first,
                          let mainCondition = MainCondition(rawValue: conditionData.main) else { throw WeatherParseError.missingData }
                    let timestamp = Date(timeIntervalSince1970: Double(listValue.dt))

                    let condition = WeatherCondition(id: conditionData.id,
                                                     main: mainCondition,
                                                     conditionWithGroup: conditionData.description)


                    return HourlyData(timeStamp: timestamp,
                                      hourlyTemp: listValue.main.temp,
                                      weatherCondition: condition)
                }
                let sliced = hourlyData.sliced(by: [.year, .month, .day], for: \.timeStamp)
                let dayData = sliced.map { key, value in
                    let main = value.closerToNoon
                    return DayData(date: main!.timeStamp,
                                   dayWeather: main!.weatherCondition,
                                   dayTemp: main!.hourlyTemp,
                                   hourlyData: value)
                }.sorted { return $0.date < $1.date }

                return WeatherModel(city: city,
                                    currentTemperature: temp,
                                    currentWeatherDesс: weatherDesc,
                                    dayData: dayData)
            }
    }

    func getWeatherFor(city: City) -> Observable<WeatherModel> {
        getWeatherFor(long: city.coordinates.1, lat:  city.coordinates.0)
    }

}
