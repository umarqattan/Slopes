//
//  DataCollectionViewController.swift
//  Slopes
//
//  Created by Umar Qattan on 11/18/18.
//  Copyright © 2018 ukaton. All rights reserved.
//

import Foundation
import UIKit


class DataCollectionViewController: UIViewController {
    
    
    var weightViewModels = [DataCollectionItemViewModel]()
    var bodyFatViewModels = [DataCollectionItemViewModel]()
    var weightValues = [CGFloat]()
    var bodyFatValues = [CGFloat]()
    
    private lazy var collectionView: UICollectionView = {
        let layout =  UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(DataCollectionItemCell.self, forCellWithReuseIdentifier: "DataCollectionItemCell")
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    private lazy var measurementControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(frame: .zero)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(onMeasurementControlChanged(_:)), for: .valueChanged)
        segmentedControl.isUserInteractionEnabled = true
        
        return segmentedControl
    }()
    
    private lazy var graphView: GraphView = {
        let graphView = GraphView(frame: .zero, viewModel: GraphViewModel(values: self.weightValues, measType: 1))
        graphView.translatesAutoresizingMaskIntoConstraints = false
        
        return graphView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.setupViews()
        self.configureMeasurementControl()
        self.applyConstraints()
        self.applyStyles()
    }
    
    func setupViews() {
        self.view.addSubview(self.measurementControl)
        self.view.addSubview(self.collectionView)
        self.view.addSubview(self.graphView)
    }
    
    func applyConstraints() {
        
        NSLayoutConstraint.activate([
            
            // measurementControl constraints
            self.measurementControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.measurementControl.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.measurementControl.widthAnchor.constraint(equalToConstant: self.measurementControl.intrinsicContentSize.width),
            self.measurementControl.heightAnchor.constraint(equalToConstant: self.measurementControl.intrinsicContentSize.height),
            
            // graphView constraints
            self.graphView.topAnchor.constraint(equalTo: self.measurementControl.bottomAnchor),
            self.graphView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.graphView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.graphView.bottomAnchor.constraint(equalTo: self.collectionView.topAnchor),
        
            // collectionView constraints
            self.collectionView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.45),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    func applyStyles() {
        
    }
}

extension DataCollectionViewController {
    
    func configureMeasurementControl() {
        self.measurementControl.insertSegment(withTitle: "Weight", at: 0, animated: true)
        self.measurementControl.insertSegment(withTitle: "Body Fat %", at: 1, animated: true)
        self.measurementControl.selectedSegmentIndex = 0
    }
    
    @objc func onMeasurementControlChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
            self.graphView.viewModel = GraphViewModel(values: self.weightValues, measType: 1)
        }
        
        if sender.selectedSegmentIndex == 1 {
            self.graphView.viewModel = GraphViewModel(values: self.bodyFatValues, measType: 6)
        }
    
        self.graphView.setNeedsDisplay()
        self.collectionView.reloadData()

    }
}

extension DataCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.measurementControl.selectedSegmentIndex == 0 {
            return self.weightViewModels.count
        } else if self.measurementControl.selectedSegmentIndex == 1 {
            return self.bodyFatViewModels.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DataCollectionItemCell", for: indexPath) as! DataCollectionItemCell
        
        if self.measurementControl.selectedSegmentIndex == 0 {
            cell.configure(self.weightViewModels[indexPath.item], measType: 1)
        }
        
        if self.measurementControl.selectedSegmentIndex == 1 {
            cell.configure(self.bodyFatViewModels[indexPath.item], measType: 6)
        }
        
        return cell
    }
    
}

extension DataCollectionViewController: UICollectionViewDelegate {
    

}

extension DataCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

struct DataCollectionItemViewModel {
    
    var timeStamp: Int
    var data: Int
    var delta: Int
    
    init(timeStamp: Int, data: Int, delta: Int) {
        self.timeStamp = timeStamp
        self.data = data
        self.delta = delta
    }
}

class DataCollectionItemCell: UICollectionViewCell {
    
    private lazy var dataLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0

        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0

        return label
    }()
    
    private lazy var deltaLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.applyConstraints()
        self.applyStyles()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupViews() {
        self.contentView.addSubview(timeLabel) // above dataLabel
        self.contentView.addSubview(dataLabel) // below timeLabel
        self.contentView.addSubview(deltaLabel) // right most
    }
    
    private func applyConstraints() {
        
        self.timeLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        self.dataLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        NSLayoutConstraint.activate([
            // timeLabel constraints
            self.timeLabel.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            self.timeLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            
            // timeLabel constraints
            self.dataLabel.leadingAnchor.constraint(equalTo: self.timeLabel.leadingAnchor),
            self.dataLabel.topAnchor.constraint(equalTo: self.timeLabel.bottomAnchor),
            self.dataLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            
            // deltaLabel constraints
            self.deltaLabel.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
            self.deltaLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        
    }
    
    private func applyStyles() {
        
    }
    

    func configure(_ viewModel: DataCollectionItemViewModel, measType: Int) {
        self.timeLabel.text = self.timeLabelText(from: viewModel.timeStamp)
        self.dataLabel.text = self.dataLabelText(from: viewModel.data, measType: measType)
        self.deltaLabel.text = self.deltaLabelText(from: viewModel.delta, measType: measType)
        self.deltaLabel.textColor = self.deltaTextColor(from: viewModel.delta, measType: measType)
    }
    
    func timeLabelText(from timeStamp: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd/yyyy hh:mm a"
        let dateFromTimeStamp = Date(timeIntervalSince1970: TimeInterval(exactly: timeStamp)!)
        let timeLabelText = formatter.string(from: dateFromTimeStamp)
        
        return timeLabelText
    }
    
    func dataLabelText(from value: Int, measType: Int) -> String {
        switch measType {
            case 1:
                return String(format: "%.2f lbs", Double(value) / 453.59237)
            case 6:
                return String(format: "%.2f %%", Double(value) * pow(10, -3))
            default:
                return ""
        }
    }
    
    func deltaTextColor(from value: Int, measType: Int) -> UIColor {
        if value < 0 {
            return .red
        } else if value == 0 {
            return .gray
        } else {
            return .green
        }
    }
    
    func deltaLabelText(from value: Int, measType: Int) -> String {

        let prefix: String = {
            if value < 0 {
                return "-"
            } else if value == 0 {
                return ""
            } else {
                return "+"
            }
        }()
        
        return prefix + self.dataLabelText(from: abs(value), measType: measType)
    }
}
