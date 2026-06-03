//
//  ContentView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
       TabView
        {
            DashboardView().tabItem
            {
                Label("Dashboard", systemImage: "chart.bar")
            }
            
            TaskListView().tabItem
            {
                Label("Dashboard", systemImage: "checklist")
            }
            
            SubjectListView().tabItem
            {
                Label("Subjects",systemImage: "books.vertical")
            }
        }
    }
}

#Preview {
    ContentView()
}
