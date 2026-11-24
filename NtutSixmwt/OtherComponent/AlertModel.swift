//
//  AlertModel.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2022/3/15.
//

import Foundation

class AlertModel: ObservableObject{
    @Published var isShow:Bool
    @Published var showAlert:String
    var isShowOption:Bool
    var title:String
    var content:String
    init(){
        title = ""
        content = ""
        isShowOption = false
        showAlert = ""
        isShow = false
    }
    func setAlert(title: String, content: String, isShowOption: Bool){
        print("set alert")
        self.title = title
        self.content = content
        self.isShowOption = isShowOption
        self.isShow = true
        self.showAlert = title
    }
    func resetAlert(){
        print("resst alert")
        self.title = ""
        self.content = ""
        self.showAlert = ""
        self.isShowOption = false
        self.isShow = false
    }
}
