// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * @title Solidity Bytes Arrays Utils
 * @author Gonçalo Sá <goncalo.sa@consensys.net>
 *
 * @dev Bytes tightly packed arrays utility library for ethereum contracts written in Solidity.
 *      The library lets you concatenate, slice and type cast bytes arrays both in memory and storage.
 *      Forked and modified from https://github.com/GNSPS/solidity-bytes-utils/blob/master/contracts/BytesLib.sol
 */
pragma solidity >=0.8.0 <0.9.0;

library BytesLib {
    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address tempAddress) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }
    }

    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24 tempUint) {
        require(_bytes.length >= _start + 3, "toUint32_outOfBounds");
        assembly {
            tempUint := mload(add(add(_bytes, 0x3), _start))
        }
    }

    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8 tempUint) {
        require(_bytes.length >= _start + 1, "toUint8_outOfBounds");

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }
    }

    function toBool(bytes memory _bytes, uint256 _start) internal pure returns (bool tempBool) {
        require(_bytes.length >= _start + 1, "toBool_outOfBounds");

        assembly {
            tempBool := and(mload(add(add(_bytes, 0x1), _start)), 0xff)
        }
    }

    function len(bytes memory _bytes, uint256 _size) internal pure returns (uint256) {
        require(_bytes.length % _size == 0, "len_extraBytes");
        return _bytes.length / _size;
    }
}
