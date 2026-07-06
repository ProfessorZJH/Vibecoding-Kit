# T-010-demo: Update OrderService validation

## Goal

Update order ID validation in the service layer only.

## Background

This fixture models a small Java/Spring-style backend task. The task is scoped
to service validation logic. Dependency changes, runtime configuration changes,
and controller changes are outside the task boundary.

## Allowed Changes

- `src/main/java/com/example/order/OrderService.java`

## Forbidden Changes

- `pom.xml`
- `src/main/resources/application.yml`
- `src/main/java/com/example/order/OrderController.java`

## Required Work

- Add service-layer validation for blank or missing order IDs.
- Keep dependency and runtime configuration files unchanged.
- Keep controller behavior unchanged.
- Produce guard, risk report, and closeout evidence.

## Forbidden Actions

- Do not edit `pom.xml`.
- Do not edit `src/main/resources/application.yml`.
- Do not edit `src/main/java/com/example/order/OrderController.java`.
- Do not run Maven, Gradle, Java compilation, or network commands.

## Test Requirements

- `bash scripts/plan-guard.sh T-010 S-001`
- `bash scripts/risk-report.sh T-010`
- `bash scripts/task-closeout.sh T-010 --no-tests --write-report`

## Completion Criteria

- Service validation logic is updated.
- No dependency change is required.
- No runtime configuration change is required.
- Unauthorized runtime configuration drift is detected when simulated.
- Risk report evidence is created.
- Closeout report is created.

## Risk

medium
