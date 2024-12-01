//
//  SwiftUIView.swift
//  PodShift
//
//  Created by Pierre-Luc Robitaille on 2024-11-20.
//

import SwiftUI

struct Podcast: Hashable, Identifiable, Codable {
    var id: String
    var title: String
    var frequence: Int
    var interval: Int
    var amount: Int
    var url: String
}

@Observable
class Podcasts {
    var items = [Podcast]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "podcasts")
            }
        }
    }

    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "podcasts") {
            if let decoded = try? JSONDecoder().decode([Podcast].self, from: savedItems) {
                items = decoded
                return
            }
        }

        items = []
    }
}

struct ListView: View {
    @State private var showAddPodcast: Bool = false
    @State private var podcastsTest = Podcasts()

    var body: some View {
        NavigationStack {
            List {
                ForEach(podcastsTest.items) { podcast in
                    NavigationLink("\(podcast.title)", value: podcast)
                }

            }
            .navigationDestination(for: Podcast.self) { podcast in
                ContentView2(podcast: podcast)
            }
            .navigationTitle("PodShift")
            .toolbar {
                Button(action: {
                    showAddPodcast = true
                }) {
                    Image(systemName: "plus")
                        .padding()
                }
            }
            .sheet(isPresented: $showAddPodcast) {
                AddView(podcasts: podcastsTest)
            }
        }

    }

}

#Preview {
    ListView()
}
