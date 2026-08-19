# sshd

Enables the OpenSSH daemon and disables password and root login, so the only
way in is a key listed in `~/.ssh/authorized_keys`.

That file is deliberately **not** managed by this topic. It is per-machine
state, and this repository is public, so tracking keys here would publish the
machine inventory.

## Populating authorized_keys from GitHub

GitHub publishes every public key on an account at `github.com/<user>.keys`,
which makes it a workable source of truth for a personal fleet: adding a new
machine's key to GitHub — something you do anyway to push over ssh — is then
enough to grant it access everywhere.

By hand:

```sh
curl -fsS https://github.com/<user>.keys -o ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

Declaratively, as a task in `topic.post_tasks.yml`. This overwrites the file,
so it is the whole story or nothing:

```yaml
- name: authorize public keys published on github
  ansible.builtin.get_url:
    url: "https://github.com/{{ github_user }}.keys"
    dest: "~/.ssh/authorized_keys"
    mode: "0600"
  when: is_arch
```

`ansible.posix.authorized_key` accepts the same URL and can merge instead of
overwrite. Drop `exclusive` to leave keys added by other means in place:

```yaml
- name: authorize public keys published on github
  ansible.posix.authorized_key:
    user: "{{ ansible_facts['user_id'] }}"
    key: "https://github.com/{{ github_user }}.keys"
    exclusive: true
```

Either form needs `github_user` defined, most naturally in this topic's
`topic.config.yml`.

## Trade-offs

- Every key on the account is authorized, not a chosen subset. Revoking a
  machine means removing its key from GitHub.
- Shell access becomes coupled to the GitHub account: whoever can add a key
  there can log in here. That is reasonable where GitHub already gates the
  machine's other access paths, and a poor fit otherwise.
- The fetch needs working network and DNS at provision time. A machine that
  cannot reach github.com ends up with a stale file, or none at all on first
  run — so authorize one key locally before making this the only path in,
  or you can lock yourself out of a freshly built host.
