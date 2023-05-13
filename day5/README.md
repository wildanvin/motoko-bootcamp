Some nice functionality that I used for this challenge:

- To call a canister when the inputs are principals:

```
dfx canister --network ic call Verifier verifyOwnership '(principal "wqece-kqaaa-aaaap-abaja-cai" , principal "wicho-jqaaa-aaaap-aa5wa-cai")'
```

- To rebuild and deploy the new code:

```
dfx build --network ic Verifier
dfx canister install Verifier --network ic --mode reinstall
```
