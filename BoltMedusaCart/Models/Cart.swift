//
//  Cart.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation

// MARK: - Cart Models (Updated for Medusa Store API v2)
struct Cart: Codable, Identifiable {
    let id: String
    let email: String?
    let currencyCode: String
    let regionId: String
    let customerId: String?
    let salesChannelId: String?
    let createdAt: String
    let updatedAt: String
    let completedAt: String?
    let metadata: [String: Any]?
    
    // Calculated totals
    let total: Int
    let subtotal: Int
    let taxTotal: Int
    let discountTotal: Int
    let discountSubtotal: Int
    let discountTaxTotal: Int
    let originalTotal: Int
    let originalTaxTotal: Int
    let itemTotal: Int
    let itemSubtotal: Int
    let itemTaxTotal: Int
    let originalItemTotal: Int
    let originalItemSubtotal: Int
    let originalItemTaxTotal: Int
    let shippingTotal: Int
    let shippingSubtotal: Int
    let shippingTaxTotal: Int
    let originalShippingTaxTotal: Int
    let originalShippingSubtotal: Int
    let originalShippingTotal: Int
    
    // Related entities
    let items: [CartLineItem]?
    let region: CartRegion?
    let customer: CartCustomer?
    let shippingAddress: CartAddress?
    let billingAddress: CartAddress?
    let shippingMethods: [CartShippingMethod]?
    let paymentSessions: [CartPaymentSession]?
    let promotions: [CartPromotion]?
    
    enum CodingKeys: String, CodingKey {
        case id, email, metadata, total, subtotal, items, region, customer, promotions
        case currencyCode = "currency_code"
        case regionId = "region_id"
        case customerId = "customer_id"
        case salesChannelId = "sales_channel_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
        case taxTotal = "tax_total"
        case discountTotal = "discount_total"
        case discountSubtotal = "discount_subtotal"
        case discountTaxTotal = "discount_tax_total"
        case originalTotal = "original_total"
        case originalTaxTotal = "original_tax_total"
        case itemTotal = "item_total"
        case itemSubtotal = "item_subtotal"
        case itemTaxTotal = "item_tax_total"
        case originalItemTotal = "original_item_total"
        case originalItemSubtotal = "original_item_subtotal"
        case originalItemTaxTotal = "original_item_tax_total"
        case shippingTotal = "shipping_total"
        case shippingSubtotal = "shipping_subtotal"
        case shippingTaxTotal = "shipping_tax_total"
        case originalShippingTaxTotal = "original_shipping_tax_total"
        case originalShippingSubtotal = "original_shipping_subtotal"
        case originalShippingTotal = "original_shipping_total"
        case shippingAddress = "shipping_address"
        case billingAddress = "billing_address"
        case shippingMethods = "shipping_methods"
        case paymentSessions = "payment_sessions"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Required fields
        id = try container.decode(String.self, forKey: .id)
        currencyCode = try container.decode(String.self, forKey: .currencyCode)
        regionId = try container.decode(String.self, forKey: .regionId)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        
        // Optional fields
        email = try container.decodeIfPresent(String.self, forKey: .email)
        customerId = try container.decodeIfPresent(String.self, forKey: .customerId)
        salesChannelId = try container.decodeIfPresent(String.self, forKey: .salesChannelId)
        completedAt = try container.decodeIfPresent(String.self, forKey: .completedAt)
        
        // Totals - provide defaults if missing
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
        subtotal = try container.decodeIfPresent(Int.self, forKey: .subtotal) ?? 0
        taxTotal = try container.decodeIfPresent(Int.self, forKey: .taxTotal) ?? 0
        discountTotal = try container.decodeIfPresent(Int.self, forKey: .discountTotal) ?? 0
        discountSubtotal = try container.decodeIfPresent(Int.self, forKey: .discountSubtotal) ?? 0
        discountTaxTotal = try container.decodeIfPresent(Int.self, forKey: .discountTaxTotal) ?? 0
        originalTotal = try container.decodeIfPresent(Int.self, forKey: .originalTotal) ?? 0
        originalTaxTotal = try container.decodeIfPresent(Int.self, forKey: .originalTaxTotal) ?? 0
        itemTotal = try container.decodeIfPresent(Int.self, forKey: .itemTotal) ?? 0
        itemSubtotal = try container.decodeIfPresent(Int.self, forKey: .itemSubtotal) ?? 0
        itemTaxTotal = try container.decodeIfPresent(Int.self, forKey: .itemTaxTotal) ?? 0
        originalItemTotal = try container.decodeIfPresent(Int.self, forKey: .originalItemTotal) ?? 0
        originalItemSubtotal = try container.decodeIfPresent(Int.self, forKey: .originalItemSubtotal) ?? 0
        originalItemTaxTotal = try container.decodeIfPresent(Int.self, forKey: .originalItemTaxTotal) ?? 0
        shippingTotal = try container.decodeIfPresent(Int.self, forKey: .shippingTotal) ?? 0
        shippingSubtotal = try container.decodeIfPresent(Int.self, forKey: .shippingSubtotal) ?? 0
        shippingTaxTotal = try container.decodeIfPresent(Int.self, forKey: .shippingTaxTotal) ?? 0
        originalShippingTaxTotal = try container.decodeIfPresent(Int.self, forKey: .originalShippingTaxTotal) ?? 0
        originalShippingSubtotal = try container.decodeIfPresent(Int.self, forKey: .originalShippingSubtotal) ?? 0
        originalShippingTotal = try container.decodeIfPresent(Int.self, forKey: .originalShippingTotal) ?? 0
        
        // Related entities
        items = try container.decodeIfPresent([CartLineItem].self, forKey: .items)
        region = try container.decodeIfPresent(CartRegion.self, forKey: .region)
        customer = try container.decodeIfPresent(CartCustomer.self, forKey: .customer)
        shippingAddress = try container.decodeIfPresent(CartAddress.self, forKey: .shippingAddress)
        billingAddress = try container.decodeIfPresent(CartAddress.self, forKey: .billingAddress)
        shippingMethods = try container.decodeIfPresent([CartShippingMethod].self, forKey: .shippingMethods)
        paymentSessions = try container.decodeIfPresent([CartPaymentSession].self, forKey: .paymentSessions)
        promotions = try container.decodeIfPresent([CartPromotion].self, forKey: .promotions)
        
        // Handle metadata
        if container.contains(.metadata) {
            if let metadataDict = try? container.decode([String: AnyCodable].self, forKey: .metadata) {
                metadata = metadataDict.mapValues { $0.value }
            } else {
                metadata = nil
            }
        } else {
            metadata = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(regionId, forKey: .regionId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(customerId, forKey: .customerId)
        try container.encodeIfPresent(salesChannelId, forKey: .salesChannelId)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
        
        try container.encode(total, forKey: .total)
        try container.encode(subtotal, forKey: .subtotal)
        try container.encode(taxTotal, forKey: .taxTotal)
        try container.encode(discountTotal, forKey: .discountTotal)
        try container.encode(discountSubtotal, forKey: .discountSubtotal)
        try container.encode(discountTaxTotal, forKey: .discountTaxTotal)
        try container.encode(originalTotal, forKey: .originalTotal)
        try container.encode(originalTaxTotal, forKey: .originalTaxTotal)
        try container.encode(itemTotal, forKey: .itemTotal)
        try container.encode(itemSubtotal, forKey: .itemSubtotal)
        try container.encode(itemTaxTotal, forKey: .itemTaxTotal)
        try container.encode(originalItemTotal, forKey: .originalItemTotal)
        try container.encode(originalItemSubtotal, forKey: .originalItemSubtotal)
        try container.encode(originalItemTaxTotal, forKey: .originalItemTaxTotal)
        try container.encode(shippingTotal, forKey: .shippingTotal)
        try container.encode(shippingSubtotal, forKey: .shippingSubtotal)
        try container.encode(shippingTaxTotal, forKey: .shippingTaxTotal)
        try container.encode(originalShippingTaxTotal, forKey: .originalShippingTaxTotal)
        try container.encode(originalShippingSubtotal, forKey: .originalShippingSubtotal)
        try container.encode(originalShippingTotal, forKey: .originalShippingTotal)
        
        try container.encodeIfPresent(items, forKey: .items)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encodeIfPresent(customer, forKey: .customer)
        try container.encodeIfPresent(shippingAddress, forKey: .shippingAddress)
        try container.encodeIfPresent(billingAddress, forKey: .billingAddress)
        try container.encodeIfPresent(shippingMethods, forKey: .shippingMethods)
        try container.encodeIfPresent(paymentSessions, forKey: .paymentSessions)
        try container.encodeIfPresent(promotions, forKey: .promotions)
    }
}

// MARK: - Cart Line Item
struct CartLineItem: Codable, Identifiable {
    let id: String
    let cartId: String
    let title: String
    let subtitle: String?
    let thumbnail: String?
    let variantId: String?
    let productId: String?
    let productTitle: String?
    let productDescription: String?
    let productSubtitle: String?
    let productType: String?
    let productCollection: String?
    let productHandle: String?
    let variantSku: String?
    let variantBarcode: String?
    let variantTitle: String?
    let variantOptionValues: [CartLineItemOptionValue]?
    let requiresShipping: Bool
    let isDiscountable: Bool
    let isTaxInclusive: Bool
    let unitPrice: Int
    let quantity: Int
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    // Calculated fields
    let total: Int
    let subtotal: Int
    let taxTotal: Int
    let discountTotal: Int
    let originalTotal: Int
    let originalTaxTotal: Int
    
    // Related entities
    let product: CartProduct?
    let variant: CartVariant?
    let adjustments: [CartAdjustment]?
    let taxLines: [CartTaxLine]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, thumbnail, quantity, metadata, total, subtotal, product, variant, adjustments
        case cartId = "cart_id"
        case variantId = "variant_id"
        case productId = "product_id"
        case productTitle = "product_title"
        case productDescription = "product_description"
        case productSubtitle = "product_subtitle"
        case productType = "product_type"
        case productCollection = "product_collection"
        case productHandle = "product_handle"
        case variantSku = "variant_sku"
        case variantBarcode = "variant_barcode"
        case variantTitle = "variant_title"
        case variantOptionValues = "variant_option_values"
        case requiresShipping = "requires_shipping"
        case isDiscountable = "is_discountable"
        case isTaxInclusive = "is_tax_inclusive"
        case unitPrice = "unit_price"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case taxTotal = "tax_total"
        case discountTotal = "discount_total"
        case originalTotal = "original_total"
        case originalTaxTotal = "original_tax_total"
        case taxLines = "tax_lines"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        cartId = try container.decode(String.self, forKey: .cartId)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        variantId = try container.decodeIfPresent(String.self, forKey: .variantId)
        productId = try container.decodeIfPresent(String.self, forKey: .productId)
        productTitle = try container.decodeIfPresent(String.self, forKey: .productTitle)
        productDescription = try container.decodeIfPresent(String.self, forKey: .productDescription)
        productSubtitle = try container.decodeIfPresent(String.self, forKey: .productSubtitle)
        productType = try container.decodeIfPresent(String.self, forKey: .productType)
        productCollection = try container.decodeIfPresent(String.self, forKey: .productCollection)
        productHandle = try container.decodeIfPresent(String.self, forKey: .productHandle)
        variantSku = try container.decodeIfPresent(String.self, forKey: .variantSku)
        variantBarcode = try container.decodeIfPresent(String.self, forKey: .variantBarcode)
        variantTitle = try container.decodeIfPresent(String.self, forKey: .variantTitle)
        variantOptionValues = try container.decodeIfPresent([CartLineItemOptionValue].self, forKey: .variantOptionValues)
        requiresShipping = try container.decodeIfPresent(Bool.self, forKey: .requiresShipping) ?? true
        isDiscountable = try container.decodeIfPresent(Bool.self, forKey: .isDiscountable) ?? true
        isTaxInclusive = try container.decodeIfPresent(Bool.self, forKey: .isTaxInclusive) ?? false
        unitPrice = try container.decode(Int.self, forKey: .unitPrice)
        quantity = try container.decode(Int.self, forKey: .quantity)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        
        // Calculated fields with defaults
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? (unitPrice * quantity)
        subtotal = try container.decodeIfPresent(Int.self, forKey: .subtotal) ?? (unitPrice * quantity)
        taxTotal = try container.decodeIfPresent(Int.self, forKey: .taxTotal) ?? 0
        discountTotal = try container.decodeIfPresent(Int.self, forKey: .discountTotal) ?? 0
        originalTotal = try container.decodeIfPresent(Int.self, forKey: .originalTotal) ?? (unitPrice * quantity)
        originalTaxTotal = try container.decodeIfPresent(Int.self, forKey: .originalTaxTotal) ?? 0
        
        // Related entities
        product = try container.decodeIfPresent(CartProduct.self, forKey: .product)
        variant = try container.decodeIfPresent(CartVariant.self, forKey: .variant)
        adjustments = try container.decodeIfPresent([CartAdjustment].self, forKey: .adjustments)
        taxLines = try container.decodeIfPresent([CartTaxLine].self, forKey: .taxLines)
        
        // Handle metadata
        if container.contains(.metadata) {
            if let metadataDict = try? container.decode([String: AnyCodable].self, forKey: .metadata) {
                metadata = metadataDict.mapValues { $0.value }
            } else {
                metadata = nil
            }
        } else {
            metadata = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(cartId, forKey: .cartId)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encodeIfPresent(thumbnail, forKey: .thumbnail)
        try container.encodeIfPresent(variantId, forKey: .variantId)
        try container.encodeIfPresent(productId, forKey: .productId)
        try container.encodeIfPresent(productTitle, forKey: .productTitle)
        try container.encodeIfPresent(productDescription, forKey: .productDescription)
        try container.encodeIfPresent(productSubtitle, forKey: .productSubtitle)
        try container.encodeIfPresent(productType, forKey: .productType)
        try container.encodeIfPresent(productCollection, forKey: .productCollection)
        try container.encodeIfPresent(productHandle, forKey: .productHandle)
        try container.encodeIfPresent(variantSku, forKey: .variantSku)
        try container.encodeIfPresent(variantBarcode, forKey: .variantBarcode)
        try container.encodeIfPresent(variantTitle, forKey: .variantTitle)
        try container.encodeIfPresent(variantOptionValues, forKey: .variantOptionValues)
        try container.encode(requiresShipping, forKey: .requiresShipping)
        try container.encode(isDiscountable, forKey: .isDiscountable)
        try container.encode(isTaxInclusive, forKey: .isTaxInclusive)
        try container.encode(unitPrice, forKey: .unitPrice)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
        
        try container.encode(total, forKey: .total)
        try container.encode(subtotal, forKey: .subtotal)
        try container.encode(taxTotal, forKey: .taxTotal)
        try container.encode(discountTotal, forKey: .discountTotal)
        try container.encode(originalTotal, forKey: .originalTotal)
        try container.encode(originalTaxTotal, forKey: .originalTaxTotal)
        
        try container.encodeIfPresent(product, forKey: .product)
        try container.encodeIfPresent(variant, forKey: .variant)
        try container.encodeIfPresent(adjustments, forKey: .adjustments)
        try container.encodeIfPresent(taxLines, forKey: .taxLines)
    }
}

// MARK: - Supporting Models
struct CartLineItemOptionValue: Codable, Identifiable {
    let id: String
    let value: String
    let optionId: String
    
    enum CodingKeys: String, CodingKey {
        case id, value
        case optionId = "option_id"
    }
}

struct CartRegion: Codable, Identifiable {
    let id: String
    let name: String
    let currencyCode: String
    let automaticTaxes: Bool
    let countries: [CartCountry]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, countries
        case currencyCode = "currency_code"
        case automaticTaxes = "automatic_taxes"
    }
}

struct CartCountry: Codable, Identifiable {
    let iso2: String
    let iso3: String
    let numCode: String
    let name: String
    let displayName: String
    
    var id: String { iso2 }
    
    enum CodingKeys: String, CodingKey {
        case name
        case iso2 = "iso_2"
        case iso3 = "iso_3"
        case numCode = "num_code"
        case displayName = "display_name"
    }
}

struct CartCustomer: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

struct CartAddress: Codable, Identifiable {
    let id: String?
    let firstName: String?
    let lastName: String?
    let company: String?
    let address1: String
    let address2: String?
    let city: String
    let countryCode: String
    let province: String?
    let postalCode: String
    let phone: String?
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case id, company, city, phone, metadata
        case firstName = "first_name"
        case lastName = "last_name"
        case address1 = "address_1"
        case address2 = "address_2"
        case countryCode = "country_code"
        case province
        case postalCode = "postal_code"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(String.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        company = try container.decodeIfPresent(String.self, forKey: .company)
        address1 = try container.decode(String.self, forKey: .address1)
        address2 = try container.decodeIfPresent(String.self, forKey: .address2)
        city = try container.decode(String.self, forKey: .city)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        province = try container.decodeIfPresent(String.self, forKey: .province)
        postalCode = try container.decode(String.self, forKey: .postalCode)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        
        // Handle metadata
        if container.contains(.metadata) {
            if let metadataDict = try? container.decode([String: AnyCodable].self, forKey: .metadata) {
                metadata = metadataDict.mapValues { $0.value }
            } else {
                metadata = nil
            }
        } else {
            metadata = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(company, forKey: .company)
        try container.encode(address1, forKey: .address1)
        try container.encodeIfPresent(address2, forKey: .address2)
        try container.encode(city, forKey: .city)
        try container.encode(countryCode, forKey: .countryCode)
        try container.encodeIfPresent(province, forKey: .province)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encodeIfPresent(phone, forKey: .phone)
    }
}

struct CartShippingMethod: Codable, Identifiable {
    let id: String
    let name: String
    let amount: Int
    let isReturn: Bool
    let adminOnly: Bool
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, amount, metadata
        case isReturn = "is_return"
        case adminOnly = "admin_only"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        amount = try container.decode(Int.self, forKey: .amount)
        isReturn = try container.decodeIfPresent(Bool.self, forKey: .isReturn) ?? false
        adminOnly = try container.decodeIfPresent(Bool.self, forKey: .adminOnly) ?? false
        
        // Handle metadata
        if container.contains(.metadata) {
            if let metadataDict = try? container.decode([String: AnyCodable].self, forKey: .metadata) {
                metadata = metadataDict.mapValues { $0.value }
            } else {
                metadata = nil
            }
        } else {
            metadata = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(amount, forKey: .amount)
        try container.encode(isReturn, forKey: .isReturn)
        try container.encode(adminOnly, forKey: .adminOnly)
    }
}

struct CartPaymentSession: Codable, Identifiable {
    let id: String
    let providerId: String
    let amount: Int
    let status: String
    let data: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, status, data
        case providerId = "provider_id"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        providerId = try container.decode(String.self, forKey: .providerId)
        amount = try container.decode(Int.self, forKey: .amount)
        status = try container.decode(String.self, forKey: .status)
        
        // Handle data
        if container.contains(.data) {
            if let dataDict = try? container.decode([String: AnyCodable].self, forKey: .data) {
                data = dataDict.mapValues { $0.value }
            } else {
                data = nil
            }
        } else {
            data = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(providerId, forKey: .providerId)
        try container.encode(amount, forKey: .amount)
        try container.encode(status, forKey: .status)
    }
}

struct CartPromotion: Codable, Identifiable {
    let id: String
    let code: String
    let type: String
    let isAutomatic: Bool
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case id, code, type, metadata
        case isAutomatic = "is_automatic"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        type = try container.decode(String.self, forKey: .type)
        isAutomatic = try container.decodeIfPresent(Bool.self, forKey: .isAutomatic) ?? false
        
        // Handle metadata
        if container.contains(.metadata) {
            if let metadataDict = try? container.decode([String: AnyCodable].self, forKey: .metadata) {
                metadata = metadataDict.mapValues { $0.value }
            } else {
                metadata = nil
            }
        } else {
            metadata = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(code, forKey: .code)
        try container.encode(type, forKey: .type)
        try container.encode(isAutomatic, forKey: .isAutomatic)
    }
}

struct CartProduct: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let thumbnail: String?
    let handle: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, thumbnail, handle
    }
}

struct CartVariant: Codable, Identifiable {
    let id: String
    let title: String
    let sku: String?
    let barcode: String?
    let inventoryQuantity: Int
    let allowBackorder: Bool
    let manageInventory: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, title, sku, barcode
        case inventoryQuantity = "inventory_quantity"
        case allowBackorder = "allow_backorder"
        case manageInventory = "manage_inventory"
    }
}

struct CartAdjustment: Codable, Identifiable {
    let id: String
    let amount: Int
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, description
    }
}

struct CartTaxLine: Codable, Identifiable {
    let id: String
    let rate: Double
    let name: String
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case id, rate, name, code
    }
}

// Helper struct for flexible JSON decoding
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if container.decodeNil() {
            value = NSNull()
        } else {
            throw DecodingError.typeMismatch(AnyCodable.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        if let bool = value as? Bool {
            try container.encode(bool)
        } else if let int = value as? Int {
            try container.encode(int)
        } else if let double = value as? Double {
            try container.encode(double)
        } else if let string = value as? String {
            try container.encode(string)
        } else if value is NSNull {
            try container.encodeNil()
        } else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}

// MARK: - API Request/Response Models
struct CartResponse: Codable {
    let cart: Cart
}

struct CreateCartRequest: Codable {
    let regionId: String?
    let salesChannelId: String?
    let countryCode: String?
    let email: String?
    let currencyCode: String?
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case email, metadata
        case regionId = "region_id"
        case salesChannelId = "sales_channel_id"
        case countryCode = "country_code"
        case currencyCode = "currency_code"
    }
    
    init(regionId: String? = nil, salesChannelId: String? = nil, countryCode: String? = nil, email: String? = nil, currencyCode: String? = nil, metadata: [String: Any]? = nil) {
        self.regionId = regionId
        self.salesChannelId = salesChannelId
        self.countryCode = countryCode
        self.email = email
        self.currencyCode = currencyCode
        self.metadata = metadata
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(regionId, forKey: .regionId)
        try container.encodeIfPresent(salesChannelId, forKey: .salesChannelId)
        try container.encodeIfPresent(countryCode, forKey: .countryCode)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(currencyCode, forKey: .currencyCode)
        
        // Handle metadata encoding
        if let metadata = metadata {
            let encodableMetadata = metadata.mapValues { AnyCodable($0) }
            try container.encode(encodableMetadata, forKey: .metadata)
        }
    }
}

struct AddLineItemRequest: Codable {
    let variantId: String
    let quantity: Int
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case quantity, metadata
        case variantId = "variant_id"
    }
    
    init(variantId: String, quantity: Int, metadata: [String: Any]? = nil) {
        self.variantId = variantId
        self.quantity = quantity
        self.metadata = metadata
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(variantId, forKey: .variantId)
        try container.encode(quantity, forKey: .quantity)
        
        // Handle metadata encoding
        if let metadata = metadata {
            let encodableMetadata = metadata.mapValues { AnyCodable($0) }
            try container.encode(encodableMetadata, forKey: .metadata)
        }
    }
}

struct UpdateLineItemRequest: Codable {
    let quantity: Int
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case quantity, metadata
    }
    
    init(quantity: Int, metadata: [String: Any]? = nil) {
        self.quantity = quantity
        self.metadata = metadata
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(quantity, forKey: .quantity)
        
        // Handle metadata encoding
        if let metadata = metadata {
            let encodableMetadata = metadata.mapValues { AnyCodable($0) }
            try container.encode(encodableMetadata, forKey: .metadata)
        }
    }
}

// MARK: - Helper Extensions
extension Cart {
    func formattedTotal(currencyCode: String? = nil) -> String {
        return formatPrice(total, currencyCode: currencyCode ?? self.currencyCode)
    }
    
    func formattedSubtotal(currencyCode: String? = nil) -> String {
        return formatPrice(subtotal, currencyCode: currencyCode ?? self.currencyCode)
    }
    
    func formattedTaxTotal(currencyCode: String? = nil) -> String {
        return formatPrice(taxTotal, currencyCode: currencyCode ?? self.currencyCode)
    }
    
    func formattedShippingTotal(currencyCode: String? = nil) -> String {
        return formatPrice(shippingTotal, currencyCode: currencyCode ?? self.currencyCode)
    }
    
    func formattedDiscountTotal(currencyCode: String? = nil) -> String {
        return formatPrice(discountTotal, currencyCode: currencyCode ?? self.currencyCode)
    }
    
    var itemCount: Int {
        return items?.reduce(0) { $0 + $1.quantity } ?? 0
    }
    
    var isEmpty: Bool {
        return items?.isEmpty ?? true
    }
    
    var isAssociatedWithCustomer: Bool {
        return customerId != nil
    }
    
    var customerStatus: String {
        if let customerId = customerId {
            return "Customer: \(customerId)"
        } else {
            return "Anonymous Cart"
        }
    }
    
    var hasShippingAddress: Bool {
        return shippingAddress != nil
    }
    
    var hasBillingAddress: Bool {
        return billingAddress != nil
    }
    
    var isReadyForCheckout: Bool {
        return !isEmpty && hasShippingAddress && hasBillingAddress
    }
    
    var isCompleted: Bool {
        return completedAt != nil
    }
    
    private func formatPrice(_ amount: Int, currencyCode: String? = nil) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = (currencyCode ?? self.currencyCode).uppercased()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let decimalAmount = Double(amount) / 100.0
        return formatter.string(from: NSNumber(value: decimalAmount)) ?? "\((currencyCode ?? self.currencyCode).uppercased()) 0.00"
    }
}

extension CartLineItem {
    func formattedUnitPrice(currencyCode: String) -> String {
        return formatPrice(unitPrice, currencyCode: currencyCode)
    }
    
    func formattedTotal(currencyCode: String) -> String {
        return formatPrice(total, currencyCode: currencyCode)
    }
    
    func formattedSubtotal(currencyCode: String) -> String {
        return formatPrice(subtotal, currencyCode: currencyCode)
    }
    
    var displayImage: String? {
        return thumbnail
    }
    
    var displayTitle: String {
        return productTitle ?? title
    }
    
    var displaySubtitle: String? {
        if let variantTitle = variantTitle, variantTitle != title {
            return variantTitle
        }
        return productSubtitle ?? subtitle
    }
    
    var optionValuesText: String? {
        guard let optionValues = variantOptionValues, !optionValues.isEmpty else {
            return nil
        }
        return optionValues.map { $0.value }.joined(separator: ", ")
    }
    
    private func formatPrice(_ amount: Int, currencyCode: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode.uppercased()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let decimalAmount = Double(amount) / 100.0
        return formatter.string(from: NSNumber(value: decimalAmount)) ?? "\(currencyCode.uppercased()) 0.00"
    }
}

extension CartAddress {
    var fullName: String {
        let components = [firstName, lastName].compactMap { $0 }
        return components.joined(separator: " ")
    }
    
    var fullAddress: String {
        var components = [address1]
        
        if let address2 = address2 {
            components.append(address2)
        }
        
        components.append("\(city), \(province ?? "") \(postalCode)")
        components.append(countryCode.uppercased())
        
        return components.joined(separator: "\n")
    }
    
    var singleLineAddress: String {
        var components = [address1]
        
        if let address2 = address2 {
            components.append(address2)
        }
        
        components.append("\(city), \(province ?? "") \(postalCode), \(countryCode.uppercased())")
        
        return components.joined(separator: ", ")
    }
}

extension CartShippingMethod {
    func formattedAmount(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode.uppercased()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        let decimalAmount = Double(amount) / 100.0
        return formatter.string(from: NSNumber(value: decimalAmount)) ?? "\(currencyCode.uppercased()) 0.00"
    }
}