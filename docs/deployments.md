# Aurora deployment

wNEAR deployed to 0x6BB0c4d909a84d118B5e6c4b17117e79E621ae94
wstNEAR deployed to 0x120908185dC7f4d4AE8B32C376484406cC16731A
wMETA deployed to 0x71B61b0c931Cad9E9a3Cae116C5f48A865c0fC7B
wNSTART deployed to 0xe2D4e5f10F1A9d3c08828c964980fd29971EEd15

# Mumbai testnet deployments

mockNEAR deployed to 0x0D6889Aaa61e01E7C886DB95512e6D608fe85F30
mockWNEAR deployed to 0x1e68Ff3D38F16f397883b7F8445ddF675A3A729d

curl https://mainnet.aurora.dev \
  -X POST \
  -H "Content-Type: application/json" \
  --data '{"method":"eth_getCode","params":["0xe2D4e5f10F1A9d3c08828c964980fd29971EEd15","latest"],"id":1,"jsonrpc":"2.0"}'
