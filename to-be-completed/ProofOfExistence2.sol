// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract ProofOfExistence2 {
    // state
    bytes32[] private proofs;

    // store a proof of existence in the contract state
    // *transactional function*
    function storeProof(bytes32 proof) public {
        if (!hasProof(proof)) {
            proofs.push(proof);
        }
    }

    // calculate and store the proof for a document
    // *transactional function*
    function notarize(string calldata document) external {
        bytes32 proof = proofFor(document);
        storeProof(proof);
    }

    // helper function to get a document's sha256
    // *read-only function*
    function proofFor(string memory document) public pure returns (bytes32) {
        return sha256(abi.encodePacked(document));
    }

    // check if a document has been notarized
    // *read-only function*
    function checkDocument(string memory document) public view returns (bool) {
        bytes32 proof = proofFor(document);
        return hasProof(proof);
    }

    // returns true if proof is stored
    // *read-only function*
    function hasProof(bytes32 proof) internal view returns (bool) {
        for (uint256 j = 0; j < proofs.length; j++) {
            if (proof == proofs[j]) return true;
        }
        return false;
    }
}
