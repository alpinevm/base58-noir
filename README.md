# Base58 Noir 

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**This software is not audited, use at your own risk.**

<hr>

**Base58 Noir** provides functions for decoding the locking script components (P2PKH, P2SH) from bitcoin [1addresses](https://en.bitcoin.it/wiki/Base58Check_encoding) in Noir Circuits.

At the moment, this library only supports decoding.
<br>

## Installation

In your `Nargo.toml` file, add the following dependency:

```toml
[dependencies]
base58 = { tag = "v0.1.0", git = "https://github.com/alpinevm/base58-noir" }
```

