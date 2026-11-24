//
//  PersonalDataViewModel.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/11/30.
//

import Foundation

class PersonalDataViewModel: ObservableObject {
    private var ks = KeychainService()
    var personalDataJson:Data?
    var namekeys: Array<String>
    let apiData = FitbitAPIConfig.load()
    let userkeys:Array<String>
    @Published var user:UserData?
    
    @Published var dataDict: Dictionary<String, String>
    init(){
        self.namekeys = ["fullName","lastName","firstName"]
        self.userkeys = ["encodeId","gender","dateOfBirth","height","weight","strideLengthRunning","strideLengthWalking"]
        self.dataDict = [String:String]()
        initUserData()
    }
    func initUserData(){
        print("init user")
        let ks = KeychainService()
        if let userData = ks.retriveData(key: "user_data"){
            do{
                print(userData)
                let userObj = try JSONDecoder().decode(UserData.self, from: userData.data(using: .utf8)!)
                    self.user = userObj
            }catch{
                print("load user data fail")
            }
        }else{
            self.user = UserData()
        }
    }
    
    func getUserData()->UserData?{
        return self.user
    }
    
    
    func downLoadPersonalData(){
        let ks = KeychainService()
        let authorization = "\(self.apiData.clientID):\(self.apiData.clientSecret)"
        let url = URL(string: "https://api.fitbit.com/1/user/-/profile.json")!
        var accessToken = ""
        var refreshToken = ""
        if let token = self.ks.retriveData(key: "access_token"){
            accessToken = token
        }
        if let token = self.ks.retriveData(key: "refresh_token"){
            refreshToken = token
        }
        let dataRequest = DataRequest(url: url, accessToken: accessToken, authorization: authorization, refreshToken: refreshToken)
        dataRequest.downLoadFitbitData()
        personalDataJson = dataRequest.getReceivedData()
        if(!isRefreshToken(data: personalDataJson!)){
            decodeDataJson()
            saveUserData()
        }
    }
    func decodeDataJson(){
        print(String(decoding: personalDataJson!, as: UTF8.self))
        do{
            let userData = try! JSONDecoder().decode(FBProfile.self, from: personalDataJson!)
            user!.ID = userData.user?.id ?? "null"
            user!.Birth = userData.user?.birth ?? "null"
            user!.Gender = userData.user?.gender ?? "null"
            user!.Height = String(format: "%.2f",userData.user?.height ?? "0")
            user!.Weight = String(format: "%.2f",userData.user?.weight ?? "0")
            user!.StrideLengthWalking = String(format: "%.2f", userData.user?.strideLengthWalking ?? "0")
            user!.StrideLengthRunning = String(format: "%.2f", userData.user?.strideLengthRunning ?? "0")
            if let name = userData.user?.firstName{
                user!.FullName = name
            }
            if let name = userData.user?.displayName{
                user!.FullName = name
            }
            if let name = userData.user?.fullName{
                user!.FullName = name
            }
        }catch{
            print("parse user json fail")
        }
    }
    
    func saveUserData(){
        if let userStr = try? JSONEncoder().encode(user){
            ks.save(data: userStr, key: "user_data")
        }else{
            print("user is null")
        }
    }

    func isRefreshToken(data: Data) -> Bool{
        let dataStr = String(decoding: data, as: UTF8.self)
        if (dataStr.contains("access_token") && dataStr.contains("refresh_token")){
            storeToken(data:data)
            return true
        }
        return false
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

}
