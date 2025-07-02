//
//  Observation.swift
//  GreenhouseTemps
//
//  Created by Jon Walters on 23/06/2025.
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
    
    func meanGreenhouseTempOverLast(days: Int) -> Double {
        let obs = observationsInLast(days: days)
        if obs.isEmpty { return 0.0}
        var total = 0.0
        for ob in obs {
            total += ob.greenhouseTemp
        }
        return total / Double(obs.count)
    }
    
    func clearObservations() {
        weatherObs = []
    }
    
    #if DEBUG
    static let example = WeatherLog(weatherObs: [WeatherOb.example])
    #endif
}

class WeatherOb: WeatherData, Equatable, Identifiable {


    
    var id: String?
    var greenhouseTemp: Double
    var gardenTemp: Double
    var maxTemp: Int
    var minTemp: Int
    var dateObserved: Date
    var note = ""
    
    var encoded: CodableWeatherData {
        .weatherOb(contents: self)
    }
    

    
    static func == (lhs: WeatherOb, rhs: WeatherOb) -> Bool {
        lhs.id == rhs.id
    }
    
    
    
    init(
        id: String,
        greenhouseTemp: Double,
        gardenTemp: Double,
        maxTemp: Int,
        minTemp: Int,
        dateObserved: Date,
        note: String = ""
    ) {
        self.id = UUID().uuidString
        self.greenhouseTemp = greenhouseTemp
        self.gardenTemp = gardenTemp
        self.maxTemp = maxTemp
        self.minTemp = minTemp
        self.dateObserved = dateObserved
        self.note = note
    }
    
    #if DEBUG
    static let example = WeatherOb (
        id: UUID().uuidString,
        greenhouseTemp: 27.4,
        gardenTemp: 24.8,
        maxTemp: 34,
        minTemp: 17,
        dateObserved: Date.now
        
    )
    #endif
}

protocol WeatherData: Codable, Identifiable {
    
    var id: String? { get set }
    var greenhouseTemp: Double { get set }
    var gardenTemp: Double { get set }
    var maxTemp: Int { get set }
    var minTemp: Int { get set }
    var dateObserved: Date { get }
    var note: String { get set }
    
    var encoded: CodableWeatherData { get }
    
    var formattedDate: String { get }
    
    var formattedGreenhouseTemp: String { get }
    
    var formattedGardenTemp: String { get }
    
    var formattedTempRange: String { get }


}

enum CodableWeatherData: Codable {
    case weatherOb(contents: WeatherOb)
    #if DEBUG
    case mockWeatherOb(contents: MockWeatherOb)
    #endif
    var contents: any WeatherData {
        switch self {
        case let .weatherOb(weatherOb): weatherOb
        #if DEBUG
        case let .mockWeatherOb(mockWeatherOb): mockWeatherOb
        #endif
        }
    }
}

#if DEBUG
struct MockWeatherOb: WeatherData, Equatable {
    
    static func == (lhs: MockWeatherOb, rhs: MockWeatherOb) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String? = UUID().uuidString
    
    var greenhouseTemp = 20.0

    var gardenTemp = 17.3

    var maxTemp = 30

    var minTemp = 21

    var dateObserved = Date.distantPast

    var note = "An example note"

    var encoded: CodableWeatherData {
        .mockWeatherOb(contents: self)
    }

    var formattedDate = Date.distantPast.formatted(
        date: .abbreviated,
        time: .shortened
    )

    var formattedGreenhouseTemp = "20.0 ℃"

    var formattedGardenTemp = "17.3 ℃"
    
    var formattedTempRange = "Range: 21  to  30  ℃"

    
    
}
#endif


extension Array <any WeatherData> {
    var encoded: [CodableWeatherData] {
        self.map(\.encoded)
    }
}
