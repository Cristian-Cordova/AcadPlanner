//
//  SubjectFormView.swift
//  AcadPlanner
//
//  Created by Cristian Cordova on 03/06/26.
//

import SwiftUI

struct SubjectFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SubjectViewModel
    
    private let subject: Subject?
    
    @State private var name = ""
    @State private var professor = ""
    @State private var colorHex = "#3B82F6"
    
    init(viewModel: SubjectViewModel, subject: Subject? = nil)
    {
        self.viewModel = viewModel
        self.subject = subject
        _name = State(initialValue: subject?.name ?? "")
        _professor = State(initialValue: subject?.professor ?? "")
        _colorHex = State(initialValue: subject?.colorHex ?? "#3B82F6")
    }
    
    var body: some View
    {
        NavigationStack
        {
            Form
            {
                Section("Subject Information")
                {
                    TextField("Subject Name", text: $name)
                    TextField("Professor", text: $professor)
                    TextField("Color Hex", text: $colorHex)
                        .textInputAutocapitalization(.never)
                }
                
                if let validationMessage = viewModel.validationMessage
                {
                    Section
                    {
                        Text(validationMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(subject == nil ? "New Subject" : "Edit Subject")
            .toolbar
            {
                ToolbarItem(placement: .cancellationAction)
                {
                    Button("Cancel")
                    {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction)
                {
                    Button("Save")
                    {
                        if viewModel.saveSubject(
                            subject: subject,
                            name: name,
                            professor: professor,
                            colorHex: colorHex
                        ) != nil
                        {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SubjectFormView(viewModel: SubjectViewModel())
}
