"""Check controller ServiceMonitor targets with local Helm rendering."""

from pathlib import Path
import subprocess
import sys

import yaml


chart = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).resolve().parent.parent
cases = {
    "default telemetry port": {},
    "custom telemetry port": {
        "controller.telemetryConfig.servicePortName": "http-telemetry",
    },
    "custom metrics and telemetry ports": {
        "controller.metricsConfig.enabled": "true",
        "controller.metricsConfig.servicePortName": "http-metrics",
        "controller.telemetryConfig.servicePortName": "http-telemetry",
    },
    "metrics port named telemetry": {
        "controller.metricsConfig.enabled": "true",
        "controller.metricsConfig.servicePortName": "telemetry",
        "controller.telemetryConfig.servicePortName": "http-telemetry",
    },
    "overridden workload and monitor namespaces": {
        "namespaceOverride": "workflow-system",
        "controller.serviceMonitor.namespace": "monitoring",
        "controller.telemetryConfig.servicePortName": "http-telemetry",
    },
}

for name, overrides in cases.items():
    command = [
        "helm", "template", "monitor-test", str(chart),
        "--namespace", "workflows",
        "--api-versions", "monitoring.coreos.com/v1",
        "--set", "controller.telemetryConfig.enabled=true",
        "--set", "controller.serviceMonitor.enabled=true",
    ]
    for key, value in overrides.items():
        command.extend(["--set", f"{key}={value}"])
    rendered = subprocess.run(command, check=True, stdout=subprocess.PIPE, text=True)
    objects = [obj for obj in yaml.safe_load_all(rendered.stdout) if obj]
    monitor, = [obj for obj in objects if obj["kind"] == "ServiceMonitor"]
    selector = monitor["spec"]["selector"]["matchLabels"]
    service, = [
        obj for obj in objects
        if obj["kind"] == "Service"
        and obj["metadata"]["namespace"] in monitor["spec"]["namespaceSelector"]["matchNames"]
        and all(obj["metadata"]["labels"].get(key) == value for key, value in selector.items())
    ]
    service_ports = [port["name"] for port in service["spec"]["ports"]]
    monitor_ports = [endpoint["port"] for endpoint in monitor["spec"]["endpoints"]]
    assert monitor_ports == service_ports, (
        f"{name}: ServiceMonitor ports {monitor_ports} do not match Service ports {service_ports}"
    )
    workload_namespace = overrides.get("namespaceOverride", "workflows")
    assert service["metadata"]["namespace"] == workload_namespace, name
    assert monitor["metadata"]["namespace"] == overrides.get(
        "controller.serviceMonitor.namespace", workload_namespace
    ), name
    print(f"PASS: {name}")
