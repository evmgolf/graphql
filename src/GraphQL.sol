// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import {Script} from "forge-std/Script.sol";
import {Decimal} from "codec/Decimal.sol";
import {Bash} from "bash/Bash.sol";

contract GraphQL is Script {
  using Decimal for uint;

  function queryManyAddresses(bytes memory url, bytes memory query, bytes memory entityName, bytes memory fieldName) public returns (address[] memory results) {
    Bash bash = new Bash();

    bytes memory filename = "result.json";
    bytes memory resultSelector = bytes.concat(".data.", entityName);
    
    bash.run(
      bytes.concat(
        "curl ",
        url,
        " -H 'Content-Type: application/json' -X POST -d '{\"query\":\"",
        query,
        "\"}'"
      ),
      filename
    );

    uint resultSize = abi.decode(
      bash.run(
        bytes.concat(
          "printf \"%.64x\" $(jq -r '",
          resultSelector,
          "|length' ",
          filename,
          ")"
        ),
        ""
      ),
      (uint)
    );

    results = new address[](resultSize);
    for (uint i=0; i<resultSize;i++) {
      results[i] = abi.decode(
        bash.run(
          bytes.concat(
            "cast --concat-hex 0x000000000000000000000000 $(jq -r '",
            resultSelector,
            "[",
            i.decimal(),
            "].",
            fieldName,
            "' ",
            filename,
            ")"
          ),
          ""
        ),
        (address)
      );
    }
  }
}
