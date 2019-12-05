package helm_test

import (
	"path/filepath"
	"testing"

	. "github.com/smartystreets/goconvey/convey"
	"github.com/stretchr/testify/require"

	monitoringv1 "github.com/coreos/prometheus-operator/pkg/apis/monitoring/v1"
	certmanagerv1alpha2 "github.com/jetstack/cert-manager/pkg/apis/certmanager/v1alpha2"
	appsv1 "k8s.io/api/apps/v1"
	v1 "k8s.io/api/core/v1"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
)

func TestApplicationControllerImageOverrides(t *testing.T) {
	t.Parallel()
	helmChartPath, err := filepath.Abs("../")
	releaseName := "argo-cd"
	require.NoError(t, err)

	options := &helm.Options{
		SetValues: map[string]string{
			"controller.image.repository": "custom/argocd",
			"controller.image.tag":        "1.2.3",
		},
		KubectlOptions: k8s.NewKubectlOptions("", "", "default"),
	}
	output := helm.RenderTemplate(t, options, helmChartPath, releaseName, []string{"templates/argocd-application-controller/deployment.yaml"})
	var deployment appsv1.Deployment
	helm.UnmarshalK8SYaml(t, output, &deployment)

	expectedContainerImage := "custom/argocd:1.2.3"
	deploymentContainers := deployment.Spec.Template.Spec.Containers
	require.Equal(t, len(deploymentContainers), 1)
	require.Equal(t, deploymentContainers[0].Image, expectedContainerImage)
}

// https://github.com/argoproj/argo-helm/pull/171
func TestApplicationCertConfig(t *testing.T) {
	t.Parallel()
	helmChartPath, err := filepath.Abs("../")
	releaseName := "argo-cd"
	require.NoError(t, err)

	options := &helm.Options{
		SetValues: map[string]string{
			"server.certificate.enabled":     "true",
			"server.certificate.issuer.kind": "certKind",
			"server.certificate.issuer.name": "certName",
		},
		KubectlOptions: k8s.NewKubectlOptions("", "", "default"),
	}
	output := helm.RenderTemplate(t, options, helmChartPath, releaseName, []string{"templates/argocd-server/certificate.yaml"})
	var certificate certmanagerv1alpha2.Certificate
	helm.UnmarshalK8SYaml(t, output, &certificate)

	// Finally, we verify the deployment pod template spec is set to the expected container image value
	// expectedContainerImage := "custom/argocd:1.2.3"
	// deploymentContainers := deployment.Spec.Template.Spec.Containers
	require.Equal(t, certificate.Spec.IssuerRef.Kind, "certKind")
	require.Equal(t, certificate.Spec.IssuerRef.Name, "certName")
	// require.Equal(t, deploymentContainers[0].Image, expectedContainerImage)
}

func TestArgoCDConfigsSecret(t *testing.T) {
	t.Parallel()
	helmChartPath, err := filepath.Abs("../")
	releaseName := "argo-cd"
	require.NoError(t, err)

	options := &helm.Options{
		SetValues: map[string]string{
			"configs.secret.argocdServerTlsConfig.key": "testKey",
			"configs.secret.argocdServerTlsConfig.crt": "testCrt",
			"configs.secret.argocdServerAdminPassword": "testPassword",
			"configs.secret.githubSecret":              "githubTest",
			"configs.secret.gitlabSecret":              "gitlabTest",
			"configs.secret.bitbucketServerSecret":     "bitbucketServerTest",
			"configs.secret.bitbucketUUID":             "bitbucketUUIDTest",
			"configs.secret.gogsSecret":                "gogsTest",
		},
		KubectlOptions: k8s.NewKubectlOptions("", "", "default"),
	}
	output := helm.RenderTemplate(t, options, helmChartPath, releaseName, []string{"templates/argocd-configs/argocd-secret.yaml"})
	var secret v1.Secret
	helm.UnmarshalK8SYaml(t, output, &secret)
	require.Equal(t, "testKey", string(secret.Data["tls.key"]))
	require.Equal(t, "testCrt", string(secret.Data["tls.crt"]))
	require.Equal(t, "testPassword", string(secret.Data["admin.password"]))
	require.Equal(t, "githubTest", string(secret.Data["webhook.github.secret"]))
	require.Equal(t, "gitlabTest", string(secret.Data["webhook.gitlab.secret"]))
	require.Equal(t, "bitbucketServerTest", string(secret.Data["webhook.bitbucketserver.secret"]))
	require.Equal(t, "bitbucketUUIDTest", string(secret.Data["webhook.bitbucket.uuid"]))
	require.Equal(t, "gogsTest", string(secret.Data["webhook.gogs.secret"]))
}

// https://github.com/argoproj/argo-helm/pull/180
func TestArgoCDControllerServiceMonitors(t *testing.T) {
	t.Parallel()
	helmChartPath, err := filepath.Abs("../")
	releaseName := "argo-cd"
	require.NoError(t, err)

	tests := []struct {
		Name           string
		DeploymentYAML []string
		SetValues      map[string]string
	}{
		{
			Name:           "Given application controller servicemonitor is enabled",
			DeploymentYAML: []string{"templates/argocd-application-controller/servicemonitor.yaml"},
			SetValues: map[string]string{
				"controller.metrics.enabled":                "true",
				"controller.metrics.serviceMonitor.enabled": "true",
			},
		},
		{
			Name:           "Given server servicemonitor is enabled",
			DeploymentYAML: []string{"templates/argocd-server/servicemonitor.yaml"},
			SetValues: map[string]string{
				"server.metrics.enabled":                "true",
				"server.metrics.serviceMonitor.enabled": "true",
			},
		},
		{
			Name:           "Given reposerver servicemonitor is enabled",
			DeploymentYAML: []string{"templates/argocd-repo-server/servicemonitor.yaml"},
			SetValues: map[string]string{
				"repoServer.metrics.enabled":                "true",
				"repoServer.metrics.serviceMonitor.enabled": "true",
			},
		},
	}

	var servicemonitor monitoringv1.ServiceMonitor

	for _, test := range tests {
		options := &helm.Options{
			SetValues:      test.SetValues,
			KubectlOptions: k8s.NewKubectlOptions("", "", "default"),
		}
		Convey(test.Name, t, func() {
			output := helm.RenderTemplate(t, options, helmChartPath, releaseName, test.DeploymentYAML)
			helm.UnmarshalK8SYaml(t, output, &servicemonitor)
			endpoints := servicemonitor.Spec.Endpoints
			So(len(endpoints), ShouldEqual, 1)
			So(endpoints[0].Path, ShouldEqual, "/metrics")
		})
	}
}

// https://github.com/argoproj/argo-helm/pull/181
func TestArgoCDEnvironmentConfig(t *testing.T) {
	t.Parallel()
	helmChartPath, err := filepath.Abs("../")
	releaseName := "argo-cd"
	require.NoError(t, err)

	tests := []struct {
		Name           string
		DeploymentYAML []string
		SetValues      map[string]string
	}{
		{
			Name:           "Given an application controller environment variable",
			DeploymentYAML: []string{"templates/argocd-application-controller/deployment.yaml"},
			SetValues: map[string]string{
				"controller.env[0].name":  "TEST_ENV",
				"controller.env[0].value": "TEST_VALUE",
			},
		},
		{
			Name:           "Given a server environment variable",
			DeploymentYAML: []string{"templates/argocd-server/deployment.yaml"},
			SetValues: map[string]string{
				"server.env[0].name":  "TEST_ENV",
				"server.env[0].value": "TEST_VALUE",
			},
		},
		{
			Name:           "Given a repo-server environment variable",
			DeploymentYAML: []string{"templates/argocd-repo-server/deployment.yaml"},
			SetValues: map[string]string{
				"repoServer.env[0].name":  "TEST_ENV",
				"repoServer.env[0].value": "TEST_VALUE",
			},
		},
	}

	var deployment appsv1.Deployment

	for _, test := range tests {
		options := &helm.Options{
			SetValues:      test.SetValues,
			KubectlOptions: k8s.NewKubectlOptions("", "", "default"),
		}
		Convey(test.Name, t, func() {
			output := helm.RenderTemplate(t, options, helmChartPath, releaseName, test.DeploymentYAML)
			helm.UnmarshalK8SYaml(t, output, &deployment)
			deploymentContainers := deployment.Spec.Template.Spec.Containers
			So(len(deploymentContainers), ShouldEqual, 1)
			So(len(deploymentContainers[0].Env), ShouldEqual, 1)
			So(deploymentContainers[0].Env[0].Name, ShouldEqual, "TEST_ENV")
			So(deploymentContainers[0].Env[0].Value, ShouldEqual, "TEST_VALUE")
		})
	}
}

// https://github.com/argoproj/argo-helm/pull/177
func TestArgoCDRepoServerCustomTools(t *testing.T) {
	t.Parallel()
	helmChartPath, err := filepath.Abs("../")
	releaseName := "argo-cd"
	require.NoError(t, err)

	tests := []struct {
		Name           string
		DeploymentYAML []string
		SetValues      map[string]string
		SetStrValues   map[string]string
	}{
		{
			Name:           "Given a repo-server initContainer",
			DeploymentYAML: []string{"templates/argocd-repo-server/deployment.yaml"},
			SetValues: map[string]string{
				"repoServer.volumes[0].name":                             "custom-tools",
				"repoServer.initContainers[0].name":                      "download-tools",
				"repoServer.initContainers[0].image":                     "alpine:3.8",
				"repoServer.initContainers[0].volumeMounts[0].mountPath": "/usr/local/bin/helm",
				"repoServer.initContainers[0].volumeMounts[0].name":      "custom-tools",
				"repoServer.volumeMounts[0].name":                        "custom-tools",
				"repoServer.volumeMounts[0].mountPath":                   "/usr/local/bin/helm",
				"repoServer.volumeMounts[0].subPath":                     "helm",
			},
			SetStrValues: map[string]string{
				"repoServer.volumes[0].emptyDir": "{}",
			},
		},
	}

	var deployment appsv1.Deployment

	for _, test := range tests {
		options := &helm.Options{
			SetValues:      test.SetValues,
			KubectlOptions: k8s.NewKubectlOptions("", "", "default"),
		}
		Convey(test.Name, t, func() {
			output := helm.RenderTemplate(t, options, helmChartPath, releaseName, test.DeploymentYAML)
			helm.UnmarshalK8SYaml(t, output, &deployment)
			initContainers := deployment.Spec.Template.Spec.InitContainers

			So(len(deployment.Spec.Template.Spec.Volumes), ShouldEqual, 2)
			So(deployment.Spec.Template.Spec.Volumes[0].Name, ShouldEqual, "custom-tools")
			So(deployment.Spec.Template.Spec.Volumes[0].EmptyDir, ShouldEqual, nil)

			So(len(deployment.Spec.Template.Spec.Containers[0].VolumeMounts), ShouldEqual, 2)
			So(deployment.Spec.Template.Spec.Containers[0].VolumeMounts[0].Name, ShouldEqual, "custom-tools")
			So(deployment.Spec.Template.Spec.Containers[0].VolumeMounts[0].MountPath, ShouldEqual, "/usr/local/bin/helm")
			So(deployment.Spec.Template.Spec.Containers[0].VolumeMounts[0].SubPath, ShouldEqual, "helm")

			So(len(initContainers), ShouldEqual, 1)
			So(len(initContainers[0].VolumeMounts), ShouldEqual, 1)
			So(initContainers[0].Name, ShouldEqual, "download-tools")
			So(initContainers[0].Image, ShouldEqual, "alpine:3.8")
			So(initContainers[0].VolumeMounts[0].Name, ShouldEqual, "custom-tools")
			So(initContainers[0].VolumeMounts[0].MountPath, ShouldEqual, "/usr/local/bin/helm")
		})
	}
}

// https://github.com/argoproj/argo-helm/pull/178
func TestArgoCDControllerPrometheusRules(t *testing.T) {
	t.Parallel()
	helmChartPath, err := filepath.Abs("../")
	releaseName := "argo-cd"
	require.NoError(t, err)

	tests := []struct {
		Name           string
		DeploymentYAML []string
		SetValues      map[string]string
	}{
		{
			Name:           "Given application controller rules are enabled",
			DeploymentYAML: []string{"templates/argocd-application-controller/prometheusrule.yaml"},
			SetValues: map[string]string{
				"controller.metrics.enabled":                               "true",
				"controller.metrics.rules.enabled":                         "true",
				"controller.metrics.rules.spec[0].alert":                   "TestAlert",
				"controller.metrics.rules.spec[0].expr":                    "absent(argocd_app_info)",
				"controller.metrics.rules.spec[0].for":                     "15m",
				"controller.metrics.rules.spec[0].labels.severity":         "critical",
				"controller.metrics.rules.spec[0].annotations.summary":     "Test summary",
				"controller.metrics.rules.spec[0].annotations.description": "Test description",
			},
		},
	}

	var servicemonitor monitoringv1.PrometheusRule

	for _, test := range tests {
		options := &helm.Options{
			SetValues:      test.SetValues,
			KubectlOptions: k8s.NewKubectlOptions("", "", "default"),
		}
		Convey(test.Name, t, func() {
			output := helm.RenderTemplate(t, options, helmChartPath, releaseName, test.DeploymentYAML)
			helm.UnmarshalK8SYaml(t, output, &servicemonitor)

			So(len(servicemonitor.Spec.Groups), ShouldEqual, 1)
			rules := servicemonitor.Spec.Groups[0].Rules
			So(len(rules), ShouldEqual, 1)
			So(rules[0].Alert, ShouldEqual, "TestAlert")
			// Requires StrVal as Expr is type IntOrStr
			So(rules[0].Expr.StrVal, ShouldEqual, "absent(argocd_app_info)")
			So(rules[0].For, ShouldEqual, "15m")
			So(rules[0].Labels["severity"], ShouldEqual, "critical")
			So(rules[0].Annotations["summary"], ShouldEqual, "Test summary")
			So(rules[0].Annotations["description"], ShouldEqual, "Test description")
		})
	}
}

// https://github.com/argoproj/argo-helm/pull/185
func TestArgoCDSecurityContext(t *testing.T) {
	t.Parallel()
	helmChartPath, err := filepath.Abs("../")
	releaseName := "argo-cd"
	require.NoError(t, err)

	tests := []struct {
		Name           string
		DeploymentYAML []string
		SetValues      map[string]string
		SetStrValues   map[string]string
	}{
		{
			Name:           "Given a global securityContext and an application controller deployment",
			DeploymentYAML: []string{"templates/argocd-application-controller/deployment.yaml"},
			SetValues: map[string]string{
				"global.securityContext.runAsUser": "999",
			},
		},
		{
			Name:           "Given a global securityContext and a reposerver deployment",
			DeploymentYAML: []string{"templates/argocd-repo-server/deployment.yaml"},
			SetValues: map[string]string{
				"global.securityContext.runAsUser": "999",
			},
		},
		{
			Name:           "Given a global securityContext and a server deployment",
			DeploymentYAML: []string{"templates/argocd-server/deployment.yaml"},
			SetValues: map[string]string{
				"global.securityContext.runAsUser": "999",
			},
		},
		{
			Name:           "Given a global securityContext and a redis deployment",
			DeploymentYAML: []string{"templates/redis/deployment.yaml"},
			SetValues: map[string]string{
				"global.securityContext.runAsUser": "999",
			},
		},
	}

	var deployment appsv1.Deployment

	for _, test := range tests {
		options := &helm.Options{
			SetValues:      test.SetValues,
			KubectlOptions: k8s.NewKubectlOptions("", "", "default"),
		}
		Convey(test.Name, t, func() {
			output := helm.RenderTemplate(t, options, helmChartPath, releaseName, test.DeploymentYAML)
			helm.UnmarshalK8SYaml(t, output, &deployment)

			So(*deployment.Spec.Template.Spec.SecurityContext.RunAsUser, ShouldEqual, 999)
		})
	}
}
