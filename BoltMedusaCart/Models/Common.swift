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







