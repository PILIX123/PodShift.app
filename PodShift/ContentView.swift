//
//  ContentView.swift
//  PodShift
//
//  Created by Pierre-Luc Robitaille on 2024-09-28.
//

import SwiftUI

struct ContentView: View {
    private let podshiftAPI = "http://localhost:8000/PodShift/"
    @State private var url = ""
    @State private var numberOfEpisode = 1
    @State private var numberOfX = 2
    @State private var interval: Interval = .day
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var customFeed: URL?
    
    struct ErrorResponse: Codable {
        let detail: String
    }
    
    struct ContentResponse: Codable{
        let url : String
    }
    
    struct FormContent: Encodable{
        let url: String
        let amountOfEpisode: Int
        let recurrence:Int
        let everyX: Int
    }
    
    enum Interval: CaseIterable{
        case day, week, month, year
        
        func stringValue() -> String{
            switch(self){
            case .day:
                return "day"
            case .week:
                return "week"
            case .month:
                return "month"
            case .year:
                return "year"
            }
        }
        func intValue() -> Int{
            switch(self){
            case .day:
                return 3
            case .week:
                return 2
            case .month:
                return 1
            case .year:
                return 0
            }
        }
    }
    
    let pasteboard = UIPasteboard.general
    
    
    var body: some View {
        NavigationStack {
            Form(){
                Section(){
                    TextField("Url of the RSS feed",text:$url)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                }
                Section("Configuratuion"){
                    VStack(alignment: .leading, spacing: 0){
                        Text("Desired interval")
                            .font(.headline)
                            .padding(.bottom, 10)
                        Picker("Desired interval", selection: $interval){
                            ForEach(Interval.allCases, id:\.self){
                                Text($0.stringValue().capitalized)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    VStack(alignment: .leading, spacing: 0){
                        Stepper("^[Every \(numberOfX) \(interval.stringValue())](inflect: true)" ,value: $numberOfX, in: 1...50 )
                    }
                    VStack(alignment: .leading, spacing: 0){
                        Text("Number of desired episodes per ^[\(numberOfX) \(interval.stringValue())](inflect: true)")
                            .font(.headline)
                            .padding(.bottom)
                        Stepper("^[\(numberOfEpisode) episode](inflect: true)" ,value: $numberOfEpisode, in: 1...15 )
                    }
                }
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
                } else {
                    HStack {
                        Text("No URL")
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .navigationTitle("PodShift")
            .toolbar{
                Button("Get Custom Feed", action: get_custom_feed)
                    .alert(alertTitle,isPresented: $showingAlert){
                        Button("Ok"){}
                    } message: {
                        Text(alertMessage)
                    }
            }
        }
    }
    
    func get_custom_feed() -> Void{
        let podshiftURL = URL(string: podshiftAPI)!
        var request = URLRequest(url: podshiftURL)
        request.httpMethod = "POST"
        
        
        let formContent = FormContent(
            url: url,
            amountOfEpisode: numberOfEpisode,
            recurrence: interval.intValue(),
            everyX: numberOfX
        )
        
        let data = try! JSONEncoder().encode(formContent)
        
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        Task{
            do{
                let (data,response) = try await URLSession.shared.data(for: request)
               
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                if statusCode == 200{
                    alertTitle = "Success"

                    let contentResponse = try JSONDecoder().decode(ContentResponse.self, from: data)
                    pasteboard.string = contentResponse.url
                    customFeed = URL(string: contentResponse.url) ?? nil
                    alertMessage = "Url added to clipboard"
                } else{
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        alertTitle = errorResponse.detail
                }
            } catch{
                alertTitle = "There was an error with the request"
                alertMessage = "\(error)"
            }
            showingAlert = true
        }
    }
}

#Preview {
    ContentView()
}
