//
//  ProductListView.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import SwiftUI

struct ProductListView: View {
    @StateObject private var productService = ProductService()
    @StateObject private var checkoutService = CheckoutService()
    @State private var selectedCategory: ProductCategory?
    @State private var selectedRegion: Region?
    @State private var searchText = ""
    @State private var showingFilters = false
    
    var filteredProducts: [Product] {
        if searchText.isEmpty {
            return productService.products
        } else {
            return productService.products.filter { product in
                product.title.localizedCaseInsensitiveContains(searchText) ||
                product.description?.localizedCaseInsensitiveContains(searchText) == true
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter Bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        
                        TextField("Search products...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        if !searchText.isEmpty {
                            Button("Clear") {
                                searchText = ""
                            }
                            .font(.caption)
                            .foregroundStyle(.blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Filter Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterPill(
                                title: "All Categories",
                                isSelected: selectedCategory == nil
                            ) {
                                selectedCategory = nil
                                Task {
                                    await productService.fetchProducts(regionId: selectedRegion?.id)
                                }
                            }
                            
                            ForEach(productService.categories) { category in
                                FilterPill(
                                    title: category.name,
                                    isSelected: selectedCategory?.id == category.id
                                ) {
                                    selectedCategory = category
                                    Task {
                                        await productService.fetchProducts(
                                            categoryId: category.id,
                                            regionId: selectedRegion?.id
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .background(Color(.systemBackground))
                
                Divider()
                
                // Products Grid
                if productService.isLoading && productService.products.isEmpty {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Loading products...")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredProducts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bag")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        
                        Text("No products found")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Try adjusting your search or filters")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
                            ForEach(filteredProducts) { product in
                                NavigationLink(destination: ProductDetailView(product: product)) {
                                    ProductCard(product: product, region: selectedRegion)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationTitle("Products")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CheckoutView()) {
                        CartButton(itemCount: checkoutService.currentCart?.items.count ?? 0)
                    }
                }
            }
            .task {
                await loadInitialData()
            }
            .refreshable {
                await loadInitialData()
            }
        }
        .environmentObject(checkoutService)
    }
    
    private func loadInitialData() async {
        async let productsTask = productService.fetchProducts()
        async let categoriesTask = productService.fetchCategories()
        async let regionsTask = productService.fetchRegions()
        
        await productsTask
        await categoriesTask
        await regionsTask
        
        // Set default region if available
        if selectedRegion == nil, let firstRegion = productService.regions.first {
            selectedRegion = firstRegion
        }
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct ProductCard: View {
    let product: Product
    let region: Region?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Product Image
            AsyncImage(url: URL(string: product.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.title)
                            .foregroundStyle(.secondary)
                    )
            }
            .frame(height: 160)
            .clipped()
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if let description = product.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer(minLength: 8)
                
                // Price
                if let variant = product.variants?.first,
                   let price = variant.prices?.first {
                    Text(formatPrice(price.amount, currencyCode: region?.currencyCode ?? "USD"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private func formatPrice(_ amount: Int, currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: Double(amount) / 100.0)) ?? "$0.00"
    }
}

struct CartButton: View {
    let itemCount: Int
    
    var body: some View {
        ZStack {
            Image(systemName: "bag")
                .font(.title2)
                .foregroundStyle(.blue)
            
            if itemCount > 0 {
                Text("\(itemCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 18, height: 18)
                    .background(Color.red)
                    .cornerRadius(9)
                    .offset(x: 12, y: -12)
            }
        }
    }
}

#Preview {
    ProductListView()
}