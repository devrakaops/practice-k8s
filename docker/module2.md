---

# Module 2: Introduction to Docker & Its Architecture

This documentation covers what Docker is, the exact problems it solves in DevOps pipelines, how its internal client-server engine communicates, and how to set it up across different operating systems.

---

## 1. Introduction to Docker

**Docker** is an open-source platform designed to automate the deployment, scaling, and management of applications using containerization.

Before Docker, containerization existed in the Linux world (via tools like LXC - Linux Containers), but it was highly complex, required deep kernel expertise, and lacked portability. Docker revolutionized the industry in 2013 by introducing a standardized toolset and a unified file format (Docker Images) that made containers accessible to every developer.

### Why Docker is Used

In traditional environments, a software delivery pipeline often stalls due to differences in infrastructure. Docker eliminates this friction by providing:

* **True Portability:** It builds a single artifact (an image) containing the code, runtime, system tools, and libraries. This artifact runs identically on a developer's local laptop, an on-premises data center, or any public cloud provider (AWS, GCP, Azure).
* **Isolation and Security:** Multiple applications can run on the exact same host without their dependencies interfering with one another.
* **Massive Resource Savings:** By eliminating the need for a Guest OS (unlike Virtual Machines), Docker allows organizations to pack drastically more applications onto the same underlying hardware.

---

## 2. Docker Use Cases in DevOps and Cloud

Docker is the foundation of modern DevOps methodologies. The most common enterprise use cases include:

* **Microservices Architectures:** Instead of deploying a massive monolithic application, enterprises break software into smaller services (e.g., payment service, inventory service). Each microservice is packaged into its own Docker container, allowing teams to develop, deploy, and scale services independently.
* **Continuous Integration / Continuous Deployment (CI/CD):** * In a CI/CD pipeline, Docker images are automatically built whenever code is pushed to GitHub.
* These images are tested in an identical containerized testing environment, eliminating the risk of test failures caused by server configuration drift.


* **Rapid Cloud Migration:** Moving applications from local servers to the cloud can be a nightmare due to OS version differences. Because cloud providers natively support Docker, migrating an application is as simple as pushing the Docker image to a cloud container registry.
* **Dynamic Scaling:** Containers start up in milliseconds. During peak traffic seasons (e.g., Black Friday), orchestration platforms can spin up thousands of identical Docker containers instantly to distribute load, and spin them down just as quickly when traffic subsides.

---

## 3. Understanding Docker Architecture

Docker uses a classic **Client-Server architecture**. The client talks to the server, which does the heavy lifting of building, running, and distributing your Docker containers.

### Component Breakdown:

#### A. The Docker Client (`docker`)

The Docker Client is the primary interface used by developers to interact with Docker. When you type a command like `docker run` or `docker build` into your terminal, you are using the Docker Client. The client itself doesn't execute the containers; it translates your CLI commands into REST API calls and sends them to the Docker Daemon.

#### B. The Docker Daemon (`dockerd`)

The Docker Daemon is a persistent background service running on the host operating system.

* It constantly listens for API requests coming from the Docker Client.
* It is the "brain" of Docker—managing heavy infrastructure objects like **Images**, **Containers**, **Networks**, and **Storage Volumes**.
* The Client and Daemon can reside on the same physical system, or you can connect a local Docker Client to a remote Docker Daemon running on a cloud server.

#### C. Docker Registries

A registry is a centralized storage repository for Docker Images.

* **Docker Hub** is the default public registry where anyone can download or share images.
* Enterprises often use private registries (like AWS ECR, Azure ACR, or JFrog Artifactory) to store proprietary internal code securely.

---

## 4. The Docker Engine Overview

The **Docker Engine** is the core component of the Docker ecosystem. It is a modular, lightweight runtime environment made up of three distinct layers:

1. **The Server (Docker Daemon):** As mentioned above, this is the long-running process (`dockerd`) that manages everything.
2. **The REST API:** A standardized interface that specifies how applications can interact with the Docker Daemon. It acts as the bridge between the client and the backend server.
3. **The CLI (Client):** The command-line interface software that makes interacting with the REST API user-friendly.

---

## 5. Installing and Verifying Docker

To transition from theory to practice, Docker must be set up properly based on the host operating system's underlying architecture.

### A. Installing Docker on Linux (Ubuntu/Debian)

On Linux, Docker runs natively because it leverages the built-in capabilities of the host's Linux Kernel.

Production-grade installation involves setting up Docker's official repository to ensure you receive the latest stable updates:

```bash
# Step 1: Update existing packages
sudo apt-get update

# Step 2: Install prerequisite packages to allow apt to use a repository over HTTPS
sudo apt-get install ca-certificates curl gnupg

# Step 3: Add Docker’s official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Step 4: Set up the stable repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.p/docker.list > /dev/null

# Step 5: Install Docker Engine, CLI, and containerd
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Step 6: Post-installation (Optional: run Docker without 'sudo')
sudo usermod -aG docker $USER

```

*(Note: Log out and log back in for the group membership changes to take effect).*

### B. Installing Docker on Windows

Because Windows uses a completely different OS kernel than Linux, running Linux-based Docker containers on Windows requires an abstraction layer.

This is achieved using **Docker Desktop**, which relies on **WSL 2 (Windows Subsystem for Linux 2)**:


1. **Prerequisites:** Ensure your system runs Windows 10/11 with virtualization enabled in your system's BIOS/UEFI settings.

2. **Install WSL 2:** Open PowerShell as Administrator and execute:
```powershell
wsl --install

```


Restart your machine when prompted.

3. **Download Docker Desktop:** Download the official installer from the [Docker Hub website](https://www.docker.com/products/docker-desktop/).

4. **Run Installer:** Execute the installer, ensure the **"Use WSL 2 instead of Hyper-V"** configuration option is checked, and complete the wizard.

5. **Launch:** Open Docker Desktop from your start menu. The backend daemon will automatically spin up.

---

### C. Verifying the Docker Installation

Once installation is complete, you must verify that both the **Client** and **Daemon** are up, operational, and communicating perfectly. Run the following three verification commands in your terminal or PowerShell window:

#### 1. Check Component Versions

```bash
docker --version

```

* **Expected Result:** Outputs the version string of the installed Docker client (e.g., `Docker version 26.1.0, build ...`).

#### 2. Inspect Deep Architecture Info

```bash
docker info

```

* **Expected Result:** Provides comprehensive system-level configurations. It displays the running container count, storage drivers being used, OS Type (Linux or Windows), CPU limits, architecture, and whether the client is connected to a live backend daemon. If you see an error here saying *"Cannot connect to the Docker daemon"*, your server process isn't running.

#### 3. Run the Smoke Test

```bash
docker run hello-world

```

* **Expected Result:** This executes the ultimate verification pipeline.
1. The client requests the daemon to run an image named `hello-world`.
2. The daemon checks locally, realizes it doesn't have it, and contacts Docker Hub to **pull** the image down.
3. The daemon spins up a container from that image, which executes a script that prints a confirmation message (*"Hello from Docker!"*) straight to your terminal, and then automatically terminates.



---

## 💡 Core Takeaways (Cheatsheet for Interviews)

* **Docker is not a Virtual Machine.** VMs isolate hardware; Docker isolates software environments by sharing the host OS kernel.
* The **Docker Client** is merely a UI tool that makes REST API calls. The **Docker Daemon (`dockerd`)** does the actual infrastructure work.
* Docker on Windows requires **WSL 2** because native Docker containers require a Linux Kernel to utilize namespace and cgroup isolation primitives.
* Running `docker run hello-world` verifies the entire lifecycle loop: Client $\rightarrow$ Daemon $\rightarrow$ Local Cache $\rightarrow$ External Registry (Docker Hub) $\rightarrow$ Container Execution.

---

### Ready for the next step?
