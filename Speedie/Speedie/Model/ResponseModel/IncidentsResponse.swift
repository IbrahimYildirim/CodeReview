//
//  IncidentsResponse.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 6/19/16.
//
//

import Foundation
import ObjectMapper

class IncidentsResponse : Mappable {
    
    var status : String = ""
    var incidents : [IncidentResponse]?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        status <- map["status"]
        incidents <- map["incidents"]
    }
}
