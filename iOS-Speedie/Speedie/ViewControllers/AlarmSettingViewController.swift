//
//  AlarmSettingViewController.swift
//  Speedie
//
//  Created by Ibrahim Yildirim on 28/02/17.
//
//

import UIKit

class AlarmSettingViewController: UIViewController {
    
    var updatedAlarmSettingDelegate : UpdatedAlarmSettingsDelegate?

    @IBOutlet weak var switchActivateAlarm: UISwitch!
    @IBOutlet weak var sliderRadius: UISlider!
    @IBOutlet weak var lblRadius: UILabel!
    @IBOutlet weak var vwSpeedControl: IncidentTypeView!
    @IBOutlet weak var vwOther: IncidentTypeView!
    @IBOutlet weak var vwAccident: IncidentTypeView!
    @IBOutlet weak var vwCue: IncidentTypeView!
    
    var alarmSetting : AlarmSetting!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alarmSetting = SpeedieUserDefaults.getAlarmSettings()
        switchActivateAlarm.isOn = alarmSetting.alarmIsActive
        updateUI()
    }
    
    func updateUI() {
        
        if alarmSetting.alarmIsActive {
            sliderRadius.isEnabled = true
            sliderRadius.value = Float(alarmSetting.alarmRadius)
            changedAlarmRadius(sliderRadius)
            
            if alarmSetting.speedControlAlarm {
                vwSpeedControl.isSelected = true
            }
            
            if alarmSetting.cueAlarm {
                vwCue.isSelected = true
            }
            
            if alarmSetting.accidentAlarm {
                vwAccident.isSelected = true
            }
            
            if alarmSetting.otherAlarm {
                vwOther.isSelected = true
            }
        } else {
            sliderRadius.isEnabled = false
            vwSpeedControl.isSelected = false
            vwCue.isSelected = false
            vwAccident.isSelected = false
            vwOther.isSelected = false
        }
    }
    
    @IBAction func alarmStatusChanged(_ sender: AnyObject) {
        let alarmSwitch = sender as! UISwitch
        alarmSetting.alarmIsActive = alarmSwitch.isOn
//        print("Alarm: \(alarmSwitch.on)")
        
        updateUI()
    }
    
    
    @IBAction func changedAlarmRadius(_ sender: AnyObject) {
        
        let slider = sender as! UISlider
//        print(slider.value)
        
        let valueIn100 : Float = roundf(slider.value / 100.0) * 100
        if valueIn100 < 1000 {
            lblRadius.text = "Radius: \(Int(valueIn100))m"
        } else {
            lblRadius.text = "Radius: \(valueIn100/1000)km"
        }
        
        alarmSetting.alarmRadius = Int(slider.value)
        
    }
    
    @IBAction func saveClicked(_ sender: AnyObject) {
        SpeedieUserDefaults.saveAlarmSettings(alarmSetting)
        dismiss(animated: true, completion: {
            if self.updatedAlarmSettingDelegate != nil {
                self.updatedAlarmSettingDelegate?.didUpdateAlarmSettings()
            }
        })
    }
    
    @IBAction func clickedSpeedControl(_ sender: AnyObject) {
        self.vwSpeedControl.isSelected = !self.vwSpeedControl.isSelected
        alarmSetting.speedControlAlarm = vwSpeedControl.isSelected
    }
    
    @IBAction func clickedCue(_ sender: AnyObject) {
        self.vwCue.isSelected = !self.vwCue.isSelected
        alarmSetting.cueAlarm = vwCue.isSelected
    }

    @IBAction func clickedAccident(_ sender: AnyObject) {
        self.vwAccident.isSelected = !self.vwAccident.isSelected
        alarmSetting.accidentAlarm = vwAccident.isSelected
    }
    
    @IBAction func clickedOther(_ sender: AnyObject) {
        self.vwOther.isSelected = !self.vwOther.isSelected
        alarmSetting.otherAlarm = vwOther.isSelected
    }
}
