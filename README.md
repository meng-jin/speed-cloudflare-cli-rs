# speed-cloudflare-cli-rs

A fast Rust implementation of Cloudflare speed test CLI.

## Installation

Download precompiled binaries from [Releases](https://github.com/Akaere-NetWorks/speed-cloudflare-cli-rs/releases)

Or build from source:
```bash
cargo install --git https://github.com/Akaere-NetWorks/speed-cloudflare-cli-rs
```

## Usage

```bash
# Basic test
speed-cloudflare-cli

# JSON output
speed-cloudflare-cli --json

# Help
speed-cloudflare-cli --help
```

## Output

- Server location & Your IP
- Latency & Jitter
- Download/Upload speeds at different file sizes
- Connection quality rating
