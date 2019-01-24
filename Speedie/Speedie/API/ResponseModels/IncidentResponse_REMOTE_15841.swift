//
//  IncidentResponse.swift
//  Speedie
//
//  Created by Janis Bruno Ozolins on 6/19/16.
//
//

import Foundation
import ObjectMapper
import SwiftDate

enum IncidentType : String {
    case SpeedControl = "Speed Control"
    case Cue = "Traffic"
    case Accident = "Accident"
    case Other = "Other"
}

class IncidentResponse : Mappable {
    
    var id : String = ""
    var type : IncidentType = .SpeedControl
    var address : String = ""
    var latitude : Double = 0.0
    var longiuted : Double = 0.0
    var description : String = ""
    var confirms : Int = 0
    var denies : Int = 0
    var createdAt : NSDate = 3.days.ago
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        createdAt <- (map["createdAt"], DateTransform())
        id <- map["_id"]
        type <- map["type"]
        address <- map["address"]
        latitude <- map["latitude"]
        longiuted <- map["longitude"]
        denies <- map["denies"]
        confirms <- map["confirms"]
        description <- map["description"]
    }
    
    func titleForType() -> String {
        switch type {
        case .SpeedControl: return "Fart Kontrol"
        case .Cue: return "Kø"
        case .Accident: return "Trafik Uheld"
        case .Other: return "Andet"
        }
    }
    
    func imageNameForType() -> String {
        switch type {
        case .SpeedControl: return "SpeedControlRound"
        case .Cue: return "CueRound"
        case .Accident: return "AccidentRound"
        case .Other: return "OtherRound"
        }
    }
    
    func createdDate(includeCreated include : Bool) -> String {
        let mutableString = NSMutableString()
        
        if include {
            mutableString.appendString("Oprettet ")
        }
        if createdAt.isInToday() {
            mutableString.appendString("I dag")
        } else if createdAt.isInYesterday() {
            mutableString.appendString("I går")
        } else {
            mutableString.appendString("\(createdAt.day).\(createdAt.month)")
        }
        
        mutableString.appendString(" kl. \(createdAt.hour).\(createdAt.minute)")
        
        return mutableString as String
    }
}
