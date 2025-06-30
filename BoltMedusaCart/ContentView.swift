//
//  ContentView.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @StateObject private var checkoutService = CheckoutService()

    var body: some View {
        TabView {
            ProductListView()
                .tabItem {
                    Image(systemName: "bag")
                    Text("Products")
                }
                .environmentObject(checkoutService)
            
            CheckoutView()
                .tabItem {
                    Image(systemName: "cart")
                    Text("Cart")
                }
                .environmentObject(checkoutService)
            
            NavigationView {
                VStack {
                    List {
                        ForEach(items) { item in
                            NavigationLink {
                                Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                            } label: {
                                Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                            }
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                        ToolbarItem {
                            Button(action: addItem) {
                                Label("Add Item", systemImage: "plus")
                            }
                        }
                    }
                }
                .navigationTitle("Demo Items")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Demo")
            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}