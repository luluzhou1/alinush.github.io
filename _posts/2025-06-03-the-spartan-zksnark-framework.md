---
tags:
title: The Spartan zkSNARK framework
#date: 2020-11-05 20:45:59
published: false 
permalink: spartan
#sidebar:
#    nav: cryptomat
#article_header:
#  type: cover
#  image:
#    src: /pictures/.jpg
---

{: .info}
**tl;dr:** What a beautiful construction!

<!--more-->

<!-- Here you can define LaTeX macros -->
<div style="display: none;">$
\def\b{\mathbf{b}}
\def\binS{\{0,1\}^s}
\def\eq{\mathsf{eq}}
\def\X{\mathbf{X}}
$</div> <!-- $ -->

## Introduction

Spartan[^Sett19e]$^,$[^Sett20] is a framework for building zkSNARK schemes using the well-known **sumcheck protocol**[^LFKN92]$^,$[^Thal20] and a **sparse multilinear polynomial commitment scheme**, a.k.a. a **sparse MLE PCS**.

## Preliminaries

 - $\eq$ Lagrange monomials
 - multilinear extensions (MLEs)
 - sumcheck

## R1CS matrices

[R1CS](/r1cs) matrices $A, B, C$ are assumed to be _square_, of $m$ rows and columns and _sparse_, with $n$ non-zero entries.

Constraint system is **satisfiable** if exists $z\in \F^m$ such that:
\begin{align}
\label{eq:r1cs-sat}
A z \circ B z = C z
\end{align}
where:
\begin{align}
\label{eq:z}
z = (io, 1, w) \in \mathbb{F}^{|io|} \times \mathbb{F} \times \mathbb{F}^{m-|io|-1}
\end{align}
with $io$ being the **public statement** and $w$ being the **private witness**.

An **R1CS instance** is defined as:
\begin{align}
\mathbb{x} = (\mathbb{F},A,B,C,io,m,n)
\end{align}
Note that it includes the public input $io$.

{: .definition}
An R1CS instance is said to be **satisfiable** iff. exists a private witness $w$ s.t. Equation $\ref{eq:r1cs-sat}$ holds.
We also say the instance is **satisfied by** $w$.

## R1CS SAT $\Leftrightarrow$ zero sumcheck on degree-3 $\log{m}$-variate polynomial

Let $s=\lceil \log{m} \rceil$, where $\log$'s base is always 2.

The matrices can be viewed as functions mapping a row and column index to their associated cell's value (i.e., $A(i,j)\bydef A_{i,j}$, where $i$ is a row index and $j$ is a column index):
\begin{align}
A : [m)\times[m) \rightarrow \mathbb{F}
\end{align}

Or, since $[m) \bydef \\{0,1\\}^s$:
\begin{align}
A : \binS\times\binS \rightarrow \mathbb{F}
\end{align}

We then can represent the functions $A$ (and $B$ and $C$) above as **multilinear extension (MLE)**:
\begin{align}
\tilde{A}(X_1, \ldots, X_s) \bydef \tilde{A}(\X) = \sum_{\b \in \\{0,1\\}^s} A_{i,j} \cdot \eq(\X, \b)
\end{align}


Similarly, the vector $z = (io, 1, w) \in \mathbb{F}^m$ can be viewed as a function:
\begin{align}
Z : \binS \rightarrow \mathbb{F}
\end{align}
with a corresponding MLE $\tilde{Z}$.

Then, satisfiability of an R1CS instance $A,B,C$ with public input $io$ by witness $w$ can be expressed as:

\begin{align}
\forall\ \text{rows}\ i\in[m), \sum_{j\in[m)} A_{i,j} z_j \cdot \sum_{j\in[m)} B_{i,j} z_j - \sum_{j\in[m)} C_{i,j} z_j = 0\Leftrightarrow\\\\\
\forall\ i\in[m), \sum_{j\in[m)} A(i,j) Z(j) \cdot \sum_{j\in[m)} B(i,j) Z(j) - \sum_{j\in[m)} C(i,j) Z(j) = 0\Leftrightarrow\\\\\
\forall\ i\in[m), \sum_{j\in[m)} \tilde{A}(i,j) Z(j) \cdot \sum_{j\in[m)} \tilde{B}(i,j) Z(j) - \sum_{j\in[m)} \tilde{C}(i,j) Z(j) = 0\Leftrightarrow\\\\\
\forall X\in [m), \sum_{j\in[m)} \tilde{A}(X,j) Z(j) \cdot \sum_{j\in[m)} \tilde{B}(X,j) Z(j) - \sum_{j\in[m)} \tilde{C}(X,j) Z(j) = 0\Leftrightarrow\\\\\
\end{align}
So, if we define:
\begin{align}
F(X)
&\bydef \sum_{j\in[m)}   \tilde{A}(X,j) Z(j) \cdot \sum_{j\in[m)}   \tilde{B}(X,j) Z(j) - \sum_{j\in[m)}   \tilde{C}(X,j) Z(j)\\\\\
     &= \sum_{j\in\binS} \tilde{A}(X,j) Z(j) \cdot \sum_{j\in\binS} \tilde{B}(X,j) Z(j) - \sum_{j\in\binS} \tilde{C}(X,j) Z(j)\\\\\
\end{align}

Then, the main result of Spartan can be stated as follows. 

**Theorem**: An R1CS instance $\mathbb{x}$ is satisfied by $w$, iff. $F(X) = 0$ for all $X \in [0,m) = \\{0,1\\}^s$ (i.e., $F$ is zero on the hypercube).

{: .todo}
Continue...

## References

For cited works, see below 👇👇

{% include refs.md %}
