//
//  AppleExportSettingsView.swift
//  GlucoseDirect
//

import SwiftUI

// MARK: - AppleExportSettingsView

struct AppleExportSettingsView: View {
    // MARK: Internal

    @EnvironmentObject var store: DirectStore

    var body: some View {
        Section(
            content: {
                Toggle("Export to Apple Health", isOn: appleHealthExport).toggleStyle(SwitchToggleStyle(tint: Color.ui.accent))
            },
            header: {
                Label("Apple Health", systemImage: "heart.text.square")
            }
        )
    }

    // MARK: Private

    private var appleHealthExport: Binding<Bool> {
        Binding(
            get: { store.state.appleHealthExport },
            set: { store.dispatch(.requestAppleHealthAccess(enabled: $0)) }
        )
    }
}
