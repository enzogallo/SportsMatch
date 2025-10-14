//
//  LoggingService.swift
//  SportsMatch
//
//  Created by Enzo Gallo on 14/10/2025.
//

import Foundation
import os.log

class LoggingService {
    static let shared = LoggingService()
    
    private let logger = Logger(subsystem: "com.sportsmatch.app", category: "API")
    
    private init() {}
    
    // MARK: - API Error Logging
    
    func logAPIError(
        endpoint: String,
        method: String,
        statusCode: Int?,
        error: Error,
        requestData: Data? = nil,
        responseData: Data? = nil,
        additionalInfo: [String: Any] = [:]
    ) {
        var logMessage = """
        🚨 API ERROR
        Endpoint: \(method) \(endpoint)
        Status Code: \(statusCode?.description ?? "Unknown")
        Error: \(error.localizedDescription)
        """
        
        if let statusCode = statusCode {
            logMessage += "\nStatus Code Details: \(getStatusCodeDescription(statusCode))"
        }
        
        if let requestData = requestData {
            logMessage += "\nRequest Data: \(String(data: requestData, encoding: .utf8) ?? "Unable to decode")"
        }
        
        if let responseData = responseData {
            logMessage += "\nResponse Data: \(String(data: responseData, encoding: .utf8) ?? "Unable to decode")"
        }
        
        if !additionalInfo.isEmpty {
            logMessage += "\nAdditional Info: \(additionalInfo)"
        }
        
        logger.error("\(logMessage)")
        print("🔴 \(logMessage)")
    }
    
    func logAPIRequest(
        endpoint: String,
        method: String,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) {
        var logMessage = """
        📤 API REQUEST
        \(method) \(endpoint)
        """
        
        if let headers = headers {
            logMessage += "\nHeaders: \(headers)"
        }
        
        if let body = body {
            logMessage += "\nBody: \(String(data: body, encoding: .utf8) ?? "Unable to decode")"
        }
        
        logger.info("\(logMessage)")
        print("🔵 \(logMessage)")
    }
    
    func logAPIResponse(
        endpoint: String,
        method: String,
        statusCode: Int,
        responseData: Data? = nil,
        duration: TimeInterval? = nil
    ) {
        var logMessage = """
        📥 API RESPONSE
        \(method) \(endpoint)
        Status: \(statusCode) \(getStatusCodeDescription(statusCode))
        """
        
        if let duration = duration {
            logMessage += "\nDuration: \(String(format: "%.2f", duration))s"
        }
        
        if let responseData = responseData {
            logMessage += "\nResponse: \(String(data: responseData, encoding: .utf8) ?? "Unable to decode")"
        }
        
        if statusCode >= 200 && statusCode < 300 {
            logger.info("\(logMessage)")
            print("🟢 \(logMessage)")
        } else {
            logger.warning("\(logMessage)")
            print("🟡 \(logMessage)")
        }
    }
    
    // MARK: - Authentication Logging
    
    func logAuthEvent(
        event: String,
        userId: UUID? = nil,
        success: Bool,
        error: Error? = nil
    ) {
        var logMessage = """
        🔐 AUTH EVENT
        Event: \(event)
        User ID: \(userId?.uuidString ?? "Unknown")
        Success: \(success)
        """
        
        if let error = error {
            logMessage += "\nError: \(error.localizedDescription)"
        }
        
        if success {
            logger.info("\(logMessage)")
            print("🟢 \(logMessage)")
        } else {
            logger.error("\(logMessage)")
            print("🔴 \(logMessage)")
        }
    }
    
    // MARK: - Database Logging
    
    func logDatabaseError(
        operation: String,
        table: String,
        error: Error,
        query: String? = nil
    ) {
        var logMessage = """
        🗄️ DATABASE ERROR
        Operation: \(operation)
        Table: \(table)
        Error: \(error.localizedDescription)
        """
        
        if let query = query {
            logMessage += "\nQuery: \(query)"
        }
        
        logger.error("\(logMessage)")
        print("🔴 \(logMessage)")
    }
    
    // MARK: - Helper Methods
    
    private func getStatusCodeDescription(_ statusCode: Int) -> String {
        switch statusCode {
        case 200: return "OK"
        case 201: return "Created"
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 403: return "Forbidden"
        case 404: return "Not Found"
        case 409: return "Conflict"
        case 422: return "Unprocessable Entity"
        case 429: return "Too Many Requests"
        case 500: return "Internal Server Error"
        case 502: return "Bad Gateway"
        case 503: return "Service Unavailable"
        case 504: return "Gateway Timeout"
        default: return "Unknown"
        }
    }
    
    // MARK: - Debug Information
    
    func logDebugInfo(
        context: String,
        info: [String: Any]
    ) {
        let logMessage = """
        🐛 DEBUG INFO
        Context: \(context)
        Info: \(info)
        """
        
        logger.debug("\(logMessage)")
        print("🔵 \(logMessage)")
    }
}
