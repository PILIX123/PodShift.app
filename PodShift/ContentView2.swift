//
//  ContentView2.swift
//  PodShift
//
//  Created by Pierre-Luc Robitaille on 2024-11-23.
//

import SwiftUI

struct FormUpdate: Encodable {
    let currentEpisode: Int
    let amountOfEpisode: Int
    let recurrence: Int
    let everyX: Int
}

struct UpdateResponse: Codable {
    let UUID: String
    let freq: Int
    let interval: Int
    let amount: Int
    let url: String
    let title: String
}

struct ContentView2: View {
    @State public var podcast: Podcast
    @State private var editMode = false
    @State private var interval: Interval
    @State private var alertTitle = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var currentEpisode: Int = 1
    private var feed: URL?

    init(podcast: Podcast) {
        self.interval = Interval(rawValue: podcast.interval)!
        self.podcast = podcast
        //TODO: Make the URL change with ENV
        self.feed = URL(string: "http://localhost:8000/PodShift/\(self.podcast.id)")
    }

    var body: some View {
        Form {
            VStack(alignment: .leading) {
                HStack {
                    Text("URL")
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(podcast.url)")
                }
                .padding(.bottom, 5)
                Divider()
                Text(
                    "Number of episodes"
                )
                .fontWeight(.bold)
                Stepper(
                    "^[\(podcast.amount) episode](inflect: true)", value: $podcast.amount,
                    in: 1...50
                )
                .disabled(!editMode)
                Divider()
                Text("Interval")
                    .fontWeight(.bold)
                Picker("Desired interval", selection: $interval) {
                    ForEach(Interval.allCases, id: \.self) {
                        Text($0.stringValue().capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(!editMode)
                Stepper(
                    "^[Every \(podcast.frequence) \(interval.stringValue())](inflect: true)",
                    value: $podcast.frequence, in: 1...50
                )
                .disabled(!editMode)
            }

            if editMode {
                HStack {
                    Text("Current episode number")
                    Spacer()
                    TextField(
                        "Number of episode", value: $currentEpisode,
                        formatter: NumberFormatter()
                    )
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .frame(minWidth: 15, maxWidth: 60)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    Stepper("Value", value: $currentEpisode, in: 1...Int.max)
                        .labelsHidden()
                }
            }
            Section {
                VStack(alignment: .leading) {
                    Text("Custom URL")
                        .fontWeight(.bold)
                    if let validFeed = feed {
                        ShareLink(item: validFeed) {
                            HStack {
                                Text(validFeed.absoluteString)
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .navigationTitle("\(podcast.title)")
        .toolbar {
            if editMode {
                Button("Done") {
                    alertMessage = "Are you sure you want to update \(podcast.title)?"
                    alertTitle = "Update \(podcast.title)?"
                    showAlert = true
                }
                .alert(alertTitle, isPresented: $showAlert) {
                    Button("Yes", action: updatePodcast)
                    Button("No", role: .cancel) { showAlert = false }
                } message: {
                    Text(alertMessage)
                }
            } else {
                Button("Edit") {
                    editMode = true
                }
            }
        }
    }

    func updatePodcast() {
        let podshiftURL = URL(string: "http://localhost:8000/PodShift/\(podcast.id)")!
        var request = URLRequest(url: podshiftURL)
        request.httpMethod = "PUT"
        let formUpdate = FormUpdate(
            currentEpisode: currentEpisode,
            amountOfEpisode: podcast.amount,
            recurrence: interval.rawValue,
            everyX: podcast.frequence
        )
        print(podcast.id)
        print(formUpdate)
        let data = try! JSONEncoder().encode(formUpdate)
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print(data)

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                let statusCode = (response as! HTTPURLResponse).statusCode

                if statusCode == 200 {
                    alertTitle = "Success"
                    alertMessage = "Podcast updated"
                    let content = try JSONDecoder().decode(UpdateResponse.self, from: data)
                    podcast.frequence = content.freq
                    podcast.amount = content.amount
                    podcast.interval = content.interval
                    podcast.url = content.url
                    podcast.title = content.title
                    podcast.id = content.UUID
                } else {
                    let content = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    alertTitle = "Error"
                    alertMessage = content.detail
                }
            } catch {
                alertTitle = "There was an error with the request"
            }
            showAlert = true
            editMode = false
        }
    }
}

#Preview {
    ContentView2(
        podcast: Podcast(
            id: "36de6aa6-52be-11ef-b68d-825a0b18bae7", title: "WOW", frequence: 1, interval: 2,
            amount: 2,
            url: "example.com"))
}
