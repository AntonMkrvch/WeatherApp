//
//  MultiDayDataView.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 17.03.23.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol MultiDayWeatherViewProtocol {
    var cellDetailsTap: Observable<Int> { get }
    func updateFoldStateFor(item: Int, state: Bool)
    func set(data: MultyDayWeatherData)
}

@IBDesignable
class MultiDayWeather: UIView, NibLoadable {

    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var dataTableView: UITableView!

    @IBOutlet weak var topInfoLabel: UILabel!
    private var cellTapRelay = PublishSubject<Int>()

    private var data: MultyDayWeatherData?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        dataTableView.delegate = self
        dataTableView.dataSource = self
        dataTableView.register(UINib(nibName: "WeatherCell", bundle: nil),
                               forCellReuseIdentifier: "WeatherCell")
    }


}

extension MultiDayWeather: MultiDayWeatherViewProtocol {
    var cellDetailsTap: Observable<Int> {
        return cellTapRelay.asObservable()
    }

    func updateFoldStateFor(item: Int, state: Bool) {
        if let cell = dataTableView.cellForRow(at: IndexPath.init(index: item)) as? WeatherCell {
            cell.folded = state
        }
    }

    func set(data: MultyDayWeatherData) {
        self.data = data
        topInfoLabel.text = data.locationDescription + "C"
        topImageView.image = data.locationImage
        dataTableView.reloadData()
    }
}


extension MultiDayWeather: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = data else { return 0 }
        return data.multyDayData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data, data.multyDayData.count >= indexPath.item else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell") as? WeatherCell else { return UITableViewCell() }
        let cellData = data.multyDayData[indexPath.item]
        cell.cellData = cellData
        cell.folded = indexPath.item != data.unfoldItemIndex
        
        cell.buttonTapped.map { _ in indexPath.item }
            .bind(to: cellTapRelay)
            .disposed(by: cell.disposeBag)
        return cell
    }



}
