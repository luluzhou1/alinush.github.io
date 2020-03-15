---
tags: papers polynomials verifiable-secret-sharing distributed-key-generation kate-zaverucha-goldberg kzg commitments polycommit
title: "Scalable Verifiable Secret Sharing and Distributed Key Generation"
date: 2020-03-12 14:00:00
published: false
---
**tl;dr:** We "authenticate" a polynomial multipoint evaluation using Kate-Zaverucha-Goldberg (KZG) commitments.
This gives a new way to precompute $n$ proofs on a degree $t$ polynomial in $O(n\log{t})$ time rather than $O(nt)$ time.
The key trade-off is that our proofs are logarithmic-sized, rather than constant-sized.
Nonetheless, we use our fast-to-compute proofs to scale Verifiable Secret Sharing (VSS) protocols and thus distributed key generation (DKG) protocols.
We also obtain a new Vector Commitment (VC) scheme, which can be used for stateless cryptocurrencies.

In a [previous post](/2020/03/12/scalable-bls-threshold-signatures.html), I described our new techniques for scaling BLS threshold signatures to millions of signers.
However, as pointed out by my friend [Albert Kwon](http://albertkwon.com), once we have such a scalable threshold signature scheme (TSS), a new question arises:

_<center>"Can we efficiently bootstrap a $(t,n)$ threshold signature scheme when $t$ and $n$ are very large?"</center>_

To securely bootstrap a TSS such as BLS[^BLS04], a _distributed key generation (DKG)_[^GJKR07] protocol must be used.
At a high level, a DKG operates as follows:

 - All the $n$ _signers_ participate in the protocol, 
    - (Perform some computations, exchange some private/public information, etc.)
 - At the end of the protocol, each signers $i$ obtains its own _secret share_ $s_i$ of the _secret key_ $s$ of the TSS,
 - Importantly, the protocol guarantees $s$ is **not** known by any of the signers,
 - Furthermore, each signer also obtains $g^s$, which will be the _public key_ of the TSS.
    + Note that all signers implicitly _agree_ on $g^s$ (and thus on $s$, even though they don't know $s$). 

As mentioned in our [first post](/2020/03/12/scalable-bls-threshold-signatures.html), our **full paper**[^TCZplus20], *which will appear in IEEE S&P'20*, can be found [here](/papers/dkg-sp2020.pdf).

Also, a **prototype implementation** of our VSS and DKG benchmarks is available on GitHub [here](https://github.com/alinush/libpolycrypto/).

<p hidden>$$
\def\G{\mathbb{G}}
\def\Zp{\mathbb{Z}_p}
\def\Ell{\mathcal{L}}
\def\blskeygen{\mathbf{BLS}.\mathbf{Keygen}}
$$</p>

## Preliminaries

Let $[n]=\\{1,2,3,\dots,n\\}$.
Let $p$ be a sufficiently large prime that denotes the order of our groups.

In this post, beyond basic group theory for cryptographers[^KL15] and basic polynomial arithmetic, I will assume you are familiar with a few concepts:

 - **Bilinear maps**[^GPS08]. Specifically, $\exists$ a bilinear map $e : \G_1 \times \G_2 \rightarrow \G_T$ such that:
    - $\forall u\in \G_1,v\in \G_2, a\in \Zp, b\in \Zp, e(u^a, v^b) = e(u,v)^{ab}$
    - $e(g_1,g_2)\ne 1_T$ where $g_1,g_2$ are the generators of $\G_1$ and $\G_2$ respectively and $1_T$ is the identity of $\G_T$
 - The **polynomial remainder theorem** which says that $\forall z$: $\phi(z) = \phi(X) \bmod (X-z)$,
    - Or, equivalently, $\exists q, \phi(X) = q(X)(X-z) + \phi(z)$.
 - The **Fast Fourier Transform (FFT)**[^CLRS09] applied to polynomials. Specifically,
    - Suppose $\Zp$ admits a primitive _root of unity_ $\omega$ of order $N$
        - i.e., $N \mid p-1$
    - Let $$H=\{1, \omega, \omega^2, \omega^3, \dots, \omega^{N-1}\}$$ denote the set of all $N$ $N$th roots of unity
    - Then, the FFT can be used to efficiently evaluate any polynomial $\phi(X)$ at all $X\in H$ in $\Theta(N\log{N})$ time
        - i.e., compute all $$\{\phi(\omega^{i-1})\}_{i\in[N]}$$

### Polynomial multipoint evaluations

A key ingredient in our work, is a _polynomial multipoint evaluation_[^vG13ModernCh10], or a _multipoint eval_ for short. 
A multipoint eval is just an algorithm for efficiently evaluating a polynomial at many points.
If done naively, evaluating a degree $t$ polynomial at $n$ points can be done in $O(nt)$ time.
But, with extra care, this time can be reduced to $O(n\log^2{t})$.

{: .info}
An FFT is an example of a multipoint eval, where the evaluation points are restricted to be all $N$ $N$th roots of unity.
However, the multipoint eval we'll describe below works for any set of points.

## Faster KZG evaluation proofs 

via Authenticated Multipoint Evaluation Trees (AMTs)

## Faster VSS via AMTs

TODO: don't want to explain VSS, but at a high level the dealer has to share a secret $s$ with the $n$ players and in this process he must compute proofs for each share

## Faster DKG via faster VSS

TODO: don't want to explain DKG fully, but at a high level, each player just does a VSS

## Remaining questions

Our $(t,n)$ VSS/DKG protocols require $t$-SDH public parameters.
Thus, we are introducing a new problem of generating $t$-SDH public parameters for large $t$.

### References

[^Boldyreva03]: **Threshold Signatures, Multisignatures and Blind Signatures Based on the Gap-Diffie-Hellman-Group Signature Scheme**, by Boldyreva, Alexandra, *in PKC 2003*, 2002
[^BLS04]: **Short Signatures from the Weil Pairing**, by Boneh, Dan and Lynn, Ben and Shacham, Hovav, *in Journal of Cryptology*, 2004
[^BT04]: **Barycentric Lagrange Interpolation**, by Berrut, J. and Trefethen, L., *in SIAM Review*, 2004
[^CLRS09]: **Introduction to Algorithms, Third Edition**, by Cormen, Thomas H. and Leiserson, Charles E. and Rivest, Ronald L. and Stein, Clifford, 2009
[^GAGplus19]: **SBFT: A Scalable and Decentralized Trust Infrastructure**, by G. Golan Gueta and I. Abraham and S. Grossman and D. Malkhi and B. Pinkas and M. Reiter and D. Seredinschi and O. Tamir and A. Tomescu, *in 2019 49th Annual IEEE/IFIP International Conference on Dependable Systems and Networks (DSN)*, 2019, [[PDF]](https://arxiv.org/pdf/1804.01626.pdf).
[^GJKR07]: **Secure Distributed Key Generation for Discrete-Log Based Cryptosystems**, by Gennaro, Rosario and Jarecki, Stanislaw and Krawczyk, Hugo and Rabin, Tal, *in Journal of Cryptology*, 2007
[^GPS08]: **Pairings for cryptographers**, by Steven D. Galbraith and Kenneth G. Paterson and Nigel P. Smart, *in Discrete Applied Mathematics*, 2008
[^KL15]: **Introduction to Modern Cryptography**, by Jonathan Katz and Yehuda Lindell, 2007
[^Shamir79]: **How to Share a Secret**, by Shamir, Adi, *in Commun. ACM*, 1979
[^TCZplus20]: **Towards Scalable Threshold Cryptosystems**, by Alin Tomescu and Robert Chen and Yiming Zheng and Ittai Abraham and Benny Pinkas and Guy Golan Gueta and Srinivas Devadas, *in 2020 IEEE Symposium on Security and Privacy (SP)*, 2020, [[PDF]](/papers/dkg-sp2020.pdf).
[^vG13ModernCh10]: **Fast polynomial evaluation and interpolation**, by von zur Gathen, Joachim and Gerhard, Jurgen, *in Modern Computer Algebra*, 2013
