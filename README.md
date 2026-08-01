# WeatherTCA

A modular iOS weather application built with **The Composable Architecture (TCA)** and **Tuist**, featuring a type-safe API client generated from an OpenAPI specification.

## About the Project

WeatherTCA is a weather app demonstrating a modular, testable architecture using Point-Free's Composable Architecture. The project is organized into independent Swift modules managed by Tuist, with API access handled through a client generated directly from an OpenAPI spec — ensuring the networking layer stays in sync with the API contract.

## Architecture

The project follows a modular structure, with each module owning a single responsibility:

```
Projects
├── App              — Application entry point, composes all features
├── Core             — Shared domain models
├── WeatherFeature   — TCA feature: state, actions, reducer, and view
└── OpenAPIClient    — Networking client generated from OpenAPI spec
```

**Module dependencies:**
```
App → WeatherFeature → OpenAPIClient
             ↓
           Core
```

- **Core** has no dependencies on other modules — it defines shared models (`WeatherModel`) used across the app.
- **OpenAPIClient** is generated from `openapi.yaml` and provides a type-safe interface to the weather API.
- **WeatherFeature** contains the TCA reducer (`WeatherFeature`), the SwiftUI view (`WeatherView`), and the client abstraction (`WeatherClient`) that
