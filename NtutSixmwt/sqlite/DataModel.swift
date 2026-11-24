//
//  DataModel.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/12/14.
//

import Foundation
import SQLite3

class DataModel{
    var db : OpaquePointer? = nil
    let sqlitePath: String
    
    init?(path :String){
        sqlitePath = path
        db = self.openDatabase(sqlitePath)
        
        if db == nil{
            return nil
        }
    }
    
    func openDatabase(_ path: String) -> OpaquePointer{
        var connectdb: OpaquePointer? = nil
        
        if sqlite3_open(path, &connectdb) == SQLITE_OK{
            print("Successfully opened database \(path)")
            return connectdb!
        }else{
            print("Unable to open database.")
            return connectdb!
        }
    }
    
    func createTable(_ tableName :String, columnsInfo:[String])-> Bool{
        let sql = "create table if not exists \(tableName)"
            + "(\(columnsInfo.joined(separator: ",")))"
        print(sql)
        if sqlite3_exec(self.db, sql.cString(using: String.Encoding.utf8), nil, nil, nil)
            == SQLITE_OK{
            print("create success")
            return true
        }
        print("create fail")
        return false
    }
    func insert(_ tableName :String, rowInfo: [String:String])->Bool{
        var statement :OpaquePointer? = nil
        let sql = " insert into \(tableName) "
            + " (\(rowInfo.keys.joined(separator: ","))) "
            + " values (\(rowInfo.values.joined(separator: ","))) "
        if sqlite3_prepare_v2(self.db, sql, -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                sqlite3_finalize(statement)
                return true
            }else{
                print("could not insert now")
            }
        }
        print("insert statement is not prepared")
        sqlite3_finalize(statement)
        return false
    }
    
    func fetch(_ tableName :String, cond :String?, order :String?) -> OpaquePointer{
        var statement :OpaquePointer? = nil
        var sql = " select * from \(tableName) "
        if let condition = cond{
            sql += " where \(condition) "
        }
        if let orderBy = order{
            sql += " order by \(orderBy) "
        }
        
        sqlite3_prepare_v2(self.db, sql, -1, &statement, nil)
        print(statement!)
        return statement!
    }
    
    func update(_ tableName :String, cond:String?, rowInfo: [String:String])->Bool{
        var statement :OpaquePointer? = nil
        var sql = " update \(tableName) set "
        
        var info :[String] = []
        for (k, v) in rowInfo{
            info.append(" \(k) = \(v) ")
        }
        sql += info.joined(separator: ",")
        
        if let condition = cond{
            sql += " where \(condition) "
        }
        
        if sqlite3_prepare_v2(
            self.db, sql.cString(using: String.Encoding.utf8), -1, &statement, nil) == SQLITE_OK{
            if sqlite3_step(statement) == SQLITE_DONE{
                return true
            }
            sqlite3_finalize(statement)
        }
        return false
    }
    
    func delete(_ tableName :String, cond:String?)->Bool{
        var statement :OpaquePointer? = nil
        var sql = " delete from \(tableName) "

        if let condition = cond{
            sql += " where \(condition) "
        }
        
        print(sql)
        if sqlite3_prepare_v2(
            self.db, sql.cString(using: String.Encoding.utf8), -1, &statement, nil) == SQLITE_OK{
            print(statement)
            if sqlite3_step(statement) == SQLITE_DONE{
                return true
            }
            sqlite3_finalize(statement)
        }
        return false
    }
    
    func addbfield(sFieldName: String, sTable: String) -> Bool{
        var bReturn: Bool = false;
        var sql = " ALTER TABLE " + sTable + " ADD COLUMN " + sFieldName + " INTEGER DEFAULT -1 ";
        var statement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK{
            print("Failed to prepare statement")
        }else{
            if sqlite3_step(statement)  == SQLITE_DONE{
                print("field " + sFieldName + "added to " + sTable);
            }
            sqlite3_finalize(statement);
            bReturn = true;
        }
        return bReturn;
        
    }
    
}
