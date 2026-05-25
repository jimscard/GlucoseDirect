//
//  GlucoseSettingsView.swift
//  GlucoseDirect
//

import SwiftUI

// MARK: - GlucoseSettingsView

struct GlucoseSettingsView: View {
    // MARK: Internal

    @EnvironmentObject var store: DirectStore

    var body: some View {
        Section(
            content: {
                Picker("Glucose unit", selection: selectedGlucoseUnit) {
                    Text(GlucoseUnit.mgdL.localizedDescription).tag(GlucoseUnit.mgdL.rawValue)
                    Text(GlucoseUnit.mmolL.localizedDescription).tag(GlucoseUnit.mmolL.rawValue)
                }.pickerStyle(.menu)

                if #available(iOS 16.1, *) {
                    Toggle("Glucose Live Activity", isOn: glucoseLiveActivity).toggleStyle(SwitchToggleStyle(tint: Color.ui.accent))
                }
            },
            header: {
                Label("Glucose settings", systemImage: "cross.case")
            }
        )
    }

    // MARK: Private

    private var glucoseLiveActivity: Binding<Bool> {
        Binding(
            get: { store.state.glucoseLiveActivity },
            set: { store.dispatch(.setGlucoseLiveActivity(enabled: $0)) }
        )
    }

    private var selectedGlucoseUnit: Binding<String> {
        Binding(
            get: { store.state.glucoseUnit.rawValue },
            set: { store.dispatch(.setGlucoseUnit(unit: GlucoseUnit(rawValue: $0)!)) }
        )
    }
}
