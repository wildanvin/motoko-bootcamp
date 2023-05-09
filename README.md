# Motoko Bootcamp

This is a repo so I can follow along the motoko bootcamp, take some notes and do the excercises.

## Notes

## Day 1

A canister is a web assembly program that is deployed to the ICP network, it is the equivalent of a smart contract in solidity and a program in solana. It is more similar to a solana program so far.

Candid is a Interface Description Language (IDL) to communicate between canisters. Since you can write your canister in rust there needs to be a way to communicate between canisters even if they have been written in different languages, and that in candid.

The command

```bash
dfx start --clean
```

is the equivalente of running `yarn hardhat` or `yarn chain` in scaffold-eth, it gives you a local blockchain. It even gives a local webapp that you can access from the browser to monutor the chain... nice

Once you have deployed your canister you can call it from the terminal:

```bash
general structure:
dfx canister call <CANISTER_NAME OR CANISTER_ID> <METHOD_NAME> '(ARGUMENT)'
example:
dfx canister call greet_backend greet '("motoko")'
for calling it on mainnet:
dfx canister --network ic call <CANISTER_NAME OR CANISTER_ID> <METHOD_NAME> '(ARGUMENT)'
```

You have a UI for for your canister by default that is the CandidUI.

### Deploying a canister step by step:

A "helloWorld" program in ICP needs only a `dfx.json` and a `main.mo` file. The first one is similar to a `package.json` in JS, it is a configuration file.

One `main.mo` file = One actor = One canister.

1. Create a canister:

```bash
dfx canister create <CANISTER_NAME OR CANISTER_ID>
```

dfx will automatically create a wallet for your identity. A wallet is a canister that works as a proxy when you create and deploy canisters, because only canisters can hold cycles not identities. I guess is similar to account abstraction in Ethereum.

2. Compile code into WASM:

```bash
dfx build <CANISTER_NAME OR CANISTER_ID>
```

After compiling the `.dfx` directory is created, it has a bunch of files including tht wasm module.

3. Install the WASM in the canister

```bash
dfx canister install <CANISTER_NAME OR CANISTER_ID>
```

This command `create`, `build` and `install` in a single step

```bash
dfx deploy --network ic --with-cycles 1000000000000
```

Better check your cycles balance before deploying to mainnet:

```bash
dfx wallet --network ic balance
```

Now that our canister is deployed we can interact with it through the terminal or through the CandidUI:

### Using the terminal

```bash
dfx canister call NAME_OF_CANISTER NAME_OF_FUNCTION '(ARGUMENTS)'
```

Example:

```bash
dfx canister call Counter add '(3)'
```

To call it on the mainnet:

```bash
dfx canister --network ic call NAME_OF_CANISTER NAME_OF_FUNCTION '(ARGUMENTS)'
```

I guess that by adding the flag `--network ic` to the previous command we can deploy to mainnet.

Upgrade the canister with a new wasm usually if we change `main.mo`:

```
dfx canister install Counter --mode upgrade
```

### Using the Candid UI

You can access the CandidUI by contructing a link to localhost using the ids in `/.dfx/local/canister_ids.json`

```bash
{
  "Counter": {
    "local": "example-local-aaaaa-aaaaq-cai"
  },
  "__Candid_UI": {
    "local": "example-Candid-aaaaa-aaaba-cai"
  }
}
```

And replace it in:

```
 http://127.0.0.1:4943/?canisterId=example-Candid-aaaaa-aaaba-cai&id=example-local-aaaaa-aaaaq-cai
```
