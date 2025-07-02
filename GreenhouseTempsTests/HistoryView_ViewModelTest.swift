//
//  HistoryView_ViewModelTest.swift
//  GreenhouseTempsTests
//
//  Created by Jon Walters on 01/07/2025.
//

import Testing
@testable import GreenhouseTemps

struct HistoryView_ViewModelTest {

    @Test func testExample() async throws {
        let sut = HistoryView.ViewModel(log: WeatherLog(weatherObs: []))
    }

}
