---
tags: polynomials
title: "Introduction to Polynomials for Cryptography"
date: 2020-03-16 10:38:00
published: false
sidebar:
    nav: crypto-for-currencies
---

A *polynomial* $\phi$ of *degree* $d$ is a vector of $d+1$ *coefficients*:

\begin{align}
    \phi &= [\phi_0, \phi_1, \phi_2, \dots, \phi_d]
\end{align}

For example, $\phi = [1, 10, 9]$ is a degree 2 polynomial.

_"A list of numbers? That makes no sense!"_
Don't panic!
You are probably more familiar to polynomials expressed as function of a variable $X$:
\begin{align}
    \phi(X) &= \phi_0 + \phi_1\cdot X + \phi_2\cdot X^2 + \cdots + \phi_d\cdot X^d]\\\\\
            &= \sum_{i=0}^{d+1} \phi_i X^i
\end{align}

For example, $\phi = [1, 10, 9]$ can be expressed as $\phi(X) = 9X^2 + 10X + 1$.

This is fine too.

## The basics of polynomials

### Roots of polynomials

### Evaluating polynomials

### Adding and subtracting polynomials

### Multiplying polynomials

### Dividing polynomials

Division of polynomials conceptually resembles division of integers.

Specifically, dividing a polynomial $a(X)$ by $b(X)$ gives a _quotient_ $q(X)$ and a _remainder_ $r(X)$ of degree less than $\deg{b(X)}$ such that:

$$a(X) = q(X) b(X) + r(X)$$

### The Discrete Fourier Transform (DFT)

## Uses

### Polynomial commitments

### Random linear combinations
