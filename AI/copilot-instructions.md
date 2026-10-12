## Code Style

### Local variable ordering

Within a scope, declare variables initialized from self-contained literals/defaults **before**
variables whose values are derived from other sources (function/method calls, parameters, or other
variables). Group the independent defaults first, then the derived values.

Within the independent-defaults group (no inter-dependencies), order variables alphabetically by
name. Within the derived group, preserve data-flow order — a variable must follow anything it reads —
and order alphabetically only where no such dependency exists.

Ordering (any language):

    // good — defaults first (alphabetical), then derived (data-flow order)
    count   = 0
    items   = []
    total   = 0
    service = context.service
    data    = service.load()   // reads `service`, so must follow it

    // avoid — derived value interleaved above independent defaults
    service = context.service
    count   = 0
    data    = service.load()
    total   = 0
