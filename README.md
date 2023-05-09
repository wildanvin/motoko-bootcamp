# Motoko Bootcamp

This is a repo so I can follow along the motoko bootcamp, take some notes and do the excercises.

## Notes

A canister is a web assembly program that is deployed to the ICP network, it is the equivalent of a smart contract in solidity and a program in solana. It is more similar to a solana program so far.

Candid is a Interface Description Language (IDL) to communicate between canisters. Since you can write your canister in rust there needs to be a way to communicate between canisters even if they have been written in different languages, and that in candid.

The command

```bash
dfx start --clean
```

is the equivalente of running `yarn hardhat` or `yarn chain` in scaffold-eth, it gives you a local blockchain. It even gives a local webapp that you can access from the browser to monutor the chain... nice

Once you have deployed your canister you can call it from the terminal:

```
general structure:
dfx canister call <CANISTER_NAME OR CANISTER_ID> <METHOD_NAME> '(ARGUMENT)'
example:
dfx canister call greet_backend greet '("motoko")'
for calling it on mainnet:
dfx canister --network ic call <CANISTER_NAME OR CANISTER_ID> <METHOD_NAME> '(ARGUMENT)'
```

You have a UI for for your canister by default that is the CandidUI.
