# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-18

### Added
- Interface `SecurityService` com padrão `Result<T>` para tratamento de erros.
- Implementação `JWTSecurityService` com suporte a `Result<T>`.
- Função helper `generateTokens` retornando `Result<(String, String)>`.
- Middlewares `verificationJWT` e `authorization` com tratamento de tipos `Result`.
- Suporte completo para infraestrutura de servidor com Shelf, JWT, bcrypt e Drift.
- Integração com PostgreSQL via drift_postgres.
