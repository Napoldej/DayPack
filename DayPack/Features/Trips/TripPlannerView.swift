import SwiftUI

struct TripPlannerView: View {
    struct TripBag: Identifiable, Codable, Equatable {
        let id: UUID
        var name: String
        var items: String
    }

    @AppStorage("tripPlanner.days") private var days = 3
    @AppStorage("tripPlanner.name") private var tripName = "Weekend Trip"
    @AppStorage("tripPlanner.bags") private var bagsData = ""
    @State private var bags: [TripBag] = [
        TripBag(id: UUID(), name: "Day Bag", items: "Wallet\nKeys\nWater Bottle"),
        TripBag(id: UUID(), name: "Suitcase", items: "Clothes\nCharger\nToothbrush"),
    ]
    @State private var newBagName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DPSpacing.lg) {
                    SectionHeader(title: "Trip", eyebrow: "Multi-day")
                    DPCard {
                        VStack(spacing: DPSpacing.md) {
                            CustomTextField(label: "Trip name", text: $tripName, placeholder: "Company Trip")
                            Stepper("\(days) days", value: $days, in: 1...30)
                                .font(.system(size: 15, weight: .semibold))
                        }
                    }

                    SectionHeader(title: "Bags", eyebrow: "\(bags.count) lists")
                    VStack(spacing: DPSpacing.md) {
                        ForEach($bags) { $bag in
                            DPCard {
                                VStack(alignment: .leading, spacing: DPSpacing.md) {
                                    CustomTextField(label: "Bag", text: $bag.name, placeholder: "Carry-on")
                                    TextEditor(text: $bag.items)
                                        .font(.system(size: 15, weight: .medium))
                                        .frame(minHeight: 120)
                                        .scrollContentBackground(.hidden)
                                    SecondaryButton(title: "Remove Bag", icon: "trash", variant: .danger, size: .sm) {
                                        bags.removeAll { $0.id == bag.id }
                                    }
                                }
                            }
                        }
                    }

                    DPCard {
                        VStack(spacing: DPSpacing.md) {
                            CustomTextField(label: "New bag", text: $newBagName, placeholder: "Camera Bag")
                            SecondaryButton(title: "Add Bag", icon: "plus", size: .md) {
                                addBag()
                            }
                        }
                    }
                }
                .padding(.horizontal, DPSpacing.lg)
                .padding(.bottom, DPSpacing.xxl)
            }
            .background(Color.dpBg)
            .navigationTitle("Trip Planner")
            .toolbarBackground(Color.dpBg, for: .navigationBar)
        }
        .onAppear(perform: loadBags)
        .onChange(of: bags) { _, _ in saveBags() }
    }

    private func addBag() {
        let cleaned = newBagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }
        bags.append(TripBag(id: UUID(), name: cleaned, items: ""))
        newBagName = ""
    }

    private func loadBags() {
        guard let data = bagsData.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([TripBag].self, from: data),
              !decoded.isEmpty
        else { return }
        bags = decoded
    }

    private func saveBags() {
        guard let data = try? JSONEncoder().encode(bags),
              let string = String(data: data, encoding: .utf8)
        else { return }
        bagsData = string
    }
}
