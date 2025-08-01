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
    
        
    func createWeatherObs(number: Int, rollingSpan: Int = 0) -> (obs: [MockWeatherOb], mean: Double) {
        
        let secondsInDay = 86_400.0
        let lowerLimitTemp = -19.9
        let upperLimitTemp = 79.9
        
        var obs = [MockWeatherOb]()
        var total = 0.0
        for index in 0..<number {
            let newOb = MockWeatherOb(
                greenhouseTemp: Double
                    .random(in: lowerLimitTemp...upperLimitTemp),
                dateObserved: Date.now.addingTimeInterval(-(secondsInDay + 10) * Double(index))
            )
            obs.append(newOb)
            
        }
        for index in 0..<rollingSpan {
            if index > number - 1 { break }
            total += obs[index].greenhouseTemp
        }
        let mean = total / Double(min(rollingSpan, number))
        return (obs: obs, mean: mean)
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
        let weatherObs = createWeatherObs(
            number: 12,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        
        // when
        
        
        // then
        #expect(sut.totalObservationNumber == weatherObs.obs.count)
    }
    
    @Test func createdWithDataHasCorrectBooleanForObsevations()  {
        // given
        let weatherObs = createWeatherObs(
            number: 12,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        
        // when
        
        
        // then
        #expect(sut.hasObservations == true)
    }
    
    @Test func clearObservations() {
        // given
        let weatherObs = createWeatherObs(
            number: 12,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        
        // when
        sut.clearObservations()
        
        
        // then
        #expect(!sut.hasObservations,
            "The observations should be empty."
        )
    }
    
    @Test func addingWeatherObIncreasesObservationsByOne()  {
        // given
        let weatherObs = createWeatherObs(
            number: 12,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        
        // when
        sut.add(observation: MockWeatherOb())
        
        // then
        #expect(
            sut.totalObservationNumber - weatherObs.obs.count == 1,
            "The number of observations shopuld be one more than the original initial number of observations."
        )
    }
    
    
    @Test func lastObservationIsTheMostRecentlyAdded()  {
        // given
        let weatherObs = createWeatherObs(
            number: 12,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
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
        let weatherObs = createWeatherObs(
            number: 12,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        
        // when
        let obsInLastSevenDays: [MockWeatherOb] = sut.observationsInLast(
            days: 7
        ).map {$0 as! MockWeatherOb }
        
        // then
        #expect(
            obsInLastSevenDays.contains(weatherObs.obs.prefix(upTo: 7)),
            "List of obs within the last seven days is incorrect"
        )
    }
    
    
    
    @Test func calculatesCorrectMeanTempOver7DayRollingPeriod() {
        // given
        let weatherObs = createWeatherObs(
            number: 12,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        
        // when
        let meanTemp = sut.meanGreenhouseTempOverRollingPeriod()
        
        // then
        #expect(
            meanTemp! == weatherObs.mean,
            "Incorrect caculation of expected mean greenhouse temperature"
        )
    }
    
    @Test func calculatesCorrectMeanTempOver28DayRollingPeriod() {
        // given
        let weatherObs = createWeatherObs(
            number: 40,
            rollingSpan: 28
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        sut.toggleRollingPeriod()
        
        // when
        let meanTemp = sut.meanGreenhouseTempOverRollingPeriod()
        
        // then
        #expect(
            meanTemp! == weatherObs.mean,
            "Incorrect caculation of expected mean greenhouse temperature"
        )
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
    
    @Test func calculatesTempVariationFrom7DayRollingAverageWhenNoObservations() {
        // given
        let sut = WeatherLog(weatherObs: [])
        let expectedVariation: Double? = nil
        
        // when
        let meanTemp = sut.variationInGreenhouseTempOverLast(days: 7)
        
        // then
        #expect(meanTemp == expectedVariation, "Incorrect calculation of temp variation when no observations")
    }
    
    @Test func calculatesTempVariationFrom7DayRollingAverageWhenLessThan7Observations() {
        // given
        let weatherObs = createWeatherObs(
            number: 5,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        let expectedVariation: Double? = weatherObs.obs[0].greenhouseTemp - weatherObs.mean
        
        // when
        let meanTemp = sut.variationInGreenhouseTempOverLast(days: 7)
        
        // then
        #expect(meanTemp == expectedVariation, "Incorrect calculation of temp variation when less than 7 observations")
    }
        
    @Test func calculatesTempVariationFrom7DayRollingAverage() {
        // given
        let weatherObs = createWeatherObs(
            number: 12,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        let expectedVariation = weatherObs.obs[0].greenhouseTemp - weatherObs.mean

        // when
        let variation = sut.variationInGreenhouseTempOverLast(days: 7)
        
        // then
        #expect(variation == expectedVariation, "Incorrect calculation of greenhouse temp variation from 7 day rolling average")
    }
    
    @Test func calculatesTempVariationFrom28DayRollingAverage() {
        // given
        let weatherObs = createWeatherObs(
            number: 35,
            rollingSpan: 28
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        sut.toggleRollingPeriod()
        let expectedVariation = weatherObs.obs[0].greenhouseTemp - weatherObs.mean

        // when
        let variation = sut.variationInGreenhouseTempInRollingPeriod()
        
        // then
        #expect(variation == expectedVariation, "Incorrect calculation of greenhouse temp variation from 28 day rolling average")
    }
    
    @Test func calculatesTempVariationUsing7DayRollingAverage() {
        // given
        let weatherObs = createWeatherObs(
            number:27,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        let expectedVariation = weatherObs.obs[0].greenhouseTemp - weatherObs.mean

        // when
        let variation = sut.variationInGreenhouseTempInRollingPeriod()
        
        // then
        #expect(variation == expectedVariation, "Incorrect calculation of greenhouse temp variation from 28 day rolling average")
    }
    
    @Test func checksStartsWith7DayRollingPeriod() {
        // given
        let weatherObs = createWeatherObs(
            number: 12,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        
        // when
        
        // then
        #expect(sut.rollingPeriod == WeatherLog.RollingPeriod.sevenDays)
    }
    
    @Test func checksToggles7RollingPeriod() {
        // given
        let weatherObs = createWeatherObs(
            number: 12,
            rollingSpan: 7
        )
        let sut = WeatherLog(weatherObs: weatherObs.obs)
        
        // when
        sut.toggleRollingPeriod()
        
        // then
        #expect(sut.rollingPeriod == WeatherLog.RollingPeriod.twentyEightDays)
    }
    
}
