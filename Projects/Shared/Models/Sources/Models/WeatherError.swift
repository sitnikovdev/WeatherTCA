//
//  WeatherError.swift
//  Models
//
//  Created by Oleg Sitnikov on 3/8/2026.
//  Copyright © 2026 WeatherTCA. All rights reserved.
//
import Foundation


public enum WeatherError: Error, Equatable, Sendable {
    case cityNotFound
    case invalidAPIKey
    case rateLimited
    case network
    case decodingFailed
    case unknown
}


extension WeatherError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cityNotFound: "Город не найден. Проверьте название."
        case .invalidAPIKey: "Неверный API-ключ."
        case .rateLimited: "Превышено количество запросов. Попробуйте позже."
        case .network: "Ошибка сети. Проверьте подключение к интернету."
        case .decodingFailed: "Ошибка декодирования. Попробуйте позже."
        case .unknown: "Что-то пошло не так. Попробуйте позже."
        }
    }
}

