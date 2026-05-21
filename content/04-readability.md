---
title: "Readability-Aware Prime Selection"
section: 4
---

# Motivation

Cryptographic primes are typically opaque hexadecimal values that resist manual inspection. While the Cocks-Pinch method is inherently transparent---all parameters derive from a public seed $T$---the resulting primes still appear as random bit strings. This opacity complicates auditing: reviewers cannot easily verify structural properties or detect anomalies by inspection.

The Dual_EC_DRBG incident [@DualECDRBG] demonstrated that even standardized constants can harbor backdoors when their generation process is opaque. We propose a complementary approach: among all cryptographically valid candidates, select the one that is most amenable to human inspection.

# Security-First Design

Our readability scoring is a *post-filter* applied only to candidates that have already passed all security requirements:

1. Primality (Miller-Rabin with sufficient rounds)
2. Correct bit length (512 for $r$, 1024 for $p$)
3. Minimum two-adicity ($\nu_2(q-1) \geq 36$)
4. Valid CM equation ($4p = t^2 + 3y^2$)
5. Embedding degree verification ($r \mid \Phi_{18}(p)$)

The scoring system cannot weaken security because it only selects among pre-validated candidates.

# Scoring Criteria

Each candidate prime is evaluated on eight independent structural criteria:

| Criterion | Rewards | Score Formula |
|-----------|---------|---------------|
| Binary sparseness | Low Hamming weight | $(n - \text{hw}) \times 2$ |
| Two-adicity | Higher $\nu_2(q-1)$ | $\nu_2 \times 3$ |
| Zero limbs | 64-bit blocks $= 0$ | count $\times 60$ |
| Full limbs | Limbs $= \texttt{0xFF...F}$ | count $\times 50$ |
| Longest zero run | Contiguous zero limbs | run $\times 40$ |
| Hex zero density | Hex digits $= 0$ | $(z - 16) \times 2$ |
| Simple top limb | Few bits in MSB limb | $(32 - \text{hw}) \times 3$ |
| Repeating limbs | Adjacent equal limbs | pairs $\times 25$ |

: Readability Scoring Criteria

The combined score weights the base field prime $p$ at $1.5\times$ the scalar field prime $r$, since $p$ appears more frequently in implementations (field arithmetic, point encoding, serialization).

**Criterion rationale.** Each criterion targets a distinct aspect of human inspectability: *zero limbs* allow developers to immediately verify correct initialization in memory dumps (an entire 64-bit word is either all-zero or not); *binary sparseness* reduces the visual complexity of the full binary expansion; *two-adicity* is directly observable from trailing zeros; *hex zero density* aids reading hexadecimal representations common in test vectors; *simple top limb* makes the most-significant word easy to memorize and verify; *repeating limbs* create visual patterns that are trivially confirmed. The weights reflect implementation impact---a zero limb eliminates an entire multiplication operand and 16 hex digits simultaneously, justifying its higher score (60) relative to individual hex zeros (2). The scoring is a design heuristic; alternative weightings that preserve the relative ordering of structural properties yield similar top candidates in practice.

# Search Procedure

The readability-aware search operates in two modes:

- **Fast mode**: Returns the first valid $(p, r)$ pair (original behavior).
- **Readable mode**: For each valid $r$, explores the *full* lift range to find the highest-scoring $p$. The search terminates when *either* a time budget (default 8 hours) expires *or* $N$ successful candidates (default $N = 50$) have been collected, whichever occurs first. The time budget is checked at the start of each iteration and takes priority.

In readable mode, the generator exhaustively searches all $(h_t, h_y)$ combinations for each valid $r$, scoring every prime candidate that passes the security filter. The best-scoring $(p, r)$ pair across all attempts is retained.

# Results

The following table shows the readability metrics of our selected parameters. Both primes share the tail pattern `...d970_00000001`, a consequence of $T \equiv 0 \pmod{2^{12}}$ propagating through the construction. This shared structure aids visual verification.

| Metric | $p$ (1024-bit) | $r$ (512-bit) |
|--------|----------------|---------------|
| Hamming weight | 464/1024 | 235/512 |
| Two-adicity | 36 | 36 |
| Zero 64-bit limbs | 0/16 | 8/16 |
| Hex zero digits | 33/256 | 16/128 |

: Readability Metrics of Selected Parameters

The scalar field prime $r$ achieves 8 zero limbs out of 16 (50%), meaning half of its 64-bit representation is zero---a property that simplifies implementation and testing. The shared tail `d970_00000001` = $d_{970} \cdot 2^{36} + 1$ visually confirms the NTT-friendly structure.
