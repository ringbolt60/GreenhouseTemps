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
        
        NavigationStack {
            Form {
                Section("Most recent observation") {
                    HStack {
                        Text(viewModel.log.lastObservation.formattedDate)
                        Spacer()
                        Text(viewModel.log.lastObservation.formattedGreenhouseTemp)
                    }
                }
                Section() {
                    HStack {
                        Text("\(viewModel.rollingAverageLabel) rolling mean")
                        Spacer()
                        Text(viewModel.log.formattedMeanGreenhouseTempInRollingPeriod)
                    }
                    HStack {
                        Text("Variance from mean")
                        Spacer()
                        Text(viewModel.log.formattedVariationOfGreenhouseTempInRollingPeriod)
                    }
                }
                
                       
                Button("Select \(viewModel.rollingAverageCommand) rolling mean") {
                    viewModel.log.toggleRollingPeriod()
                    print(viewModel.log.rollingPeriod)
                    viewModel.rollingPeriodIs7Days.toggle()
                    
                }
            }
            
            .toolbar {
                Button("dismiss") {
                    dismiss()
                }
            }
            .navigationTitle("History")
        }
        
        
        if viewModel.log.hasObservations {
            Form {
                Section("Previous observations") {
                    List {
                        ForEach(viewModel.log.observationsInLast(days: 7), id: \.self.id) {ob in
                            HStack {
                                Text(ob.formattedDate)
                                Spacer()
                                Text(ob.formattedGreenhouseTemp)
                            }
                            
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
