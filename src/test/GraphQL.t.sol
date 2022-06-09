// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import {JSONQuery, JSONExecutor} from "jsonquery/JSONQuery.sol";
import {GraphQL, GraphQLExecutor} from "../GraphQL.sol";

contract GraphQLTest is Test {
  using JSONQuery for bytes;

  JSONExecutor json;
  GraphQLExecutor graphql;

  function setUp() public {
    json = new JSONExecutor();
    graphql = new GraphQLExecutor();
  }

  function testBuildQuery() public {
    bytes[] memory argKeys = new bytes[](1);
    bytes[] memory argValues = new bytes[](1);
    argKeys[0] = "";
    argValues[0] = "";
    bytes[] memory selectionSet = new bytes[](1);
    selectionSet[0] = "id";

    GraphQL.query(
      GraphQL.field(
        "challengEntities",
        GraphQL.args(argKeys, argValues),
        GraphQL.selectionSet(selectionSet)
      )
    );
  }

  function testExecuteArray() public {
    bytes memory query;
    {
      // bytes[] memory argKeys = new bytes[](1);
      // bytes[] memory argValues = new bytes[](1);
      // argKeys[0] = "";
      // argValues[0] = "";
      bytes[] memory selectionSet = new bytes[](1);
      selectionSet[0] = "id";

      bytes[] memory topSelectionSet = new bytes[](1);
      topSelectionSet[0] = GraphQL.field(
        "challengeEntities",
        "",
        // GraphQL.args(argKeys, argValues),
        GraphQL.selectionSet(selectionSet)
      );

      query = GraphQL.selectionSet(topSelectionSet);
    }

    bytes memory filename = graphql.query(
      "https://api.thegraph.com/subgraphs/name/evmgolf/evmgolf-mumbai",
      query
    );

    bytes[] memory results = json.readArray(
      filename,
      bytes("").query("data").query("challengeEntities"),
      bytes("").query("id")
    );
    assertGt(results.length, 0);
    for (uint i=0;i<results.length;i++) {
      assertGt(results[i].length, 0);
    }
  }
}
