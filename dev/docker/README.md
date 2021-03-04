# Docker

## Extra steps on Arch

```bash
# To start the daemon automatically
sudo systemctl start docker.service
sudo systemctl enable docker.service

# To run docker commands as a non-root user
gpasswd -a username docker
sudo systemctl restart docker.service
```
