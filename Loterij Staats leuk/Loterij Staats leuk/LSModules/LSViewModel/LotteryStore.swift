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