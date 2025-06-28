//
//  Region.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation

// MARK: - Region Models (Updated for Medusa Store API v2)
struct Region: Codable, Identifiable {
    let id: String
    let name: String
    let currencyCode: String
    let automaticTaxes: Bool
    let giftCardsTaxable: Bool
    let taxInclusivePricing: Bool
    let taxRate: Double?
    let taxCode: String?
    let countries: [Country]?
    let paymentProviders: [PaymentProvider]?
    let fulfillmentProviders: [FulfillmentProvider]?
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, countries, metadata
        case currencyCode = "currency_code"
        case automaticTaxes = "automatic_taxes"
        case giftCardsTaxable = "gift_cards_taxable"
        case taxInclusivePricing = "tax_inclusive_pricing"
        case taxRate = "tax_rate"
        case taxCode = "tax_code"
        case paymentProviders = "payment_providers"
        case fulfillmentProviders = "fulfillment_providers"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        currencyCode = try container.decode(String.self, forKey: .currencyCode)
        automaticTaxes = try container.decodeIfPresent(Bool.self, forKey: .automaticTaxes) ?? false
        giftCardsTaxable = try container.decodeIfPresent(Bool.self, forKey: .giftCardsTaxable) ?? true
        taxInclusivePricing = try container.decodeIfPresent(Bool.self, forKey: .taxInclusivePricing) ?? false
        taxRate = try container.decodeIfPresent(Double.self, forKey: .taxRate)
        taxCode = try container.decodeIfPresent(String.self, forKey: .taxCode)
        countries = try container.decodeIfPresent([Country].self, forKey: .countries)
        paymentProviders = try container.decodeIfPresent([PaymentProvider].self, forKey: .paymentProviders)
        fulfillmentProviders = try container.decodeIfPresent([FulfillmentProvider].self, forKey: .fulfillmentProviders)
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
        try container.encode(name, forKey: .name)
        try container.encode(currencyCode, forKey: .currencyCode)
        try container.encode(automaticTaxes, forKey: .automaticTaxes)
        try container.encode(giftCardsTaxable, forKey: .giftCardsTaxable)
        try container.encode(taxInclusivePricing, forKey: .taxInclusivePricing)
        try container.encodeIfPresent(taxRate, forKey: .taxRate)
        try container.encodeIfPresent(taxCode, forKey: .taxCode)
        try container.encodeIfPresent(countries, forKey: .countries)
        try container.encodeIfPresent(paymentProviders, forKey: .paymentProviders)
        try container.encodeIfPresent(fulfillmentProviders, forKey: .fulfillmentProviders)
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

struct Country: Codable, Identifiable {
    let iso2: String
    let iso3: String
    let numCode: String
    let name: String
    let displayName: String
    let regionId: String?
    let metadata: [String: Any]?
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
    
    var id: String { iso2 }
    
    enum CodingKeys: String, CodingKey {
        case name, metadata
        case iso2 = "iso_2"
        case iso3 = "iso_3"
        case numCode = "num_code"
        case displayName = "display_name"
        case regionId = "region_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        iso2 = try container.decode(String.self, forKey: .iso2)
        iso3 = try container.decode(String.self, forKey: .iso3)
        numCode = try container.decode(String.self, forKey: .numCode)
        name = try container.decode(String.self, forKey: .name)
        displayName = try container.decode(String.self, forKey: .displayName)
        regionId = try container.decodeIfPresent(String.self, forKey: .regionId)
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
        
        try container.encode(iso2, forKey: .iso2)
        try container.encode(iso3, forKey: .iso3)
        try container.encode(numCode, forKey: .numCode)
        try container.encode(name, forKey: .name)
        try container.encode(displayName, forKey: .displayName)
        try container.encodeIfPresent(regionId, forKey: .regionId)
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

// MARK: - Country Selection Model (flattened from regions)
struct CountrySelection: Codable, Identifiable, Equatable {
    let country: String        // iso2 code (e.g., "gb", "fr")
    let label: String          // display name (e.g., "United Kingdom")
    let currencyCode: String   // currency (e.g., "eur")
    let regionId: String       // region ID for cart creation
    
    var id: String { country }
    
    static func == (lhs: CountrySelection, rhs: CountrySelection) -> Bool {
        return lhs.country == rhs.country &&
               lhs.regionId == rhs.regionId &&
               lhs.currencyCode == rhs.currencyCode
    }
    
    var flagEmoji: String {
        let iso = country.lowercased()
        
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
    
    var formattedCurrency: String {
        return currencyCode.uppercased()
    }
    
    var displayText: String {
        return "\(flagEmoji) \(label)"
    }
}

// MARK: - API Response Models
struct RegionsResponse: Codable {
    let regions: [Region]
    let count: Int
    let offset: Int
    let limit: Int
}

struct RegionResponse: Codable {
    let region: Region
}

// MARK: - Helper Extensions
extension Region {
    var displayName: String {
        return name
    }
    
    var formattedCurrency: String {
        return currencyCode.uppercased()
    }
    
    var hasUK: Bool {
        return countries?.contains { country in
            country.iso2.lowercased() == "gb" || 
            country.name.lowercased().contains("united kingdom") ||
            country.displayName.lowercased().contains("united kingdom")
        } ?? false
    }
    
    var flagEmoji: String {
        let regionName = name.lowercased()
        let currency = currencyCode.lowercased()
        
        if hasUK && currency == "eur" {
            return "🇪🇺"
        } else if regionName.contains("europe") || currency == "eur" {
            return "🇪🇺"
        } else if regionName.contains("united states") || regionName.contains("usa") || currency == "usd" {
            return "🇺🇸"
        } else if regionName.contains("canada") || currency == "cad" {
            return "🇨🇦"
        } else if regionName.contains("australia") || currency == "aud" {
            return "🇦🇺"
        } else if regionName.contains("japan") || currency == "jpy" {
            return "🇯🇵"
        } else if regionName.contains("brazil") || currency == "brl" {
            return "🇧🇷"
        } else {
            return "🌍"
        }
    }
    
    var countryNames: String {
        guard let countries = countries, !countries.isEmpty else {
            return "No countries"
        }
        
        if countries.count > 3 {
            let firstThree = countries.prefix(3).map { $0.displayName }
            return "\(firstThree.joined(separator: ", ")) and \(countries.count - 3) more"
        } else {
            return countries.map { $0.displayName }.joined(separator: ", ")
        }
    }
    
    var countryCount: Int {
        return countries?.count ?? 0
    }
    
    var ukCountry: Country? {
        return countries?.first { country in
            country.iso2.lowercased() == "gb"
        }
    }
    
    func toCountrySelections() -> [CountrySelection] {
        guard let countries = countries else { return [] }
        
        return countries.map { country in
            CountrySelection(
                country: country.iso2,
                label: country.displayName,
                currencyCode: currencyCode,
                regionId: id
            )
        }
    }
    
    var taxDisplayText: String {
        if automaticTaxes {
            if let taxRate = taxRate {
                return "Automatic taxes (\(String(format: "%.1f", taxRate * 100))%)"
            } else {
                return "Automatic taxes"
            }
        } else {
            return "Manual taxes"
        }
    }
    
    var pricingDisplayText: String {
        return taxInclusivePricing ? "Tax-inclusive pricing" : "Tax-exclusive pricing"
    }
}

extension Country {
    var flagEmoji: String {
        let iso = iso2.lowercased()
        
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
}