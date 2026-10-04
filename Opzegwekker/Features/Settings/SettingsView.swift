import OSLog
import SwiftData
import SwiftUI
import UserNotifications

struct SettingsView: View {
    private static let sourceCodeURL = URL(string: "https://github.com/lambertsj/Basis-abbo")
    private static let basisAppsURL = URL(string: "https://basisapps.nl")

    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Item.createdAt) private var items: [Item]
    @State private var showsEraseConfirmation = false
    @State private var csvURL: URL?

    var body: some View {
        @Bindable var settings = model.settings
        NavigationStack {
            Form {
                Section("Meldingen") {
                    LabeledContent("Meldingen", value: notificationsOn ? "Aan" : "Uit")
                    if !notificationsOn {
                        Button(model.notificationStatus == .notDetermined ? "Zet aan" : "Zet aan in iOS-instellingen") {
                            if model.notificationStatus == .notDetermined {
                                Task { await model.requestAuthorization() }
                            } else {
                                model.openNotificationSettings()
                            }
                        }
                    }
                }

                Section("Tijdstip seintjes") {
                    DatePicker("Tijdstip", selection: reminderTime, displayedComponents: .hourAndMinute)
                }

                Section {
                    Stepper(value: $settings.trialLeadDays, in: 0...30) {
                        LabeledContent("Proef", value: DutchFormat.days(settings.trialLeadDays))
                    }
                    Stepper(value: $settings.yearLeadDays, in: 0...90) {
                        LabeledContent("Jaar", value: DutchFormat.days(settings.yearLeadDays))
                    }
                } header: {
                    Text("Standaard vooraf")
                } footer: {
                    Text("Hoeveel dagen vóór de beslisdatum je het eerste seintje krijgt.")
                }

                Section {
                    Toggle("App-badge", isOn: $settings.badgeEnabled)
                } footer: {
                    Text("Toont het aantal items in Nu beslissen op het app-icoon.")
                }

                Section {
                    if let csvURL {
                        ShareLink(item: csvURL) {
                            Label("Exporteer als CSV", systemImage: "square.and.arrow.up")
                        }
                    } else {
                        Label("Exporteer als CSV", systemImage: "square.and.arrow.up")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Over") {
                    Text("Opzegwekker is een BasisApp: gratis, zonder reclame, zonder account en zonder tracking. Alles blijft op je telefoon. De broncode is openbaar, zodat iedereen kan nagaan wat de app doet.")
                        .fixedSize(horizontal: false, vertical: true)
                    if let url = Self.basisAppsURL {
                        Link("basisapps.nl", destination: url)
                    }
                    if let url = Self.sourceCodeURL {
                        Link("Broncode", destination: url)
                    }
                }

                #if DEBUG
                Section("Ontwikkeling") {
                    Button("Testdata laden") {
                        DebugSeed.populate(context: model.context, today: model.today, catalog: model.catalog)
                        model.afterChange()
                    }
                }
                #endif

                Section {
                    Button("Alles wissen", role: .destructive) {
                        showsEraseConfirmation = true
                    }
                }
            }
            .paperBackground()
            .navigationTitle("Instellingen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Klaar") { dismiss() }
                }
            }
            .confirmationDialog("Alles wissen?", isPresented: $showsEraseConfirmation, titleVisibility: .visible) {
                Button("Alles wissen", role: .destructive) {
                    model.eraseAll()
                }
            } message: {
                Text("Al je abonnementen, proeven en instellingen worden van deze telefoon verwijderd. Dit kun je niet ongedaan maken.")
            }
        }
        .onChange(of: settings.reminderSettings) {
            model.settingsChanged()
        }
        .task(id: items.map(\.updatedAt)) {
            csvURL = writeCSV()
        }
        .task {
            await model.updateNotificationStatus()
        }
        .presentationBackground(Color.paper)
    }

    private var notificationsOn: Bool {
        switch model.notificationStatus {
        case .authorized, .provisional, .ephemeral: true
        case .denied, .notDetermined: false
        @unknown default: false
        }
    }

    private var reminderTime: Binding<Date> {
        let calendar = model.calendar
        let settings = model.settings
        return Binding {
            calendar.date(bySettingHour: settings.reminderHour, minute: settings.reminderMinute, second: 0, of: Date()) ?? Date()
        } set: { date in
            let components = calendar.dateComponents([.hour, .minute], from: date)
            settings.reminderHour = components.hour ?? 9
            settings.reminderMinute = components.minute ?? 0
        }
    }

    /// Writes `opzegwekker-<yyyy-mm-dd>.csv` to the temporary directory.
    private func writeCSV() -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(CSVExport.fileName(today: model.today))
        do {
            try CSVExport.make(items.map(\.data)).write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            Logger(subsystem: "Opzegwekker", category: "export")
                .error("Writing the CSV failed: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }
}
