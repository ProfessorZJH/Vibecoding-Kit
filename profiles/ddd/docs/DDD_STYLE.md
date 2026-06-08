# DDD Style

This profile uses the exact XFG scaffold baseline:

```txt
io.github.fuzhengwei:ddd-scaffold-lite-jdk17:1.7
```

The original archetype resources are copied into generated projects under:

```txt
docs/reference/xfg-ddd-scaffold-lite-jdk17
```

## Baseline Modules

- `api`
- `app`
- `domain`
- `trigger`
- `infrastructure`
- `types`

## Dependency Direction

- `domain` must not import `infrastructure` or `trigger`.
- `api` must not import implementation layers.
- `types` must not import business implementation layers.
- `trigger` controllers must not directly import DAO / Mapper.
- `domain` must not import MyBatis.

Prefer the original archetype structure over local inventions.
