//
//  AuthorizationViewMode.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/24.
//

import Combine
import Foundation
import LocalAuthentication
import AuthenticationServices


class AuthorizationViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding{
//    @Environment(\.managedObjectContext) var context
//    @FetchRequest(entity: FitbitAuthor.entity())
//    var fitbhtAuthor: FetchedResults<FitbitAuthor>
    
    //singleton
//    static let shared = PersistenceController()
//    let container: NSPersostentContainer
//    init(){
//        container = NSPersostentContainer(name: "FitbitAuthor")
//        container.loadPersistentStores{ description, error in
//            if let error = error{
//                fatalError("Error: \(error.localizedDescription)")
//            }
//        }
//        context = container.context
//    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
    
    @Published var isAuth = false
    private var ks = KeychainService()
    var storage = Set<AnyCancellable>()
    var code:String = ""
    let apiData = FitbitAPIConfig.load()

    func requestToken(){
        let url = URL(string: "https://api.fitbit.com/oauth2/token")!
        let authorization = "\(self.apiData.clientID):\(self.apiData.clientSecret)"
        var requestBody = URLComponents()
        requestBody.queryItems = ["clientId": self.apiData.clientID,
                                      "grant_type": "authorization_code",
                                      "redirect_uri": self.apiData.redirectURL.absoluteString,
                                      "code": self.code].map { URLQueryItem(name: $0, value: $1)}
        var request = URLRequest(url: url)
        request.setValue("Basic \(authorization.tobase64())", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        request.httpBody = requestBody.query?.data(using: .utf8)
        
        
        let authTask = URLSession.shared.dataTask(with: request){  (data, response, error) in
            if error == nil {
                print(String(decoding: data!, as: UTF8.self))
                if let data = data{
                    do{
                        if let jsonObj = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let token = jsonObj["access_token"] as? String,
                           let refreshToken = jsonObj["refresh_token"] as? String{
                            self.ks.save(data: Data(token.utf8), key: "access_token")
                            self.ks.save(data: Data(refreshToken.utf8), key: "refresh_token")
                            self.ks.save(data: Data(authorization.tobase64().utf8) ,key: "authorization")
                        }
                    }catch{
                        print("response json decoding error or response with out token")
                    }
                }
            }else{
                print("token request error")
            }
        }
        authTask.resume()
    }
//    func getToken() -> String{
//        return self.token
//    }
    func singIn(){
        //app receives info
        let signInPromise = Future<URL, Error>{     completion in
            let authUrl = FitbitAuthenticationURLBuilder(apiData: self.apiData)()
            print("build url : " + authUrl.absoluteString)
            let authSession = ASWebAuthenticationSession(
                url: authUrl, callbackURLScheme: "myfitbit"){
                (url, error) in
                if let error = error{
                    print("author fail: " + error.localizedDescription)
                    completion(.failure(error))
                }else if let url = url{
                    print("author sucess: " + url.absoluteString)
                    completion(.success(url))
                }
            }
            authSession.presentationContextProvider = self
            authSession.prefersEphemeralWebBrowserSession = true
            authSession.start()
        }
        signInPromise.sink{
            (completion) in
            switch completion{
            case .failure(let error):
                print("impelement fail")
                print(error)
                break
            default: break
            }
        }
        receiveValue:{  (url) in
            print("recieve url : " + url.absoluteString)
            self.code = self.processResponseURL(url: url)
            self.requestToken()
        }.store(in: &self.storage)
    }
    
    func processResponseURL(url: URL)->String{
        print(url.absoluteURL)
        let fitbitComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let queryItems = fitbitComponents?.queryItems,
           let code = queryItems.filter({$0.name == "code"}).first?.value{
            print(code)
            return code
        }
        return ""
    }
}

extension String{
    func tobase64()-> String{
        return Data(self.utf8).base64EncodedString()
    }
}

