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
\def\btau{\boldsymbol{\tau}}
\def\B{\mathbb{B}}
\def\binS{\B^s}
\def\eq{\mathsf{eq}}
\def\i{\mathbf{i}}
\def\j{\mathbf{j}}
\def\r{\mathbf{r}}
\def\SC{\mathsf{Sumcheck}}
\def\x{\mathbf{x}}
\def\X{\mathbf{X}}
\def\y{\mathbf{y}}
\def\Y{\mathbf{Y}}
$</div> <!-- $ -->

## Introduction

Spartan[^Sett19e]$^,$[^Sett20] is a framework for building zkSNARK schemes using the well-known **sumcheck protocol**[^LFKN92]$^,$[^Thal20] and a **sparse multilinear polynomial commitment scheme**, a.k.a. a **sparse MLE PCS**.

By the end of this blog post, you should be able to fully understand the Spartan protocol:
<div align="center"><img style="width:75%" src="/pictures/spartan.png" /></div>

## Preliminaries

 - we typically denote the **boolean hypercube** of size $2^s$ as $\binS\bydef\\{0,1\\}^s$
 - multilinear extensions (MLEs)
 - MLE PCS
 - sumcheck protocol
 - sumcheck reduction algorithm $\SC_s(F, S, \r)\rightarrow (\pi,e)$ that reduces $\sum_{\b \in \binS} F(\b) = S$ to (1) verifying a sumcheck proof $\pi$ and (2) verifiying a polynomial evaluation proof that $F(\r) = e$ for some random $\r\in \F^s$ (picked after $F$ is fixed).

### $\mathsf{eq}(\mathbf{X};\mathbf{b})$ Lagrange polynomials

We want to define a polynomial $\eq$ that evaluates to 1 when $\X = \b$ and to 0 when $\X \in \binS \setminus\\{\b\\}$:
\begin{align}
\eq(\X;\b) = \begin{cases}
1,\ \text{if}\ \X = \b\\\\\
0,\ \text{if}\ \X \ne \b, \X \in \binS
\end{cases}
\end{align}

\begin{align}
\eq_s(\X;\b) &\bydef \eq_s(X_1,\ldots, X_s; b_1,\ldots,b_s)\\\\\
&= \prod_{i\in[s]}\left(b_i X_i + (1 - b_i) (1 - X_i)\right)
\end{align}

{: .note}
Evaluating each term $b_i X_i + (1-b_i)(1-X_i)$ at $b_i$ yields $b_i^2 + (1-b_i)^2$ which is always equal to 1 for $b_i\in\\{0,1\\}$.
But evaluating at $(1-b_i)$ yields $b_i(1-b_i) + (1-b_i)(1-(1-b_i)) = b_i(1-b_i)+(1-b_i)b_i=2b_i(1-b_i)$ which is always 0.

{: .note}
When the number of variables $s$ is clear from context, we simply use $\eq(\X;\b)$.
 
### Zerocheck

Suppose, we want to check that a polynomial
\begin{align}
F(\X) = 0, \forall X\in \binS
\end{align}
Then, there is a nice zerocheck-to-sumcheck reduction for this!
Let:
\begin{align}
\label{eq:G}
G(\Y)\bydef \sum_{\x\in\binS} F(\x)\cdot\eq(\x;\Y)
\end{align}
It can be shown the zerocheck is equivalent to picking a random $\btau\in\F^s$ and checking:
\begin{align}
G(\btau) = \sum_{\x\in\binS} \left(F(\x)\cdot \eq(\x; \btau)\right) = 0
\end{align}
Let's see why.

**Theorem** (informal):
Pick $\btau$ randomly. Then, $G(\btau) = 0 \Leftrightarrow F(\x) = 0, \forall \x \in \binS$.
(Roughly. There is a probability with which this does **not** hold. See lemma 4.3 in [Sett19e][^Sett19e] for a formal claim.)

**Proof** ("$\Leftarrow$"):
This follows from the definition of $G(\cdot)$ from Eq. \ref{eq:G}, by just swapping $F(\X)$ with 0 and observing $G$ is zero everywhere, including at $\btau$.

**Proof** [by contradiction] ("$\Rightarrow$"):
Suppose that $G(\btau) = 0$ at a random $\tau$ yet $\exists x\in\binS$ such that $F(\x) \ne 0$.
Then, again from the definition of $G(\cdot)$ from Eq. \ref{eq:G}, this implies that $G(\Y)$ is a non-zero polynomial.
(Because one of the terms of the sum will have a non-zero $F(\x)$ value.)
Roughly, this contradicts the Schwartz-Zippel lemma.

## R1CS matrices

[R1CS](/r1cs) matrices $A, B, C$ are assumed to be **square** (of $m$ rows and $m$ columns) and **sparse**, with $n$ non-zero entries.

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
\label{eq:r1cs-instance}
\mathbb{x} = (\mathbb{F},A,B,C,io,m,n)
\end{align}
Note that it includes the public input $io$.

{: .definition}
An R1CS instance is said to be **satisfiable** iff. exists a private witness $w$ s.t. Equation $\ref{eq:r1cs-sat}$ holds.
We also say the instance is **satisfied by** $w$.

## R1CS SAT $\Leftrightarrow$ zero sumcheck on degree-3 $\log{m}$-variate polynomial

Let $s=\lceil \log{m} \rceil$, where $\log$'s base is always 2.

We represent the R1CS matrices $A$, $B$ and $C$ as **multilinear extensions (MLE)**.
For example, for $A \bydef (A_{i,j})\_{i,j\in[m)}$, we define:
\begin{align}
\tilde{A}(X_1, \ldots, X_s, Y_1,\ldots,Y_s) \bydef \tilde{A}(\X,\Y) = \sum_{\i,\j \in \binS} A_{i,j} \cdot \eq(\X, \i)\eq(\Y,\j)
\end{align}
such that:
\begin{align}
\tilde{A}(\i,\j)=A_{i,j},\forall i,j\in[m)
\end{align}
where $i\in[m)$ is a row index, $j\in[m)$ is a column index and $\i,\j\in \binS$ are their $s$-bit binary representations, 

Similarly, the vector $z = (io, 1, w) \in \mathbb{F}^m$ can be viewed as an MLE:
\begin{align}
\tilde{Z} : \binS \rightarrow \mathbb{F},\ \text{s.t.}\ \tilde{Z}(\j) = z_j, \forall j\in[m)
\end{align}

Then, satisfiability of an R1CS instance $A,B,C$ with public input $io$ by witness $w$ can be expressed as:

\begin{align}
\forall\ \text{rows}\ i\in[m), \sum_{j\in[m)} A_{i,j} z_j \cdot \sum_{j\in[m)} B_{i,j} z_j - \sum_{j\in[m)} C_{i,j} z_j = 0\Leftrightarrow\\\\\
\forall\ \i\in\binS, \sum_{\j\in\binS} \tilde{A}(\i,\j) Z(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\i,\j) Z(\j) - \sum_{\j\in\binS} \tilde{C}(\i,\j) Z(\j) = 0
%\Leftrightarrow\\\\\
%\forall \x\in \binS, \sum_{\j\in\binS} \tilde{A}(\x,\j) Z(\j) \cdot \sum_{\j\in\binS} \tilde{B}(\x,\j) Z(\j) - \sum_{\j\in\binS} \tilde{C}(\x,\j) Z(\j) = 0\Leftrightarrow\\\\\
\end{align}
So, if w.r.t. the R1CS instance $\mathbb{x}$, we define a degree-2 multivariate polynomial:
\begin{align}
\label{eq:F}
F(\X)
&\bydef \sum_{j\in\binS} \tilde{A}(\X,j) Z(j) \cdot \sum_{j\in\binS} \tilde{B}(\X,j) Z(j) - \sum_{j\in\binS} \tilde{C}(\X,j) Z(j)
\end{align}

Then, the main result of Spartan can be stated as a theorem:

{: .theorem}
An R1CS instance $\mathbb{x}$ (see Eq. \ref{eq:r1cs-instance}) is satisfied by a witness $w \Leftrightarrow F(\x) = 0$ for all $\x \in \binS$ (i.e., $F$ is zero on the hypercube).

Of course, [we know from before](#zero-check) that such a zerocheck on $F$ can be reduced to a sumcheck on another related polynomial defined below.
\begin{align}
\label{eq:Q}
Q(\X)\bydef F(\X)\cdot \eq(\X, \btau)
%G(\Y)\bydef \sum_{x\in\binS} F(\x)\cdot \eq(\x, \Y)
\end{align}
where $\btau\randget\F^s$ is randomly picked by the prover.
Specifically:
\begin{align}
\label{eq:sumcheck-1}
F(\x) &= 0,\forall x\in\binS \Leftrightarrow \sum_{\x\in\binS} F(\x)\cdot \eq(\x,\btau) = 0,\btau\randget\F^s
\end{align}
This sumcheck from Eq. \ref{eq:sumcheck-1} is (mostly) reduced to verifying a polynomial evaluation proof at a random point $\r_x\in \F^s$:
\begin{align}
Q(\r_x) = F(\r_x)\cdot \eq(\r_x,\btau)=e_x
\end{align}
by running the sumcheck protocol:
\begin{align}
e_x \gets \SC_s(Q, 0, \r_x)
\end{align}
First, note that it is easy to verify the $\eq(\r_x,\btau)$ part of the evaluation.
Unfortunately, verifying that $F(\r_x)$ is correct is trickier, due to $F$'s complicated formula from Eq. \ref{eq:F}.

{: .todo}
Continue...

## References

For cited works, see below 👇👇

<!-- PWS
The R1CS matrices can be viewed as functions mapping a row and column index to their associated cell's value; i.e. "overload" the notation for matrix $A$ into a function:
\begin{align}
A : \binS\times\binS \rightarrow \mathbb{F}
%A : [m)\times[m) \rightarrow \mathbb{F},
\ \text{s.t.}\ A(\i,\j)\bydef A_{i,j}
\end{align}
where $i$ is a row index, $j$ is a column index and $\i,\j\in \binS$ are their $s$-bit binary representations.
-->

<!-- Univariate perspective
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

**Theorem**: An R1CS instance $\mathbb{x}$ is satisfied by $w$, iff. $F(X) = 0$ for all $X \in [m) = \\{0,1\\}^s$ (i.e., $F$ is zero on the hypercube).

-->

{% include refs.md %}
