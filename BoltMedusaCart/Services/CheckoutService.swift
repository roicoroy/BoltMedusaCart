//
//  CheckoutService.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation
import Combine

@MainActor
class CheckoutService: ObservableObject {
    @Published var currentCart: Cart?
    @Published var isLoading = false
    @Published var error: String?
    @Published var checkoutStep: CheckoutStep = .cart
    @Published var availableShippingOptions: [ShippingOption] = []
    @Published var availablePaymentProviders: [String] = []
    
    private let apiService = MedusaAPIService.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum CheckoutStep: CaseIterable {
        case cart
        case shipping
        case payment
        case confirmation
        case complete
        
        var title: String {
            switch self {
            case .cart: return "Cart"
            case .shipping: return "Shipping"
            case .payment: return "Payment"
            case .confirmation: return "Review"
            case .complete: return "Complete"
            }
        }
    }
    
    // MARK: - Cart Management
    
    func createCart(regionId: String? = nil, items: [LineItemRequest]? = nil) async {
        isLoading = true
        error = nil
        
        do {
            let request = CreateCartRequest(
                regionId: regionId,
                salesChannelId: nil,
                countryCode: nil,
                items: items,
                context: nil
            )
            
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts",
                method: .POST,
                body: request
            )
            
            currentCart = response.cart
            checkoutStep = .cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func getCart(cartId: String) async {
        isLoading = true
        error = nil
        
        do {
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)",
                method: .GET
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateCart(email: String? = nil, regionId: String? = nil, customerId: String? = nil) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            let request = UpdateCartRequest(
                regionId: regionId,
                countryCode: nil,
                email: email,
                salesChannelId: nil,
                discounts: nil,
                giftCards: nil,
                customerId: customerId,
                context: nil
            )
            
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)",
                method: .POST,
                body: request
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Line Items Management
    
    func addLineItem(variantId: String, quantity: Int) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            let request = AddLineItemRequest(
                variantId: variantId,
                quantity: quantity,
                metadata: nil
            )
            
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/line-items",
                method: .POST,
                body: request
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateLineItem(lineItemId: String, quantity: Int) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            let request = UpdateLineItemRequest(
                quantity: quantity,
                metadata: nil
            )
            
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/line-items/\(lineItemId)",
                method: .POST,
                body: request
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func removeLineItem(lineItemId: String) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/line-items/\(lineItemId)",
                method: .DELETE
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Addresses
    
    func updateShippingAddress(_ address: Address) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/shipping-address",
                method: .POST,
                body: address
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateBillingAddress(_ address: Address) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/billing-address",
                method: .POST,
                body: address
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Shipping Options
    
    func getShippingOptions() async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            struct ShippingOptionsResponse: Codable {
                let shippingOptions: [ShippingOption]
                
                enum CodingKeys: String, CodingKey {
                    case shippingOptions = "shipping_options"
                }
            }
            
            let response: ShippingOptionsResponse = try await apiService.request(
                endpoint: "/store/shipping-options/\(cartId)",
                method: .GET
            )
            
            availableShippingOptions = response.shippingOptions
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func addShippingMethod(optionId: String, data: [String: Any]? = nil) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            struct AddShippingMethodRequest: Codable {
                let optionId: String
                let data: [String: AnyCodable]?
                
                enum CodingKeys: String, CodingKey {
                    case optionId = "option_id"
                    case data
                }
            }
            
            let request = AddShippingMethodRequest(
                optionId: optionId,
                data: data?.mapValues { AnyCodable($0) }
            )
            
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/shipping-methods",
                method: .POST,
                body: request
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Payment Sessions
    
    func initializePaymentSessions() async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/payment-sessions",
                method: .POST
            )
            
            currentCart = response.cart
            availablePaymentProviders = response.cart.paymentSessions.map { $0.providerId }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func selectPaymentSession(providerId: String) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            struct SelectPaymentSessionRequest: Codable {
                let providerId: String
                
                enum CodingKeys: String, CodingKey {
                    case providerId = "provider_id"
                }
            }
            
            let request = SelectPaymentSessionRequest(providerId: providerId)
            
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/payment-sessions/\(providerId)",
                method: .POST,
                body: request
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updatePaymentSession(providerId: String, data: [String: Any]) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            let dataDict = data.mapValues { AnyCodable($0) }
            
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/payment-sessions/\(providerId)",
                method: .POST,
                body: dataDict
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Order Completion
    
    func completeCart() async -> Order? {
        guard let cartId = currentCart?.id else { return nil }
        
        isLoading = true
        error = nil
        
        do {
            let response: OrderResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/complete",
                method: .POST
            )
            
            checkoutStep = .complete
            return response.order
        } catch {
            self.error = error.localizedDescription
            return nil
        }
        
        isLoading = false
    }
    
    // MARK: - Discounts & Gift Cards
    
    func addDiscount(code: String) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            struct AddDiscountRequest: Codable {
                let code: String
            }
            
            let request = AddDiscountRequest(code: code)
            
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/discounts/\(code)",
                method: .POST,
                body: request
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func removeDiscount(code: String) async {
        guard let cartId = currentCart?.id else { return }
        
        isLoading = true
        error = nil
        
        do {
            let response: CartResponse = try await apiService.request(
                endpoint: "/store/carts/\(cartId)/discounts/\(code)",
                method: .DELETE
            )
            
            currentCart = response.cart
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Navigation
    
    func proceedToNextStep() {
        guard let currentIndex = CheckoutStep.allCases.firstIndex(of: checkoutStep),
              currentIndex < CheckoutStep.allCases.count - 1 else { return }
        
        checkoutStep = CheckoutStep.allCases[currentIndex + 1]
    }
    
    func goToPreviousStep() {
        guard let currentIndex = CheckoutStep.allCases.firstIndex(of: checkoutStep),
              currentIndex > 0 else { return }
        
        checkoutStep = CheckoutStep.allCases[currentIndex - 1]
    }
    
    func goToStep(_ step: CheckoutStep) {
        checkoutStep = step
    }
    
    // MARK: - Validation
    
    var canProceedFromCart: Bool {
        guard let cart = currentCart else { return false }
        return !cart.items.isEmpty && cart.email != nil
    }
    
    var canProceedFromShipping: Bool {
        guard let cart = currentCart else { return false }
        return cart.shippingAddress != nil && !cart.shippingMethods.isEmpty
    }
    
    var canProceedFromPayment: Bool {
        guard let cart = currentCart else { return false }
        return cart.paymentSession != nil
    }
    
    var canCompleteOrder: Bool {
        canProceedFromCart && canProceedFromShipping && canProceedFromPayment
    }
    
    // MARK: - Helpers
    
    func formatPrice(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currentCart?.region?.currencyCode ?? "USD"
        return formatter.string(from: NSNumber(value: Double(amount) / 100.0)) ?? "$0.00"
    }
    
    func resetCheckout() {
        currentCart = nil
        checkoutStep = .cart
        availableShippingOptions = []
        availablePaymentProviders = []
        error = nil
    }
}