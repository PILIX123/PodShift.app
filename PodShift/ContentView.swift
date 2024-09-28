//
//  ContentView.swift
//  PodShift
//
//  Created by Pierre-Luc Robitaille on 2024-09-28.
//

import SwiftUI

struct ContentView: View {
    private let podshiftAPI = "http://podshift.ddns.net:8080/PodShift/"
    @State private var url = ""
    @State private var numberOfEpisode = 1
    @State private var numberOfX = 2
    @State private var interval: Interval = .day
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    struct ErrorResponse: Codable {
        let detail: String?
    }
    enum Interval: CaseIterable{
        case week, day, year, month
        
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
    
    var body: some View {
        NavigationStack {
            Form(){
                Section(){
                    TextField("Url of the RSS feed",text:$url)
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
                
                
                
                
            }
            .navigationTitle("PodShift")
            .toolbar{
                Button("Get Custom Feed", action: test)
                    .alert(alertTitle,isPresented: $showingAlert){
                        Button("Ok"){}
                    } message: {
                        Text(alertMessage)
                    }
                
            }
            
            
        }
    }
    func test() -> Void{
        let podshiftURL = URL(string: podshiftAPI)!
        var request = URLRequest(url: podshiftURL)
        request.httpMethod = "POST"
        struct FormContent: Encodable{
            let url: String
            let amountOfEpisode: Int
            let recurrence:Int
            let everyX: Int
        }
        
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
                } else{
                   
                    alertTitle = "Fail"
                    do{
                        let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        alertMessage = errorResponse.detail!
                    }
                    catch{
                        alertMessage = "There was an unexpected error"
                    }
                }
                showingAlert = true
            } catch{
                alertTitle = "There was an error with the request"
                
                showingAlert = true
            }
        }
    }
    
}

#Preview {
    ContentView()
}
