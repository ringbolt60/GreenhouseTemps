//
//  WeatherLog.swift
//  GreenhouseTemps
//
//  Created by Jon Walters on 02/07/2025.
//

import Foundation

class WeatherLog: Codable {
     
    var weatherObs: [CodableWeatherData]
    
    var savePath = URL.documentsDirectory.appending(path: "SavedObservations")
    
    init(weatherObs: [any WeatherData] ) {
        self.weatherObs = weatherObs.encoded
    }
    
    func add(observation: any WeatherData) {
        weatherObs.insert(observation.encoded, at: 0)
    }
    
    var hasObservations: Bool {
        if weatherObs.isEmpty { return false} else {return  true }
    }
    
    var rollingPeriod = RollingPeriod.sevenDays
    
    func toggleRollingPeriod() {
        switch rollingPeriod {
        case .sevenDays:
            rollingPeriod = .twentyEightDays
        case .twentyEightDays:
            rollingPeriod = .sevenDays
        }
    }
    
    enum RollingPeriod: Int, Codable {
        case sevenDays = 7
        case twentyEightDays = 28
    }

    var lastObservation: any WeatherData {
        get {
            if let obs = weatherObs.first {
                return obs.contents
            }
            
            let defaultObservation = WeatherOb(
                id: UUID().uuidString,
                greenhouseTemp: 0.0,
                gardenTemp: 0.0,
                maxTemp: 0,
                minTemp: 0,
                dateObserved: Date.distantPast
                
            )
            return defaultObservation
        }
        set {
            
        }
    }
  
    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            try data
                .write(
                    to: savePath,
                    options: [.atomic, .completeFileProtection]
                )
        } catch {
            print("Unable to write data")
        }
    }
    
    func observationsInLast(days: Int) -> [any WeatherData] {
        let result = weatherObs.filter{ codableOb in
            
            DateInterval(start: codableOb.contents.dateObserved, end: Date.now).duration < TimeInterval(
                days * 86_400
            )
        }
        return result.map { $0.contents }
             
    }
    
    func meanGreenhouseTempOverLast(days: Int) -> Double? {
        if weatherObs.isEmpty { return nil }
        let obs = observationsInLast(days: days)
        if obs.isEmpty { return 0.0}
        var total = 0.0
        for ob in obs {
            total += ob.greenhouseTemp
        }
        return total / Double(obs.count)
    }
    
    func meanGreenhouseTempOverRollingPeriod() -> Double?  {
        if weatherObs.isEmpty { return nil }
        return meanGreenhouseTempOverLast(days: rollingPeriod.rawValue)
    }
    
    func variationInGreenhouseTempOverLast(days: Int) -> Double? {
        if weatherObs.isEmpty { return nil }
        return lastObservation.greenhouseTemp - meanGreenhouseTempOverLast(
            days: days)!
        
    }
    
    func variationInGreenhouseTempInRollingPeriod() -> Double? {
        if weatherObs.isEmpty { return nil }
        return variationInGreenhouseTempOverLast(days: rollingPeriod.rawValue)
    }
    
    func clearObservations() {
        weatherObs = []
    }
    
    #if DEBUG
    static func exampleObservations() -> [WeatherOb] {
        var obs = [WeatherOb]()
        for index in 0..<35 {
            let date = Date.now.addingTimeInterval(-86_410.0 * Double(index))
            let newOb = WeatherOb(
                id: UUID().uuidString,
                greenhouseTemp: Double.random(in: -2.0...35.0),
                gardenTemp: Double.random(in: -2.0...35.0),
                maxTemp: Int.random(in: 25...36),
                minTemp: Int.random(in: 15...24),
                dateObserved: date,
                note: "An example note"
            )
            obs.append(newOb)
        }
        return obs
    }
    
    static let example = WeatherLog(weatherObs: exampleObservations())
    #endif
}
