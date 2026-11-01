// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./FullMath.sol";

// 修改自 https://github.com/Uniswap/solidity-lib
// 请勿在生产环境中使用

// 用于处理二进制定点数的库 (https://en.wikipedia.org/wiki/Q_(number_format))
library FixedPoint {
    // 取值范围：[0, 2**112 - 1]
    // 分辨率：1 / 2**112
    struct uq112x112 {
        uint224 _x;
    }

    // 取值范围：[0, 2**144 - 1]
    // 分辨率：1 / 2**112
    struct uq144x112 {
        uint256 _x;
    }

    uint8 public constant RESOLUTION = 112;
    uint256 public constant Q112 = 0x10000000000000000000000000000; // 2**112
    uint256 private constant Q224 =
        0x100000000000000000000000000000000000000000000000000000000; // 2**224
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; // UQ*x112 的小数部分（低 112 位）

    // 截断小数点之后的部分，将 UQ144x112 解码为 uint144
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }

    // 将 UQ112x112 乘以一个 uint，返回 UQ144x112
    // 上溢时回滚（revert）
    function mul(uq112x112 memory self, uint256 y)
        internal
        pure
        returns (uq144x112 memory)
    {
        uint256 z = 0;
        require(
            y == 0 || (z = self._x * y) / y == self._x,
            "FixedPoint::mul: overflow"
        );
        return uq144x112(z);
    }

    // 返回一个表示分子与分母之比的 UQ112x112
    // 可能有精度损失
    function fraction(uint256 numerator, uint256 denominator)
        internal
        pure
        returns (uq112x112 memory)
    {
        require(denominator > 0, "FixedPoint::fraction: division by zero");
        if (numerator == 0) return FixedPoint.uq112x112(0);

        if (numerator <= type(uint144).max) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(
                result <= type(uint224).max, "FixedPoint::fraction: overflow"
            );
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(
                result <= type(uint224).max, "FixedPoint::fraction: overflow"
            );
            return uq112x112(uint224(result));
        }
    }
}
