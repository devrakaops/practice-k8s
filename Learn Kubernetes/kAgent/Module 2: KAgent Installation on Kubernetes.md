# Module 2: KAgent Installation on Kubernetes

---

# Learning Objectives

By the end of this module, you will be able to:

✅ Understand deployment architecture

✅ Understand installation prerequisites

✅ Deploy KAgent on Kubernetes

✅ Verify all KAgent components

✅ Understand every pod created

✅ Understand every service created

✅ Troubleshoot installation issues

✅ Prepare for Ollama/OpenAI integration in the next module

---

# Before We Start

Most people make a mistake here.

They immediately run:

```bash
helm install kagent
```

without understanding what gets installed.

As a Kubernetes Administrator, your first responsibility is:

```text
Understand Architecture
→ Then Install
→ Then Verify
```

Never install first and understand later.

---

# 1. What Are We Actually Installing?

When we deploy KAgent, we are not deploying a single pod.

We are deploying an AI platform inside Kubernetes.

High-level architecture:

```text
                     User
                       |
                       |
                       v

                KAgent UI
                       |
                       |
                       v

                KAgent Server
                       |
                       |
                       v

                   LLM
                       |
                       |
                       v

                Kubernetes API
```

Think of KAgent as a new application running inside your cluster.

---

# 2. Prerequisites

Before installation, verify:

---

## Kubernetes Version

Recommended:

```bash
kubectl version
```

Supported:

```text
Kubernetes 1.29+
Kubernetes 1.30+
Kubernetes 1.31+
Kubernetes 1.32+
```

---

## Helm

Verify:

```bash
helm version
```

Example:

```text
version.BuildInfo
```

If Helm is missing:

Ubuntu:

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

Verify again:

```bash
helm version
```

---

## kubectl Access

Verify:

```bash
kubectl get nodes
```

Expected:

```text
NAME        STATUS
worker01    Ready
worker02    Ready
```

If this fails:

```text
Do not proceed.
Fix cluster access first.
```

---

## StorageClass

Check:

```bash
kubectl get storageclass
```

Example:

```text
local-path
gp3
rook-ceph
```

Many KAgent components require persistent storage.

---

# 3. Lab Environment Recommendation

For learning:

## Option 1

Kind

```text
Laptop Friendly
```

---

## Option 2

K3s

```text
Lightweight
```

---

## Option 3

Minikube

```text
Good for beginners
```

---

## Option 4

Production-like Lab

```text
3 Node K3s Cluster
```

This is what I recommend.

---

# 4. Create Namespace

Always isolate platform components.

```bash
kubectl create namespace kagent
```

Verify:

```bash
kubectl get ns
```

Expected:

```text
kagent
```

---

# 5. Add KAgent Helm Repository

Add repository:

```bash
helm repo add kagent https://charts.kagent.dev
```

Update repository:

```bash
helm repo update
```

Verify:

```bash
helm search repo kagent
```

Expected:

```text
NAME
kagent/kagent
```

---

# Why Helm?

Without Helm:

You would need to manually create:

```text
Deployments
Services
RBAC
Secrets
ConfigMaps
Ingress
```

Helm packages everything together.

---

# 6. Inspect Chart Before Installing

Very important habit.

Never blindly install.

Check values:

```bash
helm show values kagent/kagent
```

You should inspect:

```text
Image Version
Storage
RBAC
Resources
LLM Configuration
```

This is exactly what platform teams do in production.

---

# 7. Basic Installation

Install KAgent:

```bash
helm install kagent \
kagent/kagent \
-n kagent
```

---

Verify release:

```bash
helm list -n kagent
```

Expected:

```text
NAME
kagent
```

---

# 8. What Gets Created?

Check:

```bash
kubectl get all -n kagent
```

You may see:

```text
Pods
Services
Deployments
ReplicaSets
```

---

Example:

```bash
kubectl get pods -n kagent
```

Expected:

```text
NAME                    STATUS
kagent-server           Running
kagent-ui               Running
```

Actual names may differ depending on chart version.

---

# 9. Verify Deployment

Check deployments:

```bash
kubectl get deploy -n kagent
```

Expected:

```text
READY
AVAILABLE
```

---

Describe deployment:

```bash
kubectl describe deploy <deployment-name> -n kagent
```

Check:

```text
Replicas
Events
Container Images
```

---

# 10. Verify Services

Check:

```bash
kubectl get svc -n kagent
```

Example:

```text
ClusterIP
NodePort
LoadBalancer
```

---

Describe service:

```bash
kubectl describe svc <service-name> -n kagent
```

Check:

```text
Endpoints
Selectors
Ports
```

---

# 11. Verify Pods

Check:

```bash
kubectl get pods -n kagent
```

---

Detailed:

```bash
kubectl describe pod <pod-name> -n kagent
```

Look for:

```text
Image
Volumes
Environment Variables
Events
```

---

# 12. Check Logs

Very important.

Always inspect logs after installation.

```bash
kubectl logs <pod-name> -n kagent
```

Example:

```bash
kubectl logs deployment/kagent-server -n kagent
```

Look for:

```text
Connected
Ready
Listening
```

Avoid:

```text
CrashLoopBackOff
Connection Refused
Authentication Failed
```

---

# 13. Verify RBAC

KAgent works through Kubernetes APIs.

Check ServiceAccounts:

```bash
kubectl get sa -n kagent
```

---

Check Roles:

```bash
kubectl get role -n kagent
```

---

Check ClusterRoles:

```bash
kubectl get clusterrole | grep kagent
```

---

Check Bindings:

```bash
kubectl get clusterrolebinding | grep kagent
```

---

As an Administrator, always verify:

```text
What permissions did I just give?
```

Never skip this step.

---

# 14. Verify API Access

Find ServiceAccount:

```bash
kubectl get sa -n kagent
```

Example:

```text
kagent-sa
```

Check permissions:

```bash
kubectl auth can-i \
list pods \
--as=system:serviceaccount:kagent:kagent-sa
```

Expected:

```text
yes
```

---

Check Nodes:

```bash
kubectl auth can-i \
list nodes \
--as=system:serviceaccount:kagent:kagent-sa
```

Expected:

```text
yes
```

or

```text
no
```

depending on chart configuration.

---

# 15. Accessing KAgent UI

Check services:

```bash
kubectl get svc -n kagent
```

---

If service type is ClusterIP:

Use port-forward:

```bash
kubectl port-forward svc/kagent-ui 8080:80 -n kagent
```

Access:

```text
http://localhost:8080
```

---

For production:

Use:

```text
Ingress
OpenShift Route
LoadBalancer
```

Never use port-forward in production.

---

# 16. Troubleshooting Installation

---

## Problem 1

Pod Pending

Check:

```bash
kubectl describe pod <pod-name>
```

Common cause:

```text
No Resources
No Storage
```

---

## Problem 2

ImagePullBackOff

Check:

```bash
kubectl describe pod
```

Look for:

```text
Image Pull Error
```

---

## Problem 3

CrashLoopBackOff

Check:

```bash
kubectl logs <pod>
```

Common reasons:

```text
Bad Config
Missing Secret
Missing Environment Variable
```

---

## Problem 4

RBAC Denied

Logs may show:

```text
Forbidden
Unauthorized
```

Check:

```bash
kubectl auth can-i
```

---

## Problem 5

Service Not Accessible

Check:

```bash
kubectl get endpoints
```

If empty:

```text
Service Selector mismatch
```

---

# 17. Understanding Installation Internals

When you install KAgent:

```text
Helm
 |
 |
 v

Deployment Created
 |
 |
 v

Pods Scheduled
 |
 |
 v

ServiceAccount Created
 |
 |
 v

RBAC Assigned
 |
 |
 v

Services Created
 |
 |
 v

Application Starts
 |
 |
 v

Kubernetes API Connected
```

This is the actual sequence happening behind the scenes.

---

# Production Best Practices

Never directly deploy to production.

Always follow:

```text
Dev Cluster
↓
Test Cluster
↓
Stage Cluster
↓
Production
```

---

Always verify:

```text
RBAC
Resource Limits
Storage
Logs
Services
```

before exposing KAgent to users.

---

# Module 2 Summary

You should now understand:

✅ KAgent deployment architecture

✅ Installation prerequisites

✅ Helm repository setup

✅ Namespace strategy

✅ Helm installation

✅ Pod verification

✅ Service verification

✅ RBAC verification

✅ Log analysis

✅ Installation troubleshooting

✅ Production deployment considerations

---

# Next Module

## Module 3: Ollama Integration (100% Free Local AI Setup)

In Module 3 we will build a completely free AI backend for KAgent using:

```text
Ollama
+
Llama 3
+
Kubernetes
+
KAgent
```

You will learn:

```text
Why KAgent needs an LLM
How Ollama works
Deploying Ollama on Kubernetes
Connecting KAgent to Ollama
Testing AI responses
Resource sizing
Production considerations
```

After Module 3, you will have a fully functional AI-powered Kubernetes troubleshooting platform without paying for OpenAI or any external API.
