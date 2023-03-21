//
//  MultiDayWeatherController.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 20.03.23.
//

import Foundation
import RxSwift
import RxCocoa

protocol MultiDayWeatherControllerProtocol {

}

class MultiDayWeatherController: MultiDayWeatherControllerProtocol {

    var weatherRepository: WeatherDataRepositoryProtocol
    let disposeBag = DisposeBag()
    let scheduler: SchedulerType

    var weatherData = PublishRelay<WeatherModel>()

    init(repositories: RepositoryContainerProtocol, scheduler: SchedulerType = ConcurrentDispatchQueueScheduler(qos: .default)) {
        self.weatherRepository = repositories.weatherRepository
        self.scheduler = scheduler
    }

    var uiController: MultiDayWeatherUIControllerProtocol? {
        didSet {
            guard let uiController else { return }
			registerObservers(with: uiController)
            updateData(for: .Paris)
        }
    }

    private func registerObservers(with uiController: MultiDayWeatherUIControllerProtocol) {

        weatherData
            .observe(on: scheduler)
            .subscribe(onNext: { newData in
                uiController.weatherDataObserver.on(.next(newData))
            })
            .disposed(by: disposeBag)
    }


    private func updateData(for city: City) {
        weatherRepository.getWeatherFor(city: city)
            .observe(on: scheduler)
            .subscribe(onNext: { newData in
                self.weatherData.accept(newData)
            })
            .disposed(by: disposeBag)
    }
}
