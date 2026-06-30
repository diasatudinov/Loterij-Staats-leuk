// MARK: - Reusable UI

struct BottomTabBar: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 18, weight: .semibold))

                        Text(tab.rawValue)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(selectedTab == tab ? AppPalette.orange : AppPalette.darkBlue.opacity(0.75))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        selectedTab == tab
                        ? AppPalette.orangeSoft.opacity(0.42)
                        : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(.white.opacity(0.97))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 1)
        }
    }
}

struct WizardTopBar: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let step: String

    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(AppPalette.textBlue)
                    .frame(width: 34, height: 34)
                    .background(AppPalette.card)
                    .clipShape(Circle())
            }

            Text(title)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(AppPalette.textBlue)

            Spacer()

            if !step.isEmpty {
                Text(step)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 12)
        .background(AppPalette.background)
    }
}

struct DrawTopBar: View {
    @Environment(\.dismiss) private var dismiss

    let title: String

    var body: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.14))
                    .clipShape(Circle())
            }

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Color.clear
                .frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }
}

struct ScreenTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .font(.system(size: 26, weight: .heavy, design: .rounded))
            .foregroundColor(AppPalette.textBlue)
            .padding(.horizontal, 20)
            .padding(.top, 26)
    }
}

struct SectionHeaderTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title.uppercased()
    }

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .tracking(1.4)
            .foregroundColor(.gray)
            .padding(.horizontal, 20)
    }
}

struct FormSectionTitle: View {
    let title: String

    init(_ title: String) {
        self.title = title.uppercased()
    }

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .heavy, design: .rounded))
            .tracking(1.3)
            .foregroundColor(.gray)
    }
}

struct OrangeButtonLabel: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 16, weight: .heavy, design: .rounded))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(AppPalette.orange)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: AppPalette.orange.opacity(0.28), radius: 12, y: 6)
    }
}

struct BlueButtonLabel: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 15, weight: .heavy, design: .rounded))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(AppPalette.blue)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct SecondaryDarkButtonLabel: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 14, weight: .heavy, design: .rounded))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 46)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct ChoiceChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : AppPalette.textBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 43)
                .background(isSelected ? AppPalette.orange : AppPalette.card)
                .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.plain)
    }
}

struct DrawModeCard: View {
    let mode: DistributionMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: isSelected ? "smallcircle.filled.circle" : "circle")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isSelected ? AppPalette.orange : .gray.opacity(0.5))

                VStack(alignment: .leading, spacing: 3) {
                    Text(mode.title.modeTitleWithEmoji)
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(AppPalette.textBlue)

                    Text(mode.subtitle)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .padding(13)
            .background(isSelected ? AppPalette.orangeSoft.opacity(0.35) : AppPalette.card)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay {
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? AppPalette.orange : AppPalette.stroke, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

struct VisualizationCard: View {
    let mechanic: DrawMechanic
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Text(mechanic.icon)
                    .font(.system(size: 26))

                Text(mechanic.title == "Lottery Drum" ? "Lotto machine" : "Wheel")
                    .font(.system(size: 11, weight: .heavy, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : AppPalette.textBlue)
            .frame(width: 82, height: 72)
            .background(isSelected ? AppPalette.blue : AppPalette.card)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .buttonStyle(.plain)
    }
}

struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .foregroundColor(AppPalette.textBlue)

                Text(subtitle)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(13)
        .background(AppPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct EditableMiniRow: View {
    let emoji: String
    let title: String
    var tag: String?
    let trailing: String
    let action: () -> Void

    init(
        emoji: String,
        title: String,
        tag: String? = nil,
        trailing: String,
        action: @escaping () -> Void
    ) {
        self.emoji = emoji
        self.title = title
        self.tag = tag
        self.trailing = trailing
        self.action = action
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(emoji)

            Text(title)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundColor(AppPalette.textBlue)
                .lineLimit(1)

            Spacer()

            if let tag {
                Text(tag)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.red.opacity(0.08))
                    .clipShape(Capsule())
            }

            Button(action: action) {
                Text(trailing)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 10)
        .frame(height: 42)
        .background(AppPalette.background)
        .clipShape(RoundedRectangle(cornerRadius: 11))
    }
}

struct EmojiGridView: View {
    @Binding var selectedEmoji: String

    private let emojis = [
        "😈", "😡", "😟", "😲", "🐱", "😺",
        "🥳", "🤭", "😭", "😑", "😵", "😅",
        "😘", "😰", "🤠", "🤫", "🥶", "😋",
        "😨", "🤢", "🙂", "🙄", "🤪", "😝"
    ]

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
            ForEach(emojis, id: \.self) { emoji in
                Button {
                    selectedEmoji = emoji
                } label: {
                    Text(emoji)
                        .font(.system(size: 22))
                        .frame(width: 32, height: 32)
                        .background(selectedEmoji == emoji ? AppPalette.orangeSoft : Color.clear)
                        .clipShape(Circle())
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppPalette.stroke, lineWidth: 1)
        }
    }
}

struct EmptyStateView: View {
    let text: String

    var body: some View {
        Spacer()

        Text(text)
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)

        Spacer()
    }
}

struct ArchiveActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(AppPalette.textBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(color)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}