//
//  Container.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 17.03.23.
//


import Foundation

protocol ServicesContainerProtocol {
    var networkService: NetworkService { get }
    var weatherService: WeatherServiceProtocol { get }
}

protocol RepositoryContainerProtocol {
    var weatherRepository: WeatherDataRepositoryProtocol { get }
}

class Container: ServicesContainerProtocol, RepositoryContainerProtocol {

    // Services
    var networkService: NetworkService
    var weatherService: WeatherServiceProtocol

	// Repositories
    var weatherRepository: WeatherDataRepositoryProtocol

    init() {
        networkService = MoyaNetworkService()
        weatherService = OpenWeatherService(networkService: networkService)

        weatherRepository = WeatherDataRepository(weatherService: weatherService)
    }
}
