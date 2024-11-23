//
//  PodShiftApp.swift
//  PodShift
//
//  Created by Pierre-Luc Robitaille on 2024-09-28.
//

import SwiftUI

@main
struct PodShiftApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView2(podcast:Podcast(id:UUID().uuidString,title:"Test",frequence:2,interval:1,amount:1,url:"example.com"))
        }
    }
}
