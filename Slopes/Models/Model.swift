//
//  Model.swift
//  Slopes
//
//  Created by Umar Qattan on 11/4/18.
//  Copyright © 2018 ukaton. All rights reserved.
//

import Foundation

class WeightMeasure: NSObject, Codable {
    var value: Int = 0
    var type: Int = 0
    var unit: Int = 0
    var algo: Int = 0
    var fw: Int = 0
    var fm: Int = 0
}

class BodyFatPercentageMeasure: NSObject, Codable {
    var value: Int = 0
    var type: Int = 0
    var unit: Int = 0
}

class WeightMeasureGroups: NSObject, Codable {
    var grpid: Int = 0
    var attrib: Int = 0
    var date: Int = 0
    var created: Int = 0
    var deviceid: String?
    var measures: [WeightMeasure] = [WeightMeasure]()
    var comment: String?
}

class BodyFatPercentageMeasureGroups: NSObject, Codable {
    var grpid: Int = 0
    var attrib: Int = 0
    var date: Int = 0
    var created: Int = 0
    var category: Int = 0
    var deviceid: String?
    var measures: [BodyFatPercentageMeasure] = [BodyFatPercentageMeasure]()
    var comment: String?
}

class UserDevice: NSObject, Codable {
    var type: String = ""
    var battery: String = ""
    var model: String = ""
    var deviceid: String = ""
}

class WeightBody: NSObject, Codable {
    var timezone: String = ""
    var updatetime: Int = 0
    var measuregrps: [WeightMeasureGroups] = [WeightMeasureGroups]()
}

class BodyFatPercentageBody: NSObject, Codable {
    var timezone: String = ""
    var updatetime: Int = 0
    var measuregrps: [BodyFatPercentageMeasureGroups] = [BodyFatPercentageMeasureGroups]()
}

class UserDeviceBody: NSObject, Codable {
    var devices: [UserDevice] = [UserDevice]()
}

class BodyFatPercentageModel: NSObject, Codable {
    var status: Int = 0
    var body: BodyFatPercentageBody = BodyFatPercentageBody()
    
}

class WeightModel: NSObject, Codable {
    var status: Int = 0
    var body: WeightBody = WeightBody()
}

class UserDeviceModel: NSObject, Codable {
    var status: Int = 0
    var body: UserDeviceBody = UserDeviceBody()
}



