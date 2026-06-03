//
//  DashboardViewModel.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import Foundation
import Combine

final class DashboardViewModel: ObservableObject
{
    @Published private(set) var upcomingTasks: [AcademicTask] = []
    @Published private(set) var pendingTaskCount: Int = 0
    @Published private(set) var completedTaskCount: Int = 0
    @Published private(set) var calendarTaskCount: Int = 0
    
    private let taskRepository: TaskRepository
    
    init(taskRepository: TaskRepository = TaskRepository())
    {
        self.taskRepository = taskRepository
        loadDashboardData()
    }
    
    func loadDashboardData()
    {
        let tasks = taskRepository.fetchTasks()
        
        upcomingTasks = taskRepository.fetchUpcomingTasks(limit: 5)
        pendingTaskCount = tasks.filter{$0.status == .pending || $0.status == .inProgress}.count
        completedTaskCount = tasks.filter { $0.status == .completed }.count
        calendarTaskCount = tasks.filter { $0.isAddedToCalendar}.count
    }
}
