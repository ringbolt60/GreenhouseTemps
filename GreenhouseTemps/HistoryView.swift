//
//  HistoryView.swift
//  GreenhouseTemps
//
//  Created by Jon Walters on 25/06/2025.
//

import SwiftUI

struct HistoryView: View {
    
    var log: WeatherLog
    
    @State var viewModel: ViewModel
    
    @Environment(\.dismiss) var dismiss
    
    init(log: WeatherLog) {
        self.log = log
        self.viewModel = ViewModel(log: log)
    }
    
    var body: some View {
        Form {
            Section("Most recent observation") {
                HStack {
                    Text(viewModel.log.lastObservation.formattedDate)
                    Spacer()
                    Text(viewModel.log.lastObservation.formattedGreenhouseTemp)
                }
            }
                Section("Variance from last seven days") {
                    HStack {
                        Text("7 day rolling mean")
                        Spacer()
                        Text(viewModel.log.formatted7DayMeanGreenhouseTemp)
                    }
                    HStack {
                        Text("Variance")
                        Spacer()
                        Text(viewModel.log.formatted7DayVariationOfGreenhouseTemp)
                    }
                }
            
        }
        if viewModel.log.hasObservations {
            Section("Previous seven days observations") {
                List {
                    ForEach(viewModel.log.observationsInLast(days: 7), id: \.self.id) {ob in
                        HStack {
                            Text(ob.formattedDate)
                            Spacer()
                            Text(ob.formattedGreenhouseTemp)
                        }
                        
                    }
                }
                
                Button("Clear All Observations", role: .destructive) {
                    viewModel.log.clearObservations()
                    viewModel.log.save()
                    dismiss()
                    
                }
            }
        }
        
    }
}

#Preview {
    HistoryView(log: WeatherLog.example)
}
