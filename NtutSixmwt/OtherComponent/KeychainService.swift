//
//  KeychainService.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/11/30.
//

import Foundation

class KeychainService{
    let serverName = "ntut.sixmwt.authorization.data"
    enum KeychainError: Error{
        case noPassword
        case unhandledError(status: OSStatus)
    }
    
    func save(data: Data, key: String){
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, //type of item to store
                                    kSecAttrAccount as String: key,
                                    kSecValueData as String: data]
        let status = SecItemAdd(query as CFDictionary, nil)
        if (status == errSecDuplicateItem){
            
            let updateSuccess = updateData(data: data, key: key)
            if(updateSuccess){
                print("update success")
            }else{
                print("update fail")
            }
        }
    }
    func updateData(data: Data, key: String) -> Bool{
        do{
            let query:[String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                       kSecAttrAccount as String: key]
            let attributes:[String: Any] = [kSecValueData as String: data]
            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            guard status != errSecItemNotFound else{ throw KeychainError.noPassword}
            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status)}
            return true
        }catch {
            print("no password")
            return false
        }
    }

    func retriveData(key:String) -> String?{
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnData as String: kCFBooleanTrue as Any]
        var dataTypeRef: AnyObject? = nil
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard let data = dataTypeRef as? Data else {return nil}
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func deleteData(key:String){
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: key]
        let status = SecItemDelete(query as CFDictionary)
        print(status)
    }
}


