//
//  SubjectListView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 02/06/26.
//

import SwiftUI

struct SubjectListView: View {
    @StateObject private var viewModel = SubjectViewModel()
    @State private var isShowingSubjectForm = false
    
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
                        isShowingSubjectForm = true
                    }
                    label:
                    {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Subject")
                }
            }
            .sheet(isPresented: $isShowingSubjectForm, onDismiss:
                    {
                viewModel.loadSubjects()
            }
            )
            {
                SubjectFormView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    SubjectListView()
}
