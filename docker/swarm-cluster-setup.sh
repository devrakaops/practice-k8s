#!/usr/bin/env bash
set -e

# Configuration
NETWORK_NAME="swarm-net"
MANAGERS=("manager1" "manager2" "manager3")
WORKERS=("worker1" "worker2" "worker3")
DOCKER_VERSION="docker:dind"

echo "=== 1. Cleaning up existing Swarm containers and network ==="
for node in "${MANAGERS[@]}" "${WORKERS[@]}"; do
    if [ "$(docker ps -aq -f name=^/${node}$)" ]; then
        echo "Removing old container: $node"
        docker rm -f "$node" > /dev/null
    fi
done

if [ "$(docker network ls -q -f name=^${NETWORK_NAME}$)" ]; then
    echo "Removing old network: $NETWORK_NAME"
    docker network rm "$NETWORK_NAME" > /dev/null
fi

echo -e "\n=== 2. Creating private network: $NETWORK_NAME ==="
docker network create "$NETWORK_NAME"

echo -e "\n=== 3. Launching 3 Manager and 3 Worker DinD containers ==="
# Spin up Managers
for mgr in "${MANAGERS[@]}"; do
    echo "Starting $mgr with hostname '$mgr'..."
    docker run -d --privileged --name "$mgr" --hostname "$mgr" --network "$NETWORK_NAME" "$DOCKER_VERSION" > /dev/null
done

# Spin up Workers
for wrk in "${WORKERS[@]}"; do
    echo "Starting $wrk with hostname '$wrk'..."
    docker run -d --privileged --name "$wrk" --hostname "$wrk" --network "$NETWORK_NAME" "$DOCKER_VERSION" > /dev/null
done

echo -e "\n=== 4. Waiting 30 seconds for all internal Docker daemons to boot... ==="
sleep 30

echo -e "\n=== 5. Initializing Swarm on manager1 ==="
# Dynamically pull the exact IP address of manager1 inside the virtual network
MANAGER1_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' manager1)
echo "Discovered manager1 internal IP: $MANAGER1_IP"

# Initialize using the raw IP address
docker exec manager1 docker swarm init --advertise-addr "$MANAGER1_IP" > /dev/null

# Fetch both required tokens securely
MGR_TOKEN=$(docker exec manager1 docker swarm join-token manager -q)
WRK_TOKEN=$(docker exec manager1 docker swarm join-token worker -q)

echo -e "\n=== 6. Joining remaining Managers to the Swarm ==="
for i in "${!MANAGERS[@]}"; do
    if [ $i -ne 0 ]; then
        echo "Joining ${MANAGERS[$i]} as a Manager..."
        docker exec "${MANAGERS[$i]}" docker swarm join --token "$MGR_TOKEN" "$MANAGER1_IP:2377" > /dev/null
    fi
done

echo -e "\n=== 7. Joining Workers to the Swarm ==="
for wrk in "${WORKERS[@]}"; do
    echo "Joining $wrk as a Worker..."
    docker exec "$wrk" docker swarm join --token "$WRK_TOKEN" "$MANAGER1_IP:2377" > /dev/null
done

echo -e "\n=== 8. Verification ==="
echo "Successfully deployed! Current cluster state:"
echo "--------------------------------------------------------"
docker exec manager1 docker node ls
echo "--------------------------------------------------------"
echo "To jump inside your leader node, run: docker exec -it manager1 sh"
