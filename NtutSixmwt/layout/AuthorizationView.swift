//
//  AuthorizatoinView.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/11/1.
//

import SwiftUI
import AuthenticationServices

struct AuthorizationView: View {
    @StateObject var viewModel = AuthorizationViewModel()
    @State private var showView = false
    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                Spacer()
                VStack{
                    Image("sixmwt_logo").renderingMode(.template).resizable().scaledToFit()
                        .frame(width: 150, height: 75, alignment: .center)
                        .foregroundColor(.white)
                }.frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight*0.3, alignment: .center)
                VStack(spacing:15){
                    Button(action: {viewModel.singIn()}){
                        Text("授權")
                            .fontWeight(.black)
                            .foregroundColor(Color(red:0.235, green:0.725, blue:1))
                    }.padding()
                    .frame(width: UIScreen.screenWidth*0.4)
                    .background(Color.white)
                    .clipShape(Capsule())
                    
//                    SignInWithAppleButton{ request in
//                        request.requestedScopes = [.email, .fullName]
//                    }onCompletion:{ result in
//                        switch (result){
//                            case .success(let authorization):
//                                switch(authorization.credential){
//                                    case let cred as ASAuthorizationAppleIDCredential:
//                                        let userIdentifier = cred.user
//                                        let fullName = cred.fullName
//                                        let email = cred.email
//                                        print((userIdentifier, fullName, email))
//
//                                    case let cred as ASPasswordCredential:
//                                        let username = cred.user
//                                        let password = cred.password
//                                        print((username, password))
//                                    default:
//                                        break
//                                }
//                            case .failure(let error):
//                                print("ERROR: \(error)")
//                        }
//                    }.signInWithAppleButtonStyle(.white)
                    
                    NavigationLink(destination: TabNavigatorView(), isActive: $showView){
                        Button(action: {showView = true}){
                            Text("開始測試")
                                .fontWeight(.black)
                                .foregroundColor(Color(red:0.235, green:0.725, blue:1))
                        }.padding()
                        .frame(width: UIScreen.screenWidth*0.4)
                        .background(Color.white)
                        .clipShape(Capsule())
                    }
                }.frame(width: UIScreen.screenWidth, height: UIScreen.screenHeight*0.3, alignment: .center)
                Spacer()
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).background(Color(red:0.235, green:0.725, blue:1))
            .navigationBarTitle("", displayMode: .inline)
        }.navigationViewStyle(StackNavigationViewStyle())
        
    }
}

struct AuthorizatoinView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationView()
    }
}

extension UIScreen{
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
