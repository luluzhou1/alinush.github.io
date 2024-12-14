---
tags:
title: ECDSA signatures
#date: 2020-11-05 20:45:59
#published: false
#sidebar:
#    nav: cryptomat
---

{: .info}
**tl;dr:** ECDSA is one of the most widely-deployed signature schemes (for better or worse).
ECDSA is _efficient_, offers _versatility_ via its _pubkey recovery_ feature and is widely adopted due to Bitcoin's success.
Its history is fascinating, as is its security analysis.
Nonetheless: you should **stay away from it**, as I argue [here](#why-you-should-avoid-ecdsa).

<!--more-->

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

## Preliminaries

 - Let $\lambda$ denote a security parameter (typically, set to 128)
 - Let $\Gr$ denote a group of prime order $p$, where $p \approx 2^{2\lambda}$, such that the discrete logarithm assumption is hard in $\Gr$
    - For ECDSA, $\Gr$ is an elliptic curve group[^Cost12]
    - In this case, we let $\Fq$ denote the base field of the elliptic curve group $\Gr$
 - Let $g$ denote the generator of $\Gr$
 - Let $\Zp$ denote the finite field of order $p$ that arises "in the exponent" of $g$
 - We assume a collision-resistant hash function $H : \\{0,1\\}^\* \rightarrow \Zp$
    + As per Brown's formalization of _AbstractDSA_[^Brow02].

## History

{: .todo}
Describe sequence of events: ElGamal signatures, Schnorr patent, DSA signatures, ECDSA signatures, Daniel L. Brown's ECDSA pubkey recovery algorithm[^Brow02]$^,$[^fgrieu-pubkey-recovery]


## The ECDSA signature scheme

{: .info}
It is **important** to understand that ECDSA only works with **eliptic curve** groups $\Gr$.
Such curves are "built" over a **base field** $\Fq$ such that each group element, or **point**, $P\in\Gr$ is represented by its $x$ and $y$ coordinates: i.e., $P=(x,y)\in\Fq^2$.

### The ECDSA "conversion function"

Another important detail about ECDSA is that it assumes a **conversion function** $f : \Gr \rightarrow \Zp$ that maps a group element into a non-zero field element, which works as follows:

$f(R) \rightarrow r\in \Zp$:
 1. Let $(x,y)\in\Fq^2$ denote the elliptic curve coordinates of point $R \in \Gr$
 1. Let $\bar{x}$ denote the integer representation of $x$
 1. $r\gets \bar{x} \bmod p$

### Algorithms

ECDSA key generation, signing and signature verification work as follows:

$\mathsf{ECDSA}$.$\mathsf{KeyGen}(1^\lambda) \rightarrow (\sk, \pk)\in\Gr^2$:
 - $\sk \randget \Zp\setminus\\{0\\}\ \textcolor{grey}{\text{// 0 is excluded as a valid SK}}$
 - $\pk \gets g^\sk$

$\mathsf{ECDSA}$.$\mathsf{Sign}(m, \sk) \rightarrow \sigma\in\Zp^2$:
 1. $k \randget \Zp\setminus\\{0\\}\ \textcolor{grey}{\text{// 0 is excluded as a valid nonce}}$
 1. $R\gets g^k$ 
 1. $r\gets f(R)$ (see the [conversion function](#the-ecdsa-conversion-function) above)
     - **if** $r\equals 0$, go back to **step 1**
 1. $e\gets H(m)\in\Zp$
 1. $s \gets k^{-1}(e + \sk\cdot r) \bmod p$ 
     - **if** $s\equals 0$, go back to **step 1**
 1. $\sigma\gets (r,s)$

{: .info}
**Security:** It is _crucial_ that there be absolutely no bias when picking $k$.
It must pe picked uniformly at random in $\Zp\setminus\\{0\\}$.
Otherwise, an attacker who sees enough ECDSA signatures can ultimately recover the SK[^BH19e].

{: .info}
**Security:** Not only is $(r,s)$ a valid signature but so is $(r,-s)$ which introduces _malleability attacks_.
\
_Historical aside:_ Such attacks may have played a small role in the MtGox attacks[^DW14], where \$620 million worth of Bitcoin disappeared.
However, the predominant theory is that there is other funny business that accounts for most of the stolen funds[^mtgox].

$\mathsf{ECDSA}$.$\mathsf{Verify}(m, \pk, \sigma) \rightarrow \\{0,1\\}$:
 - $(r,s)\gets \sigma$
 - **assert** $r \in \Zp\setminus\\{0\\}$
 - **assert** $s \in \Zp\setminus\\{0\\}$
 - **assert** $r \equals f\left(\left(g^{H(m)} \pk^r\right)^{s^{-1}}\right)$

{: .note}
In practice, computing this as a size-2 multiexp $g^{s^{-1}H(m)}\pk^{s^{-1} r}$ will be faster!

#### Avoiding a field inversion during verification

Verification computes a field inversion $s^{-1} \bmod p$, which can be expensive.
However, observe that if we changed signing to output $s\gets k(e+\sk\cdot r)^{-1}$, then verification would just be $r\equals f((g^{H(m)} \pk^r)^s)$.

This [remains secure](https://crypto.stackexchange.com/questions/113745/ecdsa-without-field-inversion-during-verification/113749#113749), gives slightly faster verification, but precludes precomputing many $(k,k^{-1},R)$ tuples so as to make signing faster. 
Instead, a field inversion $(e+\sk\cdot r)^{-1}$ must be computed during signing. 
Because it depends on the message, precomputation is not possible. 

Nonetheless, this is a great trade-off in applications where fast verification time is crucial, such as blockchain TXN signature verification.
(Unfortunately, this modification is no longer standard ECDSA, so it will never see wide adoption...)

{: .note}
Interestingly, avoiding this modular inversion during signing could have avoided a recent side-channel attack on ECDSA signing[^eea-side-channel]\: "This vulnerability lies in the ECDSA ephemeral key (or nonce) modular inversion. [...] More precisely, in the Infineon implementation of the Extended Euclidean Algorithm (EEA for short). To our knowledge, this is the first time an implementation of the EEA is shown to be vulnerable to side-channel analysis"

### Correctness

We show that correctly-computed signatures verify (i.e., "correctness") by expanding the verification equation:
\begin{align}
\label{eq:ecdsa-verify}
r &\equals f\left(\left(g^{H(m)} \pk^r\right)^{s^{-1}}\right)\Leftrightarrow\\\\\
r &\equals f\left(\left(g^{H(m)} g^{\sk \cdot r}\right)^{s^{-1}}\right)\Leftrightarrow\\\\\
r &\equals f\left(\left(g^{H(m) + \sk \cdot r}\right)^{s^{-1}}\right)\Leftrightarrow\\\\\
r &\equals f\left(g^{s^{-1}(H(m) + \sk \cdot r)}\right)\Leftrightarrow\\\\\
r &\equals f\left(g^{\left(k^{-1}(e + \sk\cdot r)\right)^{-1}(H(m) + \sk \cdot r)}\right)\Leftrightarrow\\\\\
r &\equals f\left(g^{k(e + \sk\cdot r)^{-1}(H(m) + \sk \cdot r)}\right)\Leftrightarrow\\\\\
r &\equals f\left(g^{k(H(m) + \sk\cdot r)^{-1}(H(m) + \sk \cdot r)}\right)\Leftrightarrow\\\\\
r &\equals f\left(g^k\right)\Leftrightarrow\\\\\
r &= f\left(R\right)
\end{align}

## Pubkey recovery algorithm

ECDSA, together with some variants of [Schnorr](/2024/05/31/Schnorr-signatures.html#pubkey-recovery), are one of the few schemes that support a **pubkey recovery** algorithm: i.e., an algorithm that, given a signature $\sigma$ on a message $m$, returns (a set of) public key(s) under which $\sigma$ verifies on $m$.

Pubkey recovery is actually used in cryptocurrencies like Ethereum and Bitcoin, where the verifiers (i.e., the miners/validators) do not have the PK of the account, but only its hash $h$.
Specifically, the verifiers:
1. Receive only $(\sigma,m)$
2. Use the pubkey recovery algorithm to recover a set of PKs $S=\\{\pk_1,\ldots,\pk_\ell\\}$ under which $(\sigma,m)$ verify 
3. Check whether there exists a $\pk_i \in S$ such that $h=H(\pk_i)$. (This step is crucial.)
4. If so, they can consider the message $m$ (typically a TXN hash) as validly-signed under the PK $\pk_i$ hashed inside the address $h$[^P2PKH].

Let's try to figure out how pubkey recovery might work.
We know from the verification algorithm in Eq. \ref{eq:ecdsa-verify} that, given a correctly-computed ECDSA signature $(r,s)$, where $r=f(R)$, we have:
\begin{align}
f(R) &= f\left(\left(g^{H(m)} \pk^r\right)^{s^{-1}}\right)
\end{align}

Assume for a second that the function $f$ were [injective](https://en.wikipedia.org/wiki/Injective_function), which it is not. Then, the equation above would imply:
\begin{align}
R &= \left(g^{H(m)} \pk^r\right)^{s^{-1}}\Leftrightarrow\\\\\
R^s &= g^{H(m)} \pk^r\Leftrightarrow\\\\\
R^s / g^{H(m)} &= \pk^r\Leftrightarrow\\\\\
\label{eq:pubkey-recovery}
\left(R^s / g^{H(m)}\right)^{(r^{-1})} &= \pk\\\\\
\end{align}

This means that, for a correctly-computed $(r,s)$, we could invert $R = f^{-1}(r)$ and then extract the PK as per Eq. \ref{eq:pubkey-recovery}.

However, things are not so simple.

**Challenge 1:** First, as stated above, $f$ is **not** injective.
A little elliptic curve background is required to understand why.
The _tl;dr_ is that, given an $x$-coordinate of a point on an elliptic curve $E_{a,b}(\Fq): y^2 = x^3 + ax + b$, there are two possible $y$-coordinates that satisfy the equation: i.e., $y=\pm\sqrt{x^3 + ax+b}$. 

As a consequence, given the $x$-coordinate $x$ of $R$, we can extract two points $R$ and $R'$ such that $r=f(R)=f(R')$.
Plugging both of these possibilites for $R$ in Eq. \ref{eq:pubkey-recovery} now yields **two possible public keys**.
This is fine: it just means the signature verifies against either one.

**Challenge 2:** Above, we assumed we have the $x$-coordinate $x$ of $R$.
But the ECDSA signature does not include $x \in \Fq$; it only includes $\bar{x} \bmod p = r\in \Zp$, where $\bar{x}$ is the representation $x$ as an integer $\in [0,q)$. 
(Recall that $p$ is the order of the elliptic curve with base field $\Fq$.)
By [Hasse's theorem](https://en.wikipedia.org/wiki/Hasse%27s_theorem_on_elliptic_curves), we know that:

$$(q + 1) - 2\sqrt{q} \le p \le (q+1) + 2\sqrt{q}$$

So, it could be that $p \ge q$ or that $p < q$.

**Case 1:** If $p\ge q$, then given $r$, we can recover $x$ since the $\bmod p$ operation does not truncate $x$ when computing $r$.

**Case 2:** But, if $p < q$, it could be that $\bar{x} \in [0,q)$ was truncated when computing $r=\bar{x} \bmod p$ (i.e., it could be that $\bar{x} \ge p$).
So, this means we have two possible x-coordinates[^bitcoin-stex]:
\begin{align}
x_1 &= \bar{r} \in [0,q)\\\\\
x_2 &= (\bar{r} + p) \bmod q
\end{align}
<!-- 
Only need to do (\bar{r} + p) \bmod q, because |p - q| < 2\sqrt{q} 
-->
Then, each $x_i$ will have two possible y-coordinates: $y_i=\pm\sqrt{x_i^3 + ax_i + b}$.
And as a result, there are now four possible $R$'s to recover:
\begin{align}
R_1 &= (x_1, y_1)\\\\\
R_1' &= (x_1, -y_1)\\\\\
R_2 &= (x_2, y_2)\\\\\
R_2' &= (x_2, -y_2)\\\\\
\end{align}
To avoid the need to brute force all possible $R$ values, some systems like Ethereum, include a 2-bit **hint** or **recovery ID** $v$ next to an ECDSA signature $(r,s)$.
This $v$ indicates to a verifier which one of the 4 values above should be computed as the actual $R$, saving precious signature verification computation. 
This is why, in online folklore, you will find ECDSA signatures described as a triple $(r,s,v)$.

## Why you should avoid ECDSA

There is **no** good reason to ever use ECDSA (except for legacy compatibility). 
At least, this is my current (limited?) sense. 

As far as I can tell, [Schnorr signatures](/2024/05/31/Schnorr-signatures.html) should always be preferred over it:
 - Schnorr is _slightly_ faster (no field inversions)
 - Schnorr admits a more efficient $t$-out-of-$n$ threshold signing protocol
 - Schnorr has a simpler pubkey recovery (no recovery hints needed)
 - Schnorr has an arguably-cleaner security reduction

Other disadvantages of ECDSA:

 1. ECDSA is **inefficient as a $t$-out-of-$n$ threshold signature** scheme
 1. ECDSA, like [Schnorr](/2024/05/31/Schnorr-signatures.html), is broken if the **nonce $k$ is reused**. Generally, they are both very **fragile** if the nonce $k$ is biased[^BH19e].
    + Even small amounts of bias in the nonce $k$ can be used to recover the SK given enough signatures.
    - Deterministic signing can mitigate this in both schemes.
 1. ECDSA does **not** have a **"clean" security reduction** to a standard assumption
    - Typically, ECDSA security reductions must make assumptions about the [conversion function](#the-ecdsa-conversion-problem)
    - ...or work in the generic group model (GGM)
    - ...or introduce strange assumptions like the _semi-discrete logarithm (SDLP)_ problem
    - For the latest security analysis, see recent works by Eike Kiltz[^FKP16]$^,$[^HK23e].

{: .note}
Although ECDSA can be very fragile in the face of side-channels (e.g., extracting ECDSA keys from Yubikeys[^eea-side-channel], it is not clear to what extent other schemes would fare better (e.g., both [Schnorr](/2024/05/31/Schnorr-signatures.html) and BLS[^BLS01] do exponentiations with secrets).

## TODOs

Other items I hope to address in the future:

 - I hope to write down a reasonable proof of EUF-CMA security.
 - Other [summaries of why ECDSA is very feeble](https://blog.trailofbits.com/2020/06/11/ecdsa-handle-with-care/).
 - [Signing as $(R,s)$](https://crypto.stackexchange.com/questions/53025/what-is-customizable-in-ecdsa-signature-and-verification) when combining ECDSA with other algorithms.
 - Look into [Shamir trick stuff](https://crypto.stackexchange.com/questions/47627/goofs-that-could-creep-in-ecdsa-signature-verification)
 - Address implementations checking that $R$ is not the identity
 - An unecessary check that [the PK is not the identity](https://crypto.stackexchange.com/questions/74354/ecdsa-signature-verification-checks) during verification
 - Incorporate insights from [SEC 1: Elliptic curve cryptography](https://www.secg.org/sec1-v2.pdf)

---

[^bitcoin-stex]: See [this comment](https://bitcoin.stackexchange.com/questions/38351/ecdsa-v-r-s-what-is-v/38909#comment46061_38909) on Bitcoin Stack Exchange for a similar explanation.
[^eea-side-channel]: [EUCLEAK](https://ninjalab.io/eucleak/), by NinjaLab
[^fgrieu-pubkey-recovery]: [ECDSA public key recovery is discovered by whom?](https://crypto.stackexchange.com/questions/60958/ecdsa-public-key-recovery-is-discovered-by-whom)
[^mtgox]: Citing from [DW14][^DW14]: _"In combination with the above mentioned success rate of malleability attacks we conclude that overall malleability attacks did not have any substantial inﬂuence in the loss of bitcoins incurred by MtGox."_
[^P2PKH]: [ECDSA verification, P2PKH uncompressed address](https://en.bitcoin.it/wiki/Message_signing#ECDSA_verification.2C_P2PKH_uncompressed_address)

{% include refs.md %}
