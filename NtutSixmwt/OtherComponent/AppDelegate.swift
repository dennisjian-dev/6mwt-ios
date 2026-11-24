//
//  AppDelegate.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2022/4/1.
//
import SwiftUI
import Foundation

class AppDelegate: NSObject, UIApplicationDelegate{
    static var orientationLock = UIInterfaceOrientationMask.all
    func application(_application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask{
        return AppDelegate.orientationLock
    }
}
