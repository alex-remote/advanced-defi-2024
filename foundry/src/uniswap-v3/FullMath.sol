// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 复制自
// https://github.com/Uniswap/v3-core/blob/0.8/contracts/libraries/FullMath.sol

/// @title 包含 512 位数学运算函数
/// @notice 支持中间值可能上溢的乘法和除法运算，且不损失任何精度
/// @dev 处理“幽灵溢出”（phantom overflow），即允许中间值超出 256 位的乘法和除法运算
library FullMath {
    /// @notice 以完全精度计算 floor(a×b÷denominator)。若结果超出 uint256 范围或 denominator == 0 则抛出异常
    /// @param a 被乘数
    /// @param b 乘数
    /// @param denominator 除数
    /// @return result 256 位的计算结果
    /// @dev 归功于 Remco Bloemen，采用 MIT 许可证 https://xn--2-umb.com/21/muldiv
    function mulDiv(uint256 a, uint256 b, uint256 denominator)
        internal
        pure
        returns (uint256 result)
    {
        unchecked {
            // 512 位乘法 [prod1 prod0] = a * b
            // 分别计算乘积 mod 2**256 与 mod 2**256 - 1 的结果，
            // 然后用中国剩余定理（Chinese Remainder Theorem）重建出
            // 512 位的结果。结果存放在两个 256 位的
            // 变量中，满足 product = prod1 * 2**256 + prod0
            uint256 prod0; // 乘积的低 256 位
            uint256 prod1; // 乘积的高 256 位
            assembly {
                let mm := mulmod(a, b, not(0))
                prod0 := mul(a, b)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // 处理不溢出的情况：256 位除以 256 位
            if (prod1 == 0) {
                require(denominator > 0);
                assembly {
                    result := div(prod0, denominator)
                }
                return result;
            }

            // 确保结果小于 2**256。
            // 同时也防止了 denominator == 0
            require(denominator > prod1);

            ///////////////////////////////////////////////
            // 512 位除以 256 位的除法。
            ///////////////////////////////////////////////

            // 从 [prod1 prod0] 中减去余数，使除法能够整除
            // 使用 mulmod 计算余数
            uint256 remainder;
            assembly {
                remainder := mulmod(a, b, denominator)
            }
            // 从 512 位数中减去 256 位数
            assembly {
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // 从 denominator 中提取出 2 的幂因子
            // 计算 denominator 的最大 2 的幂因子。
            // 其值始终 >= 1。
            uint256 twos = (0 - denominator) & denominator;
            // 将 denominator 除以该 2 的幂
            assembly {
                denominator := div(denominator, twos)
            }

            // 将 [prod1 prod0] 除以这些 2 的因子
            assembly {
                prod0 := div(prod0, twos)
            }
            // 把 prod1 中的位移入 prod0。为此我们需要
            // 翻转 `twos`，使其变为 2**256 / twos。
            // 如果 twos 为 0，则结果变为 1
            assembly {
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;

            // 求 denominator 在 mod 2**256 下的逆元
            // 现在 denominator 已是奇数，因此它存在模 2**256 的
            // 逆元，满足 denominator * inv = 1 mod 2**256。
            // 计算逆元时，先取一个种子（seed），使其
            // 在低四位上正确。即 denominator * inv = 1 mod 2**4
            uint256 inv = (3 * denominator) ^ 2;
            // 现在使用牛顿-拉弗森（Newton-Raphson）迭代来提高精度。
            // 得益于亨泽尔提升引理（Hensel's lifting lemma），这在模
            // 运算中同样适用，每一步都会使正确的位数翻倍。
            inv *= 2 - denominator * inv; // mod 2**8 下的逆元
            inv *= 2 - denominator * inv; // mod 2**16 下的逆元
            inv *= 2 - denominator * inv; // mod 2**32 下的逆元
            inv *= 2 - denominator * inv; // mod 2**64 下的逆元
            inv *= 2 - denominator * inv; // mod 2**128 下的逆元
            inv *= 2 - denominator * inv; // mod 2**256 下的逆元

            // 由于现在除法是整除，我们可以通过乘以
            // denominator 的模逆元来完成除法。这样得到的是
            // 模 2**256 意义下的正确结果。由于前置条件保证了
            // 结果小于 2**256，所以这就是最终结果。
            // 我们不需要计算结果的高位，并且 prod1
            // 也不再需要了。
            result = prod0 * inv;
            return result;
        }
    }

    /// @notice 以完全精度计算 ceil(a×b÷denominator)。若结果超出 uint256 范围或 denominator == 0 则抛出异常
    /// @param a 被乘数
    /// @param b 乘数
    /// @param denominator 除数
    /// @return result 256 位的计算结果
    function mulDivRoundingUp(uint256 a, uint256 b, uint256 denominator)
        internal
        pure
        returns (uint256 result)
    {
        unchecked {
            result = mulDiv(a, b, denominator);
            if (mulmod(a, b, denominator) > 0) {
                require(result < type(uint256).max);
                result++;
            }
        }
    }
}
