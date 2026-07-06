# T-010 Demo Plan

status: locked

## S-001 Update Service Validation

status: pending

allowed_changes:
- src/main/java/com/example/order/OrderService.java

forbidden_changes:
- pom.xml
- src/main/resources/application.yml
- src/main/java/com/example/order/OrderController.java

commands:
- bash scripts/plan-guard.sh T-010 S-001
- bash scripts/risk-report.sh T-010
- bash scripts/task-closeout.sh T-010 --no-tests --write-report

expected:
- PLAN_GUARD_PASS for service-only changes
- PLAN_GUARD_FAIL when runtime configuration drift is simulated
- RISK_REPORT_WRITTEN
- CLOSEOUT

commit:
- not required for demo
