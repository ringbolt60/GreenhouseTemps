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
        
        func clearObservations() {
            log.weatherObs = []
            save()
        }
        
        func variationFromLastPeriodOf(days: Int) -> String {
            if log.weatherObs.isEmpty { return "No available history" }
            let mean = log.meanGreenhouseTempOverLast(days: days)
            let current = log.weatherObs[0].contents.greenhouseTemp
            let variation = current - mean
            return "\(variation.formatted(.number.rounded(increment: 0.1).sign(strategy: .always()))) ℃"
            
            
        }
        
        func observationsInLast(days: Int) -> [any WeatherData] {
            log.observationsInLast(days: days)
            
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(log)
                try data
                    .write(
                        to: URL.documentsDirectory.appending(path: "SavedObservations"),
                        options: [.atomic, .completeFileProtection]
                    )
            } catch {
                print("Unable to write data")
            }
        }
        
        init(log: WeatherLog) {
            self.log = log
        }
    }
    
}
