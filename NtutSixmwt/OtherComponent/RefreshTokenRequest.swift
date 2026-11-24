//
//  RefreshTokenRequest.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/12/20.
//

import Foundation

class RefreshTokenRequest{
    let url:URL
    let authorization:String
    let refreshToken:String
    
    var receivedData:Data? = "nullToken".data(using: .ascii)
    var receivedResponse:URLResponse?
    
    init(authorization: String, refreshToken: String){
        self.url = URL(string: "https://api.fitbit.com/oauth2/token")!
        self.authorization = authorization
        self.refreshToken = refreshToken
    }
    func downloadFitbitToken(){
        let sem = DispatchSemaphore.init(value: 0)
        var request = URLRequest(url : self.url)
        request.setValue("Basic \(self.authorization.tobase64())", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.httpMethod = "POST"
        var requestBody = URLComponents()
        requestBody.queryItems = ["expires_in": "3600",
                                  "grant_type": "refresh_token",
                                  "refresh_token": self.refreshToken].map { URLQueryItem(name: $0, value: $1)}
        request.httpBody = requestBody.query?.data(using: .utf8)
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 3
        sessionConfig.timeoutIntervalForResource = 3
        let session = URLSession(configuration: sessionConfig)
        do{
            session.dataTask(with: request){
                (data, response, error) in
                defer{sem.signal()}
                if error == nil {
                    print("refresh success")
                    if let data = data{
                        self.receivedData = data
                        print(String(decoding: data,as: UTF8.self ))
                    }
                }else{
                    print("refresh token request connect error")
                    print(response)
                }
            }.resume()
        }catch{
            defer{sem.signal()}
            print("refresh token request fail")
        }
        sem.wait()
        print("cc")
    }
    func getReceivedData() -> Data{
        return self.receivedData!
    }
}

