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
    private let session = URLSession.shared
    private var cancellables = Set<AnyCancellable>()
    
    init(baseURL: String = "http://localhost:9000") {
        self.baseURL = baseURL
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
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(URLError(.badServerResponse))
            }
            
            // Check for HTTP errors
            if httpResponse.statusCode >= 400 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw APIError.serverError(httpResponse.statusCode, errorMessage)
            }
            
            // Decode response
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                // Configure date decoding strategy
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'"
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    // Try different date formats
                    let formatters = [
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
                        // ISO 8601 with timezone
                        {
                            let f = ISO8601DateFormatter()
                            f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                            return f
                        }() as DateFormatter
                    ]
                    
                    for formatter in formatters {
                        if let date = formatter.date(from: dateString) {
                            return date
                        }
                    }
                    
                    // If all formatters fail, try ISO8601DateFormatter directly
                    let iso8601Formatter = ISO8601DateFormatter()
                    iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    if let date = iso8601Formatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
                }
                
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "Unable to convert data to string")")
                throw APIError.decodingError(error)
            }
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError(error)
            }
        }
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