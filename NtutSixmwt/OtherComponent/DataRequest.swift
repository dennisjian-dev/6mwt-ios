//
//  DataRequest.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/12/20.
//

import Foundation
class DataRequest{
    let url:URL
    let accessToken:String
    let authorization:String
    let refreshToken:String
    
    var receivedData:Data? = "nullData".data(using: .ascii)
    var receivedResponse:URLResponse?
    
    init(url: URL, accessToken: String, authorization: String, refreshToken: String){
        self.url = url
        self.accessToken = accessToken
        self.authorization = authorization
        self.refreshToken = refreshToken
    }
    func downLoadFitbitData(){
        let sem = DispatchSemaphore.init(value: 0)
        
        var request = URLRequest(url : self.url)
        request.setValue("Bearer  \(self.accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "accept")
        request.httpMethod = "GET"
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 3
        sessionConfig.timeoutIntervalForResource = 3
        let session = URLSession(configuration: sessionConfig)
        do{
            session.dataTask(with: request){
                (data, response, error) in
                if error == nil {
                    if let httpResponse = response as? HTTPURLResponse{
                        if(httpResponse.statusCode == 200){
                            if let data = data{
                                self.receivedData = data
                            }
                        }
                        else if(httpResponse.statusCode == 401){
                            print("token refreshing ...")
                            let tokenRequest = RefreshTokenRequest(authorization: self.authorization, refreshToken: self.refreshToken)
                            tokenRequest.downloadFitbitToken()
                            print(tokenRequest.getReceivedData())
                            self.receivedData = tokenRequest.getReceivedData()
                        }else{
                            print("error")
                        }
                        sem.signal()
                    }
                }else{
                    print(response)
                    print("token request error")
                    sem.signal()
                }
            }.resume()
        }catch{
            sem.signal()
            print("download request fail")
        }
        sem.wait()
        print("download finish")
    }
    func getReceivedData() -> Data{
        print(self.receivedData!)
        return self.receivedData!
    }
    
}
