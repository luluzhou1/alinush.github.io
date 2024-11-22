---
tags:
title: BBS+ signatures
#date: 2020-11-05 20:45:59
#published: false
sidebar:
    nav: cryptomat
#article_header:
#  type: cover
#  image:
#    src: /pictures/.jpg
---

{: .info}
**tl;dr:** BBS+ is a transformation[^ASM08e] of the the _Boneh-Boyen-Shacham (BBS)_ **group** signature scheme[^BBS04] into a **standalone** signature scheme.
This blog post describes BBS+ as well as a recent improvement over it dubbed **standalone BBS**[^TZ23e].

## Why BBS+?

The [BBS+](#the-bbs-signature-scheme) and [standalone BBS](#the-standalone-bbs-signature-scheme) schemes have some really **nice properties**:

 - Can sign a vector of field elements $(m_1,m_2,\ldots,m_\ell)\in \Zp$
   + The signing [can be done blindly](#how-to-sign-blindly-in-bbs) over a Pedersen vector commitment to the elements
   + This way, the signer gets the commitment to sign and never sees the messages $m_i$ themselves
 - Does not rely on random oracles
 - It is as efficient to verify as BLS[^BLS01] signatures: a size-2 multipairing

These properties makes BBS+ (and standalone BBS) very useful for building **anonymous credential (AC)** schemes.
(In a future post, I hope to constrast BBS+ with other schmes like CL or [Pointcheval-Sanders (PS)](/2023/01/08/Pairing-based-anonymous-credentials-and-the-power-of-re-randomization.html).)

## Preliminaries
 
 - There is a [bilinear map](/2022/12/31/pairings-or-bilinear-maps.html) $e : \Gr_1 \times \Gr_2 \rightarrow \Gr_T$, where $\Gr_1 = \langle g_1 \rangle, \Gr_2 = \langle g_2 \rangle$ and $\Gr_T$ are of prime order $p$
 - Let $\Zp = \\{0,1,2,\ldots,p-1\\}$ denote the finite field of order $p$. 
 - A Pedersen commitment to a vector $(m_1,\ldots,m_\ell) \in \Zp^\ell$ is $C = h_0^r \prod_{i\in[\ell]} h_i^{m_i}$, where $r \randget \Zp$ is a uniformly-picked blinding factor and $(h_0,\ldots,h_\ell)$ are fixed generators in a group $\Gr$ of order $p$ whose pairwise discrete logs are unknown.

## The BBS+ signature scheme

{: .info}
BBS+ is slightly less efficient than [standalone BBS](#the-standalone-bbs-signature-scheme), so it should probably be dropped in favor of the latter.

$\mathsf{BBS+}$.$\mathsf{KeyGen}(1^\lambda, \ell) \rightarrow (\sk, \pk)$:
 - $\mathbf{h} \stackrel{\mathsf{def}}{=} (h_0, h_1 \ldots, h_{\ell}) \gets \Gr_1^{\ell+1}$
 - $x \randget \Zp$
 - $y \gets g_2^x$
 - $\sk \gets (x, \mathbf{h})$
 - $\pk \gets (y, \mathbf{h})$

$\mathsf{BBS+}$.$\mathsf{Sign}((m_1,\ldots,m_\ell), \sk) \rightarrow \sigma$:
 - $(x, \mathbf{h}) \gets \sk$
 - $(e, s)\randget \Zp^2$
 - $C \gets g_1 h_0^s \prod_{i\in[\ell]} h_i^{m_i}$
    + **Note:** This is a Pedersen-like commitment to the $m_i$'s. (Except it is not blinded, since the randomness $s$ is publicly-exposed as part of the signature.)
 - $\sigma \stackrel{\mathsf{def}}{=} (A, e, s) \gets \left(C^\frac{1}{x + e}, e, s\right)$

{: .info}
The randomness $s$ is needed to prove BBS+ secure. Fortunately, the recent [stBBS](#the-standalone-bbs-signature-scheme) variant can be proven secure without such an $s$, which results in slightly faster signing and smaller signatures!

$\mathsf{BBS+}$.$\mathsf{Verify}((m_1,\ldots,m_\ell), \pk, \sigma) \rightarrow \\{0,1\\}$:
 - $(y,\mathbf{h})\gets \pk$ 
 - $(A, e, s)\gets \sigma$
 - $C \gets g_1 h_0^s \prod_{i\in[\ell]} h_i^{m_i}$
 - **assert** $e(A, y \cdot g_2^e) \equals e(C, g_2)$


**Correctness:**
It is easy to see why correctness holds (i.e., signatures produced by $\mathsf{BBS+}.\mathsf{Sign}$ pass verification in $\mathsf{BBS+}.\mathsf{Verify}$):
\begin{align}
e(A, y \cdot g_2^e) &\equals e(C, g_2)\\\\\
e\left(C^\frac{1}{x + e}, g_2^x \cdot g_2^e\right) &\equals e(C, g_2)\\\\\
e\left(C^\frac{1}{x + e}, g_2^{x + e}\right) &\equals e(C, g_2)\\\\\
e(C, g_2) &\equals e(C, g_2)
\end{align}

### How to sign blindly in BBS+

{: .info}
This section assumes familiarity with ZKPoK of Pedersen commitment openings and the existence of two algorithms for this:
$\mathsf{ZK}.\mathsf{ProveKnowledge}$ and $\mathsf{ZK}.\mathsf{VerifyProofOfKnowledge}$


We will introduce some new algorithms to allow for the _blind signing_ flow, which works as follows:
1. The user, who is trying to get the signature, uses a new $\mathsf{BBS+}$.$\mathsf{Commit}$ algorithm to produce a blinded Pedersen commitment $C$ (with blinder $s_1$) to the messages he is trying to sign without revealing.
2. The user sends the commitment $C$ together with a ZKPoK of opening $\pi$ to the signer.
3. The signer calls a new $\mathsf{BBS+}$.$\mathsf{BlindSign}$ algorithm on this commitment $C$ and the proof $\pi$.
4. This algorithm verifies the proof $\pi$ against $C$ and returns a blind signature $(A, e, s_2)$.
5. The user unblinds this signature by calling $\mathsf{BBS+}.\mathsf{Unblind}$ on $(A, e, s_2)$ and the commitment blinder $s_1$.
6. The final (unblinded) signature is $(A, e, s) \bydef (A, e, s_1 + s_2)$.

The new algorithms follow below:

$\mathsf{BBS+}$.$\mathsf{Commit}((m_1,\ldots,m_\ell); s_1) \rightarrow (C,\pi)$:
 - $C \gets h_0^{s_1} \prod_{i\in[\ell]} h_i^{m_i}$
 - $\pi \gets \mathsf{ZK}.\mathsf{ProveKnowledge}\left((s_1, m_1, \ldots, m_\ell) : C = h_0^{s_1} \prod_{i\in[\ell]} h_i^{m_i}\right)$

{: .info}
**Note:** This is a properly-blinded Pedersen commitment. There is no $g_1$ component; it will be added later during signing.


$\mathsf{BBS+}$.$\mathsf{BlindSign}(C, \pi) \rightarrow (A, e, s_2)$:
 - **assert** $\mathsf{ZK}.\mathsf{VerifyProofOfKnowledge}(C, \pi) \equals 1$
 - $s_2\randget \Zp$
 - $e\randget\Zp$
 - $A \gets (g_1 h_0^{s_2} \cdot C)^\frac{1}{x+e}$

$\mathsf{BBS+}.\mathsf{Unblind}(A, e, s_1, s_2) \rightarrow \sigma$
 - $\sigma \gets (A, e, s_1 + s_2)$

{: .info}
**Note:** $\mathsf{BBS+}.\mathsf{Unblind}$ returns a BBS+ signature that can be verified via $\mathsf{BBS+}.\mathsf{Verify}$. The nice thing is that the signer did not learn the signed messages, since it only saw (and blindly-signed) a Pedersen commitment to these messages. However, beware that once $\sigma = (A, e, s_1 + s_2)$ is revealed, the signer learns $s_1$, can unblind the commitment $C$, and brute-force the messages $m_i$. As a result, some privacy-preserving protocols aim to never reveal the signature $\sigma$. Instead, they reveal a zero-knowledge proof-of-knowledge (ZKPoK) of such a signature over messages that satisfy useful properties in these protocols. This can be done very efficiently via $\Sigma$ protocols.


## The standalone BBS signature scheme

BBS+ was a transformation of the BBS group signature scheme[^BBS04] into a standalone signature scheme by Au et al.[^ASM08e].
Unfortunately, this transformation increased the size of the signature from $(A, e)\in\Gr\times\Zp$ to $(A, e, s)\in\Gr\times\Zp^2$.
The $s$ component had to be included only so that the security proof could pass.
Recently, however, Tessaro and Zhu[^TZ23e] gave a security proof for BBS+ without an $s$-component, which they dubbed **standalone BBS signatures**.

{: .info}
I guess the alternative BBS++ name would have been worse?
On the other hand "[standalone] BBS"[^TZ23e] stands to be confused with the BBS [group] signature scheme[^BBS04].

Naming issues aside, Tessaro and Zhu's **standalone BBS (stBBS)** scheme's decription follows below.
(It is denoted as $\mathsf{stBBS}$ to avoid confusing it with the $\mathsf{BBS}$ group signature scheme.)

$\mathsf{stBBS}$.$\mathsf{KeyGen}(1^\lambda, \ell) \rightarrow (\sk, \pk)$:
 - (This is almost the same as in BBS+, except only $\ell$ $h_i$'s are needed.)
 - $\mathbf{h} \stackrel{\mathsf{def}}{=} (h_1, \ldots, h_\ell) \gets \Gr_1^{\ell}$
 - $x \randget \Zp$
 - $y \gets g_2^x$
 - $\sk \gets (x, \mathbf{h})$
 - $\pk \gets (y, \mathbf{h})$

$\mathsf{stBBS}$.$\mathsf{Sign}((m_1,\ldots,m_\ell), \sk) \rightarrow \sigma$:
 - $(x, \mathbf{h}) \gets \sk$
 - $e\randget \Zp$
 - $C \gets g_1 \prod_{i\in[\ell]} h_i^{m_i}$
    + **Note:** This is a Pedersen-like commitment to the $m_i$'s. (Except it is not blinded.)
 - $\sigma \stackrel{\mathsf{def}}{=} (A, e) \gets \left(C^\frac{1}{x + e}, e\right)$

{: .info}
Signing is slightly faster than in BBS+ because there is no $h_0^s$

$\mathsf{stBBS}$.$\mathsf{Verify}((m_1,\ldots,m_\ell), \pk, \sigma) \rightarrow \\{0,1\\}$:
 - $(y,\mathbf{h})\gets \pk$ 
 - $(A, e)\gets \sigma$
 - $C \gets g_1 \prod_{i\in[\ell]} h_i^{m_i}$
 - **assert** $e(A, y \cdot g_2^e) \equals e(C, g_2)$

### How to sign blindly in stBBS

This works slightly differently than in [BBS+](#how-to-sign-blindly-in-bbs) because stBBS signatures lack the $s$ component.
As a result, one of the signed messages themselves has to be used as Pedersen commitment blinder.
The blind-signing flow remains largely the same as in [BBS+](#how-to-sign-blindly-in-bbs):
1. The user, who is trying to get the signature, uses a new $\mathsf{stBBS}$.$\mathsf{Commit}$ algorithm to produce a blinded Pedersen commitment $C$ (with blinder $r$) to the messages $(m_1, m_2,\ldots,m_{\ell-1})$ he is trying to sign without revealing.
   + Note that there are $\ell-1$ instead of $\ell$ messages because the last message $m_\ell$ will be set to the blinder $r$.
2. The user sends the commitment $C$ together with a ZKPoK of opening $\pi$ to the signer.
3. The signer calls a new $\mathsf{stBBS}$.$\mathsf{BlindSign}$ algorithm on this commitment $C$ and the proof $\pi$.
4. This algorithm verifies the proof $\pi$ against $C$ and returns an stBBS signature $\sigma = (A, e)$ over the messages $(m_1,m_2,\ldots,m_{\ell-1}, r)$. (Note that the blinder $r$ is part of the signed message.)

The algorithms are described below:

$\mathsf{stBBS}$.$\mathsf{Commit}((m_1,\ldots,m_{\ell - 1}); r) \rightarrow (C,\pi)$:
 - $C \gets \left(\prod_{i\in[\ell-1]} h_i^{m_i}\right) h_\ell^r$
 - $\pi \gets \mathsf{ZK}.\mathsf{ProveKnowledge}\left((s_1, m_1, \ldots, m_{\ell-1}, r) : C = (\prod_{i\in[\ell-1]} h_i^{m_i}) h_\ell^r \right)$

$\mathsf{stBBS}$.$\mathsf{BlindSign}(C, \pi) \rightarrow \sigma$:
 - **assert** $\mathsf{ZK}.\mathsf{VerifyProofOfKnowledge}(C, \pi) \equals 1$
 - $e\randget\Zp$
 - $A \gets (g_1 \cdot C)^\frac{1}{x+e}$
 - $\sigma \gets (A, e)$

{: .info}
**Note:** There is no need to unblind the signature here, unlike in [BBS+](#how-to-sign-blindly-in-bbs).

{: .info}
Note that the signature verification is done as $\mathsf{stBBS}$.$\mathsf{Verify}((m_1,\ldots,m_{\ell-1},r), \pk, \sigma)$ and accounts for the blinder $r$ as one of the signed messages!

### How to pick $e$'s simply and securely

Unlike in BBS+, the requirement on picking $e$ is simpler: $e$ does not have to be picked uniformly at random. Instead, we only need to make sure $e$'s don't collide. The simplest way is to treat $e$ as an always-increasing counter. Or, to derive it pseudo-randomly (via hashing) from the signed message (in the non-blinded variant) or the signed commitment (in the blinded variant).

{: .warning}
**Warning:** Reusing $e$ leads to a forgery attack! Given a signature $\sigma_1 = \left(C_1^\frac{1}{x+e}, e\right)$, if $e$ is reused to create another signature $\sigma_2 = \left(C_2^\frac{1}{x+e},e\right)$, then an attacker can combine these into a signature $\sigma = \left((C_1 \cdot C_2)^\frac{1}{x+e}, e\right)$. If $C_1$ commits to $(m_1,\ldots, m_\ell)$ and $C_2$ commits to $(m_1',\ldots,m_\ell')$, then  the forged signature $\sigma$ would be over a commitment to $(m_1 + m_1', \ldots, m_\ell + m_\ell')$. In many applications, such as anonymous credentials or anonymous payment systems[^TBAplus22e], this would break security.

## Conclusion

BBS+ (and/or standalone BBS) are versatile signature schemes (e.g., can sign [commitments to] field element(s) without random oracles, can verify as fast as BLS[^BLS01], etc.).

However, like any signature scheme, they have their **disadvantages**:
 - **Larger signatures** for BBS+: 1 group element and 2 field elements.
    + Standalone BBS has _smaller_ signatures: 1 group element and 1 field element.
 - They **do not "thresholdize" very well**: $t$-out-of-$n$ threshold protocols for BBS+ (and standalone BBS) either require offline preprocessing or multiple rounds of interaction between signers.
 - Signing **requires randomness**.
 - Signatures are **not re-randomizable**[^PS16]. (It may be sufficient to expose $h_0^\frac{1}{x+e}$ next to each signature $(A,e)$ to allow for re-randomizability?)
<!--more-->

<!-- Here you can define LaTeX macros -->
<div style="display: none;">$
$</div>

---

{% include refs.md %}
