//
//  IncidentResponse.swift
//  Speedie
//
//  Created by Janis Bruno Ozolins on 6/19/16.
//
//

import Foundation
import ObjectMapper

enum IncidentType {
    case SpeedControl
    case Cue
    case Accident
    case Other
}

class IncidentResponse : Mappable {
    
    var id : String = ""
    var type : String = ""
    var address : String = ""
    var latitude : Double = 0.0
    var longiuted : Double = 0.0
    var description : String = ""
    var confirms : Int = 0
    var denies : Int = 0
    var createdAt : String = ""
    var activities : [ActivityResponse]?
    var timeStamp : Int = 0
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        createdAt <- map["createdAt"]
        id <- map["_id"]
        type <- map["type"]
        address <- map["address"]
        latitude <- map["latitude"]
        longiuted <- map["longitude"]
        denies <- map["denies"]
        confirms <- map["confirms"]
        description <- map["description"]
        activities <- map["activities"]
        timeStamp <- map["timeStamp"]
    }
    
    func getType() -> IncidentType? {
        switch type {
        case "Speed Control": return .SpeedControl
        case "Traffic": return .Cue
        case "Accident": return .Accident
        case "Other": return .Other
        default:
            return nil
        }
    }
}
