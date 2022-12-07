<h1 align=center><code>
Elastic Receipt Token
</code></h1>

The Elastic Receipt Token is a rebase token that "continuously" syncs the token
supply with a supply target.

A downstream contract, inheriting from this contract, needs to implement the
`_supplyTarget()` function returning the current supply target.

The downstream contract can mint and burn tokens to addresses with the assumption
that the _supply target changes precisely by the amount of tokens minted/burned_.


## Example Use-Case

Using the Elastic Receipt Token with a treasury as downstream contract holding
assets worth 10,000 USD, and returning that amount in the `_supplyTarget()`
function, leads to a token supply of 10,000.

If a user wants to deposit assets worth 1,000 USD into the treasury, the treasury
fetches the assets from the user and mints 1,000 Elastic Receipt Tokens to the user.

If the treasury's valuation contracts to 5,000 USD, the users token balances and
the total token supply, is decreased by 50%. In case of an expansion of the
treasury valuation, the user balances and the total token supply is increased
by the percentage change of the treasury's valuation.


## Setup

To install with [**Foundry**](https://github.com/gakonst/foundry):
```sh
$ forge install pmerkleplant/elastic-receipt-token
```

## Acknowledgements

These contracts were inspired by or directly modified from:
- [Ampleforth's AMPL Token](https://github.com/ampleforth/ampleforth-contracts)
- [Buttonwood's Button Wrappers](https://github.com/buttonwood-protocol/button-wrappers)
- [t11s' solmate](https://github.com/transmissions11/solmate)


## Safety

This is experimental software and is provided on an "as is" and
"as available" basis.

We do not give any warranties and will not be liable for any loss incurred
through any use of this codebase.
