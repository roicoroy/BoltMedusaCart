//
//  Address.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation

// MARK: - Address Models (Updated for Medusa Store API v2)
struct Address: Codable, Identifiable {
    let id: String
    let addressName: String?
    let isDefaultShipping: Bool
    let isDefaultBilling: Bool
    let customerId: String?
    let company: String?
    let firstName: String?
    let lastName: String?
    let address1: String
    let address2: String?
    let city: String
    let countryCode: String
    let province: String?
    let postalCode: String
    let phone: String?
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, company, city, phone, metadata
        case addressName = "address_name"
        case isDefaultShipping = "is_default_shipping"
        case isDefaultBilling = "is_default_billing"
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        addressName = try container.decodeIfPresent(String.self, forKey: .addressName)
        isDefaultShipping = try container.decodeIfPresent(Bool.self, forKey: .isDefaultShipping) ?? false
        isDefaultBilling = try container.decodeIfPresent(Bool.self, forKey: .isDefaultBilling) ?? false
        customerId = try container.decodeIfPresent(String.self, forKey: .customerId)
        company = try container.decodeIfPresent(String.self, forKey: .company)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        address1 = try container.decode(String.self, forKey: .address1)
        address2 = try container.decodeIfPresent(String.self, forKey: .address2)
        city = try container.decode(String.self, forKey: .city)
        countryCode = try container.decode(String.self, forKey: .countryCode)
        province = try container.decodeIfPresent(String.self, forKey: .province)
        postalCode = try container.decode(String.self, forKey: .postalCode)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
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
        try container.encodeIfPresent(addressName, forKey: .addressName)
        try container.encode(isDefaultShipping, forKey: .isDefaultShipping)
        try container.encode(isDefaultBilling, forKey: .isDefaultBilling)
        try container.encodeIfPresent(customerId, forKey: .customerId)
        try container.encodeIfPresent(company, forKey: .company)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encode(address1, forKey: .address1)
        try container.encodeIfPresent(address2, forKey: .address2)
        try container.encode(city, forKey: .city)
        try container.encode(countryCode, forKey: .countryCode)
        try container.encodeIfPresent(province, forKey: .province)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encodeIfPresent(phone, forKey: .phone)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
        
        // Handle metadata encoding
        if let metadata = metadata {
            let encodableMetadata = metadata.mapValues { AnyCodable($0) }
            try container.encode(encodableMetadata, forKey: .metadata)
        }
    }
}

// MARK: - Address Request Models
struct AddressCreateRequest: Codable {
    let addressName: String?
    let isDefaultShipping: Bool?
    let isDefaultBilling: Bool?
    let company: String?
    let firstName: String?
    let lastName: String?
    let address1: String
    let address2: String?
    let city: String
    let countryCode: String
    let province: String?
    let postalCode: String
    let phone: String?
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case company, city, phone, province, metadata
        case addressName = "address_name"
        case isDefaultShipping = "is_default_shipping"
        case isDefaultBilling = "is_default_billing"
        case firstName = "first_name"
        case lastName = "last_name"
        case address1 = "address_1"
        case address2 = "address_2"
        case countryCode = "country_code"
        case postalCode = "postal_code"
    }
    
    init(addressName: String? = nil, isDefaultShipping: Bool? = nil, isDefaultBilling: Bool? = nil, company: String? = nil, firstName: String? = nil, lastName: String? = nil, address1: String, address2: String? = nil, city: String, countryCode: String, province: String? = nil, postalCode: String, phone: String? = nil, metadata: [String: Any]? = nil) {
        self.addressName = addressName
        self.isDefaultShipping = isDefaultShipping
        self.isDefaultBilling = isDefaultBilling
        self.company = company
        self.firstName = firstName
        self.lastName = lastName
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.countryCode = countryCode
        self.province = province
        self.postalCode = postalCode
        self.phone = phone
        self.metadata = metadata
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(addressName, forKey: .addressName)
        try container.encodeIfPresent(isDefaultShipping, forKey: .isDefaultShipping)
        try container.encodeIfPresent(isDefaultBilling, forKey: .isDefaultBilling)
        try container.encodeIfPresent(company, forKey: .company)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encode(address1, forKey: .address1)
        try container.encodeIfPresent(address2, forKey: .address2)
        try container.encode(city, forKey: .city)
        try container.encode(countryCode, forKey: .countryCode)
        try container.encodeIfPresent(province, forKey: .province)
        try container.encode(postalCode, forKey: .postalCode)
        try container.encodeIfPresent(phone, forKey: .phone)
        
        // Handle metadata encoding
        if let metadata = metadata {
            let encodableMetadata = metadata.mapValues { AnyCodable($0) }
            try container.encode(encodableMetadata, forKey: .metadata)
        }
    }
}

struct AddressUpdateRequest: Codable {
    let addressName: String?
    let isDefaultShipping: Bool?
    let isDefaultBilling: Bool?
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
    let metadata: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case company, city, phone, province, metadata
        case addressName = "address_name"
        case isDefaultShipping = "is_default_shipping"
        case isDefaultBilling = "is_default_billing"
        case firstName = "first_name"
        case lastName = "last_name"
        case address1 = "address_1"
        case address2 = "address_2"
        case countryCode = "country_code"
        case postalCode = "postal_code"
    }
    
    init(addressName: String? = nil, isDefaultShipping: Bool? = nil, isDefaultBilling: Bool? = nil, company: String? = nil, firstName: String? = nil, lastName: String? = nil, address1: String? = nil, address2: String? = nil, city: String? = nil, countryCode: String? = nil, province: String? = nil, postalCode: String? = nil, phone: String? = nil, metadata: [String: Any]? = nil) {
        self.addressName = addressName
        self.isDefaultShipping = isDefaultShipping
        self.isDefaultBilling = isDefaultBilling
        self.company = company
        self.firstName = firstName
        self.lastName = lastName
        self.address1 = address1
        self.address2 = address2
        self.city = city
        self.countryCode = countryCode
        self.province = province
        self.postalCode = postalCode
        self.phone = phone
        self.metadata = metadata
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(addressName, forKey: .addressName)
        try container.encodeIfPresent(isDefaultShipping, forKey: .isDefaultShipping)
        try container.encodeIfPresent(isDefaultBilling, forKey: .isDefaultBilling)
        try container.encodeIfPresent(company, forKey: .company)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(address1, forKey: .address1)
        try container.encodeIfPresent(address2, forKey: .address2)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(countryCode, forKey: .countryCode)
        try container.encodeIfPresent(province, forKey: .province)
        try container.encodeIfPresent(postalCode, forKey: .postalCode)
        try container.encodeIfPresent(phone, forKey: .phone)
        
        // Handle metadata encoding
        if let metadata = metadata {
            let encodableMetadata = metadata.mapValues { AnyCodable($0) }
            try container.encode(encodableMetadata, forKey: .metadata)
        }
    }
}

// MARK: - API Response Models
struct AddressResponse: Codable {
    let address: Address
}

struct AddressesResponse: Codable {
    let addresses: [Address]
    let count: Int
    let offset: Int
    let limit: Int
}

// MARK: - Helper Extensions
extension Address {
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
    
    var displayName: String {
        if let addressName = addressName, !addressName.isEmpty {
            return addressName
        } else if !fullName.isEmpty {
            return fullName
        } else {
            return "Address"
        }
    }
    
    var isDefault: Bool {
        return isDefaultShipping || isDefaultBilling
    }
    
    var defaultStatus: String {
        if isDefaultShipping && isDefaultBilling {
            return "Default Shipping & Billing"
        } else if isDefaultShipping {
            return "Default Shipping"
        } else if isDefaultBilling {
            return "Default Billing"
        } else {
            return ""
        }
    }
    
    var countryFlag: String {
        let iso = countryCode.lowercased()
        
        switch iso {
        case "gb": return "🇬🇧"
        case "us": return "🇺🇸"
        case "ca": return "🇨🇦"
        case "de": return "🇩🇪"
        case "fr": return "🇫🇷"
        case "es": return "🇪🇸"
        case "it": return "🇮🇹"
        case "dk": return "🇩🇰"
        case "se": return "🇸🇪"
        case "au": return "🇦🇺"
        case "jp": return "🇯🇵"
        case "br": return "🇧🇷"
        default: return "🏳️"
        }
    }
    
    var isComplete: Bool {
        return !address1.isEmpty && !city.isEmpty && !countryCode.isEmpty && !postalCode.isEmpty
    }
    
    var hasContactInfo: Bool {
        return phone != nil || !fullName.isEmpty
    }
}