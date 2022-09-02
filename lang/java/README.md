# Homebrew Caveats

```
==> Caveats
For the system Java wrappers to find this JDK, symlink it with
  For M1 Macs:
  sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk \
     /Library/Java/JavaVirtualMachines/openjdk.jdk
  For older Macs:
  sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk \
    /Library/Java/JavaVirtualMachines/openjdk.jdk
```

Note: this is taken care of in `topic.tasks.yml`.

# Switching versions on Arch

Use the `archlinux-java` helper to set the default version.

```bash
$ archlinux-java status
$ sudo archlinux-java set java-8-openjdk
```

[Wiki][1]

[1]: https://wiki.archlinux.org/index.php/java#Switching_between_JVM
