//
//  GreenhouseTempsTests.swift
//  GreenhouseTempsTests
//
//  Created by Jon Walters on 30/06/2025.
//

import Foundation
import Testing
@testable import GreenhouseTemps

struct WeatherLogTests {
    
    let mockWeatherObs = [MockWeatherOb](repeating: MockWeatherOb(), count: 8)
    
    let today = MockWeatherOb(greenhouseTemp: Double.random(in: -19.9...79.9), dateObserved: Date.now)
    let yesterday = MockWeatherOb(
        greenhouseTemp: Double.random(in: -19.9...79.9),
        dateObserved: Date.now.addingTimeInterval(-90_000)
    )
    let dayBeforeYesterday = MockWeatherOb(
        greenhouseTemp: Double.random(in: -19.9...79.9),
        dateObserved: Date.now.addingTimeInterval(-180_000)
    )
    let agesAgo = MockWeatherOb(
        greenhouseTemp: Double.random(in: -19.9...79.9),
        dateObserved: Date.distantPast
        )
    var obsToBeAdded: [MockWeatherOb] { [
        today,
        yesterday,
        dayBeforeYesterday,
        agesAgo
    ]
    }
    var expectedMean: Double {
        (today.greenhouseTemp + yesterday.greenhouseTemp + dayBeforeYesterday
                .greenhouseTemp) / 3.0
    }

    @Test func createdWithoutAnyWeatherData() {
        // given
        let sut = WeatherLog(weatherObs: [])
        
        // when
        
        
        // then
        #expect(sut.hasObservations == false)
    }

    @Test func createdWithDataHasCorrectNumberOfObservations()  {
        // given
        let sut = WeatherLog(weatherObs: mockWeatherObs)
        
        // when
        
        
        // then
        #expect(sut.weatherObs.count == mockWeatherObs.count)
    }
    
    @Test func createdWithDataHasCorrectBooleanForObsevations()  {
        // given
        let sut = WeatherLog(weatherObs: mockWeatherObs)
        
        // when
        
        
        // then
        #expect(sut.hasObservations == true)
    }
    
    @Test func clearObservations() {
        // given
        let sut = WeatherLog(weatherObs: mockWeatherObs)
        
        // when
        sut.clearObservations()
        
        
        // then
        #expect(sut.weatherObs.isEmpty,
            "The observations should be empty."
        )
    }
    
    @Test func addingWeatherObIncreasesObservationsByOne()  {
        // given
        let sut = WeatherLog(weatherObs: mockWeatherObs)
        
        // when
        sut.add(observation: MockWeatherOb())
        
        // then
        #expect(sut.weatherObs.count - mockWeatherObs.count == 1, "The number of observations shopuld be one more than the original initial number of observations.")
    }
    
    @Test func addingWeatherObIsAtBeginninOfArray()  {
        // given
        let sut = WeatherLog(weatherObs: mockWeatherObs)
        let randomNote = UUID().uuidString
        
        // when
        sut.add(observation: MockWeatherOb(note: randomNote))
        
        // then
        #expect(
            sut.weatherObs.first?.contents.note == randomNote,
            "The recently entered WeatherData is not at the beginning of the array"
        )
    }
    
    @Test func lastObservationIsTHeMostRecentlyAdded()  {
        // given
        let sut = WeatherLog(weatherObs: mockWeatherObs)
        let randomNote = UUID().uuidString
        
        // when
        sut.add(observation: MockWeatherOb(note: randomNote))
        
        
        // then
        #expect(
            sut.lastObservation.note == randomNote,
            "The most recently added observation is not the last observation."
        )
    }
    
    @Test func returnsAllObservationsInLast7Days() {
        // given
        
        let sut = WeatherLog(weatherObs: obsToBeAdded)
        
        // when
        let obsInLastSevenDays: [MockWeatherOb] = sut.observationsInLast(
            days: 7
        ).map {$0 as! MockWeatherOb }
        
        // then
        #expect(obsInLastSevenDays == [today, yesterday, dayBeforeYesterday], "List of obs within the last seven days is incorrect")
    }
    
    @Test func calculatesCorrectMeanTempOver7Days() {
        // given
        
        let sut = WeatherLog(weatherObs: obsToBeAdded)
        
        // when
        let meanTemp = sut.meanGreenhouseTempOverLast(
            days: 7
        )
        
        // then
        #expect(meanTemp == expectedMean, "Incorrect caculation of expected mean greenhouse temperature")
    }
    
    @Test func calculatesCorrectMeanTempOver7DaysWhenNoObservations() {
        // given
        let sut = WeatherLog(weatherObs: [])
        let expectedMeanTemp: Double? = nil
        
        // when
        let meanTemp = sut.meanGreenhouseTempOverLast(days: 7)
        
        // then
        #expect(meanTemp == expectedMeanTemp, "Incorrect calculation of mean temp when no observations")
    }
    
    @Test func calculatesTempVariationFrom7DayRollingAverageWhenNoObsertvations() {
        // given
        let sut = WeatherLog(weatherObs: [])
        let expectedVariation: Double? = nil
        
        // when
        let meanTemp = sut.variationInGreenhouseTempOverLast(days: 7)
        
        // then
        #expect(meanTemp == expectedVariation, "Incorrect calculation of temp variation when no observations")
    }
        
    @Test func calculatesTempVariationFrom7DayRollingAverage() {
        // given
        let sut = WeatherLog(weatherObs: obsToBeAdded)
        let expectedVariation = today.greenhouseTemp - expectedMean

        // when
        let meanTemp = sut.variationInGreenhouseTempOverLast(days: 7)
        
        // then
        #expect(meanTemp == expectedVariation, "Incorrect calculation of greenhouse temp variation from 7 day rolling average")
    }
    
}
