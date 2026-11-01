pragma solidity =0.5.16;

// 用于处理二进制定点数的库 (https://en.wikipedia.org/wiki/Q_(number_format))

// 范围：[0, 2**112 - 1]
// 分辨率：1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2**112;

    // 将 uint112 编码为 UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // 永远不会上溢
    }

    // 用 UQ112x112 除以 uint112，返回 UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        // x = reserve1 * Q112 / reserve0
        z = x / uint224(y);
    }
}
