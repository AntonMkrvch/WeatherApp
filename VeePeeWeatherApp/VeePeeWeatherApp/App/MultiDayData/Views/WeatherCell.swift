//
//  WeatherCell.swift
//  VeePeeWeatherApp
//
//  Created by Anton Makarevich on 17.03.23.
//

import UIKit
import RxSwift
import RxCocoa

class WeatherCell: UITableViewCell {

    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var detailsButton: UIButton!

    @IBOutlet weak var hourlyDataTableView: UITableView!

    @IBOutlet weak var tableContainerHeight: NSLayoutConstraint!

    var disposeBag = DisposeBag()

    var folded: Bool = true {
        didSet {
            updateTable()
        }
    }

    var cellData: WeatherCellData? {
        didSet {
            updateCell()
        }
    }

    var tableData: [WeatherCellData.HourlyData] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        hourlyDataTableView.delegate = self
        hourlyDataTableView.dataSource = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private func updateTable() {
        hourlyDataTableView.reloadData()

        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self else { return }
            self.tableContainerHeight.constant = self.folded ? 0 : CGFloat(self.tableData.count * 44)
        }

        hourlyDataTableView.setNeedsLayout()
    }

    private func updateCell() {
        guard let data = cellData else { return }
        temperatureLabel.text = data.temperature
        descLabel.text = data.mainDescription
        weatherImage.image = data.weatherImage
        mainText.text = data.date
        tableData = data.hourlyData
        detailsButton.setImage(UIImage(systemName: "arrow.up.backward.and.arrow.down.forward"), for: .normal)
		updateTable()
    }

    var buttonTapped: Observable<WeatherCell> {
        return detailsButton.rx.tap.map { self }
    }
    

}

extension WeatherCell: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")

        guard tableData.count >= indexPath.item else { return cell }
        let data = tableData[indexPath.item]
        cell.textLabel?.text = data.time + " Temperature: " + data.temperature + "C"
        cell.imageView?.image = data.weatherIcon

        return cell
    }


}
