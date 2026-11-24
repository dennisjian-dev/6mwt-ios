//
//  TestDataDetailViewModel.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2022/3/1.
//

import Foundation
import UIKit

class TestDataDetailViewModel: ObservableObject{
    let testData: TestData
    var heartValueList: [Double]?
    var heartTimeList: [Double]?
    var stepValueList: [Double]?
    var stepTimeList: [Double]?
    var startTime:Double
    var endTime:Double
    var count = 0
    
    init (testData: TestData){
        self.testData = testData
        self.startTime = 0
        self.endTime = 0
        
//
    }
    
    func decodeHeartJson(){
        print(testData.jsonData)
            do{
                let jsonData = testData.jsonData
                let jsonObj = try JSONDecoder().decode(UserData.self, from: jsonData.data(using: .utf8)!)
                let heartRate = try JSONDecoder().decode(FBDataset.self, from: jsonObj.heartIntraday.data(using: .utf8)!)
                if (heartRate.dataset != nil && heartRate.dataset!.count > 0){
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm:ss"
                    var valueList = [Double]()
                    var timeList = [Double]()
                    for item in heartRate.dataset!{
                        valueList.append(item.value)
                        timeList.append(dateFormatter.date(from: item.time)!.timeIntervalSince1970)
                    }
//                    print(valueList)
//                    print(timeList)
                    self.startTime = self.testData.startTestingTime
                    self.endTime = self.testData.endTestingTime
                    self.heartValueList = valueList
                    self.heartTimeList = timeList
                }
            }catch{
                print("decode fail")
            }
    }
    func decodeStepJson(){
            do{
                let jsonData = testData.jsonData
                let jsonObj = try JSONDecoder().decode(UserData.self, from: jsonData.data(using: .utf8)!)
                let step = try JSONDecoder().decode(FBDataset.self, from: jsonObj.stepsIntraday.data(using: .utf8)!)
                if (step.dataset != nil && step.dataset!.count > 0){
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "HH:mm:ss"
                    var valueList = [Double]()
                    var timeList = [Double]()
                    for item in step.dataset!{
                        valueList.append(item.value)
                        timeList.append(dateFormatter.date(from: item.time)!.timeIntervalSince1970)
                    }
                    self.stepValueList = valueList
                    self.stepTimeList = timeList
                }
                
            }catch{
                print("decode fail")
            }
    }
    
    
    func convertToTimeDouble(mTime: Double)->Double{

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        
        let mTimeStr = dateFormatter.string(from: Date.init(timeIntervalSince1970: mTime))
        let newmTime = dateFormatter.date(from: mTimeStr)!.timeIntervalSince1970
        return newmTime
    }
    func getHeartRateValueList()->[Double]{
        if let valueList = self.heartValueList{
//            print(valueList)
            return valueList
        }
        return []
    }
    func getHeartRateTimeList()->[Double]{
        if let valueList = self.heartTimeList{
//            print(valueList)
            return valueList
        }
        return []
    }
    func getStepValueList()->[Double]{
        if let valueList = self.stepValueList{
            return valueList
        }
        return []
    }
    func getStepTimeList()->[Double]{
        if let valueList = self.stepTimeList{
            return valueList
        }
        return []
    }
}
