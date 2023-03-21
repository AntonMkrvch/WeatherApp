//
//  ViewController.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 14.03.23.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let multyDayView = MultiDayWeather.init(frame: self.view.frame)
        self.view = multyDayView
        let controller = MultiDayWeatherController(repositories: Container())
        let uiController = MultiDayWeatherUIController(view: multyDayView)
        controller.uiController = uiController
    }


}

