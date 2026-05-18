---
title: "Related Work"
section: 6
---

**Pairing-friendly curve taxonomy.** Freeman, Scott, and Teske [@FreemanScottTeske2010] provide a comprehensive classification of pairing-friendly curve constructions, including the Cocks-Pinch method, MNT curves, and polynomial families (BN, BLS, KSS). Their work establishes the theoretical framework but does not address NTT-friendliness as a design criterion.

**TNFS security updates.** Barbulescu and Duquesne [@BarbulescuDuquesne2019] demonstrated that the Tower Number Field Sieve reduces the effective security of many pairing-friendly curves, notably downgrading BN256 from 128-bit to approximately 100-bit security. This motivates our choice of a 1024-bit base field with $k=18$, yielding a pairing target of 18,432 bits.

**BLS12-381.** Bowe [@BLS12_381] designed BLS12-381 specifically for zk-SNARKs, achieving two-adicity 32 in both fields through careful parameter selection within the BLS12 family. Our work achieves higher two-adicity (36) using the more flexible Cocks-Pinch method, at the cost of a larger $\rho$-value.

**Pasta curves.** The Pallas/Vesta cycle [@PastaCurves] achieves NTT-friendliness through a 2-cycle of curves, enabling recursive proof composition. Unlike our approach, Pasta curves are not pairing-friendly and target a different application domain (Halo 2 recursive proofs).

**Nothing-up-my-sleeve numbers.** The cryptographic community has long advocated for "nothing-up-my-sleeve" constants (e.g., using digits of $\pi$) to demonstrate absence of backdoors. Our readability scoring takes a complementary approach: rather than deriving primes from a fixed public constant, we select the most inspectable prime from a large space of equally secure candidates. Both approaches serve the goal of transparent parameter generation.

**Cocks-Pinch extensions.** Chen, Hong, and Wang [@CocksPinchK5K8] extend the Cocks-Pinch method to embedding degrees 5--8 with optimal Ate pairing computation. Our work focuses on $k=18$ with the novel addition of NTT constraints and readability scoring.
