//
//  NtutSixmwtApp.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/10/12.
//

import SwiftUI

@main

struct NtutSixmwtApp: App {
//    let persistenceController = PersistenceController.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        
        WindowGroup{
            AuthorizationView()
            //TabNavigatorView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


