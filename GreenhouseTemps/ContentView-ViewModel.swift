//
//  ContentView-ViewModel.swift
//  GreenhouseTemps
//
//  Created by Jon Walters on 23/06/2025.
//

import Foundation
import SwiftUI

extension ContentView {
    
    @Observable
    class ViewModel {
        private(set) var log: WeatherLog
        
        let savePath = URL.documentsDirectory.appending(path: "SavedObservations")
        
        var observationDate = Date.now
        var greenhouseTemp: Double?
        var gardenTemp: Double?
        var maxTemp: Int?
        var minTemp: Int?
        var note = ""
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                log = try JSONDecoder()
                    .decode(WeatherLog.self, from: data)
            } catch {
                log = WeatherLog(weatherObs: [])
            }
            
        }
        
        var lastObservation: any WeatherData {
            log.lastObservation
        }
        
        var isObservationInputValid: Bool {
            let upperTempLimit = 80.0
            let lowerTempLimit = -20.0
            guard let greenHouseTemp = self.greenhouseTemp else { return false }
            guard let gardenTemp = self.gardenTemp else { return false }
            guard let minTemp = self.minTemp else { return false }
            guard let maxTemp = self.maxTemp else { return false }
            if note.count > 80 { return false }
            
            let isGreenhouseTempValid = (
                greenHouseTemp > lowerTempLimit && greenHouseTemp < upperTempLimit
            )
            let isGardenTempValid = (
                gardenTemp > lowerTempLimit && gardenTemp < upperTempLimit
            )
            let isMaxTempValid = (
                maxTemp >= minTemp && maxTemp > Int(
                    lowerTempLimit
                ) && maxTemp < Int(upperTempLimit)
            )
            let isMinTempValid = (
                minTemp <= maxTemp && minTemp > Int(
                    lowerTempLimit
                ) && minTemp < Int(upperTempLimit)
            )
            
            if isGreenhouseTempValid && isGardenTempValid && isMinTempValid && isMaxTempValid { return true } else  { return false }
           
        }
        
        func addObservation() {
            let newObservation = WeatherOb(
                id: UUID().uuidString,
                greenhouseTemp: greenhouseTemp ?? 0.0,
                gardenTemp: gardenTemp ?? 0.0,
                maxTemp: maxTemp ?? 0,
                minTemp: minTemp ?? 0,
                dateObserved: Date.now,
                note: note
            )
            log.add(observation: newObservation)
            greenhouseTemp = nil
            gardenTemp = nil
            maxTemp = nil
            minTemp = nil
            note = ""
            log.save()
        }

        

    }
}

extension WeatherOb {
    var formattedDate: String {
        if dateObserved == Date.distantPast { return "No previous observation"} else {
            return dateObserved.formatted(date: .abbreviated, time: .shortened)
        }
        
    }
    
    var formattedGreenhouseTemp: String {
        if dateObserved == Date.distantPast { return "" }
        return "\(greenhouseTemp.formatted(.number.rounded(increment: 0.1))) ℃"
    }
    
    var formattedGardenTemp: String {
        if dateObserved == Date.distantPast { return "" }
        return "\(gardenTemp.formatted(.number.rounded(increment: 0.1))) ℃"
    }
    
    var formattedTempRange: String {
        if dateObserved == Date.distantPast { return "" }
        return "Range: \(minTemp)  to  \(maxTemp)  ℃"
    }
}

extension WeatherLog {
    var formattedMeanGreenhouseTempInRollingPeriod: String {
        guard let meanGreenhouseTemp = meanGreenhouseTempOverRollingPeriod() else {
            return "No observations"
        }
        return "\(meanGreenhouseTemp.formatted(.number.rounded(increment: 0.1))) ℃"
    }
    
    var formattedVariationOfGreenhouseTempInRollingPeriod: String {
        guard let meanGreenhouseTempVariation = variationInGreenhouseTempInRollingPeriod() else {
            return "No observations"
        }
        return "\(meanGreenhouseTempVariation.formatted(.number.rounded(increment: 0.1).sign(strategy: .always()))) ℃"
    }
}
