import SwiftData
import SwiftUI

/// Detail of one item, pushed from a row or opened from a notification.
struct ItemDetailView: View {
    private struct EditRequest: Identifiable {
        let id = UUID()
        var field: ItemFormView.Field?
    }

    @Environment(AppModel.self) private var model
    @Query private var matches: [Item]
    @State private var editRequest: EditRequest?

    init(itemID: UUID) {
        let id = itemID
        _matches = Query(filter: #Predicate<Item> { $0.id == id })
    }

    var body: some View {
        Group {
            if let item = matches.first {
                content(item.data)
            } else {
                ContentUnavailableView("Niet gevonden", systemImage: "questionmark.circle")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editRequest) { request in
            if let item = matches.first {
                NavigationStack {
                    ItemFormView(
                        draft: ItemDraft(item: item.data, today: model.today, now: model.now, calendar: model.calendar),
                        isNew: false,
                        focus: request.field
                    ) { draft in
                        model.save(draft)
                        editRequest = nil
                    }
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Annuleer") { editRequest = nil }
                        }
                    }
                }
            }
        }
    }

    /// Rows without horizontal inset sit under the rounded corners of their grouped section,
    /// which clip anything within about this distance of a corner.
    private let sectionCornerClearance: CGFloat = 20

    private func content(_ item: ItemData) -> some View {
        let today = model.today
        let texts = DetailTexts(item: item, today: today, now: model.now, calendar: model.calendar)
        let service = model.catalog.service(id: item.catalogID)

        return List {
            Section {
                header(item, texts: texts, category: service?.category ?? .other)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: sectionCornerClearance, leading: 0, bottom: sectionCornerClearance, trailing: 0))
            }

            Section {
                actions(item, appleBilling: service?.appleBilling ?? false)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: sectionCornerClearance, leading: 0, bottom: sectionCornerClearance, trailing: 0))
            }

            Section {
                infoRow("Soort", value: kindText(item), field: .kind)
                infoRow("Start", value: DutchFormat.short(item.startDate, today: today), field: .startDate)
                infoRow("Opzegtermijn", value: item.noticeValue == 0 ? "Geen" : DutchFormat.notice(value: item.noticeValue, unit: item.noticeUnit), field: .notice)
                infoRow("Seintje", value: reminderText(item), field: .lead)
                infoRow("Opzeglink", value: item.cancelURL ?? "Geen", field: .cancelURL)
                infoRow("Notitie", value: item.note.isEmpty ? "Geen" : item.note, field: .note)
            }
            .listRowBackground(Color.paperRaised)

            Section {
                Button("Bewerken") {
                    editRequest = EditRequest(field: nil)
                }
                .foregroundStyle(Color.ink)
                Button("Verwijderen", role: .destructive) {
                    model.delete(item.id)
                }
            }
            .listRowBackground(Color.paperRaised)
        }
        .listStyle(.insetGrouped)
        .paperBackground()
    }

    // MARK: - Header

    private func header(_ item: ItemData, texts: DetailTexts, category: ServiceCategory) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                LetterIcon(name: item.name, category: category, size: 52)
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(texts.headline)
                .font(.serif(.largeTitle, weight: .semibold))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
            if let subline = texts.subline {
                Text(subline)
                    .font(.body)
                    .foregroundStyle(Color.ink.opacity(0.7))
            }
            if let note = texts.tooLateNote {
                Label(note, systemImage: "exclamationmark.triangle")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Actions

    @ViewBuilder
    private func actions(_ item: ItemData, appleBilling: Bool) -> some View {
        VStack(spacing: 10) {
            switch item.status {
            case .trial, .active:
                Button {
                    model.requestCancel(item.id)
                } label: {
                    Text(hasCancelLink(item) ? "Opzeggen" : "Zoek opzegpagina")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                if appleBilling {
                    Button {
                        model.openAppleSubscriptions()
                    } label: {
                        Text("Betaald via Apple?")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SecondaryButtonStyle())
                }

                Button {
                    model.keep(item.id)
                } label: {
                    Text("Houden")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())

            case .cancelled:
                Button {
                    model.undoCancel(item.id)
                } label: {
                    Text("Toch niet opgezegd")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButtonStyle())

            case .stopped:
                EmptyView()
            }
        }
    }

    private func hasCancelLink(_ item: ItemData) -> Bool {
        !(item.cancelURL?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }

    // MARK: - Info rows

    private func infoRow(_ label: String, value: String, field: ItemFormView.Field) -> some View {
        Button {
            editRequest = EditRequest(field: field)
        } label: {
            LabeledContent(label) {
                Text(value)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(4)
            }
            .foregroundStyle(.primary)
        }
        .accessibilityHint("Wijzigen")
    }

    private func kindText(_ item: ItemData) -> String {
        if item.kind == .trial { return "Proefperiode" }
        switch item.effectiveInterval {
        case .fixedEnd: return "Abonnement met vaste einddatum"
        case .week: return "Abonnement, elke week"
        case .month: return "Abonnement, elke maand"
        case .quarter: return "Abonnement, elk kwartaal"
        case .year: return "Abonnement, elk jaar"
        }
    }

    private func reminderText(_ item: ItemData) -> String {
        guard ReminderRules.remindersEnabled(for: item) else { return "Uit" }
        let leads = ReminderRules.leads(for: item, settings: model.settings.reminderSettings)
        let parts = leads.map { $0 == 0 ? "op de dag zelf" : "\(DutchFormat.days($0)) vooraf" }
        return parts.joined(separator: " en ")
    }
}
