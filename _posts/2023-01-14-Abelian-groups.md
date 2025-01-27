---
tags: 
 - math
title: Abelian groups
#date: 2020-11-05 20:45:59
published: false
sidebar:
    nav: cryptomat
---

{: .info}
**math tl;dr:** An Abelian (or commutative) group is a set $S = \\{e_1, e_2, \ldots, e_n\\}$ that (1) admits an **operation** $\odot$ between elements such that $e_i \odot e_j = e_j \odot e_i = e_k$ for any $i,j$ and some $k$ in $\\{1, \ldots, n\\}$, (2) allows for **associativity**, or $\forall e_i, e_j, e_k$ in $S$, we have $e_i \odot (e_j \odot e_k) = (e_i \odot e_j) \odot e_k$  (3) has an **identity element** $e\in S$ such that for any $e_i \in S$, we have $e\odot e_i = e_i\odot e = e_i$, (4) for any element $e_i\in S$, there exists an **inverse element**, denoted $(e_i)^{-1} \in S$, such that $e_i \odot (e_i)^{-1} = e$ where $e$ is the identity element.

<!--more-->

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

## Introduction

Abelian groups are one of the most commonly used ingredients for cooking up a cryptosystems.

**tl;dr:** Put simply, an **Abelian** (or commutative) **group** is a **set** $S$ of **elements** that supports an **operation**: i.e., one can take any two elements from $S$, combine them with the operation and get back an element in the group.
This is referred to as $S$ being **closed under this operation**.
Importantly, this operation commutes, is invertible and associative.
We'll go into details later!

Understanding the details is crucial for cryptography, since today's most efficient cryptography relies on groups:

 - key-exchange schemes, such a Diffie-Hellman (DH)[^DH76],
 - public-key encryption schemes, such as RSA[^RSA78] or ElGamal[^Elga85],
 - digital signature schemes, such as Schnorr[^Schn89] or BLS[^BLS01],
 - polynomial commitment schemes, such as [KZG](2020/05/06/kzg-polynomial-commitments.html)[^KZG10]

(Well some of these cryptosystems, additionally rely on [pairings](http://localhost:4000/2022/12/31/pairings-or-bilinear-maps.html) across Abelian groups.)

### Motivation

If you're reading this post, chances are you've encountered one or more flavors of this notation:
\begin{align}
    &aG\\\\\
    &[a]G\\\\\
    &g^a\\\\\
    &g^a \pmod p\\\\\
    &g^{a \bmod q}\\\\\
    &g^{a \bmod q} \pmod p\\\\\
    &g^{a \bmod p-1} \pmod p
\end{align}
Or, you've read somewhere that a Schnorr signature on a message $m$ under secret key $x$ and public key $g^x$ is $(R, s)$ where:
\begin{align}
    R = g^r \qquad s = \left(r + H(g, g^x, R, m) \cdot x\right) \bmod q
\end{align}
But then someone else told you that the PK is actually denoted by $xP$ and the signature $(R, s)$ is in fact:
\begin{align}
    R = rP \qquad s = r + H(x, xP, R, m) \cdot x
\end{align}

So what is happening?

 - Why do people always exponentiate things in cryptography?

 - Why does so much different notation arises in cryptography?

 - What does this notation mean anyway?

 - Do you need to understand it to do cryptography? (Yes.)

 - Why are people always computing things modulo $q$, or $p$, or $p-1$?

The answer lies in understanding the details of _Abelian groups_.

## Preliminaries

 - You know how to multiply integers.
    + So you clearly know how to add them.
 + You remember basic properties of addition and multiplication:
    + Commutativity
    - There exists an identity element (e.g., $0 + a = a + 0 = 0$)
    - There exist inverses for each element (e.g., $a + (-a) = (-a) + a = 0$)
 - As a result you know that when you multiply an integer $g$ with itself $a$ times, you get $g^a$.
 - You know that $\forall a \in S$ means _"for all elements $a$ in set $S$"_.
 - You know that $\exists a \in S$ means _"there exists (at least) an element $a$ in set $S$"_.
 - You know how to divide an integer $a$ by another integer $b$ and obtain a quotient $Q$ and a **remainder** $r$ such that $a = Q\cdot b + r$ and $0 \le r < b$.
     - You also know that one can denote the remainder $r$ above as $r = a \bmod b$.
     - Computing $a \bmod b$ is often referred to as _"reducing $a$ modulo $b$"_ or as a _"reduction modulo $b$"_
 - Probably, you know about greatest common divisors (GCDs). We'll see.

## Addition modulo a prime $q$

Since you know how to add numbers, let us reason about adding numbers "with a twist."

If you're a normal person, you just add two integers like you were taught in 1st grade:

$$c = a + b$$

and call it a day.

But, for reasons you'll understand better, cryptographers often prefer to reduce the result modulo a prime $q$.

$$c' = (a + b) \bmod q$$

{: .info}
Recall from the [preliminaries](#preliminaries) what reduction modulo $q$ means: you compute $(a+b)$, divide it by $q$ and take the remainder to be the result $c'$.
For example, $(3 + 4) \bmod 5 = 7 \bmod 5 = 2$ because the remainder of dividing 7 by 5 is 2.

In fact, this operation (i.e., addition modulo a prime $q$), applied over the set of integers $\Zq = \\{0,1,2,\ldots, q-1\\}$ gives us the **first example of an Abelian group**

This group is denoted by $(\Zq, +)$, which indicates (1) the set $\Zq$ where the elements come from and (2) the operation $+$ (but reduced modulo $q$) applied to the elements.
We also more simply denote it as $\Zq$.

Note that $\Zq$ satisfies all the properties of an Abelian group we hinted at in the [introduction](#introduction).

### A set of $q$ elements

$\Zq$ is a set of $q$ elements $\Zq \stackrel{\mathsf{def}}{=} \\{0,1,2,\ldots,q-1\\}$.

### Closure under addition $\bmod q$

$\Zq$ is closed under addition modulo $q$:

Specifically, for any $a\in \Zq$ and for any $b\in \Zq$, we know that $(a+b) \bmod q$ will also land back in $\Zq$ because the remainder of division by $q$ is always a number from $0$ to $q-1$.

### $a + b \bmod q$ is commutative

Addition modulo $q$ is clearly commutative, since $(a + b) \bmod q = (b + a) \bmod q$.

### $0$ is an identity

There exists an identity element $e \in \Zq$ such that:

$$(a + e) \bmod q = (e + a) \bmod q = a, \forall a \in \Zq$$

Clearly, that element is $0 \in \Zq$ since:

$$(a + 0) \bmod q = (0 + a) \bmod q = a,\forall a \in Zq$$

**TODO:** Uniqueness of identity element.

### Addition modulo $q$ is associative.

The notation can become cumbersome unless we do a small trick: let us use $+_q$ to denote additional modulo $q$.
Specifically:
\begin{align}
a +_q b \stackrel{\mathsf{def}}{=} (a + b) \bmod q
\end{align}

What we need to show is that associativity holds: i.e., for any elements $a,b,c$ from $\Zq$, we have:
\begin{align}
(a +_q b) +_q c = a +_q (b +_q c)
\end{align}

The cumbersome way of denoting this would have been:
\begin{align}
(((a + b) \bmod q) + c) \bmod q = (a + ((b + c) \bmod q)) \bmod q
\end{align}

### Each element $a$ has an inverse $-a = q - a$

Addition modulo $q$ is invertible.

In other words, any element $a$ in $\Zq$ has an inverse, denoted by $-a$, such that $(a + (-a))\bmod q = 0$, where $0\in \Zq$ is the identity element [from above](#has-an-identity).

For $\Zq$, we can define the inverse of any element as:

$$\forall a\in\Zq, -a \stackrel{\mathsf{def}}{=} (q - a) \bmod q$$

$q-a$ is indeed an inverse for $a$ because:
\begin{align}
(a + (-a)) \bmod q
    &= (a + (q - a)\bmod q) \bmod q\\\\\
    &= (a + (-a + q)\bmod q) \bmod q\\\\\
    &= (((a + (-a)) \bmod q) + q) \bmod q\\\\\
    &= (0 + q) \bmod q\\\\\
    &= q \bmod q\\\\\
    &= 0 \in \Zq
\end{align}

Importantly, the inverse is in $\Zq$ because we have $0 \le -a < q \Leftrightarrow 0 \le q - a < q$.

**TODO:** Uniqueness of inverses.

## A more complicated example: Multiplication modulo a prime $p$

## A simple example: a collision-resistant hash function


## Prize-winning stuff

TODO: see cryptomat/ notes

Example of Z_7^* and generators

Could start by giving an example where if $g, g^a$ is given, and getting $a$ is hard, we could do something interesting.
Collision resistant hashing, but that's complicted to understand the proof for.

A simple example for hidden order groups are accumulators.

TODO: give **easy** examples of groups
see [wiki](https://en.wikipedia.org/wiki/Abelian_group)

replace the above definition by one or more of these examples.

TODO: list the 4 laws

TODO: examples of non-associative, but commutative groups
see [this](https://math.stackexchange.com/questions/56016/are-the-axioms-for-abelian-group-theory-independent)

TODO: Explain

 - why so many primes everywhere? Why z_p? Well, we also have Z_N=pq and Z_2^64 
    + the answer lies in which groups admit hard problems like DL

 - additive notation versus multiplicative notation
 
 - why things cycle in the exponent modulo $p$, or modulo $\phi(n)$, etc.
 
 - subgroups
 
 - generators

 - why we see both the q and the p for g^{a mod q} mod p (e.g., Schnorr's description of his signature scheme)

 - how do you find generators of prime-order subgroups, of the full group for Zp and RSA
    + you make sure they are not of any other order
    + or you pick $g$ randomly and check $g^{p-1}/q \ne 1$ (see `generators-mod-q` screenshot)

 - is DL hard for generators of composite order (sub)groups?

 - different notation: g^a, g^a mod p, g^{a mod p-1}, g^{a mod q} mod p, g^{a mod q}, aG, [a]G
    + all have a simple explanation different kinds of groups, of different sizes

Explain the three most common groups

 - Zp*
 - Zn*
 - elliptic curves


---

{% include refs.md %}
