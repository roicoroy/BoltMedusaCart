//
//  Common.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation

// MARK: - AnyCodable for handling dynamic JSON values
struct AnyCodable: Codable {
    let value: Any
    
    init<T>(_ value: T?) {
        self.value = value ?? ()
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = ()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded")
            throw EncodingError.invalidValue(value, context)
        }
    }
}

// MARK: - Address Model
struct Address: Codable, Identifiable {
    let id: String?
    let customerId: String?
    let company: String?
    let firstName: String?
    let lastName: String?
    let address1: String?
    let address2: String?
    let city: String?
    let countryCode: String?
    let province: String?
    let postalCode: String?
    let phone: String?
    let createdAt: String?
    let updatedAt: String?
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, company, city, phone, metadata
        case customerId = "customer_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case address1 = "address_1"
        case address2 = "address_2"
        case countryCode = "country_code"
        case province
        case postalCode = "postal_code"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Region Model
struct Region: Codable, Identifiable {
    let id: String
    let name: String
    let currencyCode: String
    let currency: Currency?
    let taxRate: Double
    let taxCode: String?
    let giftCardsTaxable: Bool
    let automaticTaxes: Bool
    let countries: [Country]?
    let taxProviders: [TaxProvider]?
    let paymentProviders: [PaymentProvider]?
    let fulfillmentProviders: [FulfillmentProvider]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, countries, metadata
        case currencyCode = "currency_code"
        case currency
        case taxRate = "tax_rate"
        case taxCode = "tax_code"
        case giftCardsTaxable = "gift_cards_taxable"
        case automaticTaxes = "automatic_taxes"
        case taxProviders = "tax_providers"
        case paymentProviders = "payment_providers"
        case fulfillmentProviders = "fulfillment_providers"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Currency Model
struct Currency: Codable {
    let code: String
    let symbol: String
    let symbolNative: String
    let name: String
    let includesTax: Bool?
    
    enum CodingKeys: String, CodingKey {
        case code, symbol, name
        case symbolNative = "symbol_native"
        case includesTax = "includes_tax"
    }
}

// MARK: - Country Model
struct Country: Codable, Identifiable {
    let id: Int
    let iso2: String
    let iso3: String
    let numCode: Int
    let name: String
    let displayName: String
    let regionId: String?
    let region: Region?
    
    enum CodingKeys: String, CodingKey {
        case id, name, region
        case iso2 = "iso_2"
        case iso3 = "iso_3"
        case numCode = "num_code"
        case displayName = "display_name"
        case regionId = "region_id"
    }
}

// MARK: - Customer Model
struct Customer: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let billingAddressId: String?
    let billingAddress: Address?
    let shippingAddresses: [Address]?
    let phone: String?
    let hasAccount: Bool
    let orders: [Order]?
    let groups: [CustomerGroup]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, email, phone, orders, groups, metadata
        case firstName = "first_name"
        case lastName = "last_name"
        case billingAddressId = "billing_address_id"
        case billingAddress = "billing_address"
        case shippingAddresses = "shipping_addresses"
        case hasAccount = "has_account"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Customer Group Model
struct CustomerGroup: Codable, Identifiable {
    let id: String
    let name: String
    let customers: [Customer]?
    let priceListId: String?
    let priceList: PriceList?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, customers, metadata
        case priceListId = "price_list_id"
        case priceList = "price_list"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Price List Model
struct PriceList: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let type: String
    let status: String
    let startsAt: String?
    let endsAt: String?
    let customerGroups: [CustomerGroup]?
    let prices: [MoneyAmount]?
    let includesTax: Bool
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, type, status, prices
        case startsAt = "starts_at"
        case endsAt = "ends_at"
        case customerGroups = "customer_groups"
        case includesTax = "includes_tax"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Money Amount Model
struct MoneyAmount: Codable, Identifiable {
    let id: String
    let currencyCode: String
    let currency: Currency?
    let amount: Int
    let minQuantity: Int?
    let maxQuantity: Int?
    let priceListId: String?
    let priceList: PriceList?
    let variantId: String?
    let variant: ProductVariant?
    let regionId: String?
    let region: Region?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, amount, currency, variant, region
        case currencyCode = "currency_code"
        case minQuantity = "min_quantity"
        case maxQuantity = "max_quantity"
        case priceListId = "price_list_id"
        case priceList = "price_list"
        case variantId = "variant_id"
        case regionId = "region_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Product Variant Model
struct ProductVariant: Codable, Identifiable {
    let id: String
    let title: String
    let productId: String
    let product: Product?
    let prices: [MoneyAmount]?
    let sku: String?
    let barcode: String?
    let ean: String?
    let upc: String?
    let variantRank: Int?
    let inventoryQuantity: Int
    let allowBackorder: Bool
    let manageInventory: Bool
    let hsCode: String?
    let originCountry: String?
    let midCode: String?
    let material: String?
    let weight: Double?
    let length: Double?
    let height: Double?
    let width: Double?
    let options: [ProductOptionValue]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, product, prices, sku, barcode, ean, upc, options, metadata
        case productId = "product_id"
        case variantRank = "variant_rank"
        case inventoryQuantity = "inventory_quantity"
        case allowBackorder = "allow_backorder"
        case manageInventory = "manage_inventory"
        case hsCode = "hs_code"
        case originCountry = "origin_country"
        case midCode = "mid_code"
        case material, weight, length, height, width
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Product Model
struct Product: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let description: String?
    let handle: String?
    let isGiftcard: Bool
    let status: String
    let images: [Image]?
    let thumbnail: String?
    let options: [ProductOption]?
    let variants: [ProductVariant]?
    let categories: [ProductCategory]?
    let profileId: String
    let profile: ShippingProfile?
    let weight: Double?
    let length: Double?
    let height: Double?
    let width: Double?
    let hsCode: String?
    let originCountry: String?
    let midCode: String?
    let material: String?
    let collectionId: String?
    let collection: ProductCollection?
    let typeId: String?
    let type: ProductType?
    let tags: [ProductTag]?
    let discountable: Bool
    let externalId: String?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, description, handle, status, images, thumbnail
        case options, variants, categories, weight, length, height, width, tags
        case material, discountable, metadata
        case isGiftcard = "is_giftcard"
        case profileId = "profile_id"
        case profile
        case hsCode = "hs_code"
        case originCountry = "origin_country"
        case midCode = "mid_code"
        case collectionId = "collection_id"
        case collection
        case typeId = "type_id"
        case type
        case externalId = "external_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Supporting Product Models
struct Image: Codable, Identifiable {
    let id: String
    let url: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, url, metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct ProductOption: Codable, Identifiable {
    let id: String
    let title: String
    let values: [ProductOptionValue]?
    let productId: String
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, values, metadata
        case productId = "product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct ProductOptionValue: Codable, Identifiable {
    let id: String
    let value: String
    let optionId: String
    let option: ProductOption?
    let variantId: String
    let variant: ProductVariant?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, value, option, variant, metadata
        case optionId = "option_id"
        case variantId = "variant_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct ProductCategory: Codable, Identifiable {
    let id: String
    let name: String
    let handle: String
    let parentCategoryId: String?
    let parentCategory: ProductCategory?
    let categoryChildren: [ProductCategory]?
    let rank: Int?
    let createdAt: String
    let updatedAt: String
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, handle, rank, metadata
        case parentCategoryId = "parent_category_id"
        case parentCategory = "parent_category"
        case categoryChildren = "category_children"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ProductCollection: Codable, Identifiable {
    let id: String
    let title: String
    let handle: String?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, title, handle, metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

struct ProductType: Codable, Identifiable {
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

struct ProductTag: Codable, Identifiable {
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

struct ShippingProfile: Codable, Identifiable {
    let id: String
    let name: String
    let type: String
    let products: [Product]?
    let shippingOptions: [ShippingOption]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    let metadata: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id, name, type, products, metadata
        case shippingOptions = "shipping_options"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}

// MARK: - Provider Models
struct TaxProvider: Codable, Identifiable {
    let id: String
    let isInstalled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case isInstalled = "is_installed"
    }
}

struct PaymentProvider: Codable, Identifiable {
    let id: String
    let isInstalled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case isInstalled = "is_installed"
    }
}

struct FulfillmentProvider: Codable, Identifiable {
    let id: String
    let isInstalled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case isInstalled = "is_installed"
    }
}