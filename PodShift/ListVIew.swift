//
//  SwiftUIView.swift
//  PodShift
//
//  Created by Pierre-Luc Robitaille on 2024-11-20.
//

import SwiftUI

struct Podcast: Hashable, Identifiable {
    var id: String
    var title: String
    var frequence: Int
    var interval: Int
    var amount: Int
    var url: String
}

struct ListView: View {
    @State private var showAddPodcast: Bool = false
    @State public var podcasts: [Podcast] = [
        Podcast(
            id: "73c478de-53b8-11ef-8862-b23c27c960c6", title: "ATP", frequence: 1, interval: 1,
            amount: 1, url: "https://www.swiftuiview.com/"),
        Podcast(
            id: UUID().uuidString, title: "Connected", frequence: 1, interval: 1, amount: 1,
            url: "https://www.swiftuiview.com/"),
        Podcast(
            id: UUID().uuidString, title: "Upgrade", frequence: 1, interval: 1, amount: 1,
            url: "https://www.swiftuiview.com/"),
        Podcast(
            id: UUID().uuidString, title: "Parlons marriage", frequence: 1, interval: 1, amount: 1,
            url: "https://www.swiftuiview.com/"),
    ]
    var body: some View {
        NavigationStack {
            List {
                ForEach(podcasts) { podcast in
                    NavigationLink("\(podcast.title)", value: podcast)
                }

            }.navigationDestination(for: Podcast.self) { podcast in
                ContentView2(podcast: podcast)
            }.navigationTitle("PodShift")
                .toolbar {
                    Button(action: {
                        showAddPodcast = true
                    }) {
                        Image(systemName: "plus")
                            .padding()
                    }
                }
                .sheet(isPresented: $showAddPodcast) {
                    AddView(podcasts: podcasts)
                }
        }

    }

}

#Preview {
    ListView()
}
