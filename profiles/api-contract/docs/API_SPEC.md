# API Spec

API design is contract-first.

Swagger/OpenAPI is an implementation scan result, not the source of truth.

## Required Per API

Each API entry must record:

- name
- method
- path
- permission
- request fields
- response fields
- error codes
- business rules
- audit requirements

## Template

```md
## API Name

- method:
- path:
- permission:
- request:
- response:
- error_codes:
- business_rules:
- audit:
```
