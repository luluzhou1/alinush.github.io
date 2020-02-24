---
tags: papers polynomials verifiable-secret-sharing distributed-key-generation kate-zaverucha-goldberg kzg commitments polycommit
title: "Towards Scalable Distributed Key Generation"
date: 2020-03-12 14:00:00
published: false
---
**tl;dr:** We "authenticate" a polynomial multipoint evaluation using Kate-Zaverucha-Goldberg (KZG) commitments.
This gives a new way to precompute $n$ proofs on a degree $t$ polynomial in $O(n\log{t})$ time rather than $O(nt)$ time, which helps scale Verifiable Secret Sharing (VSS) protocols and thus distributed key generation (DKG) protocols.
As a bonus, we also obtain a new Vector Commitment (VC) scheme.

The question of scaling distributed key generation (DKG)[^GJKR07] protocols needed to bootstrap threshold signature schemes such as BLS[^BLS04] was raised by [Albert Kwon](http://albertkwon.com), one of my friends at MIT.

Our **full paper**[^TCZplus20], *which will appear in IEEE S&P'20*, can be found [here](/papers/dkg-sp2020.pdf).

<p hidden>$$
\def\G{\mathbb{G}}
\def\Zp{\mathbb{Z}_p}
\def\Ell{\mathcal{L}}
\def\blskeygen{\mathbf{BLS}.\mathbf{Keygen}}
$$</p>

## Preliminaries

Let $[n]=\\{1,2,3,\dots,n\\}$.
Let $p$ be a sufficiently large prime that denotes the order of our groups.
We use $\langle g \rangle = \G$ to denote $g$ generates a group $\G$.

In this post, beyond basic group theory for cryptographers[^KL15], I will assume you are familiar with a few concepts:

 - **Bilinear maps**[^GPS08]. Specifically, $\exists$ a bilinear map $e : \G_1 \times \G_2 \rightarrow \G_T$ such that:
    - $\forall u\in \G_1,v\in \G_2, a\in \Zp, b\in \Zp, e(u^a, v^b) = e(u,v)^{ab}$
    - $e(g_1,g_2)\ne 1_T$ where $g_1,g_2$ are the generators of $\G_1$ and $\G_2$ respectively and $1_T$ is the identity of $\G_T$

## Faster KZG evaluation proofs 

via Authenticated Multipoint Evaluation Trees (AMTs)

## Faster VSS via AMTs

## Faster DKG via faster VSS

### References

[^Boldyreva03]: **Threshold Signatures, Multisignatures and Blind Signatures Based on the Gap-Diffie-Hellman-Group Signature Scheme**, by Boldyreva, Alexandra, *in PKC 2003*, 2002
[^BLS04]: **Short Signatures from the Weil Pairing**, by Boneh, Dan and Lynn, Ben and Shacham, Hovav, *in Journal of Cryptology*, 2004
[^BT04]: **Barycentric Lagrange Interpolation**, by Berrut, J. and Trefethen, L., *in SIAM Review*, 2004
[^GAGplus19]: **SBFT: A Scalable and Decentralized Trust Infrastructure**, by G. Golan Gueta and I. Abraham and S. Grossman and D. Malkhi and B. Pinkas and M. Reiter and D. Seredinschi and O. Tamir and A. Tomescu, *in 2019 49th Annual IEEE/IFIP International Conference on Dependable Systems and Networks (DSN)*, 2019, [[PDF]](https://arxiv.org/pdf/1804.01626.pdf).
[^GJKR07]: **Secure Distributed Key Generation for Discrete-Log Based Cryptosystems**, by Gennaro, Rosario and Jarecki, Stanislaw and Krawczyk, Hugo and Rabin, Tal, *in Journal of Cryptology*, 2007
[^GPS08]: **Pairings for cryptographers**, by Steven D. Galbraith and Kenneth G. Paterson and Nigel P. Smart, *in Discrete Applied Mathematics*, 2008
[^KL15]: **Introduction to Modern Cryptography**, by Jonathan Katz and Yehuda Lindell, 2007
[^Shamir79]: **How to Share a Secret**, by Shamir, Adi, *in Commun. ACM*, 1979
[^TCZplus20]: **Towards Scalable Threshold Cryptosystems**, by Alin Tomescu and Robert Chen and Yiming Zheng and Ittai Abraham and Benny Pinkas and Guy Golan Gueta and Srinivas Devadas, *in 2020 IEEE Symposium on Security and Privacy (SP)*, 2020, [[PDF]](/papers/dkg-sp2020.pdf).
[^vG13ModernCh10]: **Fast polynomial evaluation and interpolation**, by von zur Gathen, Joachim and Gerhard, Jurgen, *in Modern Computer Algebra*, 2013
