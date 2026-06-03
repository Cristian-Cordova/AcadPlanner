//
//  AcadPlannerApp.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import SwiftUI
import FirebaseCore

@main
struct AcadPlannerApp: App {
    init()
    {
        configureFirebase()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    private func configureFirebase() {
        guard FirebaseApp.app() == nil,
              Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        else {
            return
        }
        
        FirebaseApp.configure()
    }
}
