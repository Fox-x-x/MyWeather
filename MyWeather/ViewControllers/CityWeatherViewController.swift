//
//  CityWeatherViewController.swift
//  MyWeather
//
//  Created by Pavel Yurkov on 24.05.2021.
//

import UIKit
import SnapKit
import Hex

class CityWeatherViewController: UIViewController {
    
    var weatherManager = NetworkManager()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var daySummaryView = DaySummaryView()
    
    private lazy var moreFor24HRSButton: UIButton = {
        
        let button = UIButton()
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let attributeString = NSMutableAttributedString(
            string: "Подробнее на 24 часа",
            attributes: attributes
        )
        
        button.setAttributedTitle(attributeString, for: .normal)

        button.addTarget(self, action: #selector(moreFor24HRSButtonPressed), for: .touchUpInside)
        return button
        
    }()
    
    private lazy var forecast24HRSCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(
            Forecast24HRSCell.self,
            forCellWithReuseIdentifier: String(describing: Forecast24HRSCell.self)
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private lazy var daylyForecastLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(hex: "#272722")
        label.numberOfLines = 1
        label.text = "Ежедневный прогноз"
        return label
    }()
    
    private lazy var weatherTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(BriefWeatherInfoTableViewCell.self, forCellReuseIdentifier: String(describing: BriefWeatherInfoTableViewCell.self))
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        weatherManager.delegate = self
        
        title = "Chicago, USA"
        
        setupLayout()
        
        weatherManager.fetchWeather()
        
    }
    
    private func setupLayout() {
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-32)
            make.centerX.top.bottom.equalToSuperview()
        }
        
        contentView.addSubview(daySummaryView)
        
        daySummaryView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(70)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(212)
        }
        
        contentView.addSubview(moreFor24HRSButton)
        
        moreFor24HRSButton.snp.makeConstraints { make in
            make.top.equalTo(daySummaryView.snp.bottom).offset(33)
            make.trailing.equalToSuperview()
            make.height.equalTo(20)
        }
        
        contentView.addSubview(forecast24HRSCollectionView)
        
        forecast24HRSCollectionView.snp.makeConstraints { make in
            make.top.equalTo(moreFor24HRSButton.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(83)
        }
        
        contentView.addSubview(daylyForecastLabel)
        
        daylyForecastLabel.snp.makeConstraints { make in
            make.top.equalTo(forecast24HRSCollectionView.snp.bottom).offset(40)
            make.leading.equalToSuperview()
        }
        
        contentView.addSubview(weatherTableView)
        
        weatherTableView.snp.makeConstraints { make in
            make.top.equalTo(daylyForecastLabel.snp.bottom).offset(5)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height / 1.5)
            make.bottom.equalToSuperview()
        }
        
    }
    
    @objc private func moreFor24HRSButtonPressed() {
        print("24 hours")
    }
    
}

// MARK: - CollectionView extension

extension CityWeatherViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Forecast24HRSCell.self), for: indexPath) as! Forecast24HRSCell
        
        return cell
    }
    
}

extension CityWeatherViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 42
        let height: CGFloat = 83
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
}

// MARK: - TableView extension

extension CityWeatherViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: BriefWeatherInfoTableViewCell.self), for: indexPath) as! BriefWeatherInfoTableViewCell
        
        return cell
    }
    
}

extension CityWeatherViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CityWeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: NetworkManager, weather: Weather) {
        DispatchQueue.main.async {
            self.daySummaryView.weather = weather
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}
