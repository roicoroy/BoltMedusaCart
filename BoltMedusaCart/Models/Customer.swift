//
//  Customer.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation

// MARK: - Customer Models (Updated for Medusa Store API v2)
struct Customer: Codable, Identifiable {
    let id: String
    let email: String
    let defaultBillingAddressId: String?
    let defaultShippingAddressId: String?
    let companyName: String?
    let firstName: String?
    let lastName: String?
    let billingAddressId: String?
    let phone: String?
    let hasAccount: Bool
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email, phone, metadata
        case defaultBillingAddressId = "default_billing_address_id"
        case defaultShippingAddressId = "default_shipping_address_id"
        case companyName = "company_name"
        case firstName = "first_name"
        case lastName = "last_name"
        case billingAddressId = "billing_address_id"
        case hasAccount = "has_account"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        defaultBillingAddressId = try container.decodeIfPresent(String.self, forKey: .defaultBillingAddressId)
        defaultShippingAddressId = try container.decodeIfPresent(String.self, forKey: .defaultShippingAddressId)
        companyName = try container.decodeIfPresent(String.self, forKey: .companyName)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        billingAddressId = try container.decodeIfPresent(String.self, forKey: .billingAddressId)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        hasAccount = try container.decodeIfPresent(Bool.self, forKey: .hasAccount) ?? false
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
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(defaultBillingAddressId, forKey: .defaultBillingAddressId)
        try container.encodeIfPresent(defaultShippingAddressId, forKey: .defaultShippingAddressId)
        try container.encodeIfPresent(companyName, forKey: .companyName)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(billingAddressId, forKey: .billingAddressId)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encode(hasAccount, forKey: .hasAccount)
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

// MARK: - Authentication Models
struct AuthRegisterRequest: Codable {
    let email: String
    let password: String
    let firstName: String?
    let lastName: String?
    let phone: String?
    
    enum CodingKeys: String, CodingKey {
        case email, password, phone
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

struct AuthLoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let customer: Customer
    let token: String?
}

// MARK: - Customer Management Models
struct CustomerCreateRequest: Codable {
    let email: String
    let firstName: String?
    let lastName: String?
    let phone: String?
    let companyName: String?
    
    enum CodingKeys: String, CodingKey {
        case email, phone
        case firstName = "first_name"
        case lastName = "last_name"
        case companyName = "company_name"
    }
}

struct CustomerUpdateRequest: Codable {
    let email: String?
    let firstName: String?
    let lastName: String?
    let phone: String?
    let companyName: String?
    let billingAddressId: String?
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case email, phone, metadata
        case firstName = "first_name"
        case lastName = "last_name"
        case companyName = "company_name"
        case billingAddressId = "billing_address_id"
    }
    
    init(email: String? = nil, firstName: String? = nil, lastName: String? = nil, phone: String? = nil, companyName: String? = nil, billingAddressId: String? = nil, metadata: [String: Any]? = nil) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.companyName = companyName
        self.billingAddressId = billingAddressId
        self.metadata = metadata
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encodeIfPresent(companyName, forKey: .companyName)
        try container.encodeIfPresent(billingAddressId, forKey: .billingAddressId)
        
        // Handle metadata encoding
        if let metadata = metadata {
            let encodableMetadata = metadata.mapValues { AnyCodable($0) }
            try container.encode(encodableMetadata, forKey: .metadata)
        }
    }
}

// MARK: - API Response Models
struct CustomerResponse: Codable {
    let customer: Customer
}

struct CustomersResponse: Codable {
    let customers: [Customer]
    let count: Int
    let offset: Int
    let limit: Int
}

// MARK: - Helper Extensions
extension Customer {
    var fullName: String {
        let components = [firstName, lastName].compactMap { $0 }
        return components.isEmpty ? email : components.joined(separator: " ")
    }
    
    var displayName: String {
        if let firstName = firstName, !firstName.isEmpty {
            if let lastName = lastName, !lastName.isEmpty {
                return "\(firstName) \(lastName)"
            }
            return firstName
        }
        return email
    }
    
    var initials: String {
        let components = [firstName, lastName].compactMap { $0?.first }
        if components.count >= 2 {
            return String(components.prefix(2))
        } else if let first = components.first {
            return String(first)
        } else {
            return String(email.prefix(1).uppercased())
        }
    }
    
    var hasDefaultAddresses: Bool {
        return defaultBillingAddressId != nil || defaultShippingAddressId != nil
    }
    
    var accountStatus: String {
        return hasAccount ? "Registered Account" : "Guest Customer"
    }
    
    var isGuest: Bool {
        return !hasAccount
    }
    
    var isRegistered: Bool {
        return hasAccount
    }
}