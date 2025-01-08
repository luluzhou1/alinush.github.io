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

One day, I hope to edit this into a full blog post but, until then check out the resources below:

## Docs

1. I gave a [high-level overview](https://aptos.dev/en/build/guides/aptos-keyless/how-keyless-works) of how keyless accounts work on the [Aptos](https://twitter.com/aptos) blockchain 
2. I wrote an **in-depth explanation** of how keyless accounts work (and their many caveats) in [the 61th Aptos Improvement Proposal](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-61.md). 

## Presentations

In April 2024, I gave a **20-minute presentation** at zkSummit11, with [slides here](https://docs.google.com/presentation/d/1nmDYfTiFKgAmPvsodkyrniV4USNdGUIGuWYRYaAxKgI/edit?usp=sharing):
<iframe width="560" height="315" src="https://www.youtube.com/embed/sKqeGR4BoI0?si=GJDBwVoTHdS-pML6" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Tweets

A tweetstorm summarizing Aptos Keyless can be found below:
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">What is an <a href="https://twitter.com/Aptos?ref_src=twsrc%5Etfw">@aptos</a> keyless account? 🧵<br><br>It&#39;s a blockchain account derived from (say) your Google account and an application (wallet, dapp, etc).<br><br>It&#39;s bound not just to you (e.g., you@gmail.com) but also to the application (e.g., <a href="https://twitter.com/PetraWallet?ref_src=twsrc%5Etfw">@PetraWallet</a>, or <a href="https://twitter.com/ThalaLabs?ref_src=twsrc%5Etfw">@ThalaLabs</a>, or <a href="https://twitter.com/VibrantXFinance?ref_src=twsrc%5Etfw">@VibrantXFinance</a>) <a href="https://t.co/L3qgRf1WoS">pic.twitter.com/L3qgRf1WoS</a></p>&mdash; Alin Tomescu (@alinush407) <a href="https://twitter.com/alinush407/status/1800949436371304955?ref_src=twsrc%5Etfw">June 12, 2024</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## Aptos Improvement Proposals (AIPs)

AIPs for auxiliary keyless services:

 - [AIP-75: Prover service](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-75.md)
 - [AIP-81: Pepper service](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-81.md)
 - [AIP-67: Native JWK consensus](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-67.md)

AIPs for recent extensions to keyless:

 - [AIP-96: Federated Keyless](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-96.md)
    + Adds decentralized support for "federated" OIDC providers like Auth0, which have tenant-specific `iss`'s and JWKs and could not be scalably integrated into our [JWK consensus](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-67.md) mechanism
 - [AIP-108: "Audless" Federated Keyless](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-108.md)
 - Draft [AIP: Privacy-preserving pepper service](https://github.com/aptos-foundation/AIPs/pull/544)

<!--more-->

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

---

{% include refs.md %}
