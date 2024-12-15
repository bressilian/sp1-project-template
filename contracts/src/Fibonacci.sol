// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ISP1Verifier} from "@sp1-contracts/ISP1Verifier.sol";

/// @title Fibonacci Proof Verification Contract.
/// @author Succinct Labs
/// @notice This contract implements a simple example of verifying a proof for calculating a Fibonacci number.
contract Fibonacci {
    /// @notice The address of the SP1 verifier contract.
    /// @dev This can either be a specific SP1Verifier for a specific version, or the
    ///      SP1VerifierGateway which can verify proofs for any version of SP1.
    ///      For the list of supported verifiers on each chain, see:
    ///      https://github.com/succinctlabs/sp1-contracts/tree/main/contracts/deployments
    address public verifier;

    /// @notice The verification key for the Fibonacci program.
    bytes32 public fibonacciProgramVKey;

    /// @dev Defines the structure for the public values used in the Fibonacci program.
    struct PublicValuesStruct {
        uint32 n;
        uint32 a;
        uint32 b;
    }

    /// @dev Emitted when a Fibonacci proof is verified successfully.
    event FibonacciProofVerified(uint32 n, uint32 a, uint32 b);

    /// @param _verifier The address of the SP1 verifier contract.
    /// @param _fibonacciProgramVKey The verification key for the Fibonacci program.
    constructor(address _verifier, bytes32 _fibonacciProgramVKey) {
        verifier = _verifier;
        fibonacciProgramVKey = _fibonacciProgramVKey;
    }

    /// @notice The entrypoint for verifying the proof of a Fibonacci number.
    /// @param _publicValues The encoded public values (n, a, b).
    /// @param _proofBytes The encoded proof.
    /// @return (uint32 n, uint32 a, uint32 b) The public values extracted from the proof.
    function verifyFibonacciProof(bytes calldata _publicValues, bytes calldata _proofBytes)
        external
        returns (uint32, uint32, uint32)
    {
        // Verify the proof using the SP1 verifier.
        bool isVerified = ISP1Verifier(verifier).verifyProof(fibonacciProgramVKey, _publicValues, _proofBytes);
        
        // Revert if the proof verification fails.
        require(isVerified, "Fibonacci proof verification failed");

        // Decode the public values from the input bytes.
        PublicValuesStruct memory publicValues = abi.decode(_publicValues, (PublicValuesStruct));

        // Emit an event for successful verification.
        emit FibonacciProofVerified(publicValues.n, publicValues.a, publicValues.b);

        // Return the decoded public values.
        return (publicValues.n, publicValues.a, publicValues.b);
    }
}
