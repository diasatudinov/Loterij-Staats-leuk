// MARK: - Archive

struct ArchiveView: View {
    @EnvironmentObject private var store: LotteryStore

    var body: some View {
        ZStack {
            AppPalette.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                ScreenTitle("Archive")

                if store.archive.isEmpty {
                    EmptyStateView(text: "Nothing here yet")
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12) {
                            ForEach(store.archive) { result in
                                ArchiveResultCard(result: result) {
                                    store.archive.removeAll { $0.id == result.id }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }
}

struct ArchiveResultCard: View {
    let result: DrawResult
    let delete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Text(result.lotteryTitle)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
                    .foregroundColor(AppPalette.textBlue)

                Spacer()

                Text(result.date.formatted(.dateTime.year().month().day()))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }

            HStack(spacing: 10) {
                Text(result.participant.emoji)
                    .font(.system(size: 27))

                VStack(alignment: .leading, spacing: 3) {
                    Text(result.participant.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(AppPalette.textBlue)

                    Text("\(result.prize.emoji) \(result.prize.title)")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.gray)
                }
            }

            HStack(spacing: 8) {
                ArchiveActionButton(title: "Delete", icon: "trash", color: Color.red.opacity(0.13), action: delete)
                    .foregroundColor(.red)
            }
        }
        .padding(16)
        .background(AppPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppPalette.stroke, lineWidth: 1)
        }
    }
}

// MARK: - Settings

struct SettingsView: View {
    var body: some View {
        ZStack {
            AppPalette.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                ScreenTitle("Settings")

                VStack(alignment: .leading, spacing: 12) {
                    Text("App settings")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundColor(AppPalette.textBlue)

                    Text("You can add sounds, haptics, default draw mode and theme settings here.")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(AppPalette.card)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 20)

                Spacer()
            }
        }
    }
}
