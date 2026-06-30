//
//  StatsView.swift
//  Loterij Staats leuk
//
//

import SwiftUI

// MARK: - Stats

struct StatsView: View {
    @EnvironmentObject private var store: LotteryStore

    var body: some View {
        ZStack {
            AppPalette.background.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenTitle("Statistics")

                    if !store.archive.isEmpty {
                        hallOfFame
                    }

                    statsBarCard

                    prizeDistributionCard
                }
                .padding(.bottom, 20)
            }
        }
    }

    private var hallOfFame: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Hall of Fame")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.8))

            HStack(spacing: 8) {
                HeaderStatCard(
                    emoji: "👑",
                    title: store.topLucky()?.0.components(separatedBy: " ").last ?? "Emma",
                    subtitle: "\(store.topLucky()?.1 ?? 0) wins"
                )

                HeaderStatCard(
                    emoji: "🧲",
                    title: store.penaltyMagnet()?.0.components(separatedBy: " ").last ?? "Max",
                    subtitle: "\(store.penaltyMagnet()?.1 ?? 0) penalties"
                )

                HeaderStatCard(
                    emoji: "🎁",
                    title: store.favoritePrize()?.0.components(separatedBy: " ").first ?? "Pizza",
                    subtitle: "\(store.favoritePrize()?.1 ?? 0) times"
                )
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [AppPalette.blue, AppPalette.blueLight],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 20)
    }

    private var statsBarCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            FormSectionTitle("Wins by Player")

            WinsBarChart(items: winsByPlayer)
                .frame(height: 150)
        }
        .padding(16)
        .background(AppPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppPalette.stroke, lineWidth: 1)
        }
        .padding(.horizontal, 20)
    }

    private var prizeDistributionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            FormSectionTitle("Prize Distribution")

            HStack(spacing: 18) {
                DonutPrizeChart(data: store.prizeTypeCounts())
                    .frame(width: 130, height: 130)

                VStack(alignment: .leading, spacing: 10) {
                    ForEach(store.prizeTypeCounts(), id: \.0.id) { item in
                        let percent = prizePercent(item.1)

                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.0.color)
                                .frame(width: 8, height: 8)

                            Text(item.0.shortTitlePlural)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(AppPalette.textBlue)

                            Spacer()

                            Text("\(percent)%")
                                .font(.system(size: 12, weight: .heavy, design: .rounded))
                                .foregroundColor(AppPalette.textBlue)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(AppPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppPalette.stroke, lineWidth: 1)
        }
        .padding(.horizontal, 20)
    }

    private var winsByPlayer: [(String, Int)] {
        let grouped = Dictionary(grouping: store.archive) { $0.participant.name }

        return grouped
            .map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .prefix(4)
            .map { $0 }
    }

    private func prizePercent(_ count: Int) -> Int {
        let total = max(store.prizeTypeCounts().map(\.1).reduce(0, +), 1)
        return Int((Double(count) / Double(total)) * 100)
    }
}
