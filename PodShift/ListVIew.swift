//
//  SwiftUIView.swift
//  PodShift
//
//  Created by Pierre-Luc Robitaille on 2024-11-20.
//

import SwiftUI

struct Podcast:Hashable,Identifiable {
    var id: String
    var title: String
    var frequence:Int
    var interval: Int
    var amount:Int
    var url: String
}

struct ListView: View {
    @State public var podcasts: [Podcast] = [
        Podcast(id: UUID().uuidString, title: "ATP", frequence: 1, interval: 1, amount: 1, url: "https://www.swiftuiview.com/"),
        Podcast(id: UUID().uuidString, title: "Connected", frequence: 1, interval: 1, amount: 1, url: "https://www.swiftuiview.com/"),
        Podcast(id: UUID().uuidString, title: "Upgrade", frequence: 1, interval: 1, amount: 1, url: "https://www.swiftuiview.com/"),
        Podcast(id: UUID().uuidString, title: "Parlons marriage", frequence: 1, interval: 1, amount: 1, url: "https://www.swiftuiview.com/"),
    ]
    var body: some View {
        NavigationStack{
            List{
                ForEach(podcasts) { podcast in
                    NavigationLink(podcast.id, destination: Text(podcast.title))
                }.navigationDestination(for: Podcast.self){podcast in
                        ContentView2(podcast: podcast)
                }
            }
        }
    }
    
}

#Preview {
    ListView()
}
