---
tags:
 - ElGamal
 - encryption
title: ElGamal encryption
#date: 2020-11-05 20:45:59
#published: false
permalink: elgamal
#sidebar:
#    nav: cryptomat
#article_header:
#  type: cover
#  image:
#    src: /pictures/.jpg
---

{: .info}
**tl;dr:** ElGamal public key encrypting $\approx$ Using an ephemeral Diffie-Hellman exchanged key as a one-time pad.

<!--more-->

<!-- Here you can define LaTeX macros -->
<div style="display: none;">$
\def\ek{\mathsf{ek}}
\def\dk{\mathsf{ek}}
$</div> <!-- $ -->

## Preliminaries

 - We assume a group $\Gr$ where Decisional Diffie-Hellman (DDH) is hard
 - We use additive group notation for $\Gr$

## ElGamal

In this variant, the encryption pubkey is $\ek \bydef \dk \cdot H$ where $H$ is another generator such that $\log_G{H}$ is unknown and hard to compute.

### $\mathsf{E}.\mathsf{KGen}(1^\lambda) \rightarrow (\mathsf{dk}, \mathsf{ek})$

 - $\dk \randget \F$
 - $\ek \gets \dk \cdot H$

{: .note}
The [original ElGamal paper](#original-elgamal) reuses $G$ for the $\ek$ instead of a different $H$.

### $\mathsf{E}.\mathsf{Enc}(\mathsf{ek}, m; r) \rightarrow (C, D)$

 - $C \gets m \cdot G + r\cdot \ek$
 - $D \gets r \cdot H$

### $\mathsf{E}.\mathsf{Dec}(\mathsf{dk}, (C,D)) \rightarrow m\cdot G$

 - **return** $C - \dk \cdot D$

## Twisted ElGamal

{: .todo}

## Appendix

### Original ElGamal

The original ElGamal encryption paper[^Elga85] talks about encrypting a group element $m \in \Gr$, where $\Gr =\Zp$ and $p=kq+1$ for some other large prime $q$. (These days, $q \approx 2^{3072}$.)

First, the paper recalls the Diffie-Hellman[^DH76] key exchange:
<div align="center"><img style="width:50%" src="/pictures/elgamal/elga1.png" /></div>

Then, it emphasizes that the prime $p$ should have a large prime factor (i.e., our $q$ above):
<div align="center"><img style="width:50%" src="/pictures/elgamal/elga2.png" /></div>

Lastly, it introduces the scheme by describing how to encrypt and decrypt a **group element** in $m\in\Gr$:
<div align="center"><img style="width:50%" src="/pictures/elgamal/elga3.png" /></div>

Great were the days when the main result of a cryptography paper could be stated in three paragraphs like this! 🥲

## References

For cited works, see below 👇👇

{% include refs.md %}
