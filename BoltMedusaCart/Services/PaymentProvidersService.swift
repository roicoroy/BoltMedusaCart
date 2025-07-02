
//
//  PaymentProvidersService.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 01/07/2025.
//

import Foundation

struct PaymentProvider: Codable, Identifiable {
    let id: String
    let isInstalled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case isInstalled = "is_installed"
    }
}

@MainActor
class PaymentProvidersService: ObservableObject {
    @Published var paymentProviders: [PaymentProvider] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiService = MedusaAPIService.shared
    
    func retrievePaymentProviders(cartId: String) async {
        isLoading = true
        error = nil
        
        do {
            let response: PaymentCollectionResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/payment-sessions",
                method: .GET
            )
            
            paymentProviders = response.paymentCollection.paymentProviders
        } catch {
            self.error = "Failed to decode as PaymentCollectionResponse: \(error)"
        }
        
        isLoading = false
    }
}

struct PaymentCollectionResponse: Codable {
    let paymentCollection: PaymentCollection
    
    enum CodingKeys: String, CodingKey {
        case paymentCollection = "payment_collection"
    }
}

struct PaymentCollection: Codable {
    let id: String
    let currencyCode: String
    let amount: Int
    let region: Region
    let paymentSessions: [PaymentSession]
    let paymentProviders: [PaymentProvider]
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, region, status
        case currencyCode = "currency_code"
        case paymentSessions = "payment_sessions"
        case paymentProviders = "payment_providers"
    }
}
