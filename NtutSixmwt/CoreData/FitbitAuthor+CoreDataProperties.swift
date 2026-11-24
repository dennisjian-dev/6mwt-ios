//
//  FitbitAuthor+CoreDataProperties.swift
//  NtutSixmwt
//
//  Created by BioLab.NTUT on 2021/11/8.
//
//

import Foundation
import CoreData


extension FitbitAuthor {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FitbitAuthor> {
        return NSFetchRequest<FitbitAuthor>(entityName: "FitbitAuthor")
    }

    @NSManaged public var authorization: String?
    @NSManaged public var access_token: String?
    @NSManaged public var refresh_token: String?

}

extension FitbitAuthor : Identifiable {

}
