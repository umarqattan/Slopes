//
//  GraphView.swift
//  Slopes
//
//  Created by Umar Qattan on 11/20/18.
//  Copyright © 2018 ukaton. All rights reserved.
//

import UIKit

struct GraphViewModel {
    
    var minX: CGFloat
    var maxX: CGFloat
    var minY: CGFloat?
    var maxY: CGFloat?
    var values: [CGFloat]
    var measType: Int
    
    init(values: [CGFloat], measType: Int) {
        self.minX = 0
        
        if measType == 1 {
            self.minY = values.min()
        }
        if measType == 6 {
            self.minY = 0
        }
        
        self.maxX = CGFloat(values.count)
        self.maxY = values.max()
        self.values = values
        self.measType = measType
    }
}

class GraphView: UIView {
    
    var viewModel: GraphViewModel?
    
    convenience init(frame: CGRect, viewModel: GraphViewModel) {
        self.init(frame: frame)
        self.viewModel = viewModel
        self.backgroundColor = .white
        
        guard let viewModel = self.viewModel,
            let minY = viewModel.minY,
            let maxY = viewModel.maxY else { return }
        
        self.setupViews()
        
        if viewModel.measType == 1 {
            self.minLabel.text = "\(String(format: "%.2f", minY / 453.59237))"
            self.maxLabel.text = "\(String(format: "%.2f", maxY / 453.59237))"
        }
        if viewModel.measType == 6 {
            self.minLabel.text = "\(String(format: "%.2f", Double(minY) * pow(10, -3)))"
            self.maxLabel.text = "\(String(format: "%.2f", Double(maxY) * pow(10, -3)))"
        }
        
        self.applyConstraints()
        self.applyStyles()
    }
    
    private lazy var minLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 8)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        return label
    }()
    
    private lazy var maxLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 8)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func mapValueToPoint(_ value: CGFloat, from currentXOffset: CGFloat) -> CGPoint {
        guard let viewModel = self.viewModel,
            let minY = viewModel.minY,
            let maxY = viewModel.maxY else { return .zero }
        
        let height = self.frame.size.height
        
        let x = currentXOffset
        let y = (1 - (value - minY)/(maxY - minY)) * height
        
        return CGPoint(x: x, y: y)
    }
    
    private func colorForDelta(_ delta: CGFloat) -> UIColor {
        if delta < 0 {
            return .red
        } else if delta == 0 {
            return .lightGray
        } else {
            return .green
        }
    }

    override func draw(_ rect: CGRect) {
        guard let viewModel = self.viewModel,
           let minY = viewModel.minY,
           let maxY = viewModel.maxY else { return }
        
        let numberOfPoints = CGFloat(viewModel.values.count)
        let width = self.frame.size.width
        var linePath = UIBezierPath()
        var currentXOffset = CGFloat(0)
        var previousValue = CGFloat(0)
        
        linePath.move(to: self.mapValueToPoint(viewModel.values[0], from: currentXOffset))
        
        for i in 1..<viewModel.values.count {
            currentXOffset += width / numberOfPoints
            let strokeColor = self.colorForDelta(viewModel.values[i] - previousValue)
            strokeColor.set()
            linePath.addLine(to: self.mapValueToPoint(viewModel.values[i], from: currentXOffset))
            linePath.stroke()
            linePath.close()
            
            previousValue = viewModel.values[i]
            
            linePath = UIBezierPath()
            linePath.move(to: self.mapValueToPoint(viewModel.values[i], from: currentXOffset))
        }
        
        if viewModel.measType == 1 {
            self.minLabel.text = "\(String(format: "%.2f lbs", minY / 453.59237))"
            self.maxLabel.text = "\(String(format: "%.2f lbs", maxY / 453.59237))"
        }
        if viewModel.measType == 6 {
            self.minLabel.text = "\(String(format: "%.2f %%", Double(minY) * pow(10, -3)))"
            self.maxLabel.text = "\(String(format: "%.2f %%", Double(maxY) * pow(10, -3)))"
        }
    }
    
    private func setupViews() {
        self.addSubview(self.minLabel)
        self.addSubview(self.maxLabel)
    }
    
    
    
    private func applyConstraints() {
        NSLayoutConstraint.activate([
            // minLabel constraints
            self.minLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.minLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.minLabel.heightAnchor.constraint(equalToConstant: self.minLabel.intrinsicContentSize.height),
            
            // maxLabel constraints
            self.maxLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.maxLabel.topAnchor.constraint(equalTo: self.topAnchor),
            self.maxLabel.heightAnchor.constraint(equalToConstant: self.maxLabel.intrinsicContentSize.height),
            
        ])
    }
    
    private func applyStyles() {
        self.backgroundColor = .white
    }
}
