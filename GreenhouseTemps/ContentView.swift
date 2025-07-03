//
//  ContentView.swift
//  GreenhouseTemps
//
//  Created by Jon Walters on 23/06/2025.
//

import SwiftUI

struct ContentView: View {

    @State private var viewModel = ViewModel()

    @State private var isHistoryPresented = false
    @State private var showingExporter = false

    @FocusState private var greenhouseTempIsFocussed: Bool
    @FocusState private var gardenTempIsFocussed: Bool
    @FocusState private var minTempIsFocussed: Bool
    @FocusState private var maxTempIsFocussed: Bool
    @FocusState private var noteIsFocussed: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                

                Section("New observation") {
                    HStack {

                        TextField(
                            "Greenhouse Temp",
                            value: $viewModel.greenhouseTemp,
                            format: .number.rounded(increment: 0.1),
                            prompt: Text("greenhouse temperature")
                        )
                        .focused($greenhouseTempIsFocussed)

                        Text("℃")
                    }
                    HStack {
                        TextField(
                            "Min temp",
                            value: $viewModel.minTemp,
                            format: .number,
                            prompt: Text("min temp since last obs")
                        )
                        .focused($minTempIsFocussed)
                        Text("℃")

                    }
                    HStack {
                        TextField(
                            "Max temp",
                            value: $viewModel.maxTemp,
                            format: .number,
                            prompt: Text("max temp since last obs")
                        )
                        .focused($maxTempIsFocussed)
                        Text("℃")

                    }
                    HStack {
                        TextField(
                            "garden temp",
                            value: $viewModel.gardenTemp,
                            format: .number.rounded(increment: 0.1),
                            prompt: Text("garden temperature")
                        )
                        .focused($gardenTempIsFocussed)
                        Text("℃")
                    }

                    TextField("note", text: $viewModel.note)
                        .keyboardType(.default)
                        .focused($noteIsFocussed)

                }
                .keyboardType(.decimalPad)
                
                Section("Last observation") {
                    Text(viewModel.lastObservation.formattedDate)
                    Text(viewModel.lastObservation.formattedGreenhouseTemp)
                    Text(viewModel.lastObservation.formattedTempRange)
                    Text(viewModel.lastObservation.note)
                }

                Section("Garden Temperature") {
                    Text(
                        viewModel.lastObservation.formattedGardenTemp
                    )
                }
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("History", systemImage: "rectangle.on.rectangle") {
                        isHistoryPresented = true

                    }
                }
                ToolbarItem {
                    Button("Submit", systemImage: "arrow.up.circle") {
                        viewModel.addObservation()
                        gardenTempIsFocussed = false
                        minTempIsFocussed = false
                        maxTempIsFocussed = false
                        greenhouseTempIsFocussed = false
                    }
                    .disabled(viewModel.isObservationInputValid == false)
                }
            }
            .navigationTitle("Greenhouse Temps")
            .sheet(
                isPresented: $isHistoryPresented,
                onDismiss: {
                    greenhouseTempIsFocussed = true
                }
            ) {
                HistoryView(log: viewModel.log)
            }
            .onAppear {
                greenhouseTempIsFocussed = true
                
            }
        }
    }

}

#Preview {
    ContentView()
}
