//
//  SearchHistory.swift
//  TheGreenProgram
//
//  Created by Jose Alonso on 5/24/20.
//  Copyright © 2020 Jose Alonso Alfaro Perez. All rights reserved.
//

import Foundation
import CoreData

public class SearchHistory: NSManagedObject, Identifiable{
    @NSManaged public var searchString:String?
}

extension SearchHistory{
    static func getSearchHistory() -> NSFetchRequest<SearchHistory>{
        let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest() as! NSFetchRequest<SearchHistory>
        let sortDescriptor = NSSortDescriptor(key: "searchString", ascending: true)
        
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }
}
