//
//  FitbitAPIConfig.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/31.
//

import Foundation

public class FitbitAPIConfig:Codable{
    public let clientID : String
    public let clientSecret: String
    public let redirectURL: URL
    public let scope:String
    public let expires_in:String

    static func load() -> FitbitAPIConfig{
        let filePath = Bundle.main.url(forResource: "OAuthInfo", withExtension: "json")!
        let data = try! Data(contentsOf: filePath)
        let object = try! JSONDecoder().decode(FitbitAPIConfig.self, from: data)
        return object
    }
}
