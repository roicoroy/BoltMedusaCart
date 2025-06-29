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
                decoder.dateDecodingStrategy = .iso8601
                
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