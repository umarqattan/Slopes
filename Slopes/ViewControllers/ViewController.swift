//
//  ViewController.swift
//  Slopes
//
//  Created by Umar Qattan on 11/3/18.
//  Copyright © 2018 Umar Qattan. All rights reserved.
//

import UIKit
import OAuthSwift
import SafariServices

class ViewController: UIViewController {

    
    // MARK: - Private properties
    private var currentOAuth2Swift: OAuth2Swift?
    private var parameters: OAuthSwift.Parameters?
    private var viewDidAppear: Bool = false
    
    
    private lazy var appDelegate: AppDelegate = {
        return UIApplication.shared.delegate as! AppDelegate
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.isUserInteractionEnabled = true
        
        return stackView
    }()
    
    private lazy var authorizeHealthKitButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Authorize HealthKit", for: .normal)
        button.addTarget(self, action: #selector(authorizeHealthKit(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private lazy var weightButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Weight", for: .normal)
        button.addTarget(self, action: #selector(getWeights(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private lazy var userDeviceButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("User Device", for: .normal)
        button.addTarget(self, action: #selector(getUserDevice(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private lazy var bodyFatPercentageButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Body Fat %", for: .normal)
        button.addTarget(self, action: #selector(getBodyFatPercentages(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(save(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.isEnabled = self.appDelegate.isHealthKitAuthorized()
        
        return button
    }()
    
    private lazy var subscribeToNotificationsButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Subscribe to Notifications", for: .normal)
        button.addTarget(self, action: #selector(subscribeToNotifications(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private lazy var getCurrentNotificationsButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get Current Notifications", for: .normal)
        button.addTarget(self, action: #selector(getCurrentNotifications(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private lazy var revokeNotificationsButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Revoke Notifications", for: .normal)
        button.addTarget(self, action: #selector(revokeNotifications(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    private lazy var viewDataButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("View Data", for: .normal)
        button.addTarget(self, action: #selector(viewData(_:)), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        
        return button
    }()
    
    
    private lazy var responseLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        label.textAlignment = .center
        
        return label
    }()
    
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !self.viewDidAppear {
            self.authorizeOAuth()
            self.viewDidAppear = true
        }
        
        self.authorizeHealthKitButton.isEnabled = !self.appDelegate.isHealthKitAuthorized()
    
        print("ViewDidAppear(_:)")
    }
    
    // MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupViews()
        self.applyConstraints()

        print("ViewDidLoad(_:)")
    }
    
    
    // MARK: - View Setup
    func setupViews() {
        self.view.addSubview(self.buttonStackView)
        self.view.addSubview(self.responseLabel)
        self.buttonStackView.addArrangedSubview(self.authorizeHealthKitButton)
        self.buttonStackView.addArrangedSubview(self.userDeviceButton)
        self.buttonStackView.addArrangedSubview(self.weightButton)
        self.buttonStackView.addArrangedSubview(self.bodyFatPercentageButton)

        self.buttonStackView.addArrangedSubview(self.subscribeToNotificationsButton)
        self.buttonStackView.addArrangedSubview(self.getCurrentNotificationsButton)
        self.buttonStackView.addArrangedSubview(self.revokeNotificationsButton)
        
        self.buttonStackView.addArrangedSubview(self.saveButton)
        self.buttonStackView.addArrangedSubview(self.viewDataButton)
    }
    
    func applyConstraints() {
        NSLayoutConstraint.activate([
            // buttonStackView constraints
            self.buttonStackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.buttonStackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.buttonStackView.widthAnchor.constraint(
                equalToConstant: max(
                    self.userDeviceButton.intrinsicContentSize.width,
                    self.weightButton.intrinsicContentSize.width,
                    self.bodyFatPercentageButton.intrinsicContentSize.width,
                    self.subscribeToNotificationsButton.intrinsicContentSize.width,
                    self.getCurrentNotificationsButton.intrinsicContentSize.width,
                    self.revokeNotificationsButton.intrinsicContentSize.width,
                    self.authorizeHealthKitButton.intrinsicContentSize.width,
                    self.saveButton.intrinsicContentSize.width,
                    self.viewDataButton.intrinsicContentSize.width
                )
            ),
            self.buttonStackView.heightAnchor.constraint(
                equalToConstant:
                    self.userDeviceButton.intrinsicContentSize.height +
                    self.weightButton.intrinsicContentSize.height +
                    self.bodyFatPercentageButton.intrinsicContentSize.height +
                    self.subscribeToNotificationsButton.intrinsicContentSize.height +
                    self.getCurrentNotificationsButton.intrinsicContentSize.height +
                    self.revokeNotificationsButton.intrinsicContentSize.height +
                    self.authorizeHealthKitButton.intrinsicContentSize.height +
                    self.saveButton.intrinsicContentSize.height +
                    self.viewDataButton.intrinsicContentSize.height
            ),
            
            // authorizeHealthKitButton constraints
            self.authorizeHealthKitButton.widthAnchor.constraint(equalToConstant: self.authorizeHealthKitButton.intrinsicContentSize.width),
            self.authorizeHealthKitButton.heightAnchor.constraint(equalToConstant: self.authorizeHealthKitButton.intrinsicContentSize.height),
            
            // userDeviceButton constraints
            self.userDeviceButton.widthAnchor.constraint(equalToConstant: self.userDeviceButton.intrinsicContentSize.width),
            self.userDeviceButton.heightAnchor.constraint(equalToConstant: self.userDeviceButton.intrinsicContentSize.height),
            
            // weightButton constraints
            self.weightButton.heightAnchor.constraint(equalToConstant: self.weightButton.intrinsicContentSize.height),
            self.weightButton.widthAnchor.constraint(equalToConstant: self.weightButton.intrinsicContentSize.width),
            
            // bodyFatPercentagesButton constraints
            self.bodyFatPercentageButton.heightAnchor.constraint(equalToConstant: self.bodyFatPercentageButton.intrinsicContentSize.height),
            self.bodyFatPercentageButton.widthAnchor.constraint(equalToConstant: self.bodyFatPercentageButton.intrinsicContentSize.width),
            
            // saveButton constraints
            self.saveButton.heightAnchor.constraint(equalToConstant: self.saveButton.intrinsicContentSize.height),
            self.saveButton.widthAnchor.constraint(equalToConstant: self.saveButton.intrinsicContentSize.width),
            
            
            // viewDataButton constraints
            self.viewDataButton.heightAnchor.constraint(equalToConstant: self.viewDataButton.intrinsicContentSize.height),
            self.viewDataButton.widthAnchor.constraint(equalToConstant: self.viewDataButton.intrinsicContentSize.width),
            
            // subscribeToNotificationsButton constraints
            self.subscribeToNotificationsButton.heightAnchor.constraint(equalToConstant: self.subscribeToNotificationsButton.intrinsicContentSize.height),
            self.subscribeToNotificationsButton.widthAnchor.constraint(equalToConstant: self.subscribeToNotificationsButton.intrinsicContentSize.width),

            // getCurrentNotificationsButton constraints
            self.getCurrentNotificationsButton.heightAnchor.constraint(equalToConstant: self.getCurrentNotificationsButton.intrinsicContentSize.height),
            self.getCurrentNotificationsButton.widthAnchor.constraint(equalToConstant: self.getCurrentNotificationsButton.intrinsicContentSize.width),

            // revokeNotificationsButton constraints
            self.revokeNotificationsButton.heightAnchor.constraint(equalToConstant: self.revokeNotificationsButton.intrinsicContentSize.height),
            self.revokeNotificationsButton.widthAnchor.constraint(equalToConstant: self.revokeNotificationsButton.intrinsicContentSize.width),

            // responseLabel constraints
            self.responseLabel.topAnchor.constraint(equalTo: self.buttonStackView.bottomAnchor, constant: 40),
            self.responseLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.responseLabel.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2.0),
        ])
    }
    
    // MARK: - Selectors
    
    @objc func authorizeHealthKit(_ sender: UIButton) {
        if !self.appDelegate.isHealthKitAuthorized() {
            self.appDelegate.authorizeHealthKit()
            self.authorizeHealthKitButton.isEnabled = !self.appDelegate.isHealthKitAuthorized()
        }
    }

    @objc func getWeights(_ sender: UIButton) {
        
        // create an instance and retain it
        
        guard let currentOAuth2Swift = self.currentOAuth2Swift else { return }
        
        
        if let parameters = self.parameters {
            self.measure(
                currentOAuth2Swift,
                accessToken: parameters["access_token"] as! String,
                meastype: 1) { (message) in
                    print(message)
            }
        }
    }
    
    @objc func save(_ sender: UIButton) {
        
        if Disk.fileExists("weight.json", in: .documents) {
            let model = Disk.retrieve("weight.json", from: .documents, as: WeightModel.self)
            self.saveWeight(model: model)
        } else {
            print("'weight.json' is unavailable.")
        }
        
        if Disk.fileExists("bodyfat.json", in: .documents) {
            let model = Disk.retrieve("bodyfat.json", from: .documents, as: BodyFatPercentageModel.self)
            self.saveBodyFat(model: model)
        } else {
            print("'bodyfat.json' is unavailable.")
        }
    }
    
    @objc func viewData(_ sender: UIButton) {
        print("Tapped viewData button")
        
        let vc = DataCollectionViewController()
        
        // generate viewModels from weight data
        let weightModel = Disk.retrieve("weight.json", from: .documents, as: WeightModel.self)
        let weightMeasurements = weightModel.body.measuregrps
        
        let bodyFatModel = Disk.retrieve("bodyfat.json", from: .documents, as: BodyFatPercentageModel.self)
        let bodyFatMeasurements = bodyFatModel.body.measuregrps
        
        var initial = true
        var currentValue = 0
        
        weightMeasurements.reversed().forEach({
            
            var delta: Int
            
            if initial {
                initial = false
                delta = 0
                vc.weightValues.append(CGFloat($0.measures[0].value))
                vc.weightViewModels.append(DataCollectionItemViewModel(
                    timeStamp: $0.date,
                    data: $0.measures[0].value,
                    delta: delta
                ))
            } else {
                
                if abs(Double($0.measures[0].value - currentValue) / 453.59237) < 5 {
                    delta = $0.measures[0].value - currentValue
                
                    vc.weightViewModels.append(DataCollectionItemViewModel(
                        timeStamp: $0.date,
                        data: $0.measures[0].value,
                        delta: delta
                    ))
                    vc.weightValues.append(CGFloat($0.measures[0].value))
                }
            }
            currentValue = $0.measures[0].value

        })
        
        initial = true
        currentValue = 0
        
        bodyFatMeasurements.reversed().forEach({
            
            var delta: Int
            
            if initial {
                
                delta = 0
                if Float($0.measures[0].value) * powf(10, -3) < 15 {
                    vc.bodyFatValues.append(CGFloat($0.measures[0].value))
                    vc.bodyFatViewModels.append(DataCollectionItemViewModel(
                        timeStamp: $0.date,
                        data: $0.measures[0].value,
                        delta: delta
                    ))
                    
                    initial = false
                    
                }
            } else {
                if Float($0.measures[0].value) * powf(10, -3) < 15 &&
                    abs(Float($0.measures[0].value - currentValue) * powf(10, -3)) < 2 {
                    
                    delta = $0.measures[0].value - currentValue
                    vc.bodyFatViewModels.append(DataCollectionItemViewModel(
                        timeStamp: $0.date,
                        data: $0.measures[0].value,
                        delta: delta
                    ))
                    vc.bodyFatValues.append(CGFloat($0.measures[0].value))

                }
            }
            currentValue = $0.measures[0].value

            
        })
        
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func saveWeight(model: WeightModel) {
        let timeStamp = model.body.measuregrps[0].date
        let gramValue = model.body.measuregrps[0].measures[0].value
        self.appDelegate.saveWeight(gramValue: gramValue, timeStamp: timeStamp)
    }
    
    func saveBodyFat(model: BodyFatPercentageModel) {
        let timeStamp = model.body.measuregrps[0].date
        let bodyFatPercentageValue = model.body.measuregrps[0].measures[0].value
        self.appDelegate.saveBodyFat(bodyFatPercentageValue: bodyFatPercentageValue, timeStamp: timeStamp)
    }
    
    func performGetWeights(successHandler: @escaping (Bool) -> ()) {
        print("Indirectly Tapped on Weight")
        
        guard let currentOAuth2Swift = self.currentOAuth2Swift else { return }
        
        if let parameters = self.parameters {
            self.measure(
                currentOAuth2Swift,
                accessToken: parameters["access_token"] as! String,
                meastype: 1) { (isNew) in
                    
                    if isNew {
                        if Disk.fileExists("weight.json", in: .documents) {
                            let model = Disk.retrieve("weight.json", from: .documents, as: WeightModel.self)
                            self.saveWeight(model: model)
                        } else {
                            print("'weight.json' is unavailable.")
                        }
                    }
                    
                    successHandler(isNew)
                    
            }
        }
    }
    
    func performGetBodyFatPercentages(successHandler: @escaping (Bool) -> ()) {
        
        print("Indirectly tapped on Body Fat %")
        
        guard let currentOAuth2Swift = self.currentOAuth2Swift else { return }
        
        if let parameters = self.parameters {
            self.measure(
                currentOAuth2Swift,
                accessToken: parameters["access_token"] as! String,
                meastype: 6) { (isNew) in
                    
                    if isNew {
                        if Disk.fileExists("bodyfat.json", in: .documents) {
                            let model = Disk.retrieve("bodyfat.json", from: .documents, as: BodyFatPercentageModel.self)
                            self.saveBodyFat(model: model)
                        } else {
                            print("'bodyfat.json' is unavailable.")
                        }
                    }
                
                    successHandler(isNew)
            }
        }
    }
    
    @objc func getUserDevice(_ sender: UIButton) {
        print("Tapped on User Device")
        
        guard let currentOAuth2Swift = self.currentOAuth2Swift else { return }
        
        if let parameters = self.parameters {
            self.userDevice(
                currentOAuth2Swift,
                accessToken: parameters["access_token"] as! String
            )
        }
    }
    
    @objc func getBodyFatPercentages(_ sender: UIButton) {
        print("Tapped on Body Fat %")
        
        guard let currentOAuth2Swift = self.currentOAuth2Swift else { return }
        
        if let parameters = self.parameters {
            self.measure(
                currentOAuth2Swift,
                accessToken: parameters["access_token"] as! String,
                meastype: 6) { (message) in
                    print(message)
            }
        }
    }
    
    @objc func subscribeToNotifications(_ sender: UIButton) {
        print("Tapped Subscribe to Notifications")
        
        guard let currentOAuth2Swift = self.currentOAuth2Swift else { return }
        
        if let parameters = self.parameters {
            self.subscribe(
                currentOAuth2Swift,
                accessToken: parameters["access_token"] as! String,
                callbackurl: "https://www.ukaton.com",
                appli: 1,
                comment: "Subscribed to Umar's 'body weight changes' notifications."
            )
        }
    }
    
    @objc func getCurrentNotifications(_ sender: UIButton) {
        print("Tapped Get Current Notifications")
        
        guard let currentOAuth2Swift = self.currentOAuth2Swift else { return }
        
        if let parameters = self.parameters {
            self.getNotifications(
                currentOAuth2Swift,
                accessToken: parameters["access_token"] as! String,
                callbackurl: "https://www.ukaton.com",
                appli: 1
            )
        }
    }
    
    @objc func revokeNotifications(_ sender: UIButton) {
        print("Tapped Revoke Notifications")
        
        guard let currentOAuth2Swift = self.currentOAuth2Swift else { return }
        
        if let parameters = self.parameters {
            self.revokeNotifications(
                currentOAuth2Swift,
                accessToken: parameters["access_token"] as! String,
                callbackurl: "https://www.ukaton.com",
                appli: 1
            )
        }
    }

    
    // MARK: - Withings API Methods
    func authorizeOAuth() {
        
        let oauthswift = OAuth2Swift(
            consumerKey:    "41830cd866aab5c7d72bfc59fe59abb5e2de2afc48f1da6c221334782f2478a1",
            consumerSecret: "d7f6e55b288e9a45884113acf41e76e3da63f3fcc26e02a203c2d776f3685ec7",
            authorizeUrl:   "https://account.withings.com/oauth2_user/authorize2",
            accessTokenUrl: "https://account.withings.com/oauth2/token",
            responseType:   "code"
        )

        oauthswift.authorizeURLHandler = self.getURLHandler(oauthSwift: oauthswift)
        
        self.appDelegate.sharedOAuth2Swift = oauthswift
        self.currentOAuth2Swift = oauthswift
        
        
        
        let state = self.generateState(withLength: 20)
        
        guard let currentOAuth2Swift = self.currentOAuth2Swift else { return }
        
            let _ = currentOAuth2Swift.authorize(
                withCallbackURL: URL(string: "oauth-swift://oauth-callback/withings")!,
                scope: "user.info,user.metrics,user.activity",
                state: state,
                success: { credential, response, parameters in
                    self.parameters = parameters
                    self.showTokenAlert(name: nil, credential: credential)
                    parameters.forEach({print($0)})

            },
                failure: { error in
                    print(error.localizedDescription)
                    
            })
    }
    
    func getURLHandler(oauthSwift: OAuth2Swift) -> OAuthSwiftURLHandlerType {
        let handler = SafariURLHandler(viewController: self, oauthSwift: oauthSwift)
        handler.presentCompletion = {
            print("Safari presented")
        }
        handler.dismissCompletion = {
            print("Safari dismissed")
        }
        handler.factory = { url in
            let controller = SFSafariViewController(url: url)
            // Customize it, for instance
            if #available(iOS 10.0, *) {
                //  controller.preferredBarTintColor = UIColor.red
            }
            return controller
        }
        return handler
    }

    func subscribe(_ oauthswift: OAuth2Swift, accessToken: String, callbackurl: String, appli: Int, comment: String) {
        let _ = oauthswift.client.get(
            "https://wbsapi.withings.net/notify",
            parameters: [
                "access_token": accessToken,
                "action": "subscribe",
                "callbackurl": callbackurl,
                "comment": comment
            ],
            success: { response in
                self.responseLabel.text = response.dataString()!
            },
            failure: { error in
                print(error)
            }
        )
    }
    
    func getNotifications(_ oauthswift: OAuth2Swift, accessToken: String, callbackurl: String, appli: Int) {
        let _ = oauthswift.client.get(
            "https://wbsapi.withings.net/notify",
            parameters: [
                "access_token": accessToken,
                "action": "get",
                "callbackurl": callbackurl
            ],
            success: { response in
                self.responseLabel.text = response.dataString()!
            },
            failure: { error in
                print(error)
            }
        )
    }
    
    func revokeNotifications(_ oauthswift: OAuth2Swift, accessToken: String, callbackurl: String, appli: Int) {
        // https://wbsapi.withings.net/notify?action=revoke
        let _ = oauthswift.client.get(
            "https://wbsapi.withings.net/notify",
            parameters: [
                "access_token": accessToken,
                "action": "revoke",
                "callbackurl": callbackurl
            ],
            success: { response in
                self.responseLabel.text = response.dataString()!
        },
            failure: { error in
                print(error)
        })
    }
    
    func userDevice(_ oauthswift: OAuth2Swift, accessToken: String) {
        let _ = oauthswift.client.get(
            "https://wbsapi.withings.net/v2/user",
            parameters: [
                "access_token": accessToken,
                "action": "getdevice"
            ],
            success: { response in
                if let responseString = response.dataString(), let jsonData = responseString.data(using: .utf8) {
                    if let model = try? JSONDecoder().decode(UserDeviceModel.self, from: jsonData) {
                        self.responseLabel.text = "Umar's has a \(model.body.devices[0].model) \(model.body.devices[0].type.lowercased())."
                    }
                }
        }, failure: { error in
            print(error)
        })
    }
    
    func measure(
        _ oauthswift: OAuth2Swift,
        accessToken: String,
        meastype: Int,
        successHandler: @escaping (Bool) -> ()) {
        if meastype == 1 { // weightModel
            if !Disk.fileExists("weight.json", in: .documents) {
                let _ = oauthswift.client.get(
                    "https://wbsapi.withings.net/measure",
                    parameters: [
                        "access_token": accessToken,
                        "action": "getmeas",
                        "meastype": String(format: "%d", arguments: [meastype])
                    ],
                    success: { response in
                        
                        if let responseString = response.dataString(), let jsonData = responseString.data(using: .utf8) {
                            if let model = try? JSONDecoder().decode(WeightModel.self, from: jsonData) {
                                Disk.store(model, to: .documents, as: "weight.json")
                                
                                let value = model.body.measuregrps[0].measures[0].value
                                let unit = model.body.measuregrps[0].measures[0].unit
                                let weight = Float(value) * powf(10, Float(unit))
                                self.responseLabel.text = "Umar weighs \(weight) kg"
                                successHandler(true)
                            }
                        }
                },
                    failure: { error in
                    }
                )
            } else { // file exists
                let oldModel = Disk.retrieve(
                    "weight.json",
                    from: .documents,
                    as: WeightModel.self
                )

                let oldDate = oldModel.body.measuregrps[0].date
                
                let _ = oauthswift.client.get(
                    "https://wbsapi.withings.net/measure",
                    parameters: [
                        "access_token": accessToken,
                        "action": "getmeas",
                        "meastype": String(format: "%d", arguments: [meastype])
                    ],
                    success: { response in
                        
                        if let responseString = response.dataString(), let jsonData = responseString.data(using: .utf8) {
                            if let model = try? JSONDecoder().decode(WeightModel.self, from: jsonData) {
                                let value = model.body.measuregrps[0].measures[0].value
                                let unit = model.body.measuregrps[0].measures[0].unit
                                let weight = Float(value) * powf(10, Float(unit))
                                let date = model.body.measuregrps[0].date
                                self.responseLabel.text = "Umar weighs \(weight) kg"
                                if oldDate < date {
                                    Disk.store(model, to: .documents, as: "weight.json")
                                    print("New Weight measurement data has been fetched.")
                                    successHandler(true)
                                } else {
                                    print("No new Weight measurement has been fetched.")
                                    successHandler(false)
                                }
                            }
                        }
                    },
                    failure: { error in
                    }
                )
            }
        } else if meastype == 6 { // bodyfat model
            if !Disk.fileExists("bodyfat.json", in: .documents) {
                let _ = oauthswift.client.get(
                    "https://wbsapi.withings.net/measure",
                    parameters: [
                        "access_token": accessToken,
                        "action": "getmeas",
                        "meastype": String(format: "%d", arguments: [meastype])
                    ],
                    success: { response in
                        
                        if let responseString = response.dataString(), let jsonData = responseString.data(using: .utf8) {
                            if let model = try? JSONDecoder().decode(BodyFatPercentageModel.self, from: jsonData) {
                                Disk.store(model, to: .documents, as: "bodyfat.json")
                                
                                let value = model.body.measuregrps[0].measures[0].value
                                let unit = model.body.measuregrps[0].measures[0].unit
                                let bodyFatPercentage = Float(value) * powf(10, Float(unit))
                                self.responseLabel.text = "Umar is \(bodyFatPercentage) % body fat"
                                successHandler(true)
                            }
                        }
                },
                    failure: { error in
                }
                )
            } else { // file exists
                let oldModel = Disk.retrieve("bodyfat.json", from: .documents, as: BodyFatPercentageModel.self)
                let oldDate = oldModel.body.measuregrps[0].date
                
                let _ = oauthswift.client.get(
                    "https://wbsapi.withings.net/measure",
                    parameters: [
                        "access_token": accessToken,
                        "action": "getmeas",
                        "meastype": String(format: "%d", arguments: [meastype])
                    ],
                    success: { response in
                        
                        if let responseString = response.dataString(), let jsonData = responseString.data(using: .utf8) {
                            if let model = try? JSONDecoder().decode(BodyFatPercentageModel.self, from: jsonData) {
                                let value = model.body.measuregrps[0].measures[0].value
                                let unit = model.body.measuregrps[0].measures[0].unit
                                let bodyFatPercentage = Float(value) * powf(10, Float(unit))
                                let date = model.body.measuregrps[0].date
                                self.responseLabel.text = "Umar is \(bodyFatPercentage) % body fat"
                                if oldDate < date {
                                    Disk.store(model, to: .documents, as: "bodyfat.json")
                                    print("New Body Fat measurement data has been fetched.")
                                    successHandler(true)
                                } else {
                                    print("No new Body Fat measurement has been fetched.")
                                    successHandler(false)
                                }
                            }
                        }
                },
                    failure: { error in
                }
                )
            }
        }
    }
    
    // MARK: - AlertView Methods
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showTokenAlert(name: String?, credential: OAuthSwiftCredential) {
        var message = "\(credential.oauthToken)"
        if !credential.oauthTokenSecret.isEmpty {
            message += "\n\noauth_token_secret:\(credential.oauthTokenSecret)"
        }
        
        self.showAlertView(title: "OAuth2 Token", message: message)
    }
    
    // MARK: - Helper methods
    public func generateState(withLength len: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let length = UInt32(letters.count)
        
        var randomString = ""
        for _ in 0..<len {
            let rand = arc4random_uniform(length)
            let idx = letters.index(letters.startIndex, offsetBy: Int(rand))
            let letter = letters[idx]
            randomString += String(letter)
        }
        return randomString
    }
}
