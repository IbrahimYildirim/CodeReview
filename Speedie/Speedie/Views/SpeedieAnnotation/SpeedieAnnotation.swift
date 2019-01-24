//
//  SpeedieAnnotation.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 26/06/16.
//
//

import Foundation
import kingpin

class SpeedieAnnotation : KPAnnotation {
    
    var incident : IncidentResponse?
    
    func getImagePinString() -> String? {
        if let type : IncidentType = incident?.type {
            switch type {
            case .SpeedControl: return "ControlPin"
            case .Cue: return "CuePin"
            case .Accident: return "AccidentPin"
            case .Other: return "OtherPin"
            }
        }
        return ""
    }
}
