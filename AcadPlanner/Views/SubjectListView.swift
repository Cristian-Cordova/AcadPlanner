//
//  SubjectListView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import SwiftUI

struct SubjectListView: View {
    @StateObject private var viewModel = SubjectViewModel()
    @State private var formDestination: SubjectFormDestination?
    
    var body: some View
    {
        NavigationStack
        {
            List
            {
                ForEach(viewModel.subjects)
                { subject in VStack(alignment: .leading, spacing: 4) {
                        Text(subject.name)
                            .font(.headline)
                        
                        Text(subject.professor)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false)
                    {
                        Button(role: .destructive)
                        {
                            viewModel.deleteSubject(id: subject.id)
                        }
                        label:
                        {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false)
                    {
                        Button("Edit")
                        {
                            formDestination = .edit(subject)
                        }
                        .tint(.blue)
                    }
                }
                .onDelete
                { indexSet in indexSet
                        .map
                    { viewModel.subjects[$0].id }
                        .forEach
                    { viewModel.deleteSubject(id: $0) }
                }
            }
            .navigationTitle("Subjects")
            .toolbar
            {
                ToolbarItem(placement: .topBarTrailing)
                {
                    Button
                    {
                        formDestination = .create
                    }
                    label:
                    {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Subject")
                }
            }
            .sheet(item: $formDestination, onDismiss:
                    {
                viewModel.loadSubjects()
            }
            )
            {
                destination in
                switch destination
                {
                case .create:
                    SubjectFormView(viewModel: viewModel)
                case .edit(let subject):
                    SubjectFormView(viewModel: viewModel, subject: subject)
                }
            }
        }
    }
}

private enum SubjectFormDestination: Identifiable
{
    case create
    case edit(Subject)
    
    var id: String
    {
        switch self
        {
        case .create:
            return "create"
        case .edit(let subject):
            return subject.id.uuidString
        }
    }
}

#Preview {
    SubjectListView()
}
