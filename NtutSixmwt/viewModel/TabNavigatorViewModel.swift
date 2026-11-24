//
//  TabNavigatorViewModel.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2022/2/28.
//

import Foundation
class TabNavigatorViewModel: ObservableObject {
    init(){
        let sqliteURL: URL = {
            do{
                return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("db.sqlite")
            } catch{
                fatalError("errir getting file url from document directory")
            }
        }()
        let sqlitePath = sqliteURL.path
        let db = DataModel(path: sqlitePath)
        if let mydb = db {
            let status = mydb.createTable("data_list", columnsInfo:[
            "ID varying character(10) not null",
            "Time varying character(20) not null",
            "JsonData text",
            "StartTestingTime double",
            "EndTestingTime double",
            "primary key(ID, Time)"])
            if (status){}
        }
    }
}
