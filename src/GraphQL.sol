// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import {Script} from "forge-std/Script.sol";
import {Decimal} from "codec/Decimal.sol";

contract GraphQL is Script {
  using Decimal for uint;

  function shell(bytes memory script, bytes memory filename) internal returns (bytes memory) {
    string[] memory args = new string[](3);
    args[0] = "bash";
    args[1] = "-c";
    if (filename.length > 0) {
      script = bytes.concat(script, ">", filename);
    }
    args[2] = string(script);
    return vm.ffi(args);
  }

  function queryManyAddresses(bytes memory url, bytes memory query, bytes memory entityName, bytes memory fieldName) public returns (address[] memory results) {
    bytes memory filename = "result.json";
    bytes memory resultSelector = bytes.concat(".data.", entityName);
    
    shell(
      bytes.concat(
        "curl ",
        url,
        " -H 'Content-Type: application/json' -X POST -d '{\"query\":\"",
        query,
        "\"}'"
      ),
      filename
    );

    uint resultSize = abi.decode(shell(bytes.concat("printf \"%.64x\" $(jq -r '", resultSelector, "|length' ", filename, ")"), ""), (uint));
    results = new address[](resultSize);
    for (uint i=0; i<resultSize;i++) {
      results[i] = abi.decode(shell(bytes.concat("cast --concat-hex 0x000000000000000000000000 $(jq -r '", resultSelector, "[", i.decimal(), "].", fieldName, "' ", filename, ")"), ""), (address));
    }
  }

  function run() external {
    queryManyAddresses(
      "http://127.0.0.1:8000/subgraphs/name/evmgolf/evmgolf-subgraph",
      "query {challengeEntities {id}}",
      "challengeEntities",
      "id"
    );
  }
}
