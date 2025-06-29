//
//  Cart.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation

// MARK: - Cart Models
struct Cart: Codable, Identifiable {
    let id: String
    let email: String?
    let billingAddress: Address?
    let billingAddressId: String?
    let shippingAddress: Address?
    let shippingAddressId: String?
    let items: [LineItem]
    let region: Region?
    let regionId: String
    let discounts: [Discount]
    let giftCards: [GiftCard]
    let customerId: String?
    let paymentSession: PaymentSession?
    let paymentSessions: [PaymentSession]
    let paymentId: String?
    let shippingMethods: [ShippingMethod]
    let type: String
    let completedAt: String?
    let paymentAuthorizedAt: String?
    let idempotencyKey: String?
    let context: [String: AnyCodable]?
    let salesChannelId: String?
    let salesChannel: SalesChannel?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    // Computed properties
    var subtotal: Int {
        items.reduce(0) { $0 + $1.total }
    }
    
    var total: Int {
        subtotal + shippingTotal + taxTotal - discountTotal
    }
    
    var shippingTotal: Int {
        shippingMethods.reduce(0) { $0 + $1.price }
    }
    
    var taxTotal: Int {
        items.reduce(0) { $0 + ($1.taxLines?.reduce(0) { $0 + $1.rate } ?? 0) }
    }
    
    var discountTotal: Int {
        discounts.reduce(0) { $0 + $1.rule.value }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, email, items, region, discounts, type, context, metadata
        case billingAddress = "billing_address"
        case billingAddressId = "billing_address_id"
        case shippingAddress = "shipping_address"
        case shippingAddressId = "shipping_address_id"
        case regionId = "region_id"
        case giftCards = "gift_cards"
        case customerId = "customer_id"
        case paymentSession = "payment_session"
        case paymentSessions = "payment_sessions"
        case paymentId = "payment_id"
        case shippingMethods = "shipping_methods"
        case completedAt = "completed_at"
        case paymentAuthorizedAt = "payment_authorized_at"
        case idempotencyKey = "idempotency_key"
        case salesChannelId = "sales_channel_id"
        case salesChannel = "sales_channel"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct LineItem: Codable, Identifiable {
    let id: String
    let cartId: String
    let orderId: String?
    let swapId: String?
    let claimOrderId: String?
    let title: String
    let description: String?
    let thumbnail: String?
    let isReturn: Bool
    let isGiftcard: Bool
    let shouldMerge: Bool
    let allowDiscounts: Bool
    let hasShipping: Bool?
    let unitPrice: Int
    let variantId: String?
    let variant: ProductVariant?
    let quantity: Int
    let fulfilledQuantity: Int?
    let returnedQuantity: Int?
    let shippedQuantity: Int?
    let refundable: Int?
    let subtotal: Int?
    let taxTotal: Int?
    let total: Int
    let originalTotal: Int?
    let originalTaxTotal: Int?
    let discountTotal: Int?
    let originalItemId: String?
    let orderEditId: String?
    let createdAt: String
    let updatedAt: String
    let metadata: [String: AnyCodable]?
    let taxLines: [TaxLine]?
    let adjustments: [LineItemAdjustment]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, thumbnail, quantity, subtotal, total, metadata
        case cartId = "cart_id"
        case orderId = "order_id"
        case swapId = "swap_id"
        case claimOrderId = "claim_order_id"
        case isReturn = "is_return"
        case isGiftcard = "is_giftcard"
        case shouldMerge = "should_merge"
        case allowDiscounts = "allow_discounts"
        case hasShipping = "has_shipping"
        case unitPrice = "unit_price"
        case variantId = "variant_id"
        case variant
        case fulfilledQuantity = "fulfilled_quantity"
        case returnedQuantity = "returned_quantity"
        case shippedQuantity = "shipped_quantity"
        case refundable
        case taxTotal = "tax_total"
        case originalTotal = "original_total"
        case originalTaxTotal = "original_tax_total"
        case discountTotal = "discount_total"
        case originalItemId = "original_item_id"
        case orderEditId = "order_edit_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case taxLines = "tax_lines"
        case adjustments
    }
}

struct TaxLine: Codable {
    let id: String
    let rate: Int
    let name: String
    let code: String?
    let createdAt: String
    let updatedAt: String
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, rate, name, code, metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct LineItemAdjustment: Codable {
    let id: String
    let itemId: String
    let description: String
    let discountId: String?
    let amount: Int
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, description, amount, metadata
        case itemId = "item_id"
        case discountId = "discount_id"
    }
}

struct Discount: Codable, Identifiable {
    let id: String
    let code: String
    let isDynamic: Bool
    let rule: DiscountRule
    let isDisabled: Bool
    let parentDiscountId: String?
    let startsAt: String
    let endsAt: String?
    let validDuration: String?
    let regions: [Region]?
    let usageLimit: Int?
    let usageCount: Int
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, code, rule, regions, metadata
        case isDynamic = "is_dynamic"
        case isDisabled = "is_disabled"
        case parentDiscountId = "parent_discount_id"
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case validDuration = "valid_duration"
        case usageLimit = "usage_limit"
        case usageCount = "usage_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct DiscountRule: Codable {
    let id: String
    let type: String
    let description: String
    let value: Int
    let allocation: String?
    let conditions: [DiscountCondition]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, type, description, value, allocation, conditions, metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct DiscountCondition: Codable {
    let id: String
    let type: String
    let operator: String
    let discountRuleId: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, type, operator, metadata
        case discountRuleId = "discount_rule_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct GiftCard: Codable, Identifiable {
    let id: String
    let code: String
    let value: Int
    let balance: Int
    let regionId: String
    let region: Region?
    let orderId: String?
    let isDisabled: Bool
    let endsAt: String?
    let taxInclusive: Bool?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, code, value, balance, region, metadata
        case regionId = "region_id"
        case orderId = "order_id"
        case isDisabled = "is_disabled"
        case endsAt = "ends_at"
        case taxInclusive = "tax_inclusive"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct PaymentSession: Codable, Identifiable {
    let id: String
    let cartId: String
    let providerId: String
    let isSelected: Bool
    let isInitiated: Bool
    let status: String
    let data: [String: AnyCodable]
    let amount: Int
    let paymentAuthorizedAt: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, data, amount, status
        case cartId = "cart_id"
        case providerId = "provider_id"
        case isSelected = "is_selected"
        case isInitiated = "is_initiated"
        case paymentAuthorizedAt = "payment_authorized_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ShippingMethod: Codable, Identifiable {
    let id: String
    let shippingOptionId: String
    let orderId: String?
    let cartId: String?
    let swapId: String?
    let returnId: String?
    let claimOrderId: String?
    let price: Int
    let data: [String: AnyCodable]
    let shippingOption: ShippingOption?
    let taxLines: [TaxLine]?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, price, data
        case shippingOptionId = "shipping_option_id"
        case orderId = "order_id"
        case cartId = "cart_id"
        case swapId = "swap_id"
        case returnId = "return_id"
        case claimOrderId = "claim_order_id"
        case shippingOption = "shipping_option"
        case taxLines = "tax_lines"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ShippingOption: Codable, Identifiable {
    let id: String
    let name: String
    let regionId: String
    let profileId: String
    let providerId: String
    let priceType: String
    let amount: Int?
    let isReturn: Bool
    let adminOnly: Bool
    let requirements: [ShippingOptionRequirement]?
    let data: [String: AnyCodable]
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, amount, requirements, data, metadata
        case regionId = "region_id"
        case profileId = "profile_id"
        case providerId = "provider_id"
        case priceType = "price_type"
        case isReturn = "is_return"
        case adminOnly = "admin_only"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct ShippingOptionRequirement: Codable {
    let id: String
    let shippingOptionId: String
    let type: String
    let amount: Int
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, type, amount
        case shippingOptionId = "shipping_option_id"
        case deletedAt = "deleted_at"
    }
}

struct SalesChannel: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let isDisabled: Bool
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case isDisabled = "is_disabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Cart Request Models
struct CreateCartRequest: Codable {
    let regionId: String?
    let salesChannelId: String?
    let countryCode: String?
    let items: [LineItemRequest]?
    let context: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case items, context
        case regionId = "region_id"
        case salesChannelId = "sales_channel_id"
        case countryCode = "country_code"
    }
}

struct LineItemRequest: Codable {
    let variantId: String
    let quantity: Int
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case quantity, metadata
        case variantId = "variant_id"
    }
}

struct UpdateCartRequest: Codable {
    let regionId: String?
    let countryCode: String?
    let email: String?
    let salesChannelId: String?
    let discounts: [DiscountRequest]?
    let giftCards: [GiftCardRequest]?
    let customerId: String?
    let context: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case email, discounts, context
        case regionId = "region_id"
        case countryCode = "country_code"
        case salesChannelId = "sales_channel_id"
        case giftCards = "gift_cards"
        case customerId = "customer_id"
    }
}

struct DiscountRequest: Codable {
    let code: String
}

struct GiftCardRequest: Codable {
    let code: String
}

struct AddLineItemRequest: Codable {
    let variantId: String
    let quantity: Int
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case quantity, metadata
        case variantId = "variant_id"
    }
}

struct UpdateLineItemRequest: Codable {
    let quantity: Int
    let metadata: [String: AnyCodable]?
}

// MARK: - API Response Models
struct CartResponse: Codable {
    let cart: Cart
}

struct CartsResponse: Codable {
    let carts: [Cart]
}