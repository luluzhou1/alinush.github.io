---
tags: matrix multiplication vector toeplitz discrete-fourier-transform dft fast-fourier-transform fft 
title: "Multiplying a vector by a Toeplitz matrix"
date: 2020-03-19 14:00:00
published: false
---

A _Toeplitz matrix_ (e.g. of size $4\times 4$) looks like this:

\begin{bmatrix}
a_0 & a_{-1} & a_{-2} & a_{-3}\\\\\
a_1 & a_0    & a_{-1} & a_{-2}\\\\\
a_2 & a_1    & a_0    & a_{-1}\\\\\
a_3 & a_2    & a_1    & a_0   \\\\\
\end{bmatrix}

Note the odd use of negative indices here, since typically we usually use positive numbers to index.
It's just convenient for notation to use negative indices.

In other words, it's a square matrix where the entries "repeat diagonally."
A concrete example would be:

\begin{bmatrix}
7 & 11 & 5  & 6  \\\\\
3 & 7  & 11 & 5  \\\\\
8 & 3  & 7  & 11 \\\\\
1 & 8  & 3  & 7  \\\\\
\end{bmatrix}

A _circulant matrix_ $C$ is a special form of Toeplitz matrix:

\begin{bmatrix}
a_0 & a_3 & a_2 & a_1\\\\\
a_1 & a_0 & a_3 & a_2\\\\\
a_2 & a_1 & a_0 & a_3\\\\\
a_3 & a_2 & a_1 & a_0\\\\\
\end{bmatrix}

In other words, each row is shifted/rotated to the right by 1 entry.
(Or, alternatively, each column is shifted/rotated down by 1 entry.)

Again, a circulant matrix is a particular type of a Toplitz matrix because $a_{-i} = a_{n-i}, \forall i \in[n-1]$.

Here are two examples:

\begin{bmatrix}
7  & 11 & 5  & 6  \\\\\
6  & 7  & 11 & 5  \\\\\
5  & 6  & 7  & 11 \\\\\
11 & 5  & 6  & 7  \\\\\
\end{bmatrix}

\begin{bmatrix}
7 & 1 & 8 & 3 \\\\\
3 & 7 & 1 & 8 \\\\\
8 & 3 & 7 & 1 \\\\\
1 & 8 & 3 & 7 \\\\\
\end{bmatrix}
