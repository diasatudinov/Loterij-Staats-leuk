// MARK: - Lobby

struct LobbyView: View {
    @EnvironmentObject private var store: LotteryStore
    @Binding var selectedTab: MainTab

    @State private var showWizard = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppPalette.background.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        HomeHeaderView()

                        quickStartSection

                        Button {
                            store.startNewLottery()
                            showWizard = true
                        } label: {
                            OrangeButtonLabel(title: "Create Lottery", icon: "plus")
                        }
                        .padding(.horizontal, 20)

                        HomeShortcutGrid(selectedTab: $selectedTab)

                        recentSection

                        Spacer(minLength: 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showWizard) {
                WizardStepOneView()
            }
        }
    }

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderTitle("Quick Start")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(LotteryStore.templates) { template in
                        Button {
                            store.startTemplate(template)
                            showWizard = true
                        } label: {
                            QuickTemplateSmallCard(template: template)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderTitle("Recent")

            if store.archive.isEmpty {
                Text("Nothing here yet")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 55)
            } else {
                VStack(spacing: 10) {
                    ForEach(store.archive.prefix(3)) { result in
                        RecentLotteryCard(result: result)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

extension Date {
    var lobbyHeaderDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE, MMMM d"

        return formatter.string(from: self).uppercased()
    }
}

struct HomeHeaderView: View {
    @EnvironmentObject private var store: LotteryStore

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [AppPalette.blue, AppPalette.blueLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 180, height: 180)
                .offset(x: 210, y: -70)

            VStack(alignment: .leading, spacing: 14) {
                Text(Date().lobbyHeaderDate)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(1.4)
                    .foregroundColor(.white.opacity(0.75))

                Text("Good Evening 👋")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                if !store.archive.isEmpty {
                    HStack(spacing: 8) {
                        HeaderStatCard(
                            emoji: "👑",
                            title: store.topLucky()?.0.components(separatedBy: " ").last ?? "Emma",
                            subtitle: "Luckiest"
                        )

                        HeaderStatCard(
                            emoji: "🧲",
                            title: store.penaltyMagnet()?.0.components(separatedBy: " ").last ?? "Max",
                            subtitle: "Penalty Magnet"
                        )

                        HeaderStatCard(
                            emoji: "🎁",
                            title: store.favoritePrize()?.0.components(separatedBy: " ").first ?? "Pizza",
                            subtitle: "Top Prize"
                        )
                    }

                    Text("Ready to let luck decide?")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.75))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(height: store.archive.isEmpty ? 145 : 230)
        .clipShape(
            RoundedCorner(radius: 0, corners: [.bottomLeft, .bottomRight])
        )
    }
}

struct HeaderStatCard: View {
    let emoji: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 22))

            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.75))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 76)
        .background(Color.white.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct QuickTemplateSmallCard: View {
    let template: LotteryTemplate

    var body: some View {
        VStack(spacing: 8) {
            Text(template.emoji)
                .font(.system(size: 25))

            Text(template.title.shortTemplateTitle)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(AppPalette.textBlue)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 82, height: 82)
        .background(AppPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppPalette.stroke, lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

struct HomeShortcutGrid: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 12) {
            HomeShortcutCard(icon: "person.2.fill", title: "My Groups") {
                selectedTab = .groups
            }

            HomeShortcutCard(icon: "archivebox.fill", title: "Archive") {
                selectedTab = .archive
            }

            HomeShortcutCard(icon: "chart.bar.fill", title: "Statistics") {
                selectedTab = .stats
            }
        }
        .padding(.horizontal, 20)
    }
}

struct HomeShortcutCard: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AppPalette.textBlue)

                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.75))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(AppPalette.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppPalette.stroke, lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct RecentLotteryCard: View {
    let result: DrawResult

    var body: some View {
        HStack(spacing: 12) {
            Text(result.participant.emoji)
                .font(.system(size: 27))
                .frame(width: 38, height: 38)
                .background(AppPalette.orangeSoft.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(result.lotteryTitle)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppPalette.textBlue)

                Text("\(result.participant.name) won \(result.prize.displayTitle)")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            Text(result.date.formatted(.dateTime.month().day()))
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(AppPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppPalette.stroke, lineWidth: 1)
        }
    }
}

// MARK: - Wizard Step 1

struct WizardStepOneView: View {
    @EnvironmentObject private var store: LotteryStore

    var body: some View {
        ZStack {
            AppPalette.background.ignoresSafeArea()

            VStack(spacing: 0) {
                WizardTopBar(title: "New Lottery", step: "Step 1 / 2")

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        FormSectionTitle("Lottery Name")

                        TextField("", text: $store.draft.title)
                            .placeholder(when: store.draft.title.isEmpty) {
                                Text("Movie Night")
                                    .foregroundColor(.gray.opacity(0.65))
                            }
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .padding()
                            .background(AppPalette.card)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(AppPalette.stroke, lineWidth: 1)
                            }

                        FormSectionTitle("Theme")

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 9), count: 3), spacing: 9) {
                            ForEach(LotteryTheme.allCases) { theme in
                                ChoiceChip(
                                    title: "\(theme.emoji) \(theme.title)",
                                    isSelected: store.draft.theme == theme
                                ) {
                                    store.draft.theme = theme
                                }
                            }
                        }

                        FormSectionTitle("Draw Mode")

                        VStack(spacing: 10) {
                            ForEach(DistributionMode.allCases) { mode in
                                DrawModeCard(
                                    mode: mode,
                                    isSelected: store.draft.mode == mode
                                ) {
                                    store.draft.mode = mode
                                }
                            }
                        }

                        FormSectionTitle("Visualization")

                        HStack(spacing: 10) {
                            ForEach(DrawMechanic.allCases) { mechanic in
                                VisualizationCard(
                                    mechanic: mechanic,
                                    isSelected: store.draft.mechanic == mechanic
                                ) {
                                    store.draft.mechanic = mechanic
                                }
                            }
                        }

                        ToggleRow(
                            title: "Hide prizes before draw",
                            subtitle: "Surprise reveal",
                            isOn: Binding(
                                get: { !store.draft.showPrizePool },
                                set: { store.draft.showPrizePool = !$0 }
                            )
                        )

                        NavigationLink {
                            WizardStepTwoView()
                        } label: {
                            OrangeButtonLabel(title: "Continue", icon: "arrow.right")
                        }
                        .disabled(store.draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(store.draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)

                        Spacer(minLength: 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Wizard Step 2

struct WizardStepTwoView: View {
    @EnvironmentObject private var store: LotteryStore

    @State private var participantEmoji = "🙂"
    @State private var participantName = ""

    @State private var prizeEmoji = "🎁"
    @State private var prizeName = ""
    @State private var prizeType: PrizeType = .gift

    @State private var showParticipantEmojiPicker = false
    @State private var showPrizeEmojiPicker = false
    @State private var showDraw = false

    var body: some View {
        ZStack {
            AppPalette.background.ignoresSafeArea()

            VStack(spacing: 0) {
                WizardTopBar(
                    title: store.draft.title.isEmpty ? "New Lottery" : store.draft.title,
                    step: "Step 2 / 2"
                )

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        participantsBlock

                        prizePoolBlock

                        Button {
                            showDraw = true
                        } label: {
                            OrangeButtonLabel(title: "Start Lottery", icon: "dice")
                        }
                        .disabled(store.draft.participants.isEmpty || store.draft.prizes.isEmpty)
                        .opacity(store.draft.participants.isEmpty || store.draft.prizes.isEmpty ? 0.45 : 1)

                        Spacer(minLength: 14)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showDraw) {
            DrawShowView(draft: store.draft)
        }
    }

    private var participantsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            FormSectionTitle("Participants (\(store.draft.participants.count))")

            VStack(spacing: 8) {
                ForEach(store.draft.participants) { participant in
                    EditableMiniRow(
                        emoji: participant.emoji,
                        title: participant.name,
                        trailing: "×"
                    ) {
                        store.removeParticipant(participant)
                    }
                }

                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Button {
                            showParticipantEmojiPicker.toggle()
                        } label: {
                            Text(participantEmoji)
                                .font(.system(size: 18))
                                .frame(width: 42, height: 42)
                                .background(AppPalette.background)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        TextField("Participant name", text: $participantName)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .padding()
                            .frame(height: 42)
                            .background(AppPalette.background)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                        Button {
                            store.addParticipant(name: participantName, emoji: participantEmoji)
                            participantName = ""
                            participantEmoji = "🙂"
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 42, height: 42)
                                .background(AppPalette.orange)
                                .clipShape(Circle())
                        }
                    }

                    if showParticipantEmojiPicker {
                        EmojiGridView(selectedEmoji: $participantEmoji)
                    }
                }
            }
            .padding(10)
            .background(AppPalette.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppPalette.stroke, lineWidth: 1)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(store.groups) { group in
                        Button {
                            store.addGroupMembers(group)
                        } label: {
                            Text("\(group.emoji) \(group.name)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundColor(AppPalette.textBlue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(AppPalette.card)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }

    private var prizePoolBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            FormSectionTitle("Prize Pool (\(store.draft.prizes.count))")

            VStack(spacing: 10) {
                ForEach(store.draft.prizes) { prize in
                    EditableMiniRow(
                        emoji: prize.emoji,
                        title: prize.title,
                        tag: prize.type.shortTitle,
                        trailing: "×"
                    ) {
                        store.removePrize(prize)
                    }
                }

                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Button {
                            showPrizeEmojiPicker.toggle()
                        } label: {
                            Text(prizeEmoji)
                                .font(.system(size: 18))
                                .frame(width: 42, height: 42)
                                .background(AppPalette.background)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }

                        TextField("Prize name...", text: $prizeName)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .padding()
                            .frame(height: 42)
                            .background(AppPalette.background)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    if showPrizeEmojiPicker {
                        EmojiGridView(selectedEmoji: $prizeEmoji)
                    }

                    HStack(spacing: 7) {
                        ForEach(PrizeType.allCases) { type in
                            Button {
                                prizeType = type
                                prizeEmoji = type.emoji
                            } label: {
                                Text("\(type.emoji) \(type.shortTitle)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(prizeType == type ? .white : .gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 7)
                                    .background(prizeType == type ? AppPalette.orange : AppPalette.background)
                                    .clipShape(Capsule())
                            }
                        }
                    }

                    HStack(spacing: 8) {
                        Button {
                            let idea = store.randomPrizeIdea()
                            prizeEmoji = idea.emoji
                            prizeName = idea.title
                            prizeType = idea.type
                        } label: {
                            Text("↝ Generate Idea")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(AppPalette.textBlue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 36)
                                .background(AppPalette.background)
                                .clipShape(Capsule())
                        }

                        Button {
                            store.addPrize(title: prizeName, emoji: prizeEmoji, type: prizeType)
                            prizeName = ""
                            prizeEmoji = prizeType.emoji
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 42, height: 36)
                                .background(AppPalette.orange)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(10)
            .background(AppPalette.card)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppPalette.stroke, lineWidth: 1)
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
            LinearGradient(
                colors: [AppPalette.navy, AppPalette.darkBlue],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                DrawTopBar(title: draft.title.isEmpty ? "Draw Show" : draft.title)

                Spacer(minLength: 20)

                participantChips

                Text(draft.mechanic == .drum ? "🎲 LOTO DRUM" : "🎡 WHEEL")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(AppPalette.blueLight.opacity(0.45))
                    .clipShape(Capsule())
                    .padding(.top, 14)

                Spacer()

                if draft.mechanic == .wheel {
                    ShowWheelView(
                        items: wheelItems,
                        rotation: rotation
                    )
                    .frame(width: 300, height: 300)
                } else {
                    ShowDrumView(
                        participants: draft.participants,
                        rotation: rotation
                    )
                    .frame(width: 300, height: 300)
                }

                Spacer()

                Button {
                    spin()
                } label: {
                    Text(isSpinning ? "SPINNING..." : "🎲 SPIN!")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(AppPalette.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: AppPalette.orange.opacity(0.35), radius: 16, y: 8)
                }
                .disabled(isSpinning)
                .padding(.horizontal, 28)
                .padding(.bottom, 22)
            }

            if let result {
                WinnerRevealView(
                    result: result,
                    canDrawNext: canDrawNext,
                    drawAgain: {
                        self.result = nil
                    },
                    finish: {
                        store.saveResult(result)
                        dismiss()
                    },
                    drawNext: {
                        usedParticipantIds.insert(result.participant.id)
                        usedPrizeIds.insert(result.prize.id)
                        store.saveResult(result)
                        self.result = nil
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private var participantChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(draft.participants) { participant in
                    Text("\(participant.emoji) \(participant.name)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var wheelItems: [String] {
        draft.participants.isEmpty
        ? draft.prizes.map(\.emoji)
        : draft.participants.map { "\($0.emoji)\n\($0.name)" }
    }

    private var canDrawNext: Bool {
        guard let result, draft.mode == .everyonePrize else {
            return false
        }

        let nextParticipants = usedParticipantIds.union([result.participant.id])
        let nextPrizes = usedPrizeIds.union([result.prize.id])

        return draft.participants.contains { !nextParticipants.contains($0.id) }
        && draft.prizes.contains { !nextPrizes.contains($0.id) }
    }

    private func spin() {
        result = nil
        isSpinning = true

        withAnimation(.easeOut(duration: 2.6)) {
            rotation += Double.random(in: 900...1600)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            isSpinning = false
            result = store.createResult(
                from: draft,
                usedPrizeIds: usedPrizeIds,
                usedParticipantIds: usedParticipantIds
            )
        }
    }
}

struct WinnerRevealView: View {
    let result: DrawResult
    let canDrawNext: Bool
    let drawAgain: () -> Void
    let finish: () -> Void
    let drawNext: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppPalette.navy, AppPalette.darkBlue],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ConfettiView()

            VStack(spacing: 18) {
                Spacer()

                Text("🏆")
                    .font(.system(size: 84))

                Text("WINNER")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
                    .tracking(3)
                    .foregroundColor(.white.opacity(0.75))

                Text("\(result.participant.emoji) \(result.participant.name)")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)

                VStack(spacing: 12) {
                    Text("WINS")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .tracking(2)
                        .foregroundColor(.white.opacity(0.55))

                    Text(result.prize.emoji)
                        .font(.system(size: 34))

                    Text(result.prize.title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text(result.prize.type.shortTitle)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppPalette.textBlue)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .padding(.horizontal, 34)

                Spacer()

                VStack(spacing: 12) {
                    Button(action: drawAgain) {
                        SecondaryDarkButtonLabel(title: "Draw Again", icon: "arrow.clockwise")
                    }

                    if canDrawNext {
                        Button(action: drawNext) {
                            SecondaryDarkButtonLabel(title: "Draw Next Prize", icon: "plus")
                        }
                    }

                    Button(action: finish) {
                        Text("✓ Finish")
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background(AppPalette.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 34)
                .padding(.bottom, 30)
            }
        }
    }
}