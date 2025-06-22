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

## Standard ElGamal

## Damgård's ElGamal

In this variant, the encryption pubkey is $\ek \bydef \dk \cdot H$ where $H$ is another generator such that $\log_G{H}$ is unknown and hard to compute.

### $\mathsf{E}.\mathsf{KGen}(1^\lambda) \rightarrow (\dk, \ek)$

 - $\dk \randget \F$
 - $\ek \gets \dk \cdot H$

{: .todo}
Can this be $G$, or must it be a different $H$?

### $\mathsf{E}.\mathsf{Enc}(\ek, m; r) \rightarrow (C, D)$

 - $C \gets m \cdot G + r\cdot \ek$
 - $D \gets r \cdot H$

### $\mathsf{E}.\mathsf{Dec}(\dk, (C,D)) \rightarrow m\cdot G$

 - **return** $C - \dk \cdot D$

## Twisted ElGamal

{: .todo}

## References

For cited works, see below 👇👇

{% include refs.md %}
