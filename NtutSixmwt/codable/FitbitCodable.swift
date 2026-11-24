//
//  FitbitCodable.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/12/20.
//

import Foundation

struct pakagedSingleData: Codable{
    var date: String
    var Json_data: String
    var start_walking_time: Double
    var end_walking_time: Double
}

struct TestData: Identifiable{
    var id = UUID()
    var fid: String
    var Time: String
    var jsonData: String
    var startTestingTime: Double
    var endTestingTime: Double
    var checked: Bool
}

struct UserData{
    var ID: String
    var FullName: String
    var Gender: String
    var Birth: String
    var Height: String
    var Weight: String
    var StrideLengthWalking: String
    var StrideLengthRunning: String
    
    var latitude: String
    var longitude: String
    
    var heartIntraday: String
    var stepsIntraday: String
    init(){
        ID = ""
        FullName = ""
        Gender = ""
        Birth = ""
        Height = ""
        Weight = ""
        StrideLengthWalking = ""
        StrideLengthRunning = ""
        latitude = ""
        longitude = ""
        heartIntraday = ""
        stepsIntraday = ""
    }
    
}
extension UserData: Codable{
    enum CodingKeys: String, CodingKey{
        case ID = "ID"
        case FullName = "FullName"
        case Gender = "Gender"
        case Birth = "Birth"
        case Height = "Height"
        case Weight = "Weight"
        case StrideLengthWalking = "StrideLengthWalking"
        case StrideLengthRunning = "StrideLenghtRunning"
        
        case latitude = "latitude"
        case longitude = "longitude"
        
        case heartIntraday = "activities-heart-intraday"
        case stepsIntraday = "activities-steps-intraday"
    }
    init(from decoder: Decoder) throws{
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ID = try container.decode(String.self, forKey: .ID)
        FullName = try container.decode(String.self, forKey: .FullName)
        Gender = try container.decode(String.self, forKey: .Gender)
        Birth = try container.decode(String.self, forKey: .Birth)
        Height = try container.decode(String.self, forKey: .Height)
        Weight = try container.decode(String.self, forKey: .Weight)
        StrideLengthWalking = try container.decode(String.self, forKey: .StrideLengthWalking)
        StrideLengthRunning = try container.decode(String.self, forKey: .StrideLengthRunning)
        latitude = try container.decode(String.self, forKey: .latitude)
        longitude = try container.decode(String.self, forKey: .longitude)
        heartIntraday = try container.decode(String.self, forKey: .heartIntraday)
        stepsIntraday = try container.decode(String.self, forKey: .stepsIntraday)
    }
    func encode(to encoder: Encoder) throws{
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ID, forKey: .ID)
        try container.encode(FullName, forKey: .FullName)
        try container.encode(Gender, forKey: .Gender)
        try container.encode(Birth, forKey: .Birth)
        try container.encode(Height, forKey: .Height)
        try container.encode(Weight, forKey: .Weight)
        try container.encode(StrideLengthWalking, forKey: .StrideLengthWalking)
        try container.encode(StrideLengthRunning, forKey: .StrideLengthRunning)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(heartIntraday, forKey: .heartIntraday)
        try container.encode(stepsIntraday, forKey: .stepsIntraday)
    }
}

struct FBDataset: Codable{
    var dataset: [FBUnitData]?
}
struct FBUnitData: Codable{
    var value: Double
    var time: String
}


struct FBProfile: Codable{
    var user:FBUser?
}
struct FBUser: Codable{
    enum CodingKeys: String, CodingKey{
        case id = "encodedId"
        case displayName = "displayName"
        case firstName = "firstName"
        case fullName = "fullName"
        case gender = "gender"
        case birth = "dateOfBirth"
        case height = "height"
        case weight = "weight"
        case strideLengthRunning = "strideLengthRunning"
        case strideLengthWalking = "strideLengthWalking"
    }
    var id:String
    var displayName:String?
    var firstName:String?
    var fullName:String?
    var gender:String
    var birth:String
    var height:Float
    var weight:Float
    var strideLengthRunning:Float
    var strideLengthWalking:Float
}



