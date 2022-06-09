// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import {Script} from "forge-std/Script.sol";
import {Decimal} from "codec/Decimal.sol";
import {Bash} from "bash/Bash.sol";

library GraphQL {
  function args(bytes[] memory keys, bytes[] memory values) internal pure returns (bytes memory text) {
    text = "(";
    if (keys.length > 0) {
      text = bytes.concat(
        text,
        keys[0],
        ": ",
        values[0]
      );
    }
    for (uint i=1;i<keys.length;i++) {
      text = bytes.concat(
        text,
        ", ",
        keys[i],
        ": ",
        values[i]
      );
    }
    text = bytes.concat(text, ")");
  }

  function selectionSet(bytes[] memory selections) internal pure returns (bytes memory text) {
    text = "{";
    for (uint i=0;i<selections.length;i++) {
      text = bytes.concat(
        text,
        " ",
        selections[i]
      );
    }
    text = bytes.concat(text, " }");
  }

  function field(bytes memory name, bytes memory _args, bytes memory _selectionSet) internal pure returns (bytes memory) {
    return bytes.concat(
      name,
      _args,
      " ",
      _selectionSet
    );
  }

  function query(bytes memory _selectionSet) internal pure returns (bytes memory) {
    return bytes.concat("query ", _selectionSet);
  }
}

contract GraphQLExecutor is Script {
  using Decimal for uint;

  function query(
    bytes memory url,
    bytes memory queryText
  ) public returns (bytes memory filename) {
    Bash bash = new Bash();
    filename = bash.run("mktemp|cast --from-utf8");

    bash.run(
      bytes.concat(
        "curl ",
        url,
        " -H 'Content-Type: application/json' -X POST -d '{\"query\":\"",
        queryText,
        "\"}'"
      ),
      filename
    );
  }
}
