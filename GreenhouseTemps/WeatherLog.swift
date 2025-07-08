//
//  WeatherLog.swift
//  GreenhouseTemps
//
//  Created by Jon Walters on 02/07/2025.
//

import CoreTransferable
import Foundation
import SwiftCSVEncoder

/// A collection of time stamped observations of temperatures, as measured by a min-max thermometer
class WeatherLog: Codable {
    
    
    private var weatherObs: [CodableWeatherData]
    
    private var savePath = URL.documentsDirectory.appending(path: "SavedObservations")
    
    var csvSavePath = URL.documentsDirectory.appending(path: "observations.csv")
    
    /// Create a WeartherLog from a initial list of observations
    /// - Parameter weatherObs: a list of WeatherData observations
    init(weatherObs: [any WeatherData] ) {
        self.weatherObs = weatherObs.encoded
    }
    
    
    /// Add a new observation
    /// - Parameter observation: a WeatherData that has the data for the observayion
    func add(observation: any WeatherData) {
        weatherObs.insert(observation.encoded, at: 0)
    }
    
    var hasObservations: Bool {
        if weatherObs.isEmpty { return false} else {return  true }
    }
    
    var totalObservationNumber: Int {
        weatherObs.count
    }
    
    var rollingPeriod = RollingPeriod.sevenDays
    
//    /// Represents  the observations as a file in comma sepearted variable format
//    var csvFileShare: CSVFile? {
//        if weatherObs.isEmpty { return nil }
//        let obs = weatherObs.map { $0.contents } 
//        let csvFile = CSVFile(obs: obs)
//        
//        return csvFile
//    }
    
    /// Selects the other possible number of days used to calculate the rolling average
    func toggleRollingPeriod() {
        switch rollingPeriod {
        case .sevenDays:
            rollingPeriod = .twentyEightDays
        case .twentyEightDays:
            rollingPeriod = .sevenDays
        }
    }
    
    /// The allowable number of days over which the rolling average is to be calculated
    enum RollingPeriod: Int, Codable {
        case sevenDays = 7
        case twentyEightDays = 28
    }

    /// The most recently recorded observation
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
  
    /// Saves to the documents folder
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
        
        do {
            try csvData()
                .write(to: csvSavePath, atomically: true, encoding: .utf8)
        } catch {
            print("Unable to write csv data")
        }
 
    }
    
    /// The observations taken  less than the rolling period number of days ago
    func observationsInLast(days: Int) -> [any WeatherData] {
        let result = weatherObs.filter{ codableOb in
            
            DateInterval(start: codableOb.contents.dateObserved, end: Date.now).duration < TimeInterval(
                days * 86_400
            )
        }
        return result.map { $0.contents }
             
    }
    
    /// The mean greenhouse temperature over the last number of days
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
    
    /// The mean greenhouse temperature over the number of days in the rolling period
    func meanGreenhouseTempOverRollingPeriod() -> Double?  {
        if weatherObs.isEmpty { return nil }
        return meanGreenhouseTempOverLast(days: rollingPeriod.rawValue)
    }
    
    /// The difference between the last greenhouse temperature recorded and the mean temperature over a number of days
    func variationInGreenhouseTempOverLast(days: Int) -> Double? {
        if weatherObs.isEmpty { return nil }
        return lastObservation.greenhouseTemp - meanGreenhouseTempOverLast(
            days: days)!
        
    }
    
    /// The difference between the last greenhouse temperature recorded and the mean temperature over the rolling period
    func variationInGreenhouseTempInRollingPeriod() -> Double? {
        if weatherObs.isEmpty { return nil }
        return variationInGreenhouseTempOverLast(days: rollingPeriod.rawValue)
    }
    
    /// Remove all observations in the log
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


extension WeatherLog {
    
    /// Convert the CSV data into a string
    func csvData() -> String {

        if weatherObs.isEmpty { return "" }
        
        let table = CSVTable<any WeatherData>(
            columns: [
                CSVColumn("Date", \.dateObserved),
                CSVColumn("Greenhouse", \.greenhouseTemp),
                CSVColumn("Garden", \.gardenTemp),
                CSVColumn("Min", \.minTemp),
                CSVColumn("Max", \.maxTemp),
                CSVColumn("Note", \.note)
            ],
            configuration:  CSVEncoderConfiguration(
                dateEncodingStrategy: .iso8601
            )
        )
        let obs = weatherObs.map { $0.contents }
        let result = table.export(rows: obs)
        return result
    }
}

/// Allows a file to be transferred out of the applcation
extension WeatherLog: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(
            exportedContentType: .commaSeparatedText) { file in
                Data(file.csvData().utf8)
            }
    }

    }
