---
name: golden-rule
description: Use ONLY when creating or editing Nix module options — enforces that every mkOption has NO default attribute and all values are computed dynamically via mkDefault in the config block.
---

# Golden Rule — Zero Defaults

## Mandate

Every `mkOption` MUST have **NO `default` attribute**. Zero. Nada. Hardcoded defaults in option definitions are forbidden.

The ONLY way to provide a default value is via `mkDefault` in the module config block, calculated from system state, hardware detection, or other configuration context.

## Forbidden patterns

```nix
# BAD — default inside mkOption
options.foo = mkOption {
  type = types.str;
  default = "bar";
};

# BAD — mkEnableOption
options.bar = mkEnableOption "something";
```

## Correct patterns

```nix
# GOOD — no default in option
options.foo = mkOption {
  type = types.str;
};

# In config block:
config.foo = mkDefault (some calculation);

# GOOD — enable flag
options.enable = mkOption { type = types.bool; };
```

## mkEnableOption is forbidden

`mkEnableOption` injects `default = false` silently. Always use:

```nix
options.enable = mkOption { type = types.bool; description = "Enable foo"; };
```

## Validation checklist

1. Every mkOption has NO `default =` attribute
2. Every enable flag uses `mkOption { type = types.bool; }`, not `mkEnableOption`
3. Every default value is wrapped in `mkDefault` in the config block
4. Profiles and hosts may set `mkDefault` values as overrides
5. The option definition itself never contains a literal fallback
