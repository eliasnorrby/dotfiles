# Rust

After installing `rustup`, call `rustup-init` (macOS) or `rustup default stable` (arch) to install the `rust` toolchain (`rustc`, `cargo`, `rustup`).

## Setting up `coc-rls`

Read the [docs][1].

```bash
rustup component add rls rust-analysis rust-src
```

## Adding dependencies with `cargo add`

Not natively supported.

```bash
cargo install cargo-edit
cargo add <some package>
```

[1]: https://github.com/neoclide/coc-rls
[2]: https://github.com/rust-lang/cargo/issues/2179
