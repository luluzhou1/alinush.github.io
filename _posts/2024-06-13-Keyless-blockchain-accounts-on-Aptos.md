---
tags:
 - keyless
 - zero-knowledge proofs (ZKPs)
 - groth16
title: Keyless blockchain accounts on Aptos
#date: 2020-11-05 20:45:59
#published: false
#sidebar:
#    nav: cryptomat
permalink: keyless
---

{: .info}
**tl;dr:** What is a **keyless blockchain account**?
Put simply, _"Your blockchain account = Your Google account"_. 
In other words, this keyless approach allows you to derive a blockchain account from any of your existing OpenID Connect (OIDC) account (e.g., Google, Apple), rather than from a traditional secret key or mnemonic. 
There are no long-term secret keys you need to manage.
There is also no multi-party computation (MPC) system managing your account for you.
As a result, the risk of account loss is (more or less), the risk of losing your Google account.
Keyless is built using a [Groth16](/groth16) zero-knowledge proof to maintain privacy in both directions: prevent the blockchain from learning anything about your Google account & prevent Google from learning anything about your blockchain account and transaction activity.

One day, I hope to edit this into a full blog post but, until then, here's a bunch of resources.


## Drawings

### Keyless on-chain verification

Depicts what the blockchain validators need to do to verify a keyless TXN submitted by a user, Alice.

<div align="center"><img style="width:85%" src="/pictures/keyless-on-chain-verification.png" /></div>


### End-to-end keyless flow (with zero-knowledge)

Depicts the full keyless flow: the user generating an ESK and EPK, the user signing into the dapp with the EPK as the OIDC `nonce`, the dapp getting a JWT, exchanging it for a pepper, getting a ZKP from the prover service, the user signing a TXN with their ESK, the dapp sending the TXN containing the ZKP and ephemeral signature, and finally the blockchain verifying everything.

<div align="center"><img style="width:95%" src="/pictures/keyless-overview.png" /></div>

### Keyless ZK relation

The ZK relation needed for keyless:

<div align="center"><img style="width:65%" src="/pictures/keyless-zk-relation.png" /></div>

### Oblivious pepper service ZK relation

The ZK relation needed to implement an [oblivious pepper service][oblivious-pepper]:

<div align="center"><img style="width:65%" src="/pictures/keyless-oblivious-pepper-relation.png" /></div>

### End-to-end-keyless flow (without zero-knowledge)

In case of emergency, keyless supports a **ZKless** mode that is **not** privacy preserving.

We depicts this (simpler) ZKless flow: the user generating an ESK and EPK, the user signing into the dapp with the EPK as the OIDC `nonce`, the dapp getting a JWT, the user signing a TXN with their ESK, the dapp sending the TXN containing the ephemeral signature, and finally the blockchain verifying everything.


<div align="center"><img style="width:65%" src="/pictures/keyless-zkless-overview.png" /></div>

## Write-ups

1. I wrote a [high-level overview](https://aptos.dev/en/build/guides/aptos-keyless/how-keyless-works) of how keyless accounts work on the [Aptos](https://twitter.com/aptos) blockchain 
2. I wrote an [in-depth explanation](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-61.md) of how keyless accounts work (and their many caveats) in the 61st Aptos Improvement Proposal. 

## Slides

 - [Keyless blockchain accounts from ZKPs](https://docs.google.com/presentation/d/1XpkB0t-Ns4SuCosyin83ED4RLoSvFMGjH5746DCshow/), GKR bootcamp, January 2025
 - [How Keyless works](https://docs.google.com/presentation/d/1gew0fD0QFNqV9snmoYnhRtLsHBoMX0wykouVn1CJbXc), 2024-2025
 - [Aptos Keyless accounts](https://docs.google.com/presentation/d/1nmDYfTiFKgAmPvsodkyrniV4USNdGUIGuWYRYaAxKgI/edit?usp=sharing), zkSummit'11, April 2024

## Code

 - **Example:** Sending a keyless TXN to the Aptos `mainnet` via the SDK [here](https://github.com/aptos-labs/aptos-ts-sdk/blob/2386c07361f9a80f994f8b3ea22991549958402a/examples/typescript/keyless_mainnet.ts#L27)
 - **Example:** Simple Keyless dapp on Aptos [here](https://github.com/aptos-labs/aptos-keyless-example/) with guide [here](https://aptos.dev/en/build/guides/aptos-keyless/simple-example)
 - **Example:** End-to-end dapp with Keyless [here](https://github.com/aptos-labs/aptogotchi-keyless) with guide [here](https://learn.aptoslabs.com/en/code-examples/keyless)
 - Keyless blockchain validator logic [here](https://github.com/aptos-labs/aptos-core/blob/2c96107ddf0e48b7b3a3e6c67ff6cce3844d1abc/aptos-move/aptos-vm/src/keyless_validation.rs#L158)
 - Keyless governance logic [here](https://github.com/aptos-labs/aptos-core/blob/2c96107ddf0e48b7b3a3e6c67ff6cce3844d1abc/aptos-move/framework/aptos-framework/sources/keyless_account.move#L3)
 - Keyless SDK [here](https://github.com/aptos-labs/aptos-ts-sdk/tree/main/src/core/crypto)

## Aptos Improvement Proposals (AIPs)

AIPs for auxiliary keyless services:

 - [AIP-75: Prover service](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-75.md)
 - [AIP-81: Pepper service](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-81.md)
 - [AIP-67: Native JWK consensus](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-67.md)

AIPs for recent extensions to keyless:

 - [AIP-96: Federated Keyless](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-96.md)
    + Adds decentralized support for "federated" OIDC providers like Auth0, which have tenant-specific `iss`'s and JWKs and could not be scalably integrated into our [JWK consensus](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-67.md) mechanism
 - [AIP-108: "Audless" Federated Keyless](https://github.com/aptos-foundation/AIPs/blob/main/aips/aip-108.md)
 - Draft [AIP: Oblivious pepper service][oblivious-pepper]

## Tweets

A tweetstorm summarizing Aptos Keyless can be found below:
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">What is an <a href="https://twitter.com/Aptos?ref_src=twsrc%5Etfw">@aptos</a> keyless account? 🧵<br><br>It&#39;s a blockchain account derived from (say) your Google account and an application (wallet, dapp, etc).<br><br>It&#39;s bound not just to you (e.g., you@gmail.com) but also to the application (e.g., <a href="https://twitter.com/PetraWallet?ref_src=twsrc%5Etfw">@PetraWallet</a>, or <a href="https://twitter.com/ThalaLabs?ref_src=twsrc%5Etfw">@ThalaLabs</a>, or <a href="https://twitter.com/VibrantXFinance?ref_src=twsrc%5Etfw">@VibrantXFinance</a>) <a href="https://t.co/L3qgRf1WoS">pic.twitter.com/L3qgRf1WoS</a></p>&mdash; Alin Tomescu (@alinush407) <a href="https://twitter.com/alinush407/status/1800949436371304955?ref_src=twsrc%5Etfw">June 12, 2024</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>


## Presentations

In April 2024, I gave a **20-minute presentation** at zkSummit11:
<iframe width="560" height="315" src="https://www.youtube.com/embed/sKqeGR4BoI0?si=GJDBwVoTHdS-pML6" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

<!--more-->

<p hidden>$$
\def\Adv{\mathcal{A}}
\def\Badv{\mathcal{B}}
\def\vect#1{\mathbf{#1}}
$$</p>

[oblivious-pepper]: https://github.com/aptos-foundation/AIPs/pull/544

---

{% include refs.md %}
