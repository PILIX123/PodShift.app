//
//  ContentView2.swift
//  PodShift
//
//  Created by Pierre-Luc Robitaille on 2024-11-23.
//

import SwiftUI

struct ContentView2: View {
    @State public var podcast: Podcast
    @State private var editMode = false
    @State private var interval:Interval
    init(podcast:Podcast){
        self.interval = Interval(rawValue: podcast.interval)!
        self.podcast=podcast
    }
    
    var body: some View {
        VStack {
            Text("Title: \(podcast.title)")
            HStack{
                Picker("Desired interval", selection: $interval) {
                    ForEach(Interval.allCases, id: \.self) {
                        Text($0.stringValue().capitalized)
                    }
                }
                .pickerStyle(.segmented)
                .disabled(!editMode)
            }
        }
    }
}

#Preview {
    ContentView2(podcast:Podcast(id:UUID().uuidString,title:"Test",frequence:2,interval:1,amount:1,url:"example.com"))
}
