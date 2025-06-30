//
//  ProductDetailView.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @EnvironmentObject var checkoutService: CheckoutService
    @StateObject private var productService = ProductService()
    
    @State private var selectedVariant: ProductVariant?
    @State private var selectedOptions: [String: String] = [:]
    @State private var quantity = 1
    @State private var showingAddedToCart = false
    @State private var isAddingToCart = false
    @State private var selectedImageIndex = 0
    
    var availableVariants: [ProductVariant] {
        product.variants?.filter { variant in
            // Filter variants based on selected options
            guard let options = variant.options else { return true }
            
            for option in options {
                if let selectedValue = selectedOptions[option.optionId ?? ""],
                   selectedValue != option.value {
                    return false
                }
            }
            return true
        } ?? []
    }
    
    var currentVariant: ProductVariant? {
        selectedVariant ?? availableVariants.first
    }
    
    var currentPrice: String {
        guard let variant = currentVariant,
              let price = variant.prices?.first else {
            return "$0.00"
        }
        
        return productService.formatPrice(price.amount, currencyCode: price.currencyCode)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Product Images
                ProductImageCarousel(
                    images: product.images ?? [],
                    selectedIndex: $selectedImageIndex
                )
                
                VStack(alignment: .leading, spacing: 20) {
                    // Product Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(product.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if let subtitle = product.subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(currentPrice)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.blue)
                    }
                    
                    // Product Description
                    if let description = product.description {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // Product Options
                    if let options = product.options, !options.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(options) { option in
                                ProductOptionSelector(
                                    option: option,
                                    selectedValue: selectedOptions[option.id] ?? "",
                                    onSelectionChanged: { value in
                                        selectedOptions[option.id] = value
                                        updateSelectedVariant()
                                    }
                                )
                            }
                        }
                    }
                    
                    // Quantity Selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quantity")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        HStack(spacing: 16) {
                            Button(action: { 
                                if quantity > 1 { quantity -= 1 }
                            }) {
                                Image(systemName: "minus")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            .disabled(quantity <= 1)
                            
                            Text("\(quantity)")
                                .font(.title2)
                                .fontWeight(.medium)
                                .frame(minWidth: 40)
                            
                            Button(action: { quantity += 1 }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                    }
                    
                    // Stock Status
                    if let variant = currentVariant {
                        HStack {
                            Image(systemName: variant.inventoryQuantity > 0 ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(variant.inventoryQuantity > 0 ? .green : .red)
                            
                            Text(variant.inventoryQuantity > 0 ? "In Stock" : "Out of Stock")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(variant.inventoryQuantity > 0 ? .green : .red)
                            
                            if variant.inventoryQuantity > 0 {
                                Text("(\(variant.inventoryQuantity) available)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    // Add to Cart Button
                    Button(action: addToCart) {
                        HStack {
                            if isAddingToCart {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "bag.badge.plus")
                                    .font(.title3)
                            }
                            
                            Text(isAddingToCart ? "Adding..." : "Add to Cart")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            (currentVariant?.inventoryQuantity ?? 0) > 0 ? Color.blue : Color.gray
                        )
                        .cornerRadius(16)
                    }
                    .disabled((currentVariant?.inventoryQuantity ?? 0) <= 0 || isAddingToCart)
                    
                    // Product Details
                    ProductDetailsSection(product: product, variant: currentVariant)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: CheckoutView()) {
                    CartButton(itemCount: checkoutService.currentCart?.items.count ?? 0)
                }
            }
        }
        .alert("Added to Cart!", isPresented: $showingAddedToCart) {
            Button("Continue Shopping") { }
            Button("View Cart") {
                // Navigate to cart
            }
        } message: {
            Text("\(product.title) has been added to your cart.")
        }
        .onAppear {
            initializeOptions()
        }
    }
    
    private func initializeOptions() {
        // Initialize selected options with first available values
        if let options = product.options {
            for option in options {
                if let firstValue = option.values?.first?.value {
                    selectedOptions[option.id] = firstValue
                }
            }
        }
        updateSelectedVariant()
    }
    
    private func updateSelectedVariant() {
        selectedVariant = availableVariants.first
    }
    
    private func addToCart() {
        guard let variant = currentVariant else { return }
        
        isAddingToCart = true
        
        Task {
            // Create cart if needed
            if checkoutService.currentCart == nil {
                await checkoutService.createCart()
            }
            
            // Add item to cart
            await checkoutService.addLineItem(variantId: variant.id, quantity: quantity)
            
            isAddingToCart = false
            
            if checkoutService.error == nil {
                showingAddedToCart = true
            }
        }
    }
}

struct ProductImageCarousel: View {
    let images: [ProductImage]  // Changed from Image to ProductImage
    @Binding var selectedIndex: Int
    
    var body: some View {
        VStack(spacing: 12) {
            // Main Image
            TabView(selection: $selectedIndex) {
                ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                    AsyncImage(url: URL(string: image.url)) { loadedImage in
                        loadedImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                            )
                    }
                    .tag(index)
                }
            }
            .frame(height: 300)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Thumbnail Strip
            if images.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(images.enumerated()), id: \.offset) { index, image in
                            AsyncImage(url: URL(string: image.url)) { loadedImage in
                                loadedImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color(.systemGray5))
                            }
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedIndex == index ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedIndex = index
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct ProductOptionSelector: View {
    let option: ProductOption
    let selectedValue: String
    let onSelectionChanged: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(option.title)
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(option.values ?? []) { value in
                        Button(action: {
                            onSelectionChanged(value.value)
                        }) {
                            Text(value.value)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedValue == value.value ? Color.blue : Color(.systemGray5)
                                )
                                .foregroundStyle(
                                    selectedValue == value.value ? .white : .primary
                                )
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
        }
    }
}

struct ProductDetailsSection: View {
    let product: Product
    let variant: ProductVariant?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Product Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                if let sku = variant?.sku {
                    DetailRow(title: "SKU", value: sku)
                }
                
                if let material = product.material {
                    DetailRow(title: "Material", value: material)
                }
                
                if let weight = product.weight {
                    DetailRow(title: "Weight", value: "\(weight) kg")
                }
                
                if let dimensions = formatDimensions() {
                    DetailRow(title: "Dimensions", value: dimensions)
                }
                
                if let origin = product.originCountry {
                    DetailRow(title: "Origin", value: origin.uppercased())
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatDimensions() -> String? {
        let length = product.length ?? 0
        let width = product.width ?? 0
        let height = product.height ?? 0
        
        if length > 0 || width > 0 || height > 0 {
            return "\(length) × \(width) × \(height) cm"
        }
        return nil
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationView {
        ProductDetailView(product: Product(
            id: "1",
            title: "Sample Product",
            subtitle: "A great product",
            description: "This is a sample product description.",
            handle: "sample",
            isGiftcard: false,
            status: "published",
            images: [],
            thumbnail: nil,
            options: [],
            variants: [],
            categories: [],
            profileId: "1",
            profile: nil,
            weight: nil,
            length: nil,
            height: nil,
            width: nil,
            hsCode: nil,
            originCountry: nil,
            midCode: nil,
            material: nil,
            collectionId: nil,
            collection: nil,
            typeId: nil,
            type: nil,
            tags: [],
            discountable: true,
            externalId: nil,
            createdAt: "2025-01-01T00:00:00Z",
            updatedAt: "2025-01-01T00:00:00Z",
            deletedAt: nil,
            metadata: nil
        ))
    }
    .environmentObject(CheckoutService())
}