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
        
    
        init(log: WeatherLog) {
            self.log = log
        }
    }
    
}
