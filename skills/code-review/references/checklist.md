# Code Review Checklist

Detailed reference for the code-review skill. Load this when you need deeper guidance on a specific category.

## Security Checklist

- [ ] **Injection**: All database queries use parameterized queries (no string concatenation)
- [ ] **Injection**: Shell commands do not include unsanitized user input
- [ ] **Injection**: HTML output is properly escaped (XSS prevention)
- [ ] **Auth**: Every endpoint has appropriate authentication checks
- [ ] **Auth**: Authorization verifies the user owns/can access the resource
- [ ] **Secrets**: No hardcoded API keys, passwords, or tokens
- [ ] **Secrets**: Sensitive data is not logged or included in error responses
- [ ] **Input**: All external input is validated (type, range, length)
- [ ] **Input**: File uploads validate type, size, and content
- [ ] **Crypto**: Using strong, current algorithms (not MD5, SHA1 for security)
- [ ] **Deps**: No known vulnerable dependencies (check CVE databases)

## Correctness Checklist

- [ ] **Null safety**: All nullable values are checked before use
- [ ] **Boundaries**: Off-by-one errors in loops, slices, and ranges
- [ ] **Types**: Type coercions are intentional (especially in JS/TS)
- [ ] **Async**: Promises/futures are awaited, not fire-and-forget
- [ ] **Concurrency**: Shared mutable state is properly synchronized
- [ ] **Error paths**: Exceptions are caught and handled meaningfully
- [ ] **Error paths**: Resources (files, connections) are cleaned up on error
- [ ] **Edge cases**: Empty collections, zero values, very large inputs
- [ ] **Unicode**: String operations handle multi-byte characters correctly

## Database Checklist

- [ ] **Migrations**: Schema changes are backward-compatible with running code
- [ ] **Migrations**: Rollback migration is tested and works
- [ ] **Queries**: JOINs have appropriate indexes
- [ ] **Queries**: WHERE clauses use indexed columns
- [ ] **Queries**: No SELECT * in production code
- [ ] **Transactions**: Multi-step operations use transactions
- [ ] **Soft deletes**: Queries filter by `deleted_at IS NULL` where applicable

## API Checklist

- [ ] **Versioning**: Breaking changes go in a new API version
- [ ] **Validation**: Request body/params are validated with clear error messages
- [ ] **Pagination**: List endpoints support pagination
- [ ] **Rate limiting**: Public endpoints have rate limits
- [ ] **Status codes**: Correct HTTP status codes (not everything is 200/500)
- [ ] **Documentation**: OpenAPI/Swagger is updated for changed endpoints

## Test Checklist

- [ ] **Coverage**: New code has corresponding tests
- [ ] **Happy path**: Core functionality is tested
- [ ] **Error path**: Error handling is tested
- [ ] **Edge cases**: Boundary values and empty inputs are tested
- [ ] **Mocking**: External dependencies are mocked, not called
- [ ] **Assertions**: Tests assert specific values, not just "no error"
