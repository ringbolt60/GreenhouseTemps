//
//  Observation.swift
//  GreenhouseTemps
//
//  Created by Jon Walters on 23/06/2025.
//

import Foundation



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
