//
//  HistoryView-ViewModel.swift
//  GreenhouseTemps
//
//  Created by Jon Walters on 25/06/2025.
//

import Foundation

extension HistoryView {
    
    @Observable
    class ViewModel {
        private(set) var log: WeatherLog
        
        var rollingPeriodIs7Days: Bool
        
    
        init(log: WeatherLog) {
            self.log = log
            if log.rollingPeriod == .sevenDays {
                self.rollingPeriodIs7Days = true
            }
            else {
                self.rollingPeriodIs7Days = false
            }
        }
        
        var rollingAverageLabel: String {
            rollingPeriodIs7Days ? "7 day" : "28 day"
        }
        
        var rollingAverageCommand: String {
            rollingPeriodIs7Days ? "28 day" : "7 day"
        }
        
        var observationsListSectionTitle: String {
            if log.hasObservations {
                let number = log.totalObservationNumber
                let obsShown = number > 7 ? "all shown" : "\(number) shown"
                let observationText = (number == 1) ? "observation" : "observations"
                return "\(number.formatted()) \(observationText) - \(obsShown)"
            } else {
                return "No Observations"
            }
        }
        
    }
    
}
