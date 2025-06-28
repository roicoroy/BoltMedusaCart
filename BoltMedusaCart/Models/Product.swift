//
//  Product.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation
import SwiftUI

// MARK: - Product Models (Updated for Medusa Store API v2)
struct Product: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String?
    let description: String?
    let handle: String?
    let isGiftcard: Bool
    let status: ProductStatus
    let images: [ProductImage]?
    let thumbnail: String?
    let options: [ProductOption]?
    let variants: [ProductVariant]?
    let collection: ProductCollection?
    let collectionId: String?
    let type: ProductType?
    let typeId: String?
    let categories: [ProductCategory]?
    let tags: [ProductTag]?
    let weight: Int?
    let length: Int?
    let height: Int?
    let width: Int?
    let hsCode: String?
    let originCountry: String?
    let midCode: String?
    let material: String?
    let discountable: Bool
    let externalId: String?
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, description, handle, images, thumbnail, options, variants, collection, type, weight, length, height, width, material, discountable, categories, tags, metadata
        case isGiftcard = "is_giftcard"
        case status
        case collectionId = "collection_id"
        case typeId = "type_id"
        case hsCode = "hs_code"
        case originCountry = "origin_country"
        case midCode = "mid_code"
        case externalId = "external_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    // Custom decoder to handle flexible types and metadata
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        handle = try container.decodeIfPresent(String.self, forKey: .handle)
        isGiftcard = try container.decode(Bool.self, forKey: .isGiftcard)
        status = try container.decode(ProductStatus.self, forKey: .status)
        images = try container.decodeIfPresent([ProductImage].self, forKey: .images)
        thumbnail = try container.decodeIfPresent(String.self, forKey: .thumbnail)
        options = try container.decodeIfPresent([ProductOption].self, forKey: .options)
        variants = try container.decodeIfPresent([ProductVariant].self, forKey: .variants)
        collection = try container.decodeIfPresent(ProductCollection.self, forKey: .collection)
        collectionId = try container.decodeIfPresent(String.self, forKey: .collectionId)
        type = try container.decodeIfPresent(ProductType.self, forKey: .type)
        typeId = try container.decodeIfPresent(String.self, forKey: .typeId)
        categories = try container.decodeIfPresent([ProductCategory].self, forKey: .categories)
        tags = try container.decodeIfPresent([ProductTag].self, forKey: .tags)
        hsCode = try container.decodeIfPresent(String.self, forKey: .hsCode)
        originCountry = try container.decodeIfPresent(String.self, forKey: .originCountry)
        midCode = try container.decodeIfPresent(String.self, forKey: .midCode)
        material = try container.decodeIfPresent(String.self, forKey: .material)
        discountable = try container.decodeIfPresent(Bool.self, forKey: .discountable) ?? true
        externalId = try container.decodeIfPresent(String.self, forKey: .externalId)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        
        // Handle flexible numeric types
        weight = Self.decodeFlexibleInt(from: container, forKey: .weight)
        length = Self.decodeFlexibleInt(from: container, forKey: .length)
        height = Self.decodeFlexibleInt(from: container, forKey: .height)
        width = Self.decodeFlexibleInt(from: container, forKey: .width)
        
        // Handle metadata as flexible dictionary
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
    
    private static func decodeFlexibleInt(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Int? {
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
            return intValue
        }
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
            return Int(stringValue)
        }
        return nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(subtitle, forKey: .subtitle)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(handle, forKey: .handle)
        try container.encode(isGiftcard, forKey: .isGiftcard)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(images, forKey: .images)
        try container.encodeIfPresent(thumbnail, forKey: .thumbnail)
        try container.encodeIfPresent(options, forKey: .options)
        try container.encodeIfPresent(variants, forKey: .variants)
        try container.encodeIfPresent(collection, forKey: .collection)
        try container.encodeIfPresent(collectionId, forKey: .collectionId)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(typeId, forKey: .typeId)
        try container.encodeIfPresent(categories, forKey: .categories)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encodeIfPresent(length, forKey: .length)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(hsCode, forKey: .hsCode)
        try container.encodeIfPresent(originCountry, forKey: .originCountry)
        try container.encodeIfPresent(midCode, forKey: .midCode)
        try container.encodeIfPresent(material, forKey: .material)
        try container.encode(discountable, forKey: .discountable)
        try container.encodeIfPresent(externalId, forKey: .externalId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}

enum ProductStatus: String, Codable, CaseIterable {
    case draft = "draft"
    case proposed = "proposed"
    case published = "published"
    case rejected = "rejected"
}

struct ProductImage: Codable, Identifiable {
    let id: String
    let url: String
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, url, metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        url = try container.decode(String.self, forKey: .url)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        
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
        try container.encode(url, forKey: .url)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}

struct ProductOption: Codable, Identifiable {
    let id: String
    let title: String
    let values: [ProductOptionValue]?
    let productId: String?
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, values, metadata
        case productId = "product_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        values = try container.decodeIfPresent([ProductOptionValue].self, forKey: .values)
        productId = try container.decodeIfPresent(String.self, forKey: .productId)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        
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
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(values, forKey: .values)
        try container.encodeIfPresent(productId, forKey: .productId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}

struct ProductOptionValue: Codable, Identifiable {
    let id: String
    let value: String
    let optionId: String?
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, value, metadata
        case optionId = "option_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        value = try container.decode(String.self, forKey: .value)
        optionId = try container.decodeIfPresent(String.self, forKey: .optionId)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        
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
        try container.encode(value, forKey: .value)
        try container.encodeIfPresent(optionId, forKey: .optionId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}

struct ProductVariant: Codable, Identifiable {
    let id: String
    let title: String
    let productId: String?
    let sku: String?
    let barcode: String?
    let ean: String?
    let upc: String?
    let inventoryQuantity: Int
    let allowBackorder: Bool
    let manageInventory: Bool
    let hsCode: String?
    let originCountry: String?
    let midCode: String?
    let material: String?
    let weight: Int?
    let length: Int?
    let height: Int?
    let width: Int?
    let options: [ProductOptionValue]?
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, sku, barcode, ean, upc, material, options, metadata
        case productId = "product_id"
        case inventoryQuantity = "inventory_quantity"
        case allowBackorder = "allow_backorder"
        case manageInventory = "manage_inventory"
        case hsCode = "hs_code"
        case originCountry = "origin_country"
        case midCode = "mid_code"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
        case weight, length, height, width
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        productId = try container.decodeIfPresent(String.self, forKey: .productId)
        sku = try container.decodeIfPresent(String.self, forKey: .sku)
        barcode = try container.decodeIfPresent(String.self, forKey: .barcode)
        ean = try container.decodeIfPresent(String.self, forKey: .ean)
        upc = try container.decodeIfPresent(String.self, forKey: .upc)
        inventoryQuantity = try container.decodeIfPresent(Int.self, forKey: .inventoryQuantity) ?? 0
        allowBackorder = try container.decodeIfPresent(Bool.self, forKey: .allowBackorder) ?? false
        manageInventory = try container.decodeIfPresent(Bool.self, forKey: .manageInventory) ?? true
        hsCode = try container.decodeIfPresent(String.self, forKey: .hsCode)
        originCountry = try container.decodeIfPresent(String.self, forKey: .originCountry)
        midCode = try container.decodeIfPresent(String.self, forKey: .midCode)
        material = try container.decodeIfPresent(String.self, forKey: .material)
        options = try container.decodeIfPresent([ProductOptionValue].self, forKey: .options)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        
        // Handle flexible numeric types
        weight = Self.decodeFlexibleInt(from: container, forKey: .weight)
        length = Self.decodeFlexibleInt(from: container, forKey: .length)
        height = Self.decodeFlexibleInt(from: container, forKey: .height)
        width = Self.decodeFlexibleInt(from: container, forKey: .width)
        
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
    
    private static func decodeFlexibleInt(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Int? {
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
            return intValue
        }
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
            return Int(stringValue)
        }
        return nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(productId, forKey: .productId)
        try container.encodeIfPresent(sku, forKey: .sku)
        try container.encodeIfPresent(barcode, forKey: .barcode)
        try container.encodeIfPresent(ean, forKey: .ean)
        try container.encodeIfPresent(upc, forKey: .upc)
        try container.encode(inventoryQuantity, forKey: .inventoryQuantity)
        try container.encode(allowBackorder, forKey: .allowBackorder)
        try container.encode(manageInventory, forKey: .manageInventory)
        try container.encodeIfPresent(hsCode, forKey: .hsCode)
        try container.encodeIfPresent(originCountry, forKey: .originCountry)
        try container.encodeIfPresent(midCode, forKey: .midCode)
        try container.encodeIfPresent(material, forKey: .material)
        try container.encodeIfPresent(weight, forKey: .weight)
        try container.encodeIfPresent(length, forKey: .length)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(options, forKey: .options)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}

struct ProductCollection: Codable, Identifiable {
    let id: String
    let title: String
    let handle: String?
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, handle, metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        handle = try container.decodeIfPresent(String.self, forKey: .handle)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        
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
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(handle, forKey: .handle)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}

struct ProductType: Codable, Identifiable {
    let id: String
    let value: String
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, value, metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        value = try container.decode(String.self, forKey: .value)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        
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
        try container.encode(value, forKey: .value)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}

struct ProductCategory: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let handle: String?
    let isActive: Bool
    let isInternal: Bool
    let parentCategoryId: String?
    let categoryChildren: [ProductCategory]?
    let rank: Int?
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, handle, rank, metadata
        case isActive = "is_active"
        case isInternal = "is_internal"
        case parentCategoryId = "parent_category_id"
        case categoryChildren = "category_children"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        handle = try container.decodeIfPresent(String.self, forKey: .handle)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        isInternal = try container.decodeIfPresent(Bool.self, forKey: .isInternal) ?? false
        parentCategoryId = try container.decodeIfPresent(String.self, forKey: .parentCategoryId)
        categoryChildren = try container.decodeIfPresent([ProductCategory].self, forKey: .categoryChildren)
        rank = try container.decodeIfPresent(Int.self, forKey: .rank)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        
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
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(handle, forKey: .handle)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(isInternal, forKey: .isInternal)
        try container.encodeIfPresent(parentCategoryId, forKey: .parentCategoryId)
        try container.encodeIfPresent(categoryChildren, forKey: .categoryChildren)
        try container.encodeIfPresent(rank, forKey: .rank)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}

struct ProductTag: Codable, Identifiable {
    let id: String
    let value: String
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, value, metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        value = try container.decode(String.self, forKey: .value)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
        
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
        try container.encode(value, forKey: .value)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
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

// MARK: - API Response Models
struct ProductsResponse: Codable {
    let products: [Product]
    let count: Int
    let offset: Int
    let limit: Int
}

struct ProductResponse: Codable {
    let product: Product
}

// MARK: - Helper Extensions
extension Product {
    var displayImage: String? {
        return thumbnail ?? images?.first?.url
    }
    
    var isAvailable: Bool {
        guard let variant = variants?.first else { return false }
        return variant.isInStock
    }
    
    var displayStatus: String {
        return status.rawValue.capitalized
    }
    
    var isPublished: Bool {
        return status == .published
    }
    
    var categoryNames: [String] {
        return categories?.map { $0.name } ?? []
    }
    
    var tagValues: [String] {
        return tags?.map { $0.value } ?? []
    }
}

extension ProductVariant {
    var isInStock: Bool {
        if !manageInventory {
            return true
        }
        return inventoryQuantity > 0 || allowBackorder
    }
    
    var stockStatus: String {
        if !manageInventory {
            return "Available"
        }
        
        if inventoryQuantity > 0 {
            return "In Stock (\(inventoryQuantity))"
        } else if allowBackorder {
            return "Available (Backorder)"
        } else {
            return "Out of Stock"
        }
    }
    
    var stockStatusColor: Color {
        if !manageInventory || inventoryQuantity > 0 {
            return .green
        } else if allowBackorder {
            return .orange
        } else {
            return .red
        }
    }
}

extension ProductImage {
    var displayUrl: String {
        return url
    }
}

extension ProductCategory {
    var isTopLevel: Bool {
        return parentCategoryId == nil
    }
    
    var hasChildren: Bool {
        return categoryChildren?.isEmpty == false
    }
}