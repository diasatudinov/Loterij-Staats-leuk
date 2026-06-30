//
//  LoterijStaatsLeukApp.swift
//  Loterij Staats leuk
//
//  Created by Dias Atudinov on 30.06.2026.
//


import SwiftUI

// MARK: - App

@main
struct LoterijStaatsLeukApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

// MARK: - Models

enum MainTab: String, CaseIterable {
    case lobby = "Lobby"
    case groups = "Groups"
    case stats = "Stats"
    case archive = "Archive"

    var icon: String {
        switch self {
        case .lobby: return "house.fill"
        case .groups: return "person.3.fill"
        case .stats: return "chart.pie.fill"
        case .archive: return "archivebox.fill"
        }
    }
}

enum LotteryTheme: String, Codable, CaseIterable, Identifiable {
    case christmas
    case birthday
    case picnic
    case office
    case cyberpunk
    case classicCasino

    var id: String { rawValue }

    var title: String {
        switch self {
        case .christmas: return "Christmas"
        case .birthday: return "Birthday"
        case .picnic: return "Picnic"
        case .office: return "Office Party"
        case .cyberpunk: return "Cyberpunk"
        case .classicCasino: return "Classic Casino"
        }
    }

    var emoji: String {
        switch self {
        case .christmas: return "🎄"
        case .birthday: return "🎂"
        case .picnic: return "🍔"
        case .office: return "💼"
        case .cyberpunk: return "🌃"
        case .classicCasino: return "🎰"
        }
    }

    var background: LinearGradient {
        switch self {
        case .christmas:
            return LinearGradient(colors: [.red.opacity(0.85), .green.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .birthday:
            return LinearGradient(colors: [.pink.opacity(0.85), .purple.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .picnic:
            return LinearGradient(colors: [.green.opacity(0.75), .yellow.opacity(0.65)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .office:
            return LinearGradient(colors: [.blue.opacity(0.75), .gray.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .cyberpunk:
            return LinearGradient(colors: [.purple.opacity(0.9), .blue.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .classicCasino:
            return LinearGradient(colors: [.red.opacity(0.8), .black.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

enum DistributionMode: String, Codable, CaseIterable, Identifiable {
    case oneWinner
    case everyonePrize
    case russianRoulette

    var id: String { rawValue }

    var title: String {
        switch self {
        case .oneWinner: return "One Prize — One Winner"
        case .everyonePrize: return "Everyone Gets a Prize"
        case .russianRoulette: return "Russian Roulette"
        }
    }

    var subtitle: String {
        switch self {
        case .oneWinner: return "Classic random draw."
        case .everyonePrize: return "Draw one by one until everyone gets something."
        case .russianRoulette: return "Some prizes can be funny penalties or blanks."
        }
    }
}

enum DrawMechanic: String, Codable, CaseIterable, Identifiable {
    case wheel
    case drum

    var id: String { rawValue }

    var title: String {
        switch self {
        case .wheel: return "Wheel of Fortune"
        case .drum: return "Lottery Drum"
        }
    }

    var icon: String {
        switch self {
        case .wheel: return "🎡"
        case .drum: return "🎲"
        }
    }
}

enum PrizeType: String, Codable, CaseIterable, Identifiable {
    case gift
    case task
    case penalty

    var id: String { rawValue }

    var title: String {
        switch self {
        case .gift: return "Gift"
        case .task: return "Task"
        case .penalty: return "Penalty"
        }
    }

    var emoji: String {
        switch self {
        case .gift: return "🎁"
        case .task: return "📋"
        case .penalty: return "💀"
        }
    }

    var color: Color {
        switch self {
        case .gift: return .green
        case .task: return .blue
        case .penalty: return .red
        }
    }
}

struct Participant: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var emoji: String

    var displayName: String {
        "\(emoji) \(name)"
    }
}

struct LotteryPrize: Identifiable, Codable, Hashable {
    var id = UUID()
    var emoji: String
    var title: String
    var type: PrizeType

    var displayTitle: String {
        "\(emoji) \(title)"
    }
}

struct ParticipantGroup: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var emoji: String
    var members: [Participant]

    var displayTitle: String {
        "\(emoji) \(name)"
    }
}

struct LotteryDraft: Codable {
    var title: String
    var theme: LotteryTheme
    var mode: DistributionMode
    var mechanic: DrawMechanic
    var showPrizePool: Bool
    var participants: [Participant]
    var prizes: [LotteryPrize]

    static var empty: LotteryDraft {
        LotteryDraft(
            title: "",
            theme: .classicCasino,
            mode: .oneWinner,
            mechanic: .wheel,
            showPrizePool: true,
            participants: [],
            prizes: []
        )
    }
}

struct LotteryTemplate: Identifiable, Hashable {
    let id: String
    let emoji: String
    let title: String
    let subtitle: String
    let theme: LotteryTheme
    let mode: DistributionMode
    let mechanic: DrawMechanic
    let prizes: [LotteryPrize]

    func makeDraft() -> LotteryDraft {
        LotteryDraft(
            title: title,
            theme: theme,
            mode: mode,
            mechanic: mechanic,
            showPrizePool: true,
            participants: [],
            prizes: prizes
        )
    }
}

struct DrawResult: Identifiable, Codable, Hashable {
    var id = UUID()
    var date = Date()
    var lotteryTitle: String
    var participant: Participant
    var prize: LotteryPrize
    var mode: DistributionMode

    var title: String {
        "\(participant.displayName) wins \(prize.displayTitle)"
    }
}

// MARK: - Store

final class LotteryStore: ObservableObject {
    @Published var groups: [ParticipantGroup] = [] {
        didSet { saveGroups() }
    }

    @Published var archive: [DrawResult] = [] {
        didSet { saveArchive() }
    }

    @Published var draft: LotteryDraft = .empty

    private let groupsKey = "loterij.groups.key"
    private let archiveKey = "loterij.archive.key"

    init() {
        loadGroups()
        loadArchive()

        if groups.isEmpty {
            groups = Self.defaultGroups
        }
    }

    static let defaultGroups: [ParticipantGroup] = [
        ParticipantGroup(
            name: "Family",
            emoji: "👨‍👩‍👧‍👦",
            members: [
                Participant(name: "Dad", emoji: "👨"),
                Participant(name: "Mom", emoji: "👩"),
                Participant(name: "Son", emoji: "🧒")
            ]
        ),
        ParticipantGroup(
            name: "Friday Friends",
            emoji: "🍻",
            members: [
                Participant(name: "Alex", emoji: "🧢"),
                Participant(name: "Kate", emoji: "🌸"),
                Participant(name: "Max", emoji: "🎧")
            ]
        ),
        ParticipantGroup(
            name: "Marketing Team",
            emoji: "💼",
            members: [
                Participant(name: "Emma", emoji: "📱"),
                Participant(name: "Liam", emoji: "💻"),
                Participant(name: "Olivia", emoji: "📊")
            ]
        )
    ]

    static let templates: [LotteryTemplate] = [
        LotteryTemplate(
            id: "bill",
            emoji: "💸",
            title: "Who Pays the Bill?",
            subtitle: "A fast draw for restaurants and parties.",
            theme: .classicCasino,
            mode: .oneWinner,
            mechanic: .wheel,
            prizes: [
                LotteryPrize(emoji: "💸", title: "You pay the bill", type: .penalty),
                LotteryPrize(emoji: "🤑", title: "You pay, but tips are not included", type: .task),
                LotteryPrize(emoji: "👑", title: "Today you are royalty, others pay", type: .gift)
            ]
        ),
        LotteryTemplate(
            id: "movie",
            emoji: "🍿",
            title: "Movie Night",
            subtitle: "Decide who chooses the movie.",
            theme: .birthday,
            mode: .oneWinner,
            mechanic: .wheel,
            prizes: [
                LotteryPrize(emoji: "🎬", title: "Choose the movie", type: .gift),
                LotteryPrize(emoji: "🍿", title: "Choose the movie, others may comment", type: .task),
                LotteryPrize(emoji: "😴", title: "Sleep while everyone watches", type: .penalty)
            ]
        ),
        LotteryTemplate(
            id: "cleaning",
            emoji: "🧹",
            title: "General Cleaning",
            subtitle: "Funny roulette for house chores.",
            theme: .picnic,
            mode: .russianRoulette,
            mechanic: .drum,
            prizes: [
                LotteryPrize(emoji: "🛁", title: "Clean the bathroom", type: .penalty),
                LotteryPrize(emoji: "🧹", title: "Vacuum the room", type: .task),
                LotteryPrize(emoji: "🗑", title: "Take out the trash", type: .task),
                LotteryPrize(emoji: "🎉", title: "Jackpot: cleaning canceled", type: .gift)
            ]
        ),
        LotteryTemplate(
            id: "secretSanta",
            emoji: "🎅",
            title: "Secret Santa Express",
            subtitle: "Everyone draws one gift.",
            theme: .christmas,
            mode: .everyonePrize,
            mechanic: .drum,
            prizes: [
                LotteryPrize(emoji: "🎁", title: "Buy a small gift", type: .gift),
                LotteryPrize(emoji: "☕️", title: "Coffee certificate", type: .gift),
                LotteryPrize(emoji: "🍫", title: "Chocolate box", type: .gift),
                LotteryPrize(emoji: "🎧", title: "Small gadget gift", type: .gift)
            ]
        )
    ]

    static let prizeIdeas: [LotteryPrize] = [
        LotteryPrize(emoji: "🍽", title: "No dishwashing for one day", type: .gift),
        LotteryPrize(emoji: "🍿", title: "Choose a movie with no veto", type: .gift),
        LotteryPrize(emoji: "💆", title: "10-minute shoulder massage certificate", type: .gift),
        LotteryPrize(emoji: "🕺", title: "Start the music and dance first", type: .task),
        LotteryPrize(emoji: "🤐", title: "One stop-word right", type: .gift),
        LotteryPrize(emoji: "🍕", title: "Order pizza paid by losers", type: .gift),
        LotteryPrize(emoji: "🛋", title: "Best sofa spot is yours", type: .gift),
        LotteryPrize(emoji: "🧹", title: "Penalty: make a toast on one leg", type: .penalty)
    ]

    func startNewLottery() {
        draft = .empty
    }

    func startTemplate(_ template: LotteryTemplate) {
        draft = template.makeDraft()
    }

    func addParticipant(name: String, emoji: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        draft.participants.append(
            Participant(
                name: trimmedName,
                emoji: emoji.isEmpty ? "🙂" : emoji
            )
        )
    }

    func removeParticipant(_ participant: Participant) {
        draft.participants.removeAll { $0.id == participant.id }
    }

    func addGroupMembers(_ group: ParticipantGroup) {
        for member in group.members {
            if !draft.participants.contains(where: { $0.name.lowercased() == member.name.lowercased() }) {
                draft.participants.append(member)
            }
        }
    }

    func addPrize(title: String, emoji: String, type: PrizeType) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        draft.prizes.append(
            LotteryPrize(
                emoji: emoji.isEmpty ? type.emoji : emoji,
                title: trimmedTitle,
                type: type
            )
        )
    }

    func removePrize(_ prize: LotteryPrize) {
        draft.prizes.removeAll { $0.id == prize.id }
    }

    func randomPrizeIdea() -> LotteryPrize {
        Self.prizeIdeas.randomElement() ?? LotteryPrize(emoji: "🎁", title: "Mystery prize", type: .gift)
    }

    func createResult(
        from draft: LotteryDraft,
        usedPrizeIds: Set<UUID>,
        usedParticipantIds: Set<UUID>
    ) -> DrawResult? {
        let participantPool: [Participant]

        if draft.mode == .everyonePrize {
            participantPool = draft.participants.filter { !usedParticipantIds.contains($0.id) }
        } else {
            participantPool = draft.participants
        }

        guard let participant = participantPool.randomElement() else {
            return nil
        }

        let prizePool: [LotteryPrize]

        switch draft.mode {
        case .oneWinner:
            prizePool = draft.prizes

        case .everyonePrize:
            prizePool = draft.prizes.filter { !usedPrizeIds.contains($0.id) }

        case .russianRoulette:
            let blanks = [
                LotteryPrize(emoji: "😶", title: "Blank turn", type: .task),
                LotteryPrize(emoji: "💀", title: "Funny penalty", type: .penalty)
            ]
            prizePool = draft.prizes + blanks
        }

        guard let prize = prizePool.randomElement() else {
            return nil
        }

        return DrawResult(
            lotteryTitle: draft.title.isEmpty ? "Untitled Lottery" : draft.title,
            participant: participant,
            prize: prize,
            mode: draft.mode
        )
    }

    func saveResult(_ result: DrawResult) {
        archive.insert(result, at: 0)
    }

    func upsertGroup(_ group: ParticipantGroup) {
        if let index = groups.firstIndex(where: { $0.id == group.id }) {
            groups[index] = group
        } else {
            groups.insert(group, at: 0)
        }
    }

    func deleteGroup(at offsets: IndexSet) {
        groups.remove(atOffsets: offsets)
    }

    func topLucky() -> (String, Int)? {
        let grouped = Dictionary(grouping: archive) { $0.participant.displayName }
        return grouped
            .map { ($0.key, $0.value.count) }
            .max { $0.1 < $1.1 }
    }

    func penaltyMagnet() -> (String, Int)? {
        let penalties = archive.filter { $0.prize.type == .penalty }
        let grouped = Dictionary(grouping: penalties) { $0.participant.displayName }
        return grouped
            .map { ($0.key, $0.value.count) }
            .max { $0.1 < $1.1 }
    }

    func favoritePrize() -> (String, Int)? {
        let grouped = Dictionary(grouping: archive) { $0.prize.displayTitle }
        return grouped
            .map { ($0.key, $0.value.count) }
            .max { $0.1 < $1.1 }
    }

    func prizeTypeCounts() -> [(PrizeType, Int)] {
        PrizeType.allCases.map { type in
            (type, archive.filter { $0.prize.type == type }.count)
        }
    }

    private func saveGroups() {
        if let data = try? JSONEncoder().encode(groups) {
            UserDefaults.standard.set(data, forKey: groupsKey)
        }
    }

    private func saveArchive() {
        if let data = try? JSONEncoder().encode(archive) {
            UserDefaults.standard.set(data, forKey: archiveKey)
        }
    }

    private func loadGroups() {
        guard let data = UserDefaults.standard.data(forKey: groupsKey),
              let decoded = try? JSONDecoder().decode([ParticipantGroup].self, from: data) else {
            return
        }

        groups = decoded
    }

    private func loadArchive() {
        guard let data = UserDefaults.standard.data(forKey: archiveKey),
              let decoded = try? JSONDecoder().decode([DrawResult].self, from: data) else {
            return
        }

        archive = decoded
    }
}

// MARK: - Root

struct RootView: View {
    @StateObject private var store = LotteryStore()
    @State private var selectedTab: MainTab = .lobby

    var body: some View {
        ZStack(alignment: .bottom) {
            currentScreen
                .padding(.bottom, 82)

            CustomTabBar(selectedTab: $selectedTab)
        }
        .environmentObject(store)
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch selectedTab {
        case .lobby:
            LobbyView()
        case .groups:
            GroupsView()
        case .stats:
            StatsView()
        case .archive:
            ArchiveView()
        }
    }
}

// MARK: - Lobby

struct LobbyView: View {
    @EnvironmentObject private var store: LotteryStore
    @State private var showWizard = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Loterij")
                                .font(.largeTitle.bold())

                            Text("Resolve disputes. Test your friends' luck.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)

                        LuckWidgetView()

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Start")
                                .font(.title2.bold())
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 14) {
                                    ForEach(LotteryStore.templates) { template in
                                        Button {
                                            store.startTemplate(template)
                                            showWizard = true
                                        } label: {
                                            TemplateCardView(template: template)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        Button {
                            store.startNewLottery()
                            showWizard = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)

                                Text("Create Your Own Lottery")
                                    .font(.headline)

                                Spacer()

                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(.white.opacity(0.96))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .shadow(radius: 8, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
            }
            .navigationDestination(isPresented: $showWizard) {
                WizardStepOneView()
            }
        }
    }
}

struct LuckWidgetView: View {
    @EnvironmentObject private var store: LotteryStore

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Luck Indicator")
                    .font(.headline)

                if let topLucky = store.topLucky() {
                    Text("👑 Luck king of the week: \(topLucky.0) — \(topLucky.1) wins")
                        .font(.subheadline)
                } else {
                    Text("No draws yet. Start your first show!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let penalty = store.penaltyMagnet() {
                    Text("🧲 Penalty magnet: \(penalty.0) — \(penalty.1) times")
                        .font(.subheadline)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct TemplateCardView: View {
    let template: LotteryTemplate

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(template.emoji)
                .font(.system(size: 42))

            Text(template.title)
                .font(.headline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)

            Text(template.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)

            Spacer()

            Text(template.mode.title)
                .font(.caption.bold())
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.black.opacity(0.08))
                .clipShape(Capsule())
        }
        .frame(width: 210, height: 190)
        .padding()
        .background(.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 8, y: 4)
    }
}

// MARK: - Wizard Step 1

struct WizardStepOneView: View {
    @EnvironmentObject private var store: LotteryStore

    var body: some View {
        ZStack {
            store.draft.theme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Step 1")
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.8))

                    Text("Rules & Atmosphere")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    AppCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Lottery Title")
                                .font(.headline)

                            TextField("Example: Remote Control Battle", text: $store.draft.title)
                                .textFieldStyle(.roundedBorder)
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Theme")
                                .font(.headline)

                            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 10) {
                                ForEach(LotteryTheme.allCases) { theme in
                                    SelectableTile(
                                        title: "\(theme.emoji) \(theme.title)",
                                        isSelected: store.draft.theme == theme
                                    ) {
                                        store.draft.theme = theme
                                    }
                                }
                            }
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Distribution Mode")
                                .font(.headline)

                            ForEach(DistributionMode.allCases) { mode in
                                SelectableRow(
                                    title: mode.title,
                                    subtitle: mode.subtitle,
                                    isSelected: store.draft.mode == mode
                                ) {
                                    store.draft.mode = mode
                                }
                            }
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Draw Mechanic")
                                .font(.headline)

                            HStack(spacing: 12) {
                                ForEach(DrawMechanic.allCases) { mechanic in
                                    SelectableTile(
                                        title: "\(mechanic.icon) \(mechanic.title)",
                                        isSelected: store.draft.mechanic == mechanic
                                    ) {
                                        store.draft.mechanic = mechanic
                                    }
                                }
                            }
                        }
                    }

                    AppCard {
                        Toggle("Show prize pool before spinning", isOn: $store.draft.showPrizePool)
                    }

                    NavigationLink {
                        WizardStepTwoView()
                    } label: {
                        PrimaryButtonLabel(title: "Next: Participants & Prizes", icon: "arrow.right.circle.fill")
                    }
                    .disabled(store.draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(store.draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Wizard Step 2

struct WizardStepTwoView: View {
    @EnvironmentObject private var store: LotteryStore

    @State private var participantName = ""
    @State private var participantEmoji = "🙂"

    @State private var prizeTitle = ""
    @State private var prizeEmoji = "🎁"
    @State private var prizeType: PrizeType = .gift

    @State private var showDraw = false

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Step 2")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)

                    Text("Participants & Prize Pool")
                        .font(.largeTitle.bold())

                    participantsBlock

                    prizesBlock

                    Button {
                        showDraw = true
                    } label: {
                        PrimaryButtonLabel(title: "Start the Show", icon: "play.circle.fill")
                    }
                    .disabled(store.draft.participants.isEmpty || store.draft.prizes.isEmpty)
                    .opacity(store.draft.participants.isEmpty || store.draft.prizes.isEmpty ? 0.5 : 1)
                }
                .padding()
            }
        }
        .navigationDestination(isPresented: $showDraw) {
            DrawShowView(draft: store.draft)
        }
    }

    private var participantsBlock: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Participants")
                    .font(.headline)

                HStack {
                    TextField("Emoji", text: $participantEmoji)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 74)

                    TextField("Name", text: $participantName)
                        .textFieldStyle(.roundedBorder)

                    Button {
                        store.addParticipant(name: participantName, emoji: participantEmoji)
                        participantName = ""
                        participantEmoji = "🙂"
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }

                if !store.groups.isEmpty {
                    Text("Quick Groups")
                        .font(.subheadline.bold())

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(store.groups) { group in
                                Button {
                                    store.addGroupMembers(group)
                                } label: {
                                    Text(group.displayTitle)
                                        .font(.caption.bold())
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(.black.opacity(0.08))
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }

                ForEach(store.draft.participants) { participant in
                    HStack {
                        Text(participant.displayName)
                        Spacer()
                        Button {
                            store.removeParticipant(participant)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var prizesBlock: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Prize Pool")
                    .font(.headline)

                HStack {
                    TextField("Emoji", text: $prizeEmoji)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 74)

                    TextField("Prize title", text: $prizeTitle)
                        .textFieldStyle(.roundedBorder)
                }

                Picker("Prize Type", selection: $prizeType) {
                    ForEach(PrizeType.allCases) { type in
                        Text("\(type.emoji) \(type.title)")
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Button {
                        let idea = store.randomPrizeIdea()
                        prizeEmoji = idea.emoji
                        prizeTitle = idea.title
                        prizeType = idea.type
                    } label: {
                        Text("🎲 Suggest Idea")
                            .font(.subheadline.bold())
                    }

                    Spacer()

                    Button {
                        store.addPrize(title: prizeTitle, emoji: prizeEmoji, type: prizeType)
                        prizeTitle = ""
                        prizeEmoji = prizeType.emoji
                    } label: {
                        Text("Add Prize")
                            .font(.subheadline.bold())
                    }
                }

                ForEach(store.draft.prizes) { prize in
                    HStack {
                        Text(prize.displayTitle)

                        Spacer()

                        Text(prize.type.title)
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(prize.type.color.opacity(0.15))
                            .clipShape(Capsule())

                        Button {
                            store.removePrize(prize)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
}

// MARK: - Draw Show

struct DrawShowView: View {
    @EnvironmentObject private var store: LotteryStore
    @Environment(\.dismiss) private var dismiss

    let draft: LotteryDraft

    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var result: DrawResult?

    @State private var usedPrizeIds: Set<UUID> = []
    @State private var usedParticipantIds: Set<UUID> = []

    var body: some View {
        ZStack {
            draft.theme.background
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text(draft.title.isEmpty ? "Lottery Show" : draft.title)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Spacer()

                if draft.mechanic == .wheel {
                    WheelView(prizes: draft.prizes, rotation: rotation)
                        .frame(width: 310, height: 310)
                } else {
                    DrumView(participants: draft.participants, rotation: rotation)
                        .frame(width: 310, height: 310)
                }

                if draft.showPrizePool {
                    prizePoolPreview
                } else {
                    Text("Prize pool is hidden until reveal 🤫")
                        .font(.subheadline.bold())
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                Button {
                    spin()
                } label: {
                    Text(isSpinning ? "SPINNING..." : "🎲 SPIN!")
                        .font(.title2.bold())
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .disabled(isSpinning)
                .padding(.horizontal)
            }
            .padding(.vertical)

            if let result {
                ResultRevealView(
                    result: result,
                    canDrawNext: canDrawNext,
                    onRepeat: {
                        self.result = nil
                    },
                    onFinish: {
                        store.saveResult(result)
                        dismiss()
                    },
                    onNext: {
                        usedParticipantIds.insert(result.participant.id)
                        usedPrizeIds.insert(result.prize.id)
                        store.saveResult(result)
                        self.result = nil
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(isSpinning)
    }

    private var prizePoolPreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(draft.prizes) { prize in
                    Text(prize.displayTitle)
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.white.opacity(0.22))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
        }
    }

    private var canDrawNext: Bool {
        guard let result, draft.mode == .everyonePrize else {
            return false
        }

        let nextUsedParticipants = usedParticipantIds.union([result.participant.id])
        let nextUsedPrizes = usedPrizeIds.union([result.prize.id])

        let hasParticipants = draft.participants.contains { !nextUsedParticipants.contains($0.id) }
        let hasPrizes = draft.prizes.contains { !nextUsedPrizes.contains($0.id) }

        return hasParticipants && hasPrizes
    }

    private func spin() {
        result = nil
        isSpinning = true

        withAnimation(.easeOut(duration: 2.4)) {
            rotation += Double.random(in: 900...1600)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            isSpinning = false
            result = store.createResult(
                from: draft,
                usedPrizeIds: usedPrizeIds,
                usedParticipantIds: usedParticipantIds
            )
        }
    }
}

struct ResultRevealView: View {
    let result: DrawResult
    let canDrawNext: Bool
    let onRepeat: () -> Void
    let onFinish: () -> Void
    let onNext: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("🏆")
                    .font(.system(size: 78))

                Text(result.participant.displayName)
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)

                Text("wins")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))

                Text(result.prize.displayTitle)
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    Button(action: onRepeat) {
                        PrimaryButtonLabel(title: "Repeat Draw", icon: "arrow.clockwise")
                    }

                    if canDrawNext {
                        Button(action: onNext) {
                            PrimaryButtonLabel(title: "Draw Next Prize", icon: "plus.circle.fill")
                        }
                    }

                    Button(action: onFinish) {
                        PrimaryButtonLabel(title: "Save & Finish", icon: "checkmark.circle.fill")
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Groups

struct GroupsView: View {
    @EnvironmentObject private var store: LotteryStore
    @State private var editingGroup: ParticipantGroup?

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                List {
                    ForEach(store.groups) { group in
                        Button {
                            editingGroup = group
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(group.displayTitle)
                                    .font(.headline)

                                Text(group.members.map(\.displayName).joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = store.groups.firstIndex(where: { $0.id == group.id }) {
                                    store.deleteGroup(at: IndexSet(integer: index))
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Participant Groups")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingGroup = ParticipantGroup(name: "", emoji: "👥", members: [])
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $editingGroup) { group in
                GroupEditorView(group: group) { updated in
                    store.upsertGroup(updated)
                }
            }
        }
    }
}

struct GroupEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var group: ParticipantGroup
    @State private var memberName = ""
    @State private var memberEmoji = "🙂"

    let onSave: (ParticipantGroup) -> Void

    init(group: ParticipantGroup, onSave: @escaping (ParticipantGroup) -> Void) {
        _group = State(initialValue: group)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Group Info") {
                    TextField("Group name", text: $group.name)
                    TextField("Emoji", text: $group.emoji)
                }

                Section("Members") {
                    HStack {
                        TextField("Emoji", text: $memberEmoji)
                            .frame(width: 70)

                        TextField("Name", text: $memberName)

                        Button {
                            addMember()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }

                    ForEach(group.members) { member in
                        HStack {
                            Text(member.displayName)
                            Spacer()
                            Button {
                                group.members.removeAll { $0.id == member.id }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle(group.name.isEmpty ? "New Group" : group.name)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(group)
                        dismiss()
                    }
                    .disabled(group.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func addMember() {
        let trimmedName = memberName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        group.members.append(
            Participant(
                name: trimmedName,
                emoji: memberEmoji.isEmpty ? "🙂" : memberEmoji
            )
        )

        memberName = ""
        memberEmoji = "🙂"
    }
}

// MARK: - Stats

struct StatsView: View {
    @EnvironmentObject private var store: LotteryStore

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        AppCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Hall of Fame")
                                    .font(.title2.bold())

                                StatRow(title: "Main Lucky One", value: store.topLuckyText, icon: "👑")
                                StatRow(title: "Penalty Magnet", value: store.penaltyMagnetText, icon: "🧲")
                                StatRow(title: "Favorite Prize", value: store.favoritePrizeText, icon: "🎁")
                            }
                        }

                        AppCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Prize Types")
                                    .font(.title2.bold())

                                DonutChartView(data: store.prizeTypeCounts())
                                    .frame(height: 230)

                                ForEach(store.prizeTypeCounts(), id: \.0.id) { item in
                                    HStack {
                                        Text("\(item.0.emoji) \(item.0.title)")
                                        Spacer()
                                        Text("\(item.1)")
                                            .font(.headline)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Stats")
        }
    }
}

extension LotteryStore {
    var topLuckyText: String {
        guard let value = topLucky() else { return "No data yet" }
        return "\(value.0), \(value.1) wins"
    }

    var penaltyMagnetText: String {
        guard let value = penaltyMagnet() else { return "No penalties yet" }
        return "\(value.0), \(value.1) times"
    }

    var favoritePrizeText: String {
        guard let value = favoritePrize() else { return "No prizes yet" }
        return "\(value.0), \(value.1) times"
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title2)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.headline)
            }

            Spacer()
        }
    }
}

// MARK: - Archive

struct ArchiveView: View {
    @EnvironmentObject private var store: LotteryStore

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                if store.archive.isEmpty {
                    VStack(spacing: 12) {
                        Text("📦")
                            .font(.system(size: 70))

                        Text("Archive is empty")
                            .font(.title2.bold())

                        Text("Finished draws will appear here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    List {
                        ForEach(store.archive) { result in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(result.lotteryTitle)
                                    .font(.headline)

                                Text(result.title)
                                    .font(.subheadline)

                                Text(result.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Archive")
        }
    }
}

// MARK: - Components

struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(.systemGray6),
                Color(.systemGray5)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

struct AppCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.96))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(radius: 8, y: 4)
    }
}

struct PrimaryButtonLabel: View {
    let title: String
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
                .font(.headline)
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct SelectableTile: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding()
                .background(isSelected ? .black : .black.opacity(0.08))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct SelectableRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isSelected ? .black : .gray)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
            .background(isSelected ? .black.opacity(0.08) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack {
            ForEach(MainTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 5) {
                        Image(systemName: tab.icon)
                            .font(.headline)

                        Text(tab.rawValue)
                            .font(.caption2.bold())
                    }
                    .foregroundColor(selectedTab == tab ? .black : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selectedTab == tab
                        ? Color.black.opacity(0.08)
                        : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .shadow(radius: 12, y: 5)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// MARK: - Wheel

struct WheelView: View {
    let prizes: [LotteryPrize]
    let rotation: Double

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let count = max(prizes.count, 1)

            ZStack {
                ForEach(prizes.indices, id: \.self) { index in
                    let start = Angle.degrees(Double(index) * 360 / Double(count) - 90)
                    let end = Angle.degrees(Double(index + 1) * 360 / Double(count) - 90)

                    PieSliceShape(startAngle: start, endAngle: end)
                        .fill(Color(hue: Double(index) / Double(count), saturation: 0.55, brightness: 0.95))
                }

                ForEach(prizes.indices, id: \.self) { index in
                    Text(prizes[index].emoji)
                        .font(.largeTitle)
                        .offset(y: -size * 0.31)
                        .rotationEffect(.degrees(Double(index) * 360 / Double(count)))
                }

                Circle()
                    .fill(.white)
                    .frame(width: 70, height: 70)
                    .overlay {
                        Text("🎲")
                            .font(.largeTitle)
                    }

                TrianglePointer()
                    .fill(.white)
                    .frame(width: 34, height: 42)
                    .offset(y: -size / 2 + 18)
            }
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .shadow(radius: 14)
        }
    }
}

struct PieSliceShape: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

struct TrianglePointer: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()

        return path
    }
}

// MARK: - Drum

struct DrumView: View {
    let participants: [Participant]
    let rotation: Double

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)

            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .overlay {
                        Circle()
                            .stroke(.white, lineWidth: 6)
                    }

                ForEach(Array(participants.enumerated()), id: \.element.id) { index, participant in
                    DrumBallView(
                        participant: participant,
                        index: index,
                        total: max(participants.count, 1),
                        radius: size * 0.31,
                        rotation: rotation
                    )
                }

                Text("🎲")
                    .font(.system(size: 58))
            }
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation * 0.2))
            .shadow(radius: 14)
        }
    }
}

struct DrumBallView: View {
    let participant: Participant
    let index: Int
    let total: Int
    let radius: CGFloat
    let rotation: Double

    var body: some View {
        let angle = (Double(index) * 360 / Double(total) + rotation).degreesToRadians

        Circle()
            .fill(.white)
            .frame(width: 58, height: 58)
            .overlay {
                Text(participant.emoji)
                    .font(.title2)
            }
            .offset(
                x: CGFloat(cos(angle)) * radius,
                y: CGFloat(sin(angle)) * radius
            )
    }
}

extension Double {
    var degreesToRadians: Double {
        self * .pi / 180
    }
}

// MARK: - Donut Chart

struct DonutChartView: View {
    let data: [(PrizeType, Int)]

    private var total: Int {
        data.map(\.1).reduce(0, +)
    }

    var body: some View {
        ZStack {
            if total == 0 {
                Circle()
                    .stroke(.gray.opacity(0.2), lineWidth: 28)

                Text("No data")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(data.indices, id: \.self) { index in
                    DonutArcShape(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index)
                    )
                    .stroke(
                        data[index].0.color,
                        style: StrokeStyle(lineWidth: 28, lineCap: .butt)
                    )
                }

                VStack {
                    Text("\(total)")
                        .font(.title.bold())
                    Text("Draws")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(34)
    }

    private func startAngle(for index: Int) -> Angle {
        let previous = data.prefix(index).map(\.1).reduce(0, +)
        return .degrees(-90 + Double(previous) / Double(max(total, 1)) * 360)
    }

    private func endAngle(for index: Int) -> Angle {
        let current = data.prefix(index + 1).map(\.1).reduce(0, +)
        return .degrees(-90 + Double(current) / Double(max(total, 1)) * 360)
    }
}

struct DonutArcShape: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)

        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        return path
    }
}