---
tags:
title: Keyless blockchain accounts on Aptos
#date: 2020-11-05 20:45:59
#published: false
#sidebar:
#    nav: cryptomat
---

{: .info}
**tl;dr:** What is a **keyless blockchain account**?
Put simply, _"Your blockchain account = Your Google account"_. 
In other words, this keyless approach allows you to derive a blockchain account from any of your existing OpenID Connect (OIDC) account (e.g., Google, Apple), rather than from a traditional secret key or mnemonic. 
There are no long-term secret keys you need to manage.
There is also no multi-party computation (MPC) system managing your account for you.
As a result, the risk of account loss is (more or less), the risk of losing your Google account.

I wrote a high-level explanation of how keyless accounts work on the [Aptos](https://twitter.com/aptos) blockchain [here](https://aptos.dev/aptos-keyless/how-keyless-works).

An accompanying tweetstorm is [here](https://twitter.com/alinush407/status/1800949436371304955) too.

Plus, a short presentation [here](https://www.youtube.com/watch?v=sKqeGR4BoI0).

For a more in-depth discussion, see [the 61th Aptos Improvement Proposal here](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-61.md).

<!--more-->

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

---

{% include refs.md %}
