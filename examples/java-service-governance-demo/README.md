# Java Service Governance Demo

This demo shows a Java/Spring-style backend task where only the service layer is
allowed to change.

The task allows:

- `src/main/java/com/example/order/OrderService.java`

The task forbids:

- `pom.xml`
- `src/main/resources/application.yml`
- `src/main/java/com/example/order/OrderController.java`

Run from the repository root:

```bash
bash examples/java-service-governance-demo/run-demo.sh
```

The demo copies a fixture into a temporary Git repo, wires in the existing kit
scripts, applies an allowed service edit, applies an unauthorized runtime
configuration edit, and verifies guard, risk report, and closeout evidence.

No Maven, Gradle, Java compiler, network access, or core script semantic change
is required.
