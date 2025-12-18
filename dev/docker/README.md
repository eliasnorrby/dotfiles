# Docker

## Extra steps on Arch

```bash
# Start the docker daemon manually
sudo systemctl start docker.service
sudo systemctl start docker.socket

# To start the daemon on-demand
sudo systemctl enable docker.socket

# To start the daemon automatically
sudo systemctl enable docker.service

# To run docker commands as a non-root user
gpasswd -a username docker
sudo systemctl restart docker.service
```
