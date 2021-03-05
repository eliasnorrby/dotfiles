# VPN instructions

The connection script expects a config file at `~/.config/openfortivpn/config` with the following contents:

```conf
host = some.vpn.host
username = someuser
# optionally add a password
password = somepassword
```

If no password is provided, the 1Password `op` CLI can be used to retrieve it. Specify the UUID of the 1Password item in `~/.config/openfortivpn/pw_uuid`.

If none of these options are configured, `openfortivpn` will prompt for the password interactively.

To run without sudo password, follow [these instructions][1]:

`visudo -f /etc/sudoers.d/openfortivpn`

```
Cmnd_Alias    OPENFORTIVPN = /usr/bin/openfortivpn

%openfortivpn ALL=(ALL) NOPASSWD: OPENFORTIVPN
```

```
sudo groupadd openfortivpn
sudo gpasswd -a yourusername openfortivpn
```

[1]: https://github.com/adrienverge/openfortivpn#running-as-root
