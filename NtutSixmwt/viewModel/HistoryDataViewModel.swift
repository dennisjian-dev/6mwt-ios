//
//  HistoryDataViewModel.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/12/14.
//
import SQLite3
import Foundation

class HistoryDataViewModel: ObservableObject{
    @Published var dataList = Array<TestData>()
    @Published var showLoading:Bool = false
    @Published var alterModel: AlertModel = AlertModel()
    
    var db :DataModel? = nil
    let sqliteURL: URL = {
        do{
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("db.sqlite")
        } catch{
            fatalError("errir getting file url from document directory")
        }
    }()
    
    init(){
        let sqlitePath = sqliteURL.path
        db = DataModel(path: sqlitePath)
    }
    func updateList(){
        if let mydb = db {
            self.dataList.removeAll()
            let statement = mydb.fetch("data_list", cond: nil, order: "Time desc")
            while sqlite3_step(statement) == SQLITE_ROW{
                let id = String(cString: sqlite3_column_text(statement, 0))
                let time = String(cString: sqlite3_column_text(statement, 1))
                let jsonData = String(cString: sqlite3_column_text(statement, 2))
                let startTestingTime = sqlite3_column_double(statement, 3)
                let endTestingTime = sqlite3_column_double(statement, 4)
                let testData = TestData(fid: id, Time: time, jsonData: jsonData, startTestingTime: startTestingTime, endTestingTime: endTestingTime, checked: false)
                self.dataList.append(testData)
            }
            sqlite3_finalize(statement)
            print("update list")
        }
    }
    func deleteData(indices: IndexSet){
        if(indices.count > 0){
            let index = Array(indices)[0]
            let item = self.dataList[index]
            if let mydb = db{
                let deleteStatement = mydb.delete("data_list", cond: "Time = '\(item.Time)'")
            }
        }
    }
    func cleanCheck(){
        for i in 0..<self.dataList.count{
            self.dataList[i].checked = false
        }
    }
    func postData(){
        let myDataQueue = DispatchQueue(label: "DataQueue",qos: .userInitiated,attributes: .concurrent,autoreleaseFrequency: .workItem,target: nil)

        self.showLoading = true
        var successful = false
        myDataQueue.async {
            var checkedCount:Int = 0
            var postList = Array<pakagedSingleData>()
            for i in 0..<self.dataList.count{
                if(self.dataList[i].checked){
                    let obj = self.dataList[i]
                    let singleData:pakagedSingleData = pakagedSingleData(date: obj.Time, Json_data: obj.jsonData, start_walking_time: obj.startTestingTime, end_walking_time: obj.endTestingTime)
                    postList.append(singleData)
                    checkedCount += 1
                }
            }
            if(checkedCount > 0){
                do{
                    let json = try JSONEncoder().encode(postList)
//                    print(String(data: json, encoding: .utf8)!)
                    successful = self.postRequest(data: json)
                }catch{
                    print("post json encoded error")
                }
            }
            sleep(1)
            DispatchQueue.main.async {
                self.showLoading = false
            }
            
            if(successful){
                self.alterModel.setAlert(title: "上傳成功", content: "", isShowOption: false)
            }else{
                self.alterModel.setAlert(title: "上傳失敗", content: "請再試一次", isShowOption: false)
            }
        }
    }
    
    func postRequest(data: Data) -> Bool{
        var successful = false
        let sem = DispatchSemaphore.init(value: 0)
        
        let url = URL(string:"https://asia-east1-norse-block-332306.cloudfunctions.net/sixmwt_api2")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard let data = data, error == nil else{
                print(error?.localizedDescription ?? "No response")
                sem.signal()
                return
            }
            if let responseData = String(data: data, encoding: .utf8){
                print("\(responseData)")
                if(responseData.contains("sucess")){
                    successful = true
                    sem.signal()
                }
                return
            }
            print("data is null")
        }
        task.resume()
        sem.wait()
        return successful
    }
}
