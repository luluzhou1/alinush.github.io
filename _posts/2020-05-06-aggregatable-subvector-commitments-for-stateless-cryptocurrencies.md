---
tags: vector-commitments vc polynomials fast-fourier-transform fft lagrange aggregation kate-zaverucha-goldberg kzg polycommit
title: "Aggregatable Subvector Commitments for Stateless Cryptocurrencies (from Lagrange polynomials)"
date: 2020-05-06 14:00:00
published: false
---
{: .info}
We build a vector commitment (VC) scheme from KZG commitments to Lagrange polynomials which has (1) constant-sized, aggregatable proofs, which can all be precomputed in $O(n\log{n})$ time, and (2) linear public parameters, which can be derived from any "powers-of-tau" CRS in $O(n\log{n})$ time.
Importantly, the auxiliary information needed to update proofs (a.k.a. the "update key") is $O(1)$-sized.
Our scheme is compatible with recent techniques to aggregate subvector proofs across _different_ commitments[^GRWZ20].

<!--more-->

Our **full paper** is available online [here](https://eprint.iacr.org/2020/527) and is currently under peer review.

<p hidden>$$
\def\G{\mathbb{G}}
\def\Zp{\mathbb{Z}_p}
$$</p>
<!--  \overset{\mathrm{def}}{=} -->

## Preliminaries

Let $[i,j]=\\{i,i+1,i+2,\dots,j-1,j\\}$ and $[0, n) = [0,n-1]$.
Let $p$ be a sufficiently large prime that denotes the order of our groups.

In this post, beyond basic group theory for cryptographers[^KL15] and basic polynomial arithmetic, I will assume you are familiar with a few concepts:

 - **Bilinear maps**[^GPS08]. Specifically, $\exists$ a bilinear map $e : \G_1 \times \G_2 \rightarrow \G_T$ such that:
    - $\forall u\in \G_1,v\in \G_2, a\in \Zp, b\in \Zp, e(u^a, v^b) = e(u,v)^{ab}$
    - $e(g_1,g_2)\ne 1_T$ where $g_1,g_2$ are the generators of $\G_1$ and $\G_2$ respectively and $1_T$ is the identity of $\G_T$
 - **KZG**[^KZG10a] **polynomial commitments** (see [here](/2020/05/06/kzg-polynomial-commitments.html)),
 - The **Fast Fourier Transform (FFT)**[^CLRS09] applied to polynomials. Specifically,
    - Suppose $\Zp$ admits a primitive _root of unity_ $\omega$ of order $n$ (i.e., $n \mid p-1$)
    - Let $$H=\{1, \omega, \omega^2, \omega^3, \dots, \omega^{n-1}\}$$ denote the set of all $n$ $n$th roots of unity
    - Then, FFT can be used to efficiently evaluate any polynomial $\phi(X)$ at all $X\in H$ in $\Theta(n\log{n})$ time
        - i.e., compute all $$\{\phi(\omega^{i-1})\}_{i\in[n]}$$

## VCs from Lagrange polynomials

We build upon a previous line of work on VCs from Lagrange polynomials[^CDHK15]<sup>,</sup>[^KZG10a]<sup>,</sup>[^Tomescu20].

### References

[^Boldyreva03]: **Threshold Signatures, Multisignatures and Blind Signatures Based on the Gap-Diffie-Hellman-Group Signature Scheme**, by Boldyreva, Alexandra, *in PKC 2003*, 2002
[^BLS04]: **Short Signatures from the Weil Pairing**, by Boneh, Dan and Lynn, Ben and Shacham, Hovav, *in Journal of Cryptology*, 2004
[^BT04]: **Barycentric Lagrange Interpolation**, by Berrut, J. and Trefethen, L., *in SIAM Review*, 2004
[^CLRS09]: **Introduction to Algorithms, Third Edition**, by Cormen, Thomas H. and Leiserson, Charles E. and Rivest, Ronald L. and Stein, Clifford, 2009
[^CDHK15]: **Composable and Modular Anonymous Credentials: Definitions and Practical Constructions**, by Camenisch, Jan and Dubovitskaya, Maria and Haralambiev, Kristiyan and Kohlweiss, Markulf, *in Advances in Cryptology -- ASIACRYPT 2015*, 2015
[^CPZ18]: **Edrax: A Cryptocurrency with Stateless Transaction Validation**, by Alexander Chepurnoy and Charalampos Papamanthou and Yupeng Zhang, *in Cryptology ePrint Archive, Report 2018/968*, 2018
[^FK20]: **Fast amortized Kate proofs**, by Dankrad Feist and Dmitry Khovratovich, 2020, [[pdf]](https://github.com/khovratovich/Kate/blob/master/Kate_amortized.pdf)
[^GAGplus19]: **SBFT: A Scalable and Decentralized Trust Infrastructure**, by G. Golan Gueta and I. Abraham and S. Grossman and D. Malkhi and B. Pinkas and M. Reiter and D. Seredinschi and O. Tamir and A. Tomescu, *in 2019 49th Annual IEEE/IFIP International Conference on Dependable Systems and Networks (DSN)*, 2019, [[PDF]](https://arxiv.org/pdf/1804.01626.pdf).
[^GJKR07]: **Secure Distributed Key Generation for Discrete-Log Based Cryptosystems**, by Gennaro, Rosario and Jarecki, Stanislaw and Krawczyk, Hugo and Rabin, Tal, *in Journal of Cryptology*, 2007
[^GPS08]: **Pairings for cryptographers**, by Steven D. Galbraith and Kenneth G. Paterson and Nigel P. Smart, *in Discrete Applied Mathematics*, 2008
[^GRWZ20]: **Pointproofs: Aggregating Proofs for Multiple Vector Commitments**, by Sergey Gorbunov and Leonid Reyzin and Hoeteck Wee and Zhenfei Zhang, *in Cryptology ePrint Archive, Report 2020/419*, 2020, [[URL]](https://eprint.iacr.org/2020/419)
[^KL15]: **Introduction to Modern Cryptography**, by Jonathan Katz and Yehuda Lindell, 2007
[^KZG10a]: **Constant-Size Commitments to Polynomials and Their Applications**, by Kate, Aniket and Zaverucha, Gregory M. and Goldberg, Ian, *in ASIACRYPT '10*, 2010
[^Shamir79]: **How to Share a Secret**, by Shamir, Adi, *in Commun. ACM*, 1979
[^TCZplus20]: **Towards Scalable Threshold Cryptosystems**, by Alin Tomescu and Robert Chen and Yiming Zheng and Ittai Abraham and Benny Pinkas and Guy Golan Gueta and Srinivas Devadas, *in 2020 IEEE Symposium on Security and Privacy (SP)*, 2020, [[PDF]](/papers/dkg-sp2020.pdf).
[^Tomescu20]: **How to Keep a Secret and Share a Public Key (Using Polynomial Commitments)**, by Tomescu, Alin, 2020
[^vG13ModernCh10]: **Fast polynomial evaluation and interpolation**, by von zur Gathen, Joachim and Gerhard, Jurgen, *in Modern Computer Algebra*, 2013

[prevpost]: https://alinush.github.io/2020/03/12/towards-scalable-vss-and-dkg.html
