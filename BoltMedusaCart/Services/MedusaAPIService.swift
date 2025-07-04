//
//  MedusaAPIService.swift
//  BoltMedusaCart
//
//  Created by Ricardo Bento on 28/06/2025.
//

import Foundation
import Combine

class MedusaAPIService: ObservableObject {
    static let shared = MedusaAPIService()
    
    private let baseURL: String
    private let publishableApiKey: String
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(baseURL: String = "https://1839-2a00-23c7-dc88-f401-c478-f6a-492c-22da.ngrok-free.app", publishableApiKey: String = "pk_d62e2de8f849db562e79a89c8a08ec4f5d23f1a958a344d5f64dfc38ad39fa1a") {
        self.baseURL = baseURL
        self.publishableApiKey = publishableApiKey
    }
    
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
        case PATCH = "PATCH"
    }
    
    enum APIError: Error, LocalizedError {
        case invalidURL
        case noData
        case decodingError(Error)
        case networkError(Error)
        case serverError(Int, String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError(let error):
                return "Decoding error: \(error.localizedDescription)"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .serverError(let code, let message):
                return "Server error (\(code)): \(message)"
            }
        }
    }
    
    func request<T: Codable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        body: Codable? = nil,
        headers: [String: String] = [:]
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add Medusa publishable API key header
        request.setValue(publishableApiKey, forHTTPHeaderField: "x-publishable-api-key")
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body if provided
        if let body = body {
            do {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.decodingError(error)
            }
        }
        
        print("🌐 Making request to: \(url)")
        print("📋 Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(URLError(.badServerResponse))
            }
            
            print("📊 Response status: \(httpResponse.statusCode)")
            
            // Check for HTTP errors
            if httpResponse.statusCode >= 400 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ Server error: \(errorMessage)")
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📄 Raw response: \(responseString.prefix(500))...")
            }
            
            // Decode response
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                // Configure date decoding strategy to handle string dates
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    // Try different DateFormatter configurations
                    let dateFormatters: [DateFormatter] = [
                        // ISO 8601 with microseconds
                        {
                            let f = DateFormatter()
                            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
                            f.locale = Locale(identifier: "en_US_POSIX")
                            f.timeZone = TimeZone(secondsFromGMT: 0)
                            return f
                        }(),
                        // ISO 8601 with milliseconds
                        {
                            let f = DateFormatter()
                            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                            f.locale = Locale(identifier: "en_US_POSIX")
                            f.timeZone = TimeZone(secondsFromGMT: 0)
                            return f
                        }(),
                        // ISO 8601 standard
                        {
                            let f = DateFormatter()
                            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                            f.locale = Locale(identifier: "en_US_POSIX")
                            f.timeZone = TimeZone(secondsFromGMT: 0)
                            return f
                        }(),
                        // ISO 8601 with timezone offset
                        {
                            let f = DateFormatter()
                            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                            f.locale = Locale(identifier: "en_US_POSIX")
                            return f
                        }(),
                        // ISO 8601 with timezone offset and milliseconds
                        {
                            let f = DateFormatter()
                            f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                            f.locale = Locale(identifier: "en_US_POSIX")
                            return f
                        }()
                    ]
                    
                    // Try each formatter
                    for formatter in dateFormatters {
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    }
                    
                    // If all DateFormatters fail, try ISO8601DateFormatter as a last resort
                    let iso8601Formatter = ISO8601DateFormatter()
                    iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    if let date = iso8601Formatter.date(from: dateString) {
                        return date
                    }
                    
                    // Try ISO8601DateFormatter without fractional seconds
                    iso8601Formatter.formatOptions = [.withInternetDateTime]
                    if let date = iso8601Formatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                
                let result = try decoder.decode(T.self, from: data)
                print("✅ Successfully decoded response")
                return result
            } catch {
                print("❌ Decoding error: \(error)")
                print("📄 Response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                throw APIError.decodingError(error)
            }
        } catch {
            if error is APIError {
                throw error
            } else {
                print("❌ Network error: \(error)")
                throw APIError.networkError(error)
            }
        }
    }
    
    // MARK: - Configuration
    
    func updateConfiguration(baseURL: String? = nil, publishableApiKey: String? = nil) {
        // This would require reinitializing the service or making properties mutable
        // For now, configuration is set during initialization
    }
    
    // MARK: - Convenience Methods
    
    func get<T: Codable>(_ endpoint: String, headers: [String: String] = [:]) async throws -> T {
        return try await request(endpoint: endpoint, method: .GET, headers: headers)
    }
    
    func post<T: Codable>(_ endpoint: String, body: Codable? = nil, headers: [String: String] = [:]) async throws -> T {
        return try await request(endpoint: endpoint, method: .POST, body: body, headers: headers)
    }
    
    func put<T: Codable>(_ endpoint: String, body: Codable? = nil, headers: [String: String] = [:]) async throws -> T {
        return try await request(endpoint: endpoint, method: .PUT, body: body, headers: headers)
    }
    
    func delete<T: Codable>(_ endpoint: String, headers: [String: String] = [:]) async throws -> T {
        return try await request(endpoint: endpoint, method: .DELETE, headers: headers)
    }
    
    func patch<T: Codable>(_ endpoint: String, body: Codable? = nil, headers: [String: String] = [:]) async throws -> T {
        return try await request(endpoint: endpoint, method: .PATCH, body: body, headers: headers)
    }
}

// MARK: - Response Wrappers
struct MedusaResponse<T: Codable>: Codable {
    let data: T
}

struct MedusaListResponse<T: Codable>: Codable {
    let data: [T]
    let count: Int
    let offset: Int
    let limit: Int
}

struct MedusaErrorResponse: Codable {
    let message: String
    let type: String?
    let code: String?
}
