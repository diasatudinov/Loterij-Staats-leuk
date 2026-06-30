//
//  GroupsView.swift
//  Loterij Staats leuk
//
//

import SwiftUI

// MARK: - Groups

struct GroupsView: View {
    @EnvironmentObject private var store: LotteryStore

    @State private var editorGroup: ParticipantGroup?
    @State private var isEditorPresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppPalette.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    ScreenTitle("My Groups")

                    if store.groups.isEmpty {
                        EmptyStateView(text: "Nothing here yet")
                    } else {
                        VStack(spacing: 12) {
                            ForEach(store.groups) { group in
                                GroupCard(group: group) {
                                    openEditor(for: group)
                                } delete: {
                                    store.groups.removeAll { $0.id == group.id }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    Spacer()

                    Button {
                        openEditor(
                            for: ParticipantGroup(
                                name: "",
                                emoji: "👥",
                                members: []
                            )
                        )
                    } label: {
                        OrangeButtonLabel(title: "Create Group", icon: "plus")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isEditorPresented) {
                if let editorGroup {
                    GroupEditorScreen(group: editorGroup) { updated in
                        store.upsertGroup(updated)
                    }
                }
            }
            .onChange(of: isEditorPresented) { isPresented in
                if !isPresented {
                    editorGroup = nil
                }
            }
        }
    }

    private func openEditor(for group: ParticipantGroup) {
        editorGroup = group
        isEditorPresented = true
    }
}
struct GroupCard: View {
    let group: ParticipantGroup
    let edit: () -> Void
    let delete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(group.emoji)
                .font(.system(size: 24))
                .frame(width: 44, height: 44)
                .background(AppPalette.background)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(AppPalette.textBlue)

                Text("\(group.members.count) members · Last used June 15")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: edit) {
                Image(systemName: "pencil")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
                    .frame(width: 28, height: 28)
                    .background(AppPalette.orangeSoft.opacity(0.7))
                    .clipShape(Circle())
            }

            Button(action: delete) {
                Image(systemName: "trash")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.red)
                    .frame(width: 28, height: 28)
                    .background(Color.red.opacity(0.12))
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(AppPalette.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppPalette.stroke, lineWidth: 1)
        }
    }
}

struct GroupEditorScreen: View {
    @Environment(\.dismiss) private var dismiss

    @State private var group: ParticipantGroup
    @State private var newMemberName = ""
    @State private var newMemberEmoji = "🙂"
    @State private var showEmojiPicker = false

    let onSave: (ParticipantGroup) -> Void

    init(group: ParticipantGroup, onSave: @escaping (ParticipantGroup) -> Void) {
        _group = State(initialValue: group)
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            AppPalette.background.ignoresSafeArea()

            VStack(spacing: 0) {
                WizardTopBar(title: group.name.isEmpty ? "New Group" : "Edit Group", step: "")

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        FormSectionTitle("Group Name & Emoji")

                        HStack(spacing: 10) {
                            TextField("", text: $group.emoji)
                                .font(.system(size: 20))
                                .multilineTextAlignment(.center)
                                .frame(width: 52, height: 48)
                                .background(AppPalette.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            TextField("e.g. Family", text: $group.name)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .padding()
                                .frame(height: 48)
                                .background(AppPalette.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        FormSectionTitle("Participants (\(group.members.count))")

                        VStack(spacing: 9) {
                            if group.members.isEmpty {
                                Text("No participants yet. Add the first one below.")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.black.opacity(0.04))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            ForEach(Array(group.members.enumerated()), id: \.element.id) { index, member in
                                HStack {
                                    Text(member.emoji)

                                    Text(member.name)
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(AppPalette.textBlue)

                                    Spacer()

                                    Text("#\(index + 1)")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(AppPalette.background)
                                        .clipShape(Capsule())

                                    Button {
                                        group.members.removeAll { $0.id == member.id }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.red)
                                            .frame(width: 24, height: 24)
                                            .background(Color.red.opacity(0.12))
                                            .clipShape(Circle())
                                    }
                                }
                                .padding(10)
                                .background(AppPalette.card)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Button {
                                        showEmojiPicker.toggle()
                                    } label: {
                                        Text(newMemberEmoji)
                                            .font(.system(size: 18))
                                            .frame(width: 42, height: 42)
                                            .background(AppPalette.card)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }

                                    TextField("Participant name...", text: $newMemberName)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .padding()
                                        .frame(height: 42)
                                        .background(AppPalette.card)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }

                                if showEmojiPicker {
                                    EmojiGridView(selectedEmoji: $newMemberEmoji)
                                }

                                Button {
                                    addMember()
                                } label: {
                                    OrangeButtonLabel(title: "Add Participant", icon: "plus")
                                }
                                .disabled(newMemberName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                .opacity(newMemberName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                            }
                            .padding(10)
                            .background(AppPalette.card)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button {
                            onSave(group)
                            dismiss()
                        } label: {
                            BlueButtonLabel(title: "Save Group", icon: "checkmark")
                        }
                        .disabled(group.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(group.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.45 : 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func addMember() {
        let trimmed = newMemberName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        group.members.append(
            Participant(
                name: trimmed,
                emoji: newMemberEmoji.isEmpty ? "🙂" : newMemberEmoji
            )
        )

        newMemberName = ""
        newMemberEmoji = "🙂"
    }
}
