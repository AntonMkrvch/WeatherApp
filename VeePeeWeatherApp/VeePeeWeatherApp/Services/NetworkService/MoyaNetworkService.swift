//
//  MoyaNetworkService.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 15.03.23.
//

import Moya
import RxSwift

protocol NetworkService {
    func getWeatherBy(longitude: Float, latitude: Float, apiKey: String) -> Single<OpenWeather3hForecastModel>
    func getWeatherBy(cityName: String, apiKey: String) -> Single<OpenWeather3hForecastModel>
    func getCurrentWeather(longitude: Float, latitude: Float, apiKey: String) -> Single<OpenWeatherCurrentModel>
}

class MoyaNetworkService: NetworkService {

    let provider = MoyaProvider<Endpoint>()
    let decoder = JSONDecoder()
    let dateFormatter = DateFormatter()

    func getWeatherBy(longitude: Float, latitude: Float, apiKey: String) -> Single<OpenWeather3hForecastModel> {
        provider.rx.request(.getWeatherByPosition(longitude: longitude, latitude: latitude, apiKey: apiKey))
            .map { 
                try! JSONDecoder().decode(OpenWeather3hForecastModel.self, from: $0.data)
            }
    }

    func getWeatherBy(cityName: String, apiKey: String) -> Single<OpenWeather3hForecastModel> {
        provider.rx.request(.getWeatherByCity(cityName: cityName, apiKey: apiKey))
            .map {
                try! JSONDecoder().decode(OpenWeather3hForecastModel.self, from: $0.data)
            }
    }

    func getCurrentWeather(longitude: Float, latitude: Float, apiKey: String) -> Single<OpenWeatherCurrentModel> {
        provider.rx.request(.getCurrentWeather(longitude: longitude, latitude: latitude, apiKey: apiKey))
            .map {
                try! JSONDecoder().decode(OpenWeatherCurrentModel.self, from: $0.data)
            }
    }

    enum Endpoint: TargetType {
        var baseURL: URL { URL(string: "https://api.openweathermap.org/data/2.5/")! }
        
        case getWeatherByPosition(longitude: Float, latitude: Float, apiKey: String)
        case getWeatherByCity(cityName: String, apiKey: String)
        case getWeatherByCityAndCountry(cityName: String, countryCode: String, apiKey: String)
        case getCurrentWeather(longitude: Float, latitude: Float, apiKey: String)

        var path: String {
            switch self {
            case .getWeatherByPosition:
                return "forecast"
            case .getWeatherByCity(let cityName, let apiKey):
				return "forecast?q=\(cityName)&appid=\(apiKey)"
            case .getWeatherByCityAndCountry(let cityName, let countryCode, let apiKey):
                return "forecast?q=\(cityName),\(countryCode)&appid=\(apiKey)"
            case .getCurrentWeather:
                return "weather"
            }
        }

        var method: Moya.Method {
            switch self {
            case .getWeatherByPosition, .getWeatherByCity, .getWeatherByCityAndCountry, .getCurrentWeather:
                return .get
            }
        }

        var task: Task {
            switch self {
            case .getWeatherByPosition(let long, let lat, let apiKey):
                return .requestParameters(parameters: ["lat": lat, "lon": long, "appid": apiKey, "units": "metric"], encoding: URLEncoding.queryString)
            case .getCurrentWeather(let long, let lat, let apiKey):
                return .requestParameters(parameters: ["lat": lat, "lon": long, "appid": apiKey, "units": "metric"], encoding: URLEncoding.queryString)
            case .getWeatherByCity, .getWeatherByCityAndCountry:
                return .requestPlain
            }
        }

        var headers: [String: String]? {
            return ["Content-type": "application/json"]
        }
    }


}
