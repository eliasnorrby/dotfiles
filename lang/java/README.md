# Homebrew Caveats

```
==> Caveats
For the system Java wrappers to find this JDK, symlink it with
  sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
```

# Switching versions on Arch

Use the `archlinux-java` helper to set the default version.

```bash
$ archlinux-java status
$ sudo archlinux-java set java-8-openjdk
```

[Wiki][1]

[1]: https://wiki.archlinux.org/index.php/java#Switching_between_JVM
