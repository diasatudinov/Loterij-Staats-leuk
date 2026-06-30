// MARK: - Models

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
