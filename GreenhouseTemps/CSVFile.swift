//
//  CSVFile.swift
//  GreenhouseTemps
//
//  Created by Jon Walters on 03/07/2025.
//

import CoreTransferable
import Foundation
import SwiftCSVEncoder
import SwiftUI

/// A list of WeatherData objects formatted as a CSV file
struct CSVFile {


    var obs: [any WeatherData]
    
    init(obs: [any WeatherData]) {
        self.obs = obs
    }
}

extension CSVFile {
    
    /// Convert the CSV data into a string
    func csvData() -> String {

        
        
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
        
        return table.export(rows: obs)
    }
}

/// Allows a file to be transferred out of the applcation
extension CSVFile: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(
            exportedContentType: .commaSeparatedText) { file in
                Data(file.csvData().utf8)
            }
            

    }

}
