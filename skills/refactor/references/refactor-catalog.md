# Refactoring Catalog

Full reference for the refactor skill. Organized by code smell → recommended refactoring.

## Code Smells → Actions

### Long Function (> 30 lines)
1. **Extract Function**: Pull out coherent blocks into named functions
2. **Replace Temp with Query**: If temp variables are just caching a computation, extract to a function
3. **Decompose Conditional**: Extract complex if/else branches into named functions

### Duplicate Code
1. **Extract Function**: Pull shared logic into a common function
2. **Extract Superclass/Mixin**: If duplication spans classes, extract shared behavior
3. **Template Method**: If algorithms differ only in steps, use a template with overridable steps

### Long Parameter List (> 3-4 params)
1. **Introduce Parameter Object**: Group related params into a dataclass/struct
2. **Preserve Whole Object**: Pass the object instead of extracting fields from it
3. **Use Builder Pattern**: For complex construction with many optional params

### Feature Envy
A function uses more data from another class than from its own.
1. **Move Function**: Move the function to the class whose data it uses
2. **Extract + Move**: Extract the envious part, then move it

### Data Clumps
The same group of variables appears together in multiple places.
1. **Extract Class/Dataclass**: Create a class to hold the related data
2. **Introduce Parameter Object**: Replace the group with a single object

### Primitive Obsession
Using primitives (string, int) instead of small domain objects.
1. **Replace Primitive with Object**: `email: str` → `email: Email`
2. **Replace Type Code with Enum**: `status: int` → `status: Status`
3. **Extract Class**: When multiple primitives form a concept

### Switch Statements / Long Conditionals
1. **Replace with Polymorphism**: Each case becomes a subclass
2. **Replace with Strategy**: Inject the behavior as a dependency
3. **Replace with Lookup Table/Dict**: Map values to functions

### Divergent Change
One class is modified for many different reasons.
1. **Extract Class**: Split into focused classes, one reason to change each

### Shotgun Surgery
One change requires editing many different classes.
1. **Move Function/Field**: Consolidate the scattered logic into one place
2. **Inline Class**: If a class is too thin, merge it back

## Safe Refactoring Checklist

```
- [ ] Tests exist and pass before starting
- [ ] Each step is a single, reversible change
- [ ] Tests pass after every step
- [ ] No behavior change (same inputs → same outputs)
- [ ] Public API is unchanged (or migration path documented)
- [ ] Commit after each successful step
- [ ] Final review: is the code actually simpler?
```

## Anti-Patterns to Avoid

1. **Big Bang Refactor**: Rewriting everything at once. Always refactor incrementally.
2. **Speculative Generalization**: Making code "flexible" for future needs that may never come. Refactor to simplify, not to add abstraction.
3. **Refactor + Feature**: Mixing refactoring with new behavior. Separate commits, separate PRs if possible.
4. **Perfectionist Refactoring**: Refactoring code that's already clear enough. Focus on the code that's actually causing problems.
