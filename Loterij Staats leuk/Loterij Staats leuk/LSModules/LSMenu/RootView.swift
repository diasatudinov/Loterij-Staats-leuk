// MARK: - Root

struct RootView: View {
    @StateObject private var store = LotteryStore()
    @State private var selectedTab: MainTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .home:
                    LobbyView(selectedTab: $selectedTab)
                case .groups:
                    GroupsView()
                case .archive:
                    ArchiveView()
                case .stats:
                    StatsView()
                }
            }
            .environmentObject(store)
            .padding(.bottom, 70)

            BottomTabBar(selectedTab: $selectedTab)
        }
        .background(AppPalette.background.ignoresSafeArea())
    }
}