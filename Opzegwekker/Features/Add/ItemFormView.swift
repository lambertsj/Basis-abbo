import SwiftUI

/// Step 2 of adding, and the edit form. The save button is always enabled.
struct ItemFormView: View {
    enum Field: Hashable {
        case name
        case kind
        case date
        case price
        case startDate
        case notice
        case lead
        case cancelURL
        case note

        /// Fields that live under "Meer opties".
        var isInMoreOptions: Bool {
            switch self {
            case .startDate, .notice, .lead, .cancelURL, .note: true
            case .name, .kind, .date, .price: false
            }
        }
    }

    private enum IntervalChoice: Hashable {
        case month
        case year
        case other
    }

    @Environment(AppModel.self) private var model
    @State private var draft: ItemDraft
    @State private var showsMoreOptions: Bool
    @FocusState private var focus: Field?
    private let isNew: Bool
    private let initialFocus: Field?
    private let onSave: (ItemDraft) -> Void

    init(draft: ItemDraft, isNew: Bool, focus: Field? = nil, onSave: @escaping (ItemDraft) -> Void) {
        _draft = State(initialValue: draft)
        _showsMoreOptions = State(initialValue: focus?.isInMoreOptions ?? false)
        self.isNew = isNew
        initialFocus = focus
        self.onSave = onSave
    }

    var body: some View {
        Form {
            Section {
                TextField("Naam", text: $draft.name)
                    .focused($focus, equals: .name)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
            }

            Section {
                Picker("Soort", selection: $draft.kind) {
                    Text("Proefperiode").tag(Kind.trial)
                    Text("Abonnement").tag(Kind.subscription)
                }
                .pickerStyle(.segmented)
                .listRowSeparator(.hidden)

                if draft.kind == .trial {
                    trialFields
                } else {
                    subscriptionFields
                }

                Text(liveLine)
                    .font(.footnote)
                    .foregroundStyle(liveLineIsWarning ? Color.orange : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Section {
                HStack(spacing: 6) {
                    Text("€")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                    TextField("Prijs (optioneel)", text: $draft.priceText)
                        .keyboardType(.decimalPad)
                        .focused($focus, equals: .price)
                        .accessibilityLabel("Prijs in euro, optioneel")
                    Text(priceLabel)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                DisclosureGroup("Meer opties", isExpanded: $showsMoreOptions) {
                    moreOptions
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                onSave(draft)
            } label: {
                Text("Bewaar")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.bar)
        }
        .navigationTitle(isNew ? "Toevoegen" : "Bewerken")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            guard let initialFocus else { return }
            try? await Task.sleep(nanoseconds: 350_000_000)
            focus = initialFocus
        }
    }

    // MARK: - Trial

    @ViewBuilder
    private var trialFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Eindigt over")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            FlowLayout(spacing: 8) {
                ForEach(ItemDraft.trialChips, id: \.self) { days in
                    Button("\(days) dagen") {
                        draft.selectTrialDays(days, today: model.today)
                    }
                    .buttonStyle(ChipStyle(isSelected: draft.trialLength == .days(days)))
                    .accessibilityAddTraits(draft.trialLength == .days(days) ? .isSelected : [])
                }
                Button("Datum…") {
                    draft.trialLength = .date
                }
                .buttonStyle(ChipStyle(isSelected: draft.trialLength == .date))
                .accessibilityAddTraits(draft.trialLength == .date ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)

        if draft.trialLength == .date {
            DatePicker("Einddatum", selection: dayBinding(\.trialEnd), displayedComponents: .date)
        }
    }

    // MARK: - Subscription

    @ViewBuilder
    private var subscriptionFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Verlengt elke")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Picker("Verlengt elke", selection: intervalChoice) {
                Text("Maand").tag(IntervalChoice.month)
                Text("Jaar").tag(IntervalChoice.year)
                Text("Anders").tag(IntervalChoice.other)
            }
            .pickerStyle(.segmented)
        }
        .padding(.vertical, 4)

        if intervalChoice.wrappedValue == .other {
            Picker("Interval", selection: otherInterval) {
                Text("Week").tag(BillingInterval.week)
                Text("Kwartaal").tag(BillingInterval.quarter)
                Text("Vaste einddatum").tag(BillingInterval.fixedEnd)
            }
        }

        DatePicker(
            draft.interval == .fixedEnd ? "Loopt tot" : "Volgende verlenging",
            selection: dayBinding(\.renewalDate),
            displayedComponents: .date
        )
    }

    private var intervalChoice: Binding<IntervalChoice> {
        Binding {
            switch draft.interval {
            case .month: .month
            case .year: .year
            case .week, .quarter, .fixedEnd: .other
            }
        } set: { choice in
            switch choice {
            case .month: draft.selectInterval(.month, today: model.today)
            case .year: draft.selectInterval(.year, today: model.today)
            case .other:
                if draft.interval == .month || draft.interval == .year {
                    draft.selectInterval(.quarter, today: model.today)
                }
            }
        }
    }

    private var otherInterval: Binding<BillingInterval> {
        Binding {
            draft.interval
        } set: { interval in
            draft.selectInterval(interval, today: model.today)
        }
    }

    // MARK: - More options

    @ViewBuilder
    private var moreOptions: some View {
        DatePicker("Startdatum", selection: dayBinding(\.startDate), displayedComponents: .date)
            .focused($focus, equals: .startDate)

        HStack {
            Text("Opzegtermijn")
            Spacer()
            TextField("0", value: $draft.noticeValue, format: .number)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: 60)
                .focused($focus, equals: .notice)
                .accessibilityLabel("Opzegtermijn")
            Picker("Eenheid", selection: $draft.noticeUnit) {
                Text("dagen").tag(NoticeUnit.days)
                Text("maanden").tag(NoticeUnit.months)
            }
            .labelsHidden()
        }

        Stepper(value: leadDays, in: 0...90) {
            LabeledContent("Seintje vooraf", value: DutchFormat.days(leadDays.wrappedValue))
        }
        .focused($focus, equals: .lead)

        if draft.showsRenewalToggle {
            Toggle("Seintje bij verlenging", isOn: renewalReminders)
        }

        TextField("Opzeglink", text: $draft.cancelURL)
            .keyboardType(.URL)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($focus, equals: .cancelURL)

        TextField("Notitie", text: $draft.note, axis: .vertical)
            .lineLimit(1...6)
            .focused($focus, equals: .note)
    }

    private var leadDays: Binding<Int> {
        Binding {
            draft.leadDaysOverride ?? draft.defaultFirstLead(
                settings: model.settings.reminderSettings, today: model.today, now: model.now, calendar: model.calendar
            )
        } set: { value in
            let fallback = draft.defaultFirstLead(
                settings: model.settings.reminderSettings, today: model.today, now: model.now, calendar: model.calendar
            )
            draft.leadDaysOverride = value == fallback ? nil : value
        }
    }

    private var renewalReminders: Binding<Bool> {
        Binding {
            draft.remindersEnabledOverride ?? false
        } set: { isOn in
            draft.remindersEnabledOverride = isOn ? true : nil
        }
    }

    // MARK: - Helpers

    private func dayBinding(_ keyPath: WritableKeyPath<ItemDraft, CalendarDay>) -> Binding<Date> {
        let calendar = model.calendar
        return Binding {
            draft[keyPath: keyPath].date(hour: 12, minute: 0, calendar: calendar) ?? Date()
        } set: { date in
            draft[keyPath: keyPath] = CalendarDay(date, calendar: calendar)
        }
    }

    private var liveLine: String {
        draft.liveLine(settings: model.settings.reminderSettings, today: model.today, now: model.now, calendar: model.calendar)
    }

    private var liveLineIsWarning: Bool {
        if draft.isInPast(today: model.today) { return true }
        let item = draft.build(today: model.today, now: model.now, calendar: model.calendar)
        return DecisionRules.decision(for: item, today: model.today, now: model.now, calendar: model.calendar)?.isTooLateThisRound ?? false
    }

    private var priceLabel: String {
        DutchFormat.perInterval(draft.interval)
    }
}
