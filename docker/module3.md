---

## Lab 1: The Basics – Pulling, Running, and Detached Mode

**Objective:** Learn to pull images, run containers in different modes, and check container status.

### Task Description

You need to spin up a web server to host a static page, but you want it to run in the background so it doesn't block your terminal. Afterward, you need to verify it is running.

### Steps for the Candidate

1. Pull the official `nginx` image from Docker Hub without running it.
2. Verify that the image exists in your local registry.
3. Run an Nginx container named `my-web-server` in **detached mode**.
4. Check the status of your running containers to confirm it's active.
5. Run a second Nginx container named `my-foreground-server`, but this time run it in the **foreground** (attached mode). Observe what happens to your terminal, then safely exit/stop it using a keyboard shortcut.

### Expected Deliverables

* The commands used for pulling, listing, and running the containers.
* A brief explanation in your own words of the difference between detached (`-d`) and foreground running.

---

## Lab 2: Interactive Containers & Ephemeral Nature

**Objective:** Understand how to interact with a container's OS and witness the ephemeral nature of container storage.

### Task Description

You need to test some shell commands inside a lightweight Linux distribution (`Ubuntu`) and verify what happens to files you create when the container dies.

### Steps for the Candidate

1. Run an `ubuntu` container in **interactive mode** (allocation of a TTY and keeping STDIN open), naming it `ubuntu-test`.
2. Once inside the container's bash prompt, create a file named `/tmp/secret.txt` and write `"Docker was here"` into it.
3. Type `exit` to leave the container.
4. Start the exact same container (`ubuntu-test`) back up and check if `/tmp/secret.txt` still exists.
5. Now, spin up a *brand new* Ubuntu container named `ubuntu-fresh`. Check if `/tmp/secret.txt` exists there.

### Expected Deliverables

* The exact flags used to make a container interactive.
* An answer to this question: *Why did the file exist/not exist in step 4 versus step 5?*

---

## Lab 3: Container Lifecycle Management & Cleanup

**Objective:** Master starting, stopping, restarting, and completely purging containers and images.

### Task Description

A microservice is misbehaving. You need to perform a series of lifestyle operations on it, and eventually clean up your system so it doesn't consume disk space.

### Steps for the Candidate

1. Run a detached `redis` container named `cache-db`.
2. **Stop** the container gracefully, then verify it is no longer in the running list (but still exists on disk).
3. **Start** the container back up.
4. **Restart** the container directly with a single command.
5. Try to delete the `redis` image from your system while `cache-db` is still using it. Note the error message.
6. Stop the container, delete the container, and then successfully remove the `redis` image.

### Expected Deliverables

* The exact sequence of commands (`stop`, `start`, `restart`, `rm`, `rmi`).
* The error message encountered in Step 5 and the reason why Docker prevents that action.

---

## Lab 4: Exploring Docker Layers & Image History

**Objective:** Look under the hood of a Docker image to understand how layers are constructed.

### Task Description

Before deploying an image, security and optimization teams want you to audit how many layers an image has and how large those layers are.

### Steps for the Candidate

1. Pull the `alpine` image (a very minimal Linux distro).
2. Pull the standard `python:3.11` image.
3. Use the Docker CLI to inspect the **history** of both images.
4. Compare the number of layers and the size difference between the two images.
5. Identify which command/instruction in the Python image history created the largest layer.

### Expected Deliverables

* The command used to view the layer history.
* A short summary comparing the layers of Alpine vs. Python, and why layer management matters for efficient Docker usage.

---

## Lab 5: Implementing Docker Restart Policies

**Objective:** Configure containers to automatically recover from crashes or system reboots.

### Task Description

You are deploying a critical background worker container. If the process inside crashes, or if the Docker daemon restarts, the container must automatically bring itself back online.

### Steps for the Candidate

1. Run a detached container named `always-up` using the `alpine` image that runs a continuous ping command (`ping 8.8.8.8`). Configure it with the `always` restart policy.
2. Run a second container named `failure-only` using the same image, but configure it to restart *only* if it exits with a non-zero error code (`on-failure`).
3. Manually kill the process inside `always-up` or use `docker stop` followed by a system daemon simulated restart (or just check container stats after forcing a container crash using a kill command) to see if it boots back up automatically.
4. Clean up both containers. Note what happens when you try to `docker rm` a container that has an active restart policy.

### Expected Deliverables

* The syntax used to apply restart policies during `docker run`.
* A clear explanation of the difference between `always`, `unless-stopped`, and `on-failure`.

---

### Ready for the next step?

You can copy this markdown directly into a `README.md` or a `Labs/` folder in your GitHub repo.

When you have saved these or want to move to the next set, **tell me what your next Docker topic or concept is!**
