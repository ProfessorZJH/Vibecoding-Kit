# API Style

API workflow:

1. Write or update `docs/API_SPEC.md`.
2. Implement Controller / route / handler to match the contract.
3. Add Swagger/OpenAPI annotations or equivalent generated documentation.
4. Export OpenAPI when supported.
5. Compare OpenAPI output against `API_SPEC.md`.

Do not treat generated Swagger/OpenAPI as the original requirement.
