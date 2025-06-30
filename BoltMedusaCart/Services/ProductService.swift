//
//  ProductService.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation
import Combine

@MainActor
class ProductService: ObservableObject {
    @Published var products: [Product] = []
    @Published var currentProduct: Product?
    @Published var categories: [ProductCategory] = []
    @Published var regions: [Region] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiService = MedusaAPIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Products
    
    func fetchProducts(
        limit: Int = 20,
        offset: Int = 0,
        categoryId: String? = nil,
        collectionId: String? = nil,
        regionId: String? = nil
    ) async {
        isLoading = true
        error = nil
        
        do {
            var queryParams: [String] = []
            queryParams.append("limit=\(limit)")
            queryParams.append("offset=\(offset)")
            
            if let categoryId = categoryId {
                queryParams.append("category_id[]=\(categoryId)")
            }
            
            if let collectionId = collectionId {
                queryParams.append("collection_id[]=\(collectionId)")
            }
            
            if let regionId = regionId {
                queryParams.append("region_id=\(regionId)")
            }
            
            let queryString = queryParams.isEmpty ? "" : "?" + queryParams.joined(separator: "&")
            let endpoint = "/store/products\(queryString)"
            
            print("🔍 Fetching products from: \(endpoint)")
            
            let response: ProductsResponse = try await apiService.request(
                endpoint: endpoint,
                method: .GET
            )
            
            print("✅ Received \(response.products.count) products")
            
            if offset == 0 {
                products = response.products
            } else {
                products.append(contentsOf: response.products)
            }
        } catch {
            print("❌ Error fetching products: \(error)")
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchProduct(id: String, regionId: String? = nil) async {
        isLoading = true
        error = nil
        
        do {
            var endpoint = "/store/products/\(id)"
            if let regionId = regionId {
                endpoint += "?region_id=\(regionId)"
            }
            
            let response: ProductResponse = try await apiService.request(
                endpoint: endpoint,
                method: .GET
            )
            
            currentProduct = response.product
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Categories
    
    func fetchCategories() async {
        do {
            let response: CategoriesResponse = try await apiService.request(
                endpoint: "/store/product-categories",
                method: .GET
            )
            
            categories = response.productCategories
        } catch {
            print("❌ Error fetching categories: \(error)")
            // Don't set error for categories as it's not critical
        }
    }
    
    // MARK: - Regions
    
    func fetchRegions() async {
        do {
            let response: RegionsResponse = try await apiService.request(
                endpoint: "/store/regions",
                method: .GET
            )
            
            regions = response.regions
            print("✅ Received \(response.regions.count) regions")
        } catch {
            print("❌ Error fetching regions: \(error)")
            // Don't set error for regions as it's not critical
        }
    }
    
    // MARK: - Helpers
    
    func formatPrice(_ amount: Int, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        return formatter.string(from: NSNumber(value: Double(amount) / 100.0)) ?? "$0.00"
    }
    
    func getVariantPrice(_ variant: ProductVariant, regionId: String? = nil) -> Int? {
        // In a real implementation, you'd calculate the price based on region and price lists
        // For now, we'll return a default price or the first available price
        return variant.prices?.first?.amount
    }
    
    func clearCurrentProduct() {
        currentProduct = nil
    }
}

// MARK: - Response Models

struct ProductsResponse: Codable {
    let products: [Product]
    let count: Int?
    let offset: Int?
    let limit: Int?
}

struct ProductResponse: Codable {
    let product: Product
}

struct CategoriesResponse: Codable {
    let productCategories: [ProductCategory]
    let count: Int?
    let offset: Int?
    let limit: Int?
    
    enum CodingKeys: String, CodingKey {
        case productCategories = "product_categories"
        case count, offset, limit
    }
}

struct RegionsResponse: Codable {
    let regions: [Region]
    let count: Int?
    let offset: Int?
    let limit: Int?
}