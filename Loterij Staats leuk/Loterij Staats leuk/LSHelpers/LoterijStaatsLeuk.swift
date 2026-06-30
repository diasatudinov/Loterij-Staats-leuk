//
//  LoterijStaatsLeukApp.swift
//  Loterij Staats leuk
//
//


import SwiftUI

// MARK: - Charts

struct WinsBarChart: View {
    let items: [(String, Int)]

    private var maxValue: Int {
        max(items.map(\.1).max() ?? 1, 1)
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            ForEach(items, id: \.0) { item in
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppPalette.orange)
                        .frame(height: max(8, CGFloat(item.1) / CGFloat(maxValue) * 95))

                    Text(item.0)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct DonutPrizeChart: View {
    let data: [(PrizeType, Int)]

    private var total: Int {
        data.map(\.1).reduce(0, +)
    }

    var body: some View {
        ZStack {
            if total == 0 {
                Circle()
                    .stroke(Color.green.opacity(0.9), lineWidth: 26)

                Text("0%")
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundColor(AppPalette.textBlue)
            } else {
                ForEach(data.indices, id: \.self) { index in
                    DonutArc(
                        startAngle: startAngle(for: index),
                        endAngle: endAngle(for: index)
                    )
                    .stroke(
                        data[index].0.color,
                        style: StrokeStyle(lineWidth: 26, lineCap: .butt)
                    )
                }
            }
        }
        .padding(16)
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

struct DonutArc: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addArc(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )

        return path
    }
}

// MARK: - Draw Visuals

struct ShowWheelView: View {
    let items: [String]
    let rotation: Double

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let count = max(items.count, 1)

            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    WheelSlice(
                        startAngle: .degrees(Double(index) * 360 / Double(count) - 90),
                        endAngle: .degrees(Double(index + 1) * 360 / Double(count) - 90)
                    )
                    .fill(sliceColor(index))
                }

                ForEach(0..<count, id: \.self) { index in
                    Text(items[safe: index] ?? "🎲")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .rotationEffect(.degrees(Double(index) * 360 / Double(count)))
                        .offset(y: -size * 0.27)
                }

                Circle()
                    .fill(Color.white)
                    .frame(width: 58, height: 58)
                    .overlay {
                        Text("⭐️")
                            .font(.system(size: 27))
                    }
                    .shadow(radius: 8)

                Circle()
                    .stroke(AppPalette.orange, lineWidth: 5)
            }
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .shadow(color: AppPalette.orange.opacity(0.45), radius: 14)
        }
    }

    private func sliceColor(_ index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.96, green: 0.61, blue: 0.04),
            Color(red: 0.20, green: 0.63, blue: 0.75),
            Color(red: 0.58, green: 0.80, blue: 0.22)
        ]

        return colors[index % colors.count]
    }
}

struct ShowDrumView: View {
    let participants: [Participant]
    let rotation: Double

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)

            ZStack {
                Circle()
                    .stroke(AppPalette.blueLight, lineWidth: 5)
                    .shadow(color: AppPalette.blueLight.opacity(0.8), radius: 12)

                Circle()
                    .fill(Color.white.opacity(0.04))

                ForEach(Array(participants.enumerated()), id: \.element.id) { index, participant in
                    let angle = Double(index) * 360 / Double(max(participants.count, 1)) + rotation

                    VStack(spacing: 2) {
                        Text(participant.emoji)
                        Text(participant.name)
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(width: 54, height: 54)
                    .background(ballColor(index))
                    .clipShape(Circle())
                    .offset(
                        x: CGFloat(cos(angle.degreesToRadians)) * size * 0.25,
                        y: CGFloat(sin(angle.degreesToRadians)) * size * 0.25
                    )
                }
            }
            .frame(width: size, height: size)
        }
    }

    private func ballColor(_ index: Int) -> Color {
        let colors: [Color] = [.orange, .yellow.opacity(0.8), .blue, .red.opacity(0.8)]
        return colors[index % colors.count]
    }
}

struct WheelSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)

        path.move(to: center)
        path.addArc(
            center: center,
            radius: min(rect.width, rect.height) / 2,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

struct ConfettiView: View {
    var body: some View {
        GeometryReader { geo in
            ForEach(0..<80, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(confettiColor(index))
                    .frame(width: CGFloat.random(in: 4...9), height: CGFloat.random(in: 8...17))
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    )
                    .opacity(0.85)
            }
        }
        .ignoresSafeArea()
    }

    private func confettiColor(_ index: Int) -> Color {
        let colors: [Color] = [.yellow, .orange, .blue, .white]
        return colors[index % colors.count]
    }
}

// MARK: - Helpers

struct RoundedCorner: Shape {
    var radius: CGFloat = 25
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )

        return Path(path.cgPath)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }

            self
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Double {
    var degreesToRadians: Double {
        self * .pi / 180
    }
}

extension String {
    var shortTemplateTitle: String {
        switch self {
        case "Who Pays the Bill?":
            return "Who Pays\nthe Bill?"
        case "Movie Night":
            return "Movie Night"
        case "General Cleaning":
            return "Who Washes\nthe Dishes?"
        case "Secret Santa Express":
            return "Secret Santa"
        default:
            return self
        }
    }

    var modeTitleWithEmoji: String {
        if contains("One Prize") {
            return "🏆 \(self)"
        }

        if contains("Everyone") {
            return "🎁 \(self)"
        }

        return "💀 \(self)"
    }
}

extension PrizeType {
    var shortTitle: String {
        switch self {
        case .gift: return "Reward"
        case .task: return "Challenge"
        case .penalty: return "Penalty"
        }
    }

    var shortTitlePlural: String {
        switch self {
        case .gift: return "Rewards"
        case .task: return "Challenges"
        case .penalty: return "Penalties"
        }
    }
}
