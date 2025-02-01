---
title: Understanding Simulation and Zero-Knowledge
date: 2020-05-07 10:00:00
published: false
sidebar:
    nav: cryptomat
---

<!-- TODO:

A nice explanation of ZK via two games by Groth at MSR: https://youtu.be/KSZB9hsrh3c?t=1146

See ZK definition in 20.3.5 of Boneh-Shoup'23, which discusses why the simulator must have "extra power":
 - without extra power, it would allow anyone to forge proofs for x \notin L
 - and if you say, well, maybe the simulator could work just for x \in L and fail for x \notin L, then that gives a poly-time decider for L. since many L's are in NP or NP-complete, this will not work

Interesting subtleties to cover:

1. signatures are zkpoks of a secret key or not?

2. Simulation for deniable authentication should be 'straight line' (no rewinding allowed for some reason) according to Gennaro's presentation.
See:

 - straight line extraction[^BWN15e]: "An extractor is straight-line if it only
 sees a single execution of the prover (and learns the RO queries/answers that the
 prover makes), or rewinding if it is allowed to launch and interact with further
 copies of the prover (with the same coins used to produce the statement) before
 returning a witness"
 - Pass's paper on why: https://iacr.org/archive/crypto2003/27290315/27290315.pdf
 - https://www.dmi.unict.it/diraimondo/web/wp-content/uploads/papers/deniability-ake.pdf

3. NIZK versus interactive ZK: both have simulators, no? But NIZK guarantees are  weaker since you can send proof to others and convince them. How is the simulation different?

4. witness indistinguishability

5. adaptive ZK

6. ZK vs ZKPoK: https://crypto.stackexchange.com/questions/10595/when-would-one-prefer-a-proof-of-knowledge-instead-of-a-zero-knowledge-proof/79930#79930

sure, there exists x such that h = g^x. for any h... but do you know the god damn x?

-->

---

{% include bib.md %}
