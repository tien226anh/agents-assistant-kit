# Defense in Depth

Adding validation at multiple layers to catch bugs and narrow down their location.

## The Principle

Don't rely on a single validation point. Add checks at every layer so bugs are caught as early as possible and their location is narrowed down.

## Layers of Defense

### Layer 1: Input Validation

Validate data at the boundary of your system:

```python
def create_order(customer_id: str, items: list[dict]) -> Order:
    # Input validation — catch problems at the door
    if not customer_id:
        raise ValueError("customer_id is required")
    if not items:
        raise ValueError("items list cannot be empty")
    for item in items:
        if "product_id" not in item:
            raise ValueError("each item must have a product_id")
```

### Layer 2: Intermediate Assertions

Add assertions at processing steps to catch data corruption:

```python
def process_order(order: Order) -> ProcessedOrder:
    # Intermediate assertion — catch corruption mid-flow
    assert order.customer_id is not None, "customer_id should be set by now"
    assert len(order.items) > 0, "order should have items at this point"

    result = apply_pricing(order)

    # Post-step assertion — verify the transformation was correct
    assert result.total > 0, "total must be positive after pricing"
    return result
```

### Layer 3: Output Verification

Verify the final output matches expectations:

```python
def finalize_order(processed: ProcessedOrder) -> Confirmation:
    confirmation = submit_to_payment(processed)

    # Output verification — ensure the result makes sense
    assert confirmation.order_id is not None
    assert confirmation.status in ("confirmed", "pending_payment")
    return confirmation
```

### Layer 4: Strategic Logging

Add logging at key decision points:

```python
import logging
logger = logging.getLogger(__name__)

def apply_discount(order: Order, discount_code: str) -> Order:
    logger.info(f"Applying discount code: {discount_code} to order: {order.id}")
    discount = lookup_discount(discount_code)
    if discount is None:
        logger.warning(f"Discount code not found: {discount_code}")
        return order
    logger.debug(f"Discount found: {discount.percentage}% off")
    order.apply_discount(discount)
    logger.info(f"Order total after discount: {order.total}")
    return order
```

## Patterns

### The Sandwich Pattern

Wrap any risky operation with pre and post checks:

```python
# Before: verify preconditions
assert data is not None, "data should exist before processing"

result = risky_operation(data)

# After: verify postconditions
assert result.status == "success", f"expected success, got {result.status}"
```

### The Canary Pattern

Add lightweight checks that fail fast when something is wrong:

```python
def canary_check():
    """Quick health check — if this fails, something is fundamentally wrong."""
    assert db.connection is not None, "Database connection lost"
    assert cache.is_responsive(), "Cache not responding"
    assert config.is_loaded(), "Configuration not loaded"
```

### The Tripwire Pattern

Add assertions that should never be reached — if they are, you've found a bug:

```python
def handle_event(event):
    if event.type == "created":
        return handle_created(event)
    elif event.type == "updated":
        return handle_updated(event)
    else:
        # Tripwire — this should never happen
        raise ValueError(f"Unexpected event type: {event.type}")
```

## When to Use Defense in Depth

- **Hard-to-reproduce bugs** — Add assertions at every layer to catch the bug when it happens
- **Complex data flows** — Add checkpoints to narrow down where data gets corrupted
- **Integration points** — Validate data at system boundaries
- **After fixing a bug** — Leave the assertions in place as regression protection