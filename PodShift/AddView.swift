////
////  AddView.swift
////  PodShift
////
////  Created by Pierre-Luc Robitaille on 2024-10-30.
////
import SwiftUI

struct AddView: View {
    @Environment(\.dismiss) var dismiss
    private let podshiftAPI = "http://localhost:8000/PodShift/"
    @State private var url = ""
    @State private var numberOfEpisode = 1
    @State private var numberOfX = 2
    @State private var interval: Interval = .day
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var customFeed: URL?
    //@State private var containCustomFeed:
    @FocusState private var urlSelected: Bool
    var podcasts: [Podcast]
    var formattedURL: String {
        if !url.starts(with: "https://") {
            return "https://\(url)"
        } else {
            return url
        }
    }

    let pasteboard = UIPasteboard.general

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("URL of the RSS feed", text: $url)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .focused($urlSelected)
                        .keyboardType(.URL)
                }
                Section("Configuratuion") {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Desired interval")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Picker("Desired interval", selection: $interval) {
                            ForEach(Interval.allCases, id: \.self) {
                                Text($0.stringValue().capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Stepper(
                            "^[Every \(numberOfX) \(interval.stringValue())](inflect: true)",
                            value: $numberOfX, in: 1...50)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        Text(
                            "Number of desired episodes per ^[\(numberOfX) \(interval.stringValue())](inflect: true)"
                        )
                        .font(.headline)
                        .padding(.bottom)
                        Stepper(
                            "^[\(numberOfEpisode) episode](inflect: true)",
                            value: $numberOfEpisode, in: 1...15)
                    }
                }

                Section {
                    if let validFeed = customFeed {
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
                if !url.isEmpty {
                    Section {
                        HStack {
                            Spacer()
                            Button("Get Custom Feed", action: get_custom_feed)
                                .alert(alertTitle, isPresented: $showingAlert) {
                                    Button("Ok") {}
                                } message: {
                                    Text(alertMessage)
                                }
                                .controlSize(.large)
                                .buttonStyle(.borderedProminent)
                            Spacer()
                        }
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle("Add a new shifted feed")
            .toolbar {
                if urlSelected {
                    Button("Done") {
                        urlSelected = false
                    }
                }
            }
        }
    }

    func get_custom_feed() {
        let podshiftURL = URL(string: podshiftAPI)!
        var request = URLRequest(url: podshiftURL)
        request.httpMethod = "POST"
        let formContent = FormContent(
            url: formattedURL,
            amountOfEpisode: numberOfEpisode,
            recurrence: interval.intValue(),
            everyX: numberOfX
        )

        let data = try! JSONEncoder().encode(formContent)

        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)

                let statusCode = (response as! HTTPURLResponse).statusCode

                if statusCode == 200 {
                    alertTitle = "Success"

                    let contentResponse = try JSONDecoder().decode(ContentResponse.self, from: data)
                    pasteboard.string = contentResponse.url
                    customFeed = URL(string: contentResponse.url) ?? nil
                    alertMessage = "Url added to clipboard"
                } else {
                    let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                    alertTitle = errorResponse.detail
                }
            } catch {
                alertTitle = "There was an error with the request"
            }
            showingAlert = true

            dismiss()
        }
    }
}

#Preview {
    AddView(podcasts: [
        Podcast(
            id: "36de6aa6-52be-11ef-b68d-825a0b18bae7", title: "ATP", frequence: 2, interval: 1,
            amount: 1, url: "atp.fm/rss")
    ])
}
