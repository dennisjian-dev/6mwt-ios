//
//  TestingViewModel.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/21.
//

import Foundation
import Combine
import CoreLocation


class TestingViewModel: ObservableObject {
    enum TestingStatus{
        case WaitingStart
        case Testing
        case Resting
        case Finish
    }
    enum AddDataCondition{
        case RefreshToken
        case NeedAuthorization
        case PersonalDataNull
        case DownloadDataNull
        case FitbitDataNotUpdate
        case NonexceptError
        case AddDataSuccess
    }
    var alertCondition:AddDataCondition = AddDataCondition.AddDataSuccess
    
    @Published var testingStatus: TestingStatus
    @Published var remainedTimeStr: String = ""
    @Published var testInfo: String = "請按開始鈕"
    @Published var alterModel: AlertModel = AlertModel()
    @Published var showLoading:Bool = false
    var nofication: Notification
    var hasSendNotification:Bool
    var location: LocationManager
    var anyCancellable = Set<AnyCancellable>()
    
    let testingTime:Int
    let restingTime:Int
    var myCountDownTimer: MyCountDownTimer!=nil
    var startTime:Date?
    var startTestingTime:Date?
    var endTestingTime:Date?
    var endTime:Date?
    var heartRateData:Data?
    var stepData:Data?
    let apiData = FitbitAPIConfig.load()
    private var ks = KeychainService()
    var user:UserData?
    
    var db :DataModel? = nil
    let sqliteURL: URL = {
        do{
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("db.sqlite")
        } catch{
            fatalError("errir getting file url from document directory")
        }
    }()
    
    init(){
        self.hasSendNotification = false
        self.testingStatus = TestingStatus.WaitingStart
        self.nofication = Notification()
        self.nofication.getPermission()// 通知授權
        self.location = LocationManager()// 初始化GPS＆授權
        self.testingTime = 360
        self.restingTime = 120
        self.myCountDownTimer = MyCountDownTimer(model: self, originTime: testingTime)
        self.remainedTimeStr = self.myCountDownTimer.convertTommss()
        self.heartRateData = Data("did not download".utf8)
        self.stepData = Data("did not download".utf8)
        
        
        user = UserData()
        let sqlitePath = sqliteURL.path
        db = DataModel(path: sqlitePath)
        
        alterModel.objectWillChange.sink{[weak self] (_)  in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }.store(in: &anyCancellable)
        myCountDownTimer.objectWillChange.sink{[weak self](_) in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }.store(in: &anyCancellable)
        loadTestCondition()
    }
    deinit{
        print("deinit viewmodel")
        setNotification()
        self.myCountDownTimer.pause()
        anyCancellable.forEach{$0.cancel()}
        saveTestCondition()
//        anyCancellable?.cancel()
    }
    
    func saveTestCondition(){
        print("saveTestCondition")
        if(self.testingStatus != TestingStatus.WaitingStart){
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            ks.save(data: Data(dateFormatter.string(from: startTime!).utf8), key: "start_time")
            ks.save(data: Data(dateFormatter.string(from: endTime!).utf8), key: "end_time")
            ks.save(data: Data(dateFormatter.string(from: startTestingTime!).utf8), key: "start_testing_time")
            ks.save(data: Data(dateFormatter.string(from: endTestingTime!).utf8), key: "end_testing_time")
            
            saveTimeRelated()
        }
    }
    func saveTimeRelated(){
        print("saveTimeRelated")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        switch testingStatus{
        case TestingStatus.WaitingStart:
            ks.save(data: Data("waiting_start".utf8), key: "test_status")
        case TestingStatus.Testing:
            ks.save(data: Data("testing".utf8), key: "test_status")
        case TestingStatus.Resting:
            ks.save(data: Data("resting".utf8), key: "test_status")
        case TestingStatus.Finish:
            ks.save(data: Data("finish".utf8), key: "test_status")
        }
        ks.save(data: Data("\(self.hasSendNotification)".utf8), key: "has_send_notification")
        ks.save(data: Data(self.myCountDownTimer.convertTommss().utf8), key: "remainder_time")
        ks.save(data: Data(dateFormatter.string(from: Date()).utf8), key: "last_time")
    }
    func deleteAllCondition(){
        ks.deleteData(key: "start_time")
        ks.deleteData(key: "end_time")
        ks.deleteData(key: "start_testing_time")
        ks.deleteData(key: "end_testing_time")
        ks.deleteData(key: "remainder_time")
        ks.deleteData(key: "test_status")
        ks.deleteData(key: "last_time")
        ks.deleteData(key: "has_send_notification")
    }
    func loadTestCondition(){

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        if let mstartTime = ks.retriveData(key: "start_time"),
        let mendTime = ks.retriveData(key: "end_time"),
        let mstartTestingTime = ks.retriveData(key: "start_testing_time"),
        let mendTestingTime = ks.retriveData(key: "end_testing_time"),
        let tstartTime = dateFormatter.date(from: mstartTime),
        let tendTime = dateFormatter.date(from: mendTime),
        let tstartTestingTime = dateFormatter.date(from: mstartTestingTime),
        let tendTestingTime = dateFormatter.date(from: mendTestingTime){
            print("continue test")
            startTime = tstartTime
            endTime = tendTime
            startTestingTime = tstartTestingTime
            endTestingTime = tendTestingTime
            loadTimerRelated()
        }else{
            deleteAllCondition()
        }
            
    }
    func loadTimerRelated(){
        if let test_status = ks.retriveData(key: "test_status"),
           let has_send_notification = ks.retriveData(key: "has_send_notification"),
           let remainder_time = ks.retriveData(key: "remainder_time"){
            switch has_send_notification{
            case "true":
                self.hasSendNotification = true
            case "false":
                self.hasSendNotification = false
            default:
                break
            }
            switch test_status{
            case "waiting_start":
                testingStatus = TestingStatus.WaitingStart
                return
            case "testing":
                testingStatus = TestingStatus.Testing
            case "resting":
                testingStatus = TestingStatus.Resting
            case "finish":
                testingStatus = TestingStatus.Finish
            default:
                testingStatus = TestingStatus.WaitingStart
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "mm:ss"
            let remainderTime = Int(dateFormatter.date(from: remainder_time)!.timeIntervalSince1970 - dateFormatter.date(from: "00:00")!.timeIntervalSince1970)
            let delta = calDelta()
            let rT = calRemainderTime(delta: delta, lastRemainderTime: remainderTime)
            switch testingStatus{
            case .WaitingStart:
                self.testInfo = "請按開始鈕"
            case .Testing:
                self.testInfo = "步行測試進行中"
            case .Resting:
                self.testInfo = "請靜待休息"
            case .Finish:
                self.testInfo = "測試完成\n請下載資料"
            }
            self.myCountDownTimer.reset(time: rT)
            self.myCountDownTimer.start()
        }else{
            deleteAllCondition()
        }
    }
    func calDelta() -> Int{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        let now = Date()
        let lastTime = ks.retriveData(key: "last_time")!
        let delta = (Int((now - dateFormatter.date(from: lastTime)!.timeIntervalSince1970).timeIntervalSince1970))
        return delta
    }
    func calRemainderTime(delta:Int, lastRemainderTime: Int) -> Int{
        var currRemainderTime = 0
        switch testingStatus {
        case .Testing:
            currRemainderTime = lastRemainderTime + restingTime
            currRemainderTime = currRemainderTime - delta
            if(currRemainderTime > restingTime){
                currRemainderTime = currRemainderTime - restingTime
            }else if( currRemainderTime <= 0){
                currRemainderTime = 0
                testingStatus = TestingStatus.Finish
            }else{
                testingStatus = TestingStatus.Resting
            }
        case .Resting:
            currRemainderTime = lastRemainderTime - delta
            if( currRemainderTime <= 0){
                currRemainderTime = 0
                testingStatus = TestingStatus.Finish
            }
        default:
            break
        }
        
        return currRemainderTime
    }
    
    func setNotification(){
        if(hasSendNotification){
            return
        }
        hasSendNotification = true
        if(testingStatus != TestingStatus.WaitingStart && testingStatus != TestingStatus.Finish){
            nofication.addNotification(title: "6分鐘測試提醒", subtitile: "您還在測試中，請留意測試通知", notifedTime: Double(2))
        }
        switch testingStatus{
        case TestingStatus.WaitingStart:
            print("do nothing")
        case TestingStatus.Testing:
            var notiTime = myCountDownTimer.getRemainedTime()
            if(notiTime < 1){
                notiTime = 1
            }
            nofication.addNotification(title: "6分鐘測試步行時間到", subtitile: "請休息靜待通知，或打開app等休息時間結束", notifedTime: Double(notiTime))
            nofication.addNotification(title: "6分鐘測試測試完成", subtitile: "測試已完成，請至fitbit app 更新資料，再回來新增資料", notifedTime: Double(notiTime + restingTime))
        case TestingStatus.Resting:
            let notiTime = myCountDownTimer.getRemainedTime()
            nofication.addNotification(title: "6分鐘測試測試完成", subtitile: "測試已完成，請至fitbit app 更新資料，再回來新增資料", notifedTime: Double(notiTime))
        case TestingStatus.Finish:
            print("do nothing")
        }
    }
    
    func setTimer(option: String){
        
        switch option {
        case "start":
            self.alterModel.setAlert(title: "開始前確認", content: "請確定在測試前已經休息2分鐘以上", isShowOption: true)
        case "pause":
            self.myCountDownTimer.pause()
        case "reset":
            print("reset")
            self.alterModel.setAlert(title: "確定要重置計時器？", content: "", isShowOption: true)
        default:
            break
        }
    }

    func startTimer(){
        self.testInfo = "步行測試進行中"
        recordTime(message: "start")
        self.myCountDownTimer.start()
    }
    func recordTime(message:String){
        if message.compare("start", options: .caseInsensitive) == .orderedSame && self.testingStatus == TestingStatus.WaitingStart{
            if self.testingStatus == TestingStatus.WaitingStart{
                self.testingStatus = TestingStatus.Testing
                self.startTime = getCurrentTime(time: -3)
                self.startTestingTime = getCurrentTime(time: 0)
                self.endTestingTime = getCurrentTime(time: testingTime/60)
                self.endTime = getCurrentTime(time: testingTime/60+restingTime/60)
            }
        }
    }
    func resetTimer(){
        self.testInfo = "請按開始鈕"
        self.hasSendNotification = false
        deleteAllCondition()
        self.testingStatus = TestingStatus.WaitingStart
        self.myCountDownTimer.reset(time: testingTime)
    }

    //call by countdownTimer
    func timerDone(){
        self.location.requestLocation()
        switch testingStatus{
        case TestingStatus.WaitingStart:
            print("status error")
        case TestingStatus.Testing:
            self.testInfo = "請靜待休息"
            testingStatus = TestingStatus.Resting
            self.myCountDownTimer.reset(time: restingTime)
            self.myCountDownTimer.start()
        case TestingStatus.Resting:
            self.testInfo = "測試完成\n請先至fitbit app更新資料\n再按下載資料"
            testingStatus = TestingStatus.Finish
        case TestingStatus.Finish:
            print("status error")
        }
        print(testInfo)
    }

    
    func updateRemainedTime(){
        self.remainedTimeStr = self.myCountDownTimer.convertTommss()
    }
    
    func getCurrentTime(time: Int)->Date{
        let now = Date()
        let newTime = Calendar.current.date(byAdding: .minute, value: time, to: now)!
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let stringDate = timeFormatter.string(from: newTime)
        return newTime
    }
    
    func downLoadFitbitData(){
        let myDataQueue = DispatchQueue(label: "DataQueue",qos: .userInitiated,attributes: .concurrent,autoreleaseFrequency: .workItem,target: nil)
        
        self.showLoading = true

        myDataQueue.async {
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            let tf = DateFormatter()
            tf.dateFormat = "HH:mm"
            let authorization = "\(self.apiData.clientID):\(self.apiData.clientSecret)"
            var accessToken = ""
            var refreshToken = ""
            if let token = self.ks.retriveData(key: "access_token"){
                accessToken = token
            }
            if let token = self.ks.retriveData(key: "refresh_token"){
                refreshToken = token
            }
            let newEndTime = Calendar.current.date(byAdding: .minute, value: 1, to: self.endTime!)!
            for _ in 0..<3{
                
                var url = URL(string: "https://api.fitbit.com/1/user/-/activities/heart/date/\(df.string(from: self.startTime!))/\(df.string(from: newEndTime))/1sec/time/\(tf.string(from: self.startTime!))/\(tf.string(from: newEndTime)).json")!
                var dataRequest = DataRequest(url: url, accessToken: accessToken, authorization: authorization, refreshToken: refreshToken)
                dataRequest.downLoadFitbitData();
                self.heartRateData = dataRequest.getReceivedData()
                
                url = URL(string: "https://api.fitbit.com/1/user/-/activities/steps/date/\(df.string(from: self.startTime!))/\(df.string(from: newEndTime))/1min/time/\(tf.string(from: self.startTime!))/\(tf.string(from: newEndTime)).json")!
                dataRequest = DataRequest(url: url, accessToken: accessToken, authorization: authorization, refreshToken: refreshToken)
                dataRequest.downLoadFitbitData();
                self.stepData = dataRequest.getReceivedData()
                self.location.requestLocation()
                if(self.checkDataCondition()){
                    break
                }
                sleep(2)
            }
            DispatchQueue.main.async {
                self.showLoading = false
            }
            self.sendAlert()
        }
        
    }
    func sendAlert(){
        switch self.alertCondition{
        case .NeedAuthorization:
            self.alterModel.setAlert(title: "下載測試資料失敗", content: "請回首頁重新授權", isShowOption: false)
        case .PersonalDataNull:
            self.alterModel.setAlert(title: "未下載使用者資料", content: "請至使用者頁面下載資料", isShowOption: false)
        case .DownloadDataNull:
            self.alterModel.setAlert(title: "下載測試資料失敗", content: "請稍後再試，或回首頁重新授權", isShowOption: false)
        case .FitbitDataNotUpdate:
            self.alterModel.setAlert(title: "手錶資料未更新", content: "請至fitbit app 更新資料", isShowOption: false)
        case .NonexceptError:
            self.alterModel.setAlert(title: "資料新增失敗", content: "新增資料失敗，未知錯誤", isShowOption: false)
        case .AddDataSuccess:
            self.alterModel.setAlert(title: "資料新增成功", content: "", isShowOption: false)
        case .RefreshToken:
            self.alterModel.setAlert(title: "重新刷新token", content: "請再下載一次", isShowOption: false)
        }
    }
    
    func addDataToList()->Bool{
        let formatterDate = DateFormatter()
        formatterDate.dateFormat = "yyyy/MM/dd HH:mm"
        guard let _ = self.user else{
            return false
        }
        self.user!.latitude = self.location.getLatitude()
        self.user!.longitude = self.location.getLongitude()
        let id = "'\(self.user!.ID)'"
        let keyStr = "'\(formatterDate.string(from: self.endTime!))'"
        let jsonStr = "'\(String(decoding: try! JSONEncoder().encode(self.user!), as: UTF8.self))'"
//        print(jsonStr)
        let startTimeDou = self.startTestingTime!.timeIntervalSince1970
        let endTimeDou = self.endTestingTime!.timeIntervalSince1970
        let insertStatus = db!.insert("data_list", rowInfo: ["ID":id,"Time":keyStr,"JsonData":jsonStr,"StartTestingTime":String(format: "%.1f",startTimeDou),"EndTestingTime":String(format: "%.1f",endTimeDou)])
        if(insertStatus){
            print("insert succes")
            return true
        }
        print("insert fail")
        return false
    }
    
    
    func checkDataCondition() -> Bool{
        if(self.checkAuthorizatoin(data: heartRateData!)){
            self.alertCondition = AddDataCondition.NeedAuthorization //沒授權 停止下載
            return true
        }
        if(!self.checkHavingPersonalData()){
            self.alertCondition = AddDataCondition.PersonalDataNull //沒下載使用者資料 停止下載
            return true
        }
        
        if(self.isRefreshToken(data: heartRateData!)){
            self.alertCondition = AddDataCondition.RefreshToken //刷token 繼續下載
            return false
        }
        if(self.downLoadDataIsNull()){
            self.alertCondition = AddDataCondition.DownloadDataNull //下載失敗 繼續下載
            return false
        }
        if(self.dataIsNotUpdated()){
            self.alertCondition = AddDataCondition.FitbitDataNotUpdate //沒更新資料 停止下載
            return true
        }

        if(!self.addDataToList()){
            self.alertCondition = AddDataCondition.NonexceptError //新增失敗 停止下載
            return false
        }
       
        self.alertCondition = AddDataCondition.AddDataSuccess
        return true
    }
    
    func checkHavingPersonalData()->Bool{
        if let userData = ks.retriveData(key: "user_data"){
            do{
                let userObj = try JSONDecoder().decode(UserData.self, from: userData.data(using: .utf8)!)
                if (userObj.ID == "null" || userObj.ID == ""){
                    return false
                }
                self.user = userObj
                return true
            }catch{
                print("decode personal data error")
            }
        }
        return false
    }
    func checkAuthorizatoin(data: Data) -> Bool{
        let dataStr = String(decoding: data, as: UTF8.self)
        if (dataStr.contains("invalid_grant") && dataStr.contains("errors")){
            return true
        }
        return false
    }
    func isRefreshToken(data: Data) -> Bool{
        let dataStr = String(decoding: data, as: UTF8.self)
        if (dataStr.contains("access_token") && dataStr.contains("refresh_token")){
            
            storeToken(data:data)
            return true
        }
        return false
    }
    func dataIsNotUpdated()->Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        do{
            let heartRate = try JSONDecoder().decode(FBDataset.self, from: user!.heartIntraday.data(using: .utf8)!)
            if (heartRate.dataset != nil && heartRate.dataset!.count > 0){
//                print(heartRate.dataset)
                let lastDataTime = dateFormatter.date(from: heartRate.dataset![heartRate.dataset!.count - 1].time)!.timeIntervalSince1970
                let newEndTime = dateFormatter.date(from: dateFormatter.string(from: endTime!))!.timeIntervalSince1970
                print("\(dateFormatter.string(from: NSDate(timeIntervalSince1970: lastDataTime) as Date))")
                print("\(dateFormatter.string(from: NSDate(timeIntervalSince1970: newEndTime) as Date))")
                if(lastDataTime - newEndTime > -30){
                    return false
                }
            }
        }catch{
            print("heart rate intraday decode error")
        }
        return true
    }
    
    func downLoadDataIsNull()->Bool{
        self.user!.heartIntraday = parseHeartRateJson()
        self.user!.stepsIntraday = parseStepJson()
        if(self.user!.heartIntraday != "" && self.user!.stepsIntraday != ""){
            return false
        }
        print("there is activities data is null")
        return true
    }
    func parseHeartRateJson()->String{
//        print(String(decoding: heartRateData!, as: UTF8.self))
        do{
            if let heartRateObj = try JSONSerialization.jsonObject(with: heartRateData!) as? [String: Any]{
                if let heartRate = heartRateObj["activities-heart-intraday"] as? [String:Any]{
                    let jsonData = try JSONSerialization.data(withJSONObject: heartRate, options: [])
                    return String(data: jsonData, encoding: String.Encoding.utf8)!
                }else{
                    print("heart rate is null")
                }
            }
        }catch{
            print("parse heart fail")
        }
        return ""
    }
    func parseStepJson()->String{
//        print(String(decoding: stepData!, as: UTF8.self))
        do{
            if let stepObj = try JSONSerialization.jsonObject(with: stepData!) as? [String: Any]{
                if let step = stepObj["activities-steps-intraday"] as? [String:Any]{
                    let jsonData = try JSONSerialization.data(withJSONObject: step, options: [])
                    return String(data: jsonData, encoding: String.Encoding.utf8)!
                }else{
                    print("step step is null")
                }
            }
        }catch{
            print("parse step fail")
        }
        return ""
    }


    
    
    func storeToken(data : Data){
        do{
            if let jsonObj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let token = jsonObj["access_token"] as? String,
               let refreshToken = jsonObj["refresh_token"] as? String{
                self.ks.save(data: Data(token.utf8), key: "access_token")
                self.ks.save(data: Data(refreshToken.utf8), key: "refresh_token")
            }
        }catch{
            print("seve refresh token error")
        }
    }
    

//------------------------Timer----------------------------------------------
    class MyCountDownTimer: ObservableObject{
        enum TimerStatus{
            case WaitStart
            case Counting
            case Pause
            case Done
        }
        @Published var timerStatus: TimerStatus
        @Published var remainedTime: Int
        private var customTimer: Timer
        weak var testingViewModel: TestingViewModel?
        
        init(model: TestingViewModel, originTime: Int){
            self.timerStatus = TimerStatus.WaitStart
            self.remainedTime = originTime
            self.customTimer = Timer.init()
            self.testingViewModel = model
        }
        
        func getRemainedTime() -> Int{
            return self.remainedTime
        }
        func getStatus() -> TimerStatus{
            return self.timerStatus
        }
        
        func start(){
            print("start")
            timerStatus = TimerStatus.Counting
            self.customTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
        }
        @objc func countdown(){
            if(self.remainedTime > 0){
                self.remainedTime -= 1
            }else{
                timerStatus = TimerStatus.Done
                self.customTimer.invalidate()//stop counting
                self.testingViewModel!.timerDone()
            }
            updateModel()
        }
        func pause(){
            print("pause")
            print("\(remainedTime)")
            timerStatus = TimerStatus.Pause
            self.customTimer.invalidate()
        }
        func reset(time : Int){
            self.timerStatus = TimerStatus.WaitStart
            self.customTimer.invalidate()
            self.remainedTime = time
            updateModel()
        }
        
        func convertTommss() -> String{
            var minus: String
            var second: String
            if(self.remainedTime / 60 < 10){
                minus = "0" + String(self.remainedTime/60)
            }else{
                minus = String(self.remainedTime/60)
            }
            if(self.remainedTime % 60 < 10){
                second = "0" + String(self.remainedTime%60)
            }else{
                second = String(self.remainedTime%60)
            }
            //print("\(minus):\(second)")
            return "\(minus):\(second)"
        }
        
        func updateModel(){
//            print("\(remainedTime)")
            self.testingViewModel!.updateRemainedTime()
        }
        
    }
    
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
