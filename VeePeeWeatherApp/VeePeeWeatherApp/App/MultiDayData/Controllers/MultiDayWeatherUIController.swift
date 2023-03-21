//
//  MultiDayWeatherUIController.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 20.03.23.
//

import Foundation
import RxSwift
import RxCocoa

protocol MultiDayWeatherUIControllerProtocol {
    var weatherDataObserver: AnyObserver<WeatherModel> { get }
    var foldTapObservable: Observable<Int> { get }
}


class MultiDayWeatherUIController: MultiDayWeatherUIControllerProtocol {

    init(view: MultiDayWeatherViewProtocol, uiScheduler: SchedulerType = MainScheduler.asyncInstance) {
        self.view = view
        self.uiScheduler = uiScheduler
        self.dayFormatter = DateFormatter()
        self.timeFormatter = DateFormatter()
        self.calendar = Calendar.current
        dayFormatter.dateFormat = "MM-dd-EEEE"
        timeFormatter.dateFormat = "HH:mm"
        registerObservers()
    }

    let view: MultiDayWeatherViewProtocol
    let uiScheduler: SchedulerType
    let disposeBag = DisposeBag()
    let dayFormatter: DateFormatter
    let timeFormatter: DateFormatter
    let calendar: Calendar

    let dataSubject = PublishSubject<WeatherModel>()
    let unfoldedItem = PublishSubject<Int?>()

    var weatherDataObserver: AnyObserver<WeatherModel> {
        return dataSubject.asObserver()
    }

    var foldTapObservable: Observable<Int> {
        return view.cellDetailsTap
    }

    func registerObservers() {

        view.cellDetailsTap
            .withLatestFrom(unfoldedItem.startWith(nil).asObservable(),
                            resultSelector: { taped, current in
                if current == taped {
                    self.unfoldedItem.on(.next(nil))
                } else {
                    self.unfoldedItem.on(.next(taped))
                }
            })
            .observe(on: uiScheduler)
            .subscribe()
            .disposed(by: disposeBag)

        Observable.combineLatest(dataSubject, unfoldedItem.startWith(nil))
            .observe(on: uiScheduler)
            .map { [weak self] model, selectedCell in
                let weatherCellData = model.dayData.map {
                    let hourlyModel = $0.hourlyData.map { dayData in
                        // Hourly data
                        WeatherCellData.HourlyData(time: self!.timeFormatter.string(from: dayData.timeStamp),
                                                   weatherDesc: dayData.weatherCondition.main.rawValue ,
                                                   temperature: String(dayData.hourlyTemp),
                                                   weatherIcon: dayData.weatherCondition.main.conditionIcon ) }
                    // Data for the sigle day
                    return WeatherCellData(mainDescription: $0.dayWeather.main.rawValue ,
                                           temperature: String($0.dayTemp),
                                           weatherImage: $0.dayWeather.main.conditionImage,
                                           date: self!.dayFormatter.string(from: $0.date),
                                           hourlyData: hourlyModel)
                }
                // Data for the main view
                return  MultyDayWeatherData(unfoldItemIndex: selectedCell,
                                            locationDescription: String(model.currentTemperature),
                                            locationImage: model.mainImage,
                                            multyDayData: weatherCellData)
            }
            .subscribe(onNext: {
                self.view.set(data: $0)
            }) .disposed(by: disposeBag)


    }

}
