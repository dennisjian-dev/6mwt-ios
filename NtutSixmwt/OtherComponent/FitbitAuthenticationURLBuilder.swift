//
//  FitbitAuthenticationURLBuilder.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/31.
//

import Foundation

public class FitbitAuthenticationURLBuilder{
    let domain: String
    let apiData: FitbitAPIConfig
    
    init(domain:String = "www.fitbit.com", apiData: FitbitAPIConfig){
        self.domain = domain
        self.apiData = apiData
    }
    var url: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = domain
        components.path = "/oauth2/authorize"
        components.queryItems = [URLQueryItem(name: "client_id", value: String(self.apiData.clientID)),
                                 URLQueryItem(name: "scope",value : String(self.apiData.scope)),
                                 //URLQueryItem (name: "redirect_uri",value : self.apiData.redirectURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)),
                                 URLQueryItem(name: "expires_in", value: String(self.apiData.expires_in)),
                                 URLQueryItem(name: "response_type",value :"code")]
        let urlwithRedirect = components.url!.absoluteString + "&redirect_uri=" + self.apiData.redirectURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        return URL(string: urlwithRedirect)!
    }
    func callAsFunction() -> URL{
        return url
    }
}
