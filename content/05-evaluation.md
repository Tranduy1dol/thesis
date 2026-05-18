---
title: "Curve1024: Parameters and Evaluation"
section: 5
---

This section presents the concrete Curve1024 parameters produced by our improved Cocks-Pinch construction with readability-aware selection, followed by implementation details and security analysis.

# Curve1024 Parameters

The construction produces the following pairing-friendly elliptic curve over a 1024-bit prime field. All parameters are publicly verifiable from the seed $T$.

## Seed and Construction

**Seed:** $T = \texttt{0x26704d2ace0facdd539} \cdot 2^{12}$

The seed satisfies $T \equiv 0 \pmod{2^{12}}$, guaranteeing $\nu_2(r-1) = 36$ via the relation $r - 1 = T^3(T^3 - 1)$.

## Scalar Field Order ($r = \Phi_{18}(T) = T^6 - T^3 + 1$, 512 bits)

```
r = 0x c042c338 9e72044d 9ec8078a ea7bc954
      ebf209d9 18f0ef27 425259e2 47711927
      97463bf2 3832d0de 5e46e47f c61cab50
      4bcfd36f c2a945c5 1055d970 00000001
```

Properties: $|r| = 512$ bits, $\nu_2(r-1) = 36$, 8 zero 64-bit limbs out of 16.

## Base Field Prime ($p = (t^2 + 3y^2)/4$, 1024 bits)

```
p = 0x c0859da8 3a500988 10eea35c 61fea054
      c8669025 99220d30 c93f3826 5ed6b830
      5785b8a0 73e482e8 685cfeeb 388dc45e
      bca16862 45b326fe 824ca74a c0844160
      f4e28980 6084e50e 6c02f32c b94d786b
      f80fb080 c07d6a07 73f2b459 1eb70df3
      9367aa32 ebb42449 e0a648f6 1a20e876
      f971f3bf 976a7d6a dd20d970 00000001
```

Properties: $|p| = 1024$ bits, $\nu_2(p-1) = 36$, Hamming weight 464/1024.

## Curve Equation and Generator

| Parameter | Value |
|-----------|-------|
| Equation | $E: y^2 = x^3 + 41$ |
| Embedding degree | $k = 18$ |
| CM discriminant | $D = -3$ ($j = 0$) |
| $\rho = \log p / \log r$ | 2.0 |

: Curve1024 Summary

**Generator point** $G = (G_x, G_y)$ of order $r$:

```
Gx = 0x 0c04c9bd 75d883ea 501c1b00 33b81dac
       69a688eb 67bd7126 0fc49d36 6674a0c0
       4686227983a7188a ed3767b9 ff894eeb
       2cdf8073 5a9a4456 afbfe264 e8139ad5
       b0e90ca9 a9588464 771871c2 d8b86b09
       a52440ff e1b9984e 1566ace7 87feea0d
       11310eec baf0a39d 0d3feb5b 7279c384
       d74dc993 caef5866 7681783133a11cfa
```

```
Gy = 0x 9dde8a42 a8a618aa c7691f9d e4d4e626
       d037825e 33d925f0 775be9a8 d60969c9
       4fe1033b a71c6518 5280e262 11a43ddf
       30bd4d40 60d21a65 b5234cd9 f29763c2
       b70048d7 fdd4a9be f0cc4c70 1bbed367
       8a371139 fcadacc5 b8dc9361 469d8ddc
       c5c93289 767dceca 4763febd 6a618277
       2dcf7bfc 3dc1cce3 d8c75862 4a40c468
```

## Structural Properties

Both primes share the tail pattern `...d970_00000001`, visually confirming the NTT-friendly structure $q = d \cdot 2^{36} + 1$. This shared suffix is a direct consequence of the seed constraint $T \equiv 0 \pmod{2^{12}}$ propagating through the cyclotomic polynomial.

| Metric | $p$ (1024-bit) | $r$ (512-bit) |
|--------|----------------|---------------|
| Hamming weight | 464/1024 | 235/512 |
| Two-adicity | 36 | 36 |
| Zero 64-bit limbs | 0/16 | 8/16 |
| Hex zero digits | 33/256 | 16/128 |

: Readability Metrics

# Implementation

We implement the complete system in Rust without external cryptographic dependencies [@LumenMath]. The implementation comprises:

- A custom `U1024` big integer type with Montgomery multiplication [@Montgomery1985]
- Prime field arithmetic (`PrimeFieldElement`) with constant-time Fermat inversion
- Elliptic curve group operations in affine coordinates
- Schnorr and ECDSA signature schemes
- The parameter generation tool (improved Cocks-Pinch + readability scoring)

The test suite contains 36 tests covering arithmetic correctness, group law verification, and attack simulation (MOV, Anomalous, Invalid Curve).

# Performance Benchmarks

The following table reports timing measurements using the Criterion framework (release build, LLVM O3 optimization, 10 samples per measurement, commodity hardware without AVX-512).

| Operation | Min | Mean | Max |
|-----------|-----|------|-----|
| Key generation | 1.629 s | 1.687 s | 1.757 s |
| Schnorr sign | 1.473 s | 1.551 s | 1.641 s |
| Schnorr verify | 2.656 s | 2.831 s | 3.025 s |
| ECDSA sign | 1.524 s | 1.606 s | 1.711 s |
| ECDSA verify | 2.847 s | 3.140 s | 3.459 s |
| Scalar mult. $[k]G$ | 1.061 s | ~1.2 s | 1.489 s |

: Performance Benchmarks

The performance reflects the 1024-bit field size: each scalar multiplication requires ~512 double-and-add iterations, each involving a Fermat inversion (~1536 Montgomery multiplications). This is approximately $8000\times$ slower than optimized secp256k1 implementations, which is expected given the $4\times$ larger field and $O(n^2)$ multiplication cost. The system targets offline signing scenarios (legal documents, software releases, PKI certificates) where seconds of latency are acceptable.

# Security Analysis

| Attack | Complexity | Status |
|--------|-----------|--------|
| Pollard-$\rho$ (ECDLP) | $O(2^{256})$ | Secure |
| MOV reduction | DLP in $\mathbb{F}_{p^{18}}$ (18432-bit) | Secure |
| Anomalous (SSSA) | Requires $\#E = p$ | Immune |
| TNFS | $\geq 250$-bit in $\mathbb{F}_{p^{18}}$ | Secure |
| Invalid curve | Point validation in constructor | Mitigated |

: Security Evaluation Summary

The 256-bit ECDLP security exceeds NIST SP 800-57 recommendations through 2030+ [@NIST80057]. The MOV attack maps ECDLP to DLP in $\mathbb{F}_{p^{18}}$, a field of 18,432 bits---far exceeding the 3,072-bit threshold for 128-bit security. The curve is provably non-anomalous since $\#E(\mathbb{F}_p) = h \cdot r$ with $r \approx 2^{512} \neq p \approx 2^{1024}$.

**Limitation:** The current affine-coordinate implementation uses variable-time double-and-add, which leaks scalar bits through timing. A Montgomery ladder (constant-time) is identified as future work.

# Curve Family Comparison

| Curve | $|p|$ | $\rho$ | $\nu_2$ | Security |
|-------|--------|--------|---------|----------|
| BN254 | 254 | 1.0 | ~1 | 100-bit |
| BLS12-381 | 381 | 1.5 | 32 | 128-bit |
| KSS18 (generic) | varies | 1.33 | random | varies |
| **Curve1024** | 1024 | 2.0 | **36** | **256-bit** |

: Comparison with Standard Curve Families
