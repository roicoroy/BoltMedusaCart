//
//  Order.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation

// MARK: - Order Models
struct Order: Codable, Identifiable {
    let id: String
    let status: OrderStatus
    let fulfillmentStatus: FulfillmentStatus
    let paymentStatus: PaymentStatus
    let displayId: Int
    let cartId: String?
    let customerId: String
    let customer: Customer?
    let email: String
    let billingAddress: Address?
    let billingAddressId: String?
    let shippingAddress: Address?
    let shippingAddressId: String?
    let regionId: String
    let region: Region?
    let currencyCode: String
    let currency: Currency?
    let taxRate: Double?
    let discounts: [Discount]
    let giftCards: [GiftCard]
    let shippingMethods: [ShippingMethod]
    let payments: [Payment]
    let fulfillments: [Fulfillment]
    let returns: [Return]?
    let claims: [ClaimOrder]?
    let refunds: [Refund]?
    let swaps: [Swap]?
    let draftOrderId: String?
    let items: [LineItem]
    let edits: [OrderEdit]?
    let giftCardTransactions: [GiftCardTransaction]?
    let canceledAt: String?
    let noNotification: Bool?
    let idempotencyKey: String?
    let externalId: String?
    let salesChannelId: String?
    let salesChannel: SalesChannel?
    let shippingTotal: Int
    let discountTotal: Int
    let taxTotal: Int
    let refundedTotal: Int
    let total: Int
    let subtotal: Int
    let paidTotal: Int
    let refundableAmount: Int
    let giftCardTotal: Int
    let giftCardTaxTotal: Int
    let returnableItems: [LineItem]?
    let createdAt: String
    let updatedAt: String
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, status, email, discounts, payments, items, total, subtotal, metadata
        case fulfillmentStatus = "fulfillment_status"
        case paymentStatus = "payment_status"
        case displayId = "display_id"
        case cartId = "cart_id"
        case customerId = "customer_id"
        case customer
        case billingAddress = "billing_address"
        case billingAddressId = "billing_address_id"
        case shippingAddress = "shipping_address"
        case shippingAddressId = "shipping_address_id"
        case regionId = "region_id"
        case region
        case currencyCode = "currency_code"
        case currency
        case taxRate = "tax_rate"
        case giftCards = "gift_cards"
        case shippingMethods = "shipping_methods"
        case fulfillments, returns, claims, refunds, swaps
        case draftOrderId = "draft_order_id"
        case edits
        case giftCardTransactions = "gift_card_transactions"
        case canceledAt = "canceled_at"
        case noNotification = "no_notification"
        case idempotencyKey = "idempotency_key"
        case externalId = "external_id"
        case salesChannelId = "sales_channel_id"
        case salesChannel = "sales_channel"
        case shippingTotal = "shipping_total"
        case discountTotal = "discount_total"
        case taxTotal = "tax_total"
        case refundedTotal = "refunded_total"
        case paidTotal = "paid_total"
        case refundableAmount = "refundable_amount"
        case giftCardTotal = "gift_card_total"
        case giftCardTaxTotal = "gift_card_tax_total"
        case returnableItems = "returnable_items"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending
    case completed
    case archived
    case canceled
    case requires_action = "requires_action"
}

enum FulfillmentStatus: String, Codable, CaseIterable {
    case not_fulfilled = "not_fulfilled"
    case partially_fulfilled = "partially_fulfilled"
    case fulfilled
    case partially_shipped = "partially_shipped"
    case shipped
    case partially_returned = "partially_returned"
    case returned
    case canceled
    case requires_action = "requires_action"
}

enum PaymentStatus: String, Codable, CaseIterable {
    case not_paid = "not_paid"
    case awaiting
    case captured
    case partially_refunded = "partially_refunded"
    case refunded
    case canceled
    case requires_action = "requires_action"
}

struct Payment: Codable, Identifiable {
    let id: String
    let swapId: String?
    let cartId: String?
    let orderId: String?
    let amount: Int
    let currencyCode: String
    let currency: Currency?
    let amountRefunded: Int
    let providerId: String
    let data: [String: AnyCodable]
    let capturedAt: String?
    let canceledAt: String?
    let createdAt: String
    let updatedAt: String
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, data, metadata
        case swapId = "swap_id"
        case cartId = "cart_id"
        case orderId = "order_id"
        case currencyCode = "currency_code"
        case currency
        case amountRefunded = "amount_refunded"
        case providerId = "provider_id"
        case capturedAt = "captured_at"
        case canceledAt = "canceled_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Fulfillment: Codable, Identifiable {
    let id: String
    let claimOrderId: String?
    let swapId: String?
    let orderId: String?
    let providerId: String
    let locationId: String?
    let shippedAt: String?
    let canceledAt: String?
    let data: [String: AnyCodable]
    let trackingNumbers: [String]
    let trackingLinks: [TrackingLink]
    let items: [FulfillmentItem]
    let noNotification: Bool?
    let createdAt: String
    let updatedAt: String
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, data, items, metadata
        case claimOrderId = "claim_order_id"
        case swapId = "swap_id"
        case orderId = "order_id"
        case providerId = "provider_id"
        case locationId = "location_id"
        case shippedAt = "shipped_at"
        case canceledAt = "canceled_at"
        case trackingNumbers = "tracking_numbers"
        case trackingLinks = "tracking_links"
        case noNotification = "no_notification"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct TrackingLink: Codable {
    let id: String
    let url: String
    let trackingNumber: String
    let fulfillmentId: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, url, metadata
        case trackingNumber = "tracking_number"
        case fulfillmentId = "fulfillment_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct FulfillmentItem: Codable {
    let fulfillmentId: String
    let itemId: String
    let quantity: Int
    
    enum CodingKeys: String, CodingKey {
        case quantity
        case fulfillmentId = "fulfillment_id"
        case itemId = "item_id"
    }
}

struct Return: Codable, Identifiable {
    let id: String
    let status: String
    let items: [ReturnItem]
    let swapId: String?
    let claimOrderId: String?
    let orderId: String?
    let shippingMethod: ShippingMethod?
    let shippingData: [String: AnyCodable]?
    let locationId: String?
    let refundAmount: Int
    let noNotification: Bool?
    let idempotencyKey: String?
    let receivedAt: String?
    let createdAt: String
    let updatedAt: String
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, status, items, metadata
        case swapId = "swap_id"
        case claimOrderId = "claim_order_id"
        case orderId = "order_id"
        case shippingMethod = "shipping_method"
        case shippingData = "shipping_data"
        case locationId = "location_id"
        case refundAmount = "refund_amount"
        case noNotification = "no_notification"
        case idempotencyKey = "idempotency_key"
        case receivedAt = "received_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ReturnItem: Codable {
    let returnId: String
    let itemId: String
    let quantity: Int
    let isRequested: Bool
    let requestedQuantity: Int?
    let receivedQuantity: Int?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case quantity, metadata
        case returnId = "return_id"
        case itemId = "item_id"
        case isRequested = "is_requested"
        case requestedQuantity = "requested_quantity"
        case receivedQuantity = "received_quantity"
    }
}

struct ClaimOrder: Codable, Identifiable {
    let id: String
    let paymentStatus: String
    let fulfillmentStatus: String
    let type: String
    let orderId: String
    let returnOrder: Return?
    let shippingAddressId: String?
    let shippingAddress: Address?
    let shippingMethods: [ShippingMethod]
    let fulfillments: [Fulfillment]
    let claimItems: [ClaimItem]
    let additionalItems: [LineItem]
    let noNotification: Bool?
    let canceledAt: String?
    let deletedAt: String?
    let createdAt: String
    let updatedAt: String
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, type, fulfillments, metadata
        case paymentStatus = "payment_status"
        case fulfillmentStatus = "fulfillment_status"
        case orderId = "order_id"
        case returnOrder = "return_order"
        case shippingAddressId = "shipping_address_id"
        case shippingAddress = "shipping_address"
        case shippingMethods = "shipping_methods"
        case claimItems = "claim_items"
        case additionalItems = "additional_items"
        case noNotification = "no_notification"
        case canceledAt = "canceled_at"
        case deletedAt = "deleted_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ClaimItem: Codable {
    let id: String
    let images: [ClaimImage]
    let claimOrderId: String
    let itemId: String
    let variantId: String
    let reason: String
    let note: String?
    let quantity: Int
    let tags: [ClaimTag]
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, images, reason, note, quantity, tags, metadata
        case claimOrderId = "claim_order_id"
        case itemId = "item_id"
        case variantId = "variant_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct ClaimImage: Codable, Identifiable {
    let id: String
    let claimItemId: String
    let url: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, url, metadata
        case claimItemId = "claim_item_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct ClaimTag: Codable, Identifiable {
    let id: String
    let value: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, value, metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct Refund: Codable, Identifiable {
    let id: String
    let orderId: String?
    let amount: Int
    let note: String?
    let reason: String
    let paymentId: String
    let createdAt: String
    let updatedAt: String
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, note, reason, metadata
        case orderId = "order_id"
        case paymentId = "payment_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Swap: Codable, Identifiable {
    let id: String
    let fulfillmentStatus: String
    let paymentStatus: String
    let orderId: String
    let differenceDue: Int?
    let shippingAddressId: String?
    let shippingAddress: Address?
    let shippingMethods: [ShippingMethod]
    let cartId: String?
    let cart: Cart?
    let returnOrder: Return?
    let fulfillments: [Fulfillment]
    let payment: Payment?
    let additionalItems: [LineItem]
    let allowBackorder: Bool
    let canceledAt: String?
    let confirmedAt: String?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, cart, payment, metadata
        case fulfillmentStatus = "fulfillment_status"
        case paymentStatus = "payment_status"
        case orderId = "order_id"
        case differenceDue = "difference_due"
        case shippingAddressId = "shipping_address_id"
        case shippingAddress = "shipping_address"
        case shippingMethods = "shipping_methods"
        case cartId = "cart_id"
        case returnOrder = "return_order"
        case fulfillments
        case additionalItems = "additional_items"
        case allowBackorder = "allow_backorder"
        case canceledAt = "canceled_at"
        case confirmedAt = "confirmed_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct OrderEdit: Codable, Identifiable {
    let id: String
    let orderId: String
    let internalNote: String?
    let createdBy: String
    let requestedBy: String?
    let requestedAt: String?
    let confirmedBy: String?
    let confirmedAt: String?
    let declinedBy: String?
    let declinedReason: String?
    let declinedAt: String?
    let canceledBy: String?
    let canceledAt: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case orderId = "order_id"
        case internalNote = "internal_note"
        case createdBy = "created_by"
        case requestedBy = "requested_by"
        case requestedAt = "requested_at"
        case confirmedBy = "confirmed_by"
        case confirmedAt = "confirmed_at"
        case declinedBy = "declined_by"
        case declinedReason = "declined_reason"
        case declinedAt = "declined_at"
        case canceledBy = "canceled_by"
        case canceledAt = "canceled_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct GiftCardTransaction: Codable, Identifiable {
    let id: String
    let giftCardId: String
    let orderId: String
    let amount: Int
    let createdAt: String
    let isRefund: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, amount
        case giftCardId = "gift_card_id"
        case orderId = "order_id"
        case createdAt = "created_at"
        case isRefund = "is_refund"
    }
}

// MARK: - API Response Models
struct OrderResponse: Codable {
    let order: Order
}

struct OrdersResponse: Codable {
    let orders: [Order]
    let count: Int
    let offset: Int
    let limit: Int
}