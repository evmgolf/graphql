// SPDX-License-Identifier: BSD-3-Clause
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import {GraphQL} from "../GraphQL.sol";

contract GraphQLTest is Test {
  GraphQL graphql;

  function setUp() public {
    graphql = new GraphQL();
  }

  function testQueryManyAddresses() public {
    address[] memory results = graphql.queryManyAddresses(
      "https://api.thegraph.com/subgraphs/name/evmgolf/evmgolf-mumbai",
      "query {challengeEntities {id}}",
      "challengeEntities",
      "id"
    );
    assertGt(results.length, 0);
    for (uint i=0;i<results.length;i++) {
      assertTrue(results[i] != address(0));
    }
  }
}
