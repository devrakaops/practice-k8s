
---

# 🏆 Practical Lab: Orchestrating a Self-Healing, Load-Balanced Production Swarm Cluster

## 📋 The Business Scenario

> **The Situation:** You are a Cloud Operations Architect for *FastStream Video*. The company runs a backend microservice API that handles user authentication. The service is highly critical and cannot drop offline under any circumstance.
> 
> 
> 
> 
> 
> 
> 
> 
> **The Problem:** The current deployment architecture runs on a single cloud server. If that server crashes or enters a maintenance reboot window, the entire authentication pipeline fails, locking out millions of customers.
> 
> 
> 
> 
> 
> 
> 
> 
> **The Goal:** You will initialize a highly available Docker Swarm engine cluster environment. You will deploy a multi-replica authentication api service, verify how the internal cluster routing mesh balances incoming traffic requests, inject secure system credentials using Swarm Secrets, and simulate a hardware disaster to prove the self-healing engine works.

---

## 🛠️ Interactive Sandbox Environment

To execute this production cluster orchestration verification loop, launch the cloud sandbox terminal below:

👉 **[Launch Interactive Ubuntu Sandbox on Killercoda](https://killercoda.com/playgrounds/scenario/ubuntu)**

---

## 🛠️ Lab Tasks & Complete Walkthrough Solution

### Phase 1: Initializing the Cluster Engine

We will transform a standard single-host terminal environment into an enterprise Swarm Manager node.

#### **Task 1.1:** Initialize the Swarm subsystem on your host machine to activate cluster routing controls.

```bash
docker swarm init --advertise-addr 127.0.0.1

```

* **Expected Output Verification:** The terminal will display a message stating: `Swarm initialized: current node (xxxx) is now a manager.` It will also output a long `docker swarm join --token ...` command string. This is the security string you would copy-paste onto other laptops or cloud instances to attach them as worker machines.





#### **Task 1.2:** Inspect the cluster infrastructure pool to verify your administrative status.

```bash
docker node ls

```

* **Expected Output Verification:** You will see a single host node listed with an **AVAILABILITY** status of `Active` and a **MANAGER STATUS** set to `Leader`.

---

### Phase 2: Provisioning Secure Cluster Infrastructure

Before launching our application, we must securely provision its sensitive connection string credentials inside the encrypted Swarm vault manager storage layer.

#### **Task 2.1:** Create a highly secure Swarm Secret object designated as `db-password`, passing an encrypted token string into it.

```bash
echo "SuperSecureBankPassword2026" | docker secret create db-password

```

* **Verification:** Run `docker secret ls` to confirm your secret is safely logged inside the cluster security infrastructure with an active ID assigned.

---

### Phase 3: Deploying and Scaling the Microservice Engine

Now, instead of a simple container, we will declare a multi-replica scalable service architecture that utilizes our secure token vault asset.

#### **Task 3.1:** Deploy a managed service framework named `auth-api`. Configure it to run **3 parallel identical copies (replicas)**, expose external host network port `8080` into internal container port `80`, attach your encrypted `db-password` secret securely, and utilize the lightweight `alpine` base engine image wrapper.

```bash
docker service create --name auth-api --replicas 3 --secret db-password -p 8080:80 alpine sh -c "while true; do nc -lp 80 -e echo -e 'HTTP/1.1 200 OK\n\n Auth System Active - Process Node: \$(hostname)'; done"

```

#### **Task 3.2:** Verify that the Swarm manager successfully split your deployment workload across multiple virtual tracking slots.

```bash
docker service ps auth-api

```

* **Expected Output Verification:** You will see 3 distinct tasks listed (`auth-api.1`, `auth-api.2`, and `auth-api.3`), all showing an active status of `Running`.

---

### Phase 4: Proving Load Balancing & Forensic Secret Analysis

Now, test if the internal Ingress Routing Mesh works by making repeated web requests to your application.

#### **Task 4.1:** Send multiple consecutive HTTP requests to your exposed service port using the system network loopback utility.

```bash
curl http://127.0.0.1:8080
curl http://127.0.0.1:8080
curl http://127.0.0.1:8080

```

* **Expected Output Analysis:** Look closely at the hostname strings returned in your terminal response profiles. You will notice that the strings change across each request (e.g., returning different container IDs). This proves that the **Ingress Routing Mesh is actively load-balancing your web traffic** automatically across all healthy containers in the background!





#### **Task 4.2:** Log inside one of your active running service tasks to verify that your secure database token is mounted inside RAM and completely invisible to disk tracking scripts.

```bash
# Extract a target running container ID
TARGET_CONTAINER=$(docker ps -q | head -n 1)

# Read the secret file from memory inside the container space
docker exec $TARGET_CONTAINER cat /run/secrets/db-password

```

* **Expected Output Verification:** The system prints out your plain text key string (`SuperSecureBankPassword2026`). This file exists *only* inside the container's isolated memory space and vanishes instantly if the process drops.

---

### Phase 5: Simulating a Production Crash (Self-Healing)

Now, simulate a critical software crash on one of your application tasks to prove that Docker Swarm can recover automatically.

#### **Task 5.1:** Forcefully delete one of the running application container processes out of memory using a standard low-level container delete loop.

```bash
docker rm -f $TARGET_CONTAINER

```

#### **Task 5.2:** Immediately inspect your Swarm status records to monitor the manager's recovery timeline.

```bash
docker service ps auth-api

```

* **Expected Output Analysis:** Look at the history records carefully. You will see that the old container task is marked as `Shutdown` or `Failed`. Directly above it, **a brand new container task has been automatically initialized and deployed** by the Swarm Manager to restore your architecture back to its desired state of 3 running replicas. Your application self-healed in milliseconds with zero data or service loss!

---

## 🔍 Grading Key & Conceptual Answers

### 1. What is the fundamental difference between a standard Docker Container (`docker run`) and a Docker Swarm Service (`docker service create`)?

### 2. Detail how the Ingress Routing Mesh handles data packets when an external user hits a port on a Swarm node that isn't running your application container.

### 3. Why are Swarm Secrets considered vastly superior to standard Docker environment variables (`-e PASSWORD=xyz`) for securing enterprise cloud infrastructure credentials?
