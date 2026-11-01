# @version 0.3.9

# (c) Curve.Fi, 2020-2023
# 3 币 Curve Cryptoswap 池子的 AMM 数学库
#
# Unless otherwise agreed on, only contracts owned by Curve DAO or
# Swiss Stake GmbH are allowed to call this contract.

"""
@title CurveTricryptoMathOptimized
@author Curve.Fi
@license Copyright (c) Curve.Fi, 2020-2023 - all rights reserved
@notice 适用于 3 种非锚定资产（例如 ETH、BTC、USD）的 Curve AMM 数学库。
"""

N_COINS: constant(uint256) = 3
A_MULTIPLIER: constant(uint256) = 10000

MIN_GAMMA: constant(uint256) = 10**10
MAX_GAMMA: constant(uint256) = 5 * 10**16

MIN_A: constant(uint256) = N_COINS**N_COINS * A_MULTIPLIER / 100
MAX_A: constant(uint256) = N_COINS**N_COINS * A_MULTIPLIER * 1000

version: public(constant(String[8])) = "v2.0.0"


# ------------------------ AMM 数学函数 --------------------------------


@external
@view
def get_y(
    _ANN: uint256, _gamma: uint256, x: uint256[N_COINS], _D: uint256, i: uint256
) -> uint256[2]:
    """
    @notice 在给定其他余额 x[0..N_COINS-1] 和不变量 D 的情况下计算 x[i]。
    @dev ANN = A * N**N.
    @param _ANN AMM.A() 的值。
    @param _gamma AMM.gamma() 的值。
    @param x 所有币种的余额乘以各自价格和精度后的值。
    @param _D 不变量。
    @param i 要计算 y 的币种索引。
    """

    # 安全检查
    assert _ANN > MIN_A - 1 and _ANN < MAX_A + 1  # dev: A 值不安全
    assert _gamma > MIN_GAMMA - 1 and _gamma < MAX_GAMMA + 1  # dev: gamma 值不安全
    assert _D > 10**17 - 1 and _D < 10**15 * 10**18 + 1  # dev: D 值不安全

    frac: uint256 = 0
    for k in range(3):
        if k != i:
            frac = x[k] * 10**18 / _D
            assert frac > 10**16 - 1 and frac < 10**20 + 1, "Unsafe values x[i]"
            # 如果满足上述条件，则 x[k] > 0

    j: uint256 = 0
    k: uint256 = 0
    if i == 0:
        j = 1
        k = 2
    elif i == 1:
        j = 0
        k = 2
    elif i == 2:
        j = 0
        k = 1

    ANN: int256 = convert(_ANN, int256)
    gamma: int256 = convert(_gamma, int256)
    D: int256 = convert(_D, int256)
    x_j: int256 = convert(x[j], int256)
    x_k: int256 = convert(x[k], int256)
    gamma2: int256 = unsafe_mul(gamma, gamma)

    a: int256 = 10**36 / 27

    # 10**36/9 + 2*10**18*gamma/27 - D**2/x_j*gamma**2*ANN/27**2/convert(A_MULTIPLIER, int256)/x_k
    b: int256 = (
        unsafe_add(
            10**36 / 9,
            unsafe_div(unsafe_mul(2 * 10**18, gamma), 27)
        )
        - unsafe_div(
            unsafe_div(
                unsafe_div(
                    unsafe_mul(
                        unsafe_div(unsafe_mul(D, D), x_j),
                        gamma2
                    ) * ANN,
                    27**2
                ),
                convert(A_MULTIPLIER, int256)
            ),
            x_k,
        )
    )  # <------- 前两个表达式可以用 unsafe 运算，并以 unsafe 方式相加。

    # 10**36/9 + gamma*(gamma + 4*10**18)/27 + gamma**2*(x_j+x_k-D)/D*ANN/27/convert(A_MULTIPLIER, int256)
    c: int256 = (
        unsafe_add(
            10**36 / 9,
            unsafe_div(unsafe_mul(gamma, unsafe_add(gamma, 4 * 10**18)), 27)
        )
        + unsafe_div(
            unsafe_div(
                unsafe_mul(
                    unsafe_div(gamma2 * unsafe_sub(unsafe_add(x_j, x_k), D), D),
                    ANN
                ),
                27
            ),
            convert(A_MULTIPLIER, int256),
        )
    )  # <--------- 前两个表达式同上。在第三个
    #   表达式中，x_j + x_k 不会上溢，因为我们已经从
    #                                              前面的 assert 语句得知它们的取值范围。

    # (10**18 + gamma)**2/27
    d: int256 = unsafe_div(unsafe_add(10**18, gamma)**2, 27)

    # abs(3*a*c/b - b)
    d0: int256 = abs(unsafe_mul(3, a) * c / b - b)  # <------------ a 很小。

    divider: int256 = 0
    if d0 > 10**48:
        divider = 10**30
    elif d0 > 10**44:
        divider = 10**26
    elif d0 > 10**40:
        divider = 10**22
    elif d0 > 10**36:
        divider = 10**18
    elif d0 > 10**32:
        divider = 10**14
    elif d0 > 10**28:
        divider = 10**10
    elif d0 > 10**24:
        divider = 10**6
    elif d0 > 10**20:
        divider = 10**2
    else:
        divider = 1

    additional_prec: int256 = 0
    if abs(a) > abs(b):
        additional_prec = abs(unsafe_div(a, b))
        a = unsafe_div(unsafe_mul(a, additional_prec), divider)
        b = unsafe_div(b * additional_prec, divider)
        c = unsafe_div(c * additional_prec, divider)
        d = unsafe_div(d * additional_prec, divider)
    else:
        additional_prec = abs(unsafe_div(b, a))
        a = unsafe_div(a / additional_prec, divider)
        b = unsafe_div(unsafe_div(b, additional_prec), divider)
        c = unsafe_div(unsafe_div(c, additional_prec), divider)
        d = unsafe_div(unsafe_div(d, additional_prec), divider)

    # 3*a*c/b - b
    _3ac: int256 = unsafe_mul(3, a) * c
    delta0: int256 = unsafe_div(_3ac, b) - b

    # 9*a*c/b - 2*b - 27*a**2/b*d/b
    delta1: int256 = (
        unsafe_div(3 * _3ac, b)
        - unsafe_mul(2, b)
        - unsafe_div(unsafe_div(27 * a**2, b) * d, b)
    )

    # delta1**2 + 4*delta0**2/b*delta0
    sqrt_arg: int256 = (
        delta1**2 +
        unsafe_div(4 * delta0**2, b) * delta0
    )

    sqrt_val: int256 = 0
    if sqrt_arg > 0:
        sqrt_val = convert(isqrt(convert(sqrt_arg, uint256)), int256)
    else:
        return [self._newton_y(_ANN, _gamma, x, _D, i), 0]

    b_cbrt: int256 = 0
    if b >= 0:
        b_cbrt = convert(self._cbrt(convert(b, uint256)), int256)
    else:
        b_cbrt = -convert(self._cbrt(convert(-b, uint256)), int256)

    second_cbrt: int256 = 0
    if delta1 > 0:
        # convert(self._cbrt(convert((delta1 + sqrt_val), uint256)/2), int256)
        second_cbrt = convert(
            self._cbrt(unsafe_div(convert(delta1 + sqrt_val, uint256), 2)),
            int256
        )
    else:
        second_cbrt = -convert(
            self._cbrt(unsafe_div(convert(-(delta1 - sqrt_val), uint256), 2)),
            int256
        )

    # b_cbrt*b_cbrt/10**18*second_cbrt/10**18
    C1: int256 = unsafe_div(
        unsafe_div(b_cbrt * b_cbrt, 10**18) * second_cbrt,
        10**18
    )

    # (b + b*delta0/C1 - C1)/3
    root_K0: int256 = unsafe_div(b + b * delta0 / C1 - C1, 3)

    # D*D/27/x_k*D/x_j*root_K0/a
    root: int256 = unsafe_div(
        unsafe_div(
            unsafe_div(unsafe_div(D * D, 27), x_k) * D,
            x_j
        ) * root_K0,
        a
    )

    out: uint256[2] = [
        convert(root, uint256),
        convert(unsafe_div(10**18 * root_K0, a), uint256)
    ]

    frac = unsafe_div(out[0] * 10**18, _D)
    assert frac >= 10**16 - 1 and frac < 10**20 + 1,  "Unsafe value for y"
    # 由于精度问题，get_y 的结果与 _newton_y 相比可能相差 2 wei 左右

    return out


@internal
@view
def _newton_y(
    ANN: uint256, gamma: uint256, x: uint256[N_COINS], D: uint256, i: uint256
) -> uint256:

    # 在给定 A、gamma、xp 和 D 的情况下，用牛顿法计算 x[i]。
    # 这是最初的方法；get_y 取代了它，但在特定条件下
    # 仍会回退到这个版本。

    # 这里可以跳过安全检查，因为 get_y 中已经做过了

    frac: uint256 = 0
    for k in range(3):
        if k != i:
            frac = x[k] * 10**18 / D
            assert frac > 10**16 - 1 and frac < 10**20 + 1, "Unsafe values x[i]"

    y: uint256 = D / N_COINS
    K0_i: uint256 = 10**18
    S_i: uint256 = 0

    x_sorted: uint256[N_COINS] = x
    x_sorted[i] = 0
    x_sorted = self._sort(x_sorted)  # 从大到小

    convergence_limit: uint256 = max(max(x_sorted[0] / 10**14, D / 10**14), 100)

    for j in range(2, N_COINS + 1):
        _x: uint256 = x_sorted[N_COINS - j]
        y = y * D / (_x * N_COINS)  # 先处理较小的 _x
        S_i += _x

    for j in range(N_COINS - 1):
        K0_i = K0_i * x_sorted[j] * N_COINS / D  # 先处理较大的 _x

    # 初始化变量：
    diff: uint256 = 0
    y_prev: uint256 = 0
    K0: uint256 = 0
    S: uint256 = 0
    _g1k0: uint256 = 0
    mul1: uint256 = 0
    mul2: uint256 = 0
    yfprime: uint256 = 0
    _dyfprime: uint256 = 0
    fprime: uint256 = 0
    y_minus: uint256 = 0
    y_plus: uint256 = 0

    for j in range(255):
        y_prev = y

        K0 = K0_i * y * N_COINS / D
        S = S_i + y

        _g1k0 = gamma + 10**18
        if _g1k0 > K0:
            _g1k0 = _g1k0 - K0 + 1
        else:
            _g1k0 = K0 - _g1k0 + 1

        # mul1 = 10**18 * D / gamma * _g1k0 / gamma * _g1k0 * A_MULTIPLIER / ANN
        mul1 = 10**18 * D / gamma * _g1k0 / gamma * _g1k0 * A_MULTIPLIER / ANN

        # 2*K0 / _g1k0
        mul2 = 10**18 + (2 * 10**18) * K0 / _g1k0

        yfprime = 10**18 * y + S * mul2 + mul1
        _dyfprime = D * mul2
        if yfprime < _dyfprime:
            y = y_prev / 2
            continue
        else:
            yfprime -= _dyfprime

        fprime = yfprime / y

        # y -= f / f_prime;  y = (y * fprime - f) / fprime
        y_minus = mul1 / fprime
        y_plus = (yfprime + 10**18 * D) / fprime + y_minus * 10**18 / K0
        y_minus += 10**18 * S / fprime

        if y_plus < y_minus:
            y = y_prev / 2
        else:
            y = y_plus - y_minus

        if y > y_prev:
            diff = y - y_prev
        else:
            diff = y_prev - y

        if diff < max(convergence_limit, y / 10**14):
            frac = y * 10**18 / D
            assert frac > 10**16 - 1 and frac < 10**20 + 1,  "Unsafe value for y"
            return y

    raise "Did not converge"


@external
@view
def newton_D(
    ANN: uint256,
    gamma: uint256,
    x_unsorted: uint256[N_COINS],
    K0_prev: uint256 = 0,
) -> uint256:
    """
    @notice 借助良好的初始猜测值，用牛顿法求解不变量。
    @dev ANN 已放大了 A_MULTIPLIER 倍
    @dev ANN 已经是 A * N**N
    @param ANN A * N**N 的值
    @param gamma gamma 值
    @param x_unsorted 币种余额数组（未排序）
    @param K0_prev 牛顿法的先验值，由 get_y_int 推导得出。默认
           为零（即无先验值）
    """
    x: uint256[N_COINS] = self._sort(x_unsorted)
    assert x[0] < max_value(uint256) / 10**18 * N_COINS**N_COINS  # dev: 超出限制
    assert x[0] > 0  # dev: 池子为空

    # 可以安全地使用 unsafe add，因为前面已经检查过最大 x 的边界
    S: uint256 = unsafe_add(unsafe_add(x[0], x[1]), x[2])
    D: uint256 = 0

    if K0_prev == 0:
        # 3 个数的几何平均值不可能大于其中最大的数，
        # 所以下面的操作是安全的：
        D = unsafe_mul(N_COINS, self._geometric_mean(x))
    else:
        if S > 10**36:
            D = self._cbrt(
                unsafe_div(
                    unsafe_div(x[0] * x[1], 10**36) * x[2],
                    K0_prev
                ) * 27 * 10**12
            )
        elif S > 10**24:
            D = self._cbrt(
                unsafe_div(
                    unsafe_div(x[0] * x[1], 10**24) * x[2],
                    K0_prev
                ) * 27 * 10**6
            )
        else:
            D = self._cbrt(
                unsafe_div(
                    unsafe_div(x[0] * x[1], 10**18) * x[2],
                    K0_prev
                ) * 27
            )

        # 若 K0_prev > 0，此处 D 不为零，而且我们已检查过 x[0] 大于 0。

    # 初始化变量：
    K0: uint256 = 0
    _g1k0: uint256 = 0
    mul1: uint256 = 0
    mul2: uint256 = 0
    neg_fprime: uint256 = 0
    D_plus: uint256 = 0
    D_minus: uint256 = 0
    D_prev: uint256 = 0

    diff: uint256 = 0
    frac: uint256 = 0

    for i in range(255):

        D_prev = D

        # K0 = 10**18 * x[0] * N_COINS / D * x[1] * N_COINS / D * x[2] * N_COINS / D
        K0 = unsafe_div(
            unsafe_mul(
                unsafe_mul(
                    unsafe_div(
                        unsafe_mul(
                            unsafe_mul(
                                unsafe_div(
                                    unsafe_mul(
                                        unsafe_mul(10**18, x[0]), N_COINS
                                    ),
                                    D,
                                ),
                                x[1],
                            ),
                            N_COINS,
                        ),
                        D,
                    ),
                    x[2],
                ),
                N_COINS,
            ),
            D,
        )  # <-------- 整个表达式都可以改用 unsafe 数学运算，
        #   因为 x_i 与 D 相差不大，所以预计不会上溢。此外
        #      D > 0，这一点前面已经证明过，所以 unsafe_div 是安全的。K0 > 0，
        #        因为可以放心地假设 D < 10**18 * x[0]。K0 也
        #                            处于 10**18 量级（这是它的性质）。

        _g1k0 = unsafe_add(gamma, 10**18)  # <--------- 可以安全地使用 unsafe_add。

        if _g1k0 > K0:  #       下面的运算可以安全地使用 unsafe 方式。
            _g1k0 = unsafe_add(unsafe_sub(_g1k0, K0), 1)
        else:
            _g1k0 = unsafe_add(unsafe_sub(K0, _g1k0), 1)

        # D / (A * N**N) * _g1k0**2 / gamma**2
        # mul1 = 10**18 * D / gamma * _g1k0 / gamma * _g1k0 * A_MULTIPLIER / ANN
        mul1 = unsafe_div(
            unsafe_mul(
                unsafe_mul(
                    unsafe_div(
                        unsafe_mul(
                            unsafe_div(unsafe_mul(10**18, D), gamma), _g1k0
                        ),
                        gamma,
                    ),
                    _g1k0,
                ),
                A_MULTIPLIER,
            ),
            ANN,
        )  # <------ 由于 D > 0，gamma 很小，_g1k0 很小，其余各项都是
        #        非零的小常数，并且 D 在此方法中有上限，
        #                    所以可以安全地把所有运算都改为 unsafe 数学运算。

        # 2*N*K0 / _g1k0
        # mul2 = (2 * 10**18) * N_COINS * K0 / _g1k0
        mul2 = unsafe_div(
            unsafe_mul(2 * 10**18 * N_COINS, K0), _g1k0
        )  # <--------------- K0 大致在 D 附近，而 D 的上限为
        #      10**15 * 10**18 + 1，这是由与 newton_D 配合调用的
        #    get_y 保证的。_g1k0 > 0，因此整个表达式都可以用 unsafe 运算。

        # neg_fprime: uint256 = (S + S * mul2 / 10**18) + mul1 * N_COINS / K0 - mul2 * D / 10**18
        neg_fprime = unsafe_sub(
            unsafe_add(
                unsafe_add(S, unsafe_div(unsafe_mul(S, mul2), 10**18)),
                unsafe_div(unsafe_mul(mul1, N_COINS), K0),
            ),
            unsafe_div(unsafe_mul(mul2, D), 10**18),
        )  # <--- mul1 是个大数但不算巨大：可以安全地以 unsafe 方式
        # 与 N_coins 相乘。若该表达式得以执行，则 neg_fprime > 0。
        # mul2 处于 10**18 量级（因为 K0 处于该量级），所以 S * mul2
        # 是安全的。前三项求和可以安全地用 unsafe 数学运算完成，
        # 并且由于 mul2 很小，最终表达式的值也会很小，因此
        # 整个表达式都可以安全地以 unsafe 方式计算。

        # D -= f / fprime
        # D * (neg_fprime + S) / neg_fprime
        D_plus = unsafe_div(D * unsafe_add(neg_fprime, S), neg_fprime)

        # D*D / neg_fprime
        D_minus = unsafe_div(D * D, neg_fprime)

        # 由于已知 K0 > 0 且 neg_fprime > 0，下面有若干运算
        # 可以用 unsafe 方式。此外，(10**18 - K0) 可以安全地参与乘法。
        # 因此只有 (D_minus + ...) 和 (D * ...) 这两个表达式保留安全运算
        if 10**18 > K0:
            # D_minus += D * (mul1 / neg_fprime) / 10**18 * (10**18 - K0) / K0
            D_minus += unsafe_div(
                unsafe_mul(
                    unsafe_div(D * unsafe_div(mul1, neg_fprime), 10**18),
                    unsafe_sub(10**18, K0),
                ),
                K0,
            )
        else:
            # D_minus -= D * (mul1 / neg_fprime) / 10**18 * (K0 - 10**18) / K0
            D_minus -= unsafe_div(
                unsafe_mul(
                    unsafe_div(D * unsafe_div(mul1, neg_fprime), 10**18),
                    unsafe_sub(K0, 10**18),
                ),
                K0,
            )

        if D_plus > D_minus:
            D = unsafe_sub(D_plus, D_minus)  # <--------- 安全，因为前面已做了检查。
        else:
            D = unsafe_div(unsafe_sub(D_minus, D_plus), 2)

        if D > D_prev:
            diff = unsafe_sub(D, D_prev)
        else:
            diff = unsafe_sub(D_prev, D)

        # 此处可以降低精度以节省 gas：
        if unsafe_mul(diff, 10**14) < max(10**16, D):

            # 检查下一次调用 get_y 是否安全
            for _x in x:
                frac = unsafe_div(unsafe_mul(_x, 10**18), D)
                assert frac >= 10**16 - 1 and frac < 10**20 + 1, "Unsafe values x[i]"

            return D
    raise "Did not converge"


@external
@view
def get_p(
    _xp: uint256[N_COINS], _D: uint256, _A_gamma: uint256[N_COINS-1]
) -> uint256[N_COINS-1]:
    """
    @notice 计算 dx/dy。
    @dev 输出值需要乘以 price_scale 才能得到实际值。
    @param _xp 池子的余额。
    @param _D D 的当前值。
    @param _A_gamma 放大系数 A 和 gamma。
    """

    assert _D > 10**17 - 1 and _D < 10**15 * 10**18 + 1  # dev: D 值不安全

    # K0 = P * N**N / D**N.
    # K0 是无量纲的，精度为 10**36：
    K0: uint256 = unsafe_div(
        unsafe_div(unsafe_div(27 * _xp[0] * _xp[1], _D) * _xp[2], _D) * 10**36,
        _D
    )

    # GK0 的精度为 10**36，且是无量纲的。
    # GK0 = (
    #     2 * _K0 * _K0 / 10**36 * _K0 / 10**36
    #     + (gamma + 10**18)**2
    #     - (_K0 * _K0 / 10**36 * (2 * gamma + 3 * 10**18) / 10**18)
    # )
    # GK0 始终为正，因此下面的运算永远不会回滚（revert）：
    GK0: uint256 = (
        unsafe_div(unsafe_div(2 * K0 * K0, 10**36) * K0, 10**36)
        + pow_mod256(unsafe_add(_A_gamma[1], 10**18), 2)
        - unsafe_div(
            unsafe_div(pow_mod256(K0, 2), 10**36) * unsafe_add(unsafe_mul(2, _A_gamma[1]), 3 * 10**18),
            10**18
        )
    )

    # NNAG2 = N**N * A * gamma**2
    NNAG2: uint256 = unsafe_div(unsafe_mul(_A_gamma[0], pow_mod256(_A_gamma[1], 2)), A_MULTIPLIER)

    # denominator = (GK0 + NNAG2 * x / D * _K0 / 10**36)
    denominator: uint256 = (GK0 + unsafe_div(unsafe_div(NNAG2 * _xp[0], _D) * K0, 10**36) )

    # p_xy = x * (GK0 + NNAG2 * y / D * K0 / 10**36) / y * 10**18 / denominator
    # p_xz = x * (GK0 + NNAG2 * z / D * K0 / 10**36) / z * 10**18 / denominator
    # p 的精度为 10**18。
    return [
        unsafe_div(
            _xp[0] * ( GK0 + unsafe_div(unsafe_div(NNAG2 * _xp[1], _D) * K0, 10**36) ) / _xp[1] * 10**18,
            denominator
        ),
        unsafe_div(
            _xp[0] * ( GK0 + unsafe_div(unsafe_div(NNAG2 * _xp[2], _D) * K0, 10**36) ) / _xp[2] * 10**18,
            denominator
        ),
    ]


# --------------------------- 数学工具函数 -------------------------------------


@external
@view
def cbrt(x: uint256) -> uint256:
    """
    @notice 以 1e18 精度计算一个数的立方根
    @dev 大约消耗 1500 单位 gas
    @param x 要计算立方根的数
    """
    return self._cbrt(x)


@external
@view
def geometric_mean(_x: uint256[3]) -> uint256:
    """
    @notice 以 1e18 精度计算一组数的几何平均值。
    @param _x 待排序的 3 个数组成的列表
    """
    return self._geometric_mean(_x)


@external
@view
def reduction_coefficient(x: uint256[N_COINS], fee_gamma: uint256) -> uint256:
    """
    @notice 根据给定的 x 和 fee_gamma 计算缩减系数（reduction coefficient）
    @dev 该方法用于计算手续费。
    @param x x 值
    @param fee_gamma 手续费 gamma 值
    """
    return self._reduction_coefficient(x, fee_gamma)


@external
@view
def wad_exp(_power: int256) -> uint256:
    """
    @notice 以 1e18 精度计算 e**x
    @param _power 要计算指数函数值的数（即 e**x 中的 x）
    """
    return self._snekmate_wad_exp(_power)


@internal
@pure
def _reduction_coefficient(x: uint256[N_COINS], fee_gamma: uint256) -> uint256:

    # 缩减系数 = fee_gamma / (fee_gamma + 1 - K)
    # K = x[0] ... x[N-1] / ((x[0] + ... + x[N-1]) / N)**N
    # 0 <= K <= 1
    # fee_gamma / (fee_gamma + 1) <= 缩减系数 <= 1

    S: uint256 = x[0] + x[1] + x[2]

    # 预先对 x 排序可能更好，但这里只用于计算动态手续费
    K: uint256 = 10**18 * N_COINS * x[0] / S
    K = unsafe_div(K * N_COINS * x[1], S)  # <- 这里的 unsafe div 是安全的。
    K = unsafe_div(K * N_COINS * x[2], S)

    if fee_gamma > 0:
        K = fee_gamma * 10**18 / (fee_gamma + 10**18 - K)

    return K


@internal
@pure
def _snekmate_wad_exp(x: int256) -> uint256:

    """
    @dev 计算有符号整数的自然指数函数，
         精度为 1e18。
    @notice 注意，该函数大约消耗 810 单位 gas。其实现
            参考了 Remco Bloemen 以 MIT 许可证发布的实现，见：
            https://xn--2-umb.com/22/exp-ln.
    @dev 本实现源自 Snekmate，其作者为
         pcaversaccio (Snekmate)，以 AGPL-3.0 许可证发布。
         https://github.com/pcaversaccio/snekmate
    @param x 32 字节的变量。
    @return int256 32 字节的计算结果。
    """
    value: int256 = x

    # 如果结果 `< 0.5`，则返回零。当满足以下条件时就会出现这种情况：
    # "x <= floor(log(0.5e18) * 1e18) ~ -42e18".
    if (x <= -42139678854452767551):
        return empty(uint256)

    # 当结果 "> (2 ** 255 - 1) / 1e18" 时，无法将其表示为有符号整数。
    # 当 "x >= floor(log((2 ** 255 - 1) / 1e18) * 1e18) ~ 135" 时就会出现这种情况。
    assert x < 135305999368893231589, "wad_exp overflow"

    # 此时 `x` 处于 "(-42, 136) * 1e18" 范围内。将其转换为 "(-42, 136) * 2 ** 96"，以获得更高的
    # 中间精度并使用二进制基数。这一基数转换相当于乘以
    # "1e18 / 2 ** 96 = 5 ** 18 / 2 ** 78".
    value = unsafe_div(x << 78, 5 ** 18)

    # 通过提取 2 的幂次，将 `x` 的范围缩小到 "(-½ ln 2, ½ ln 2) * 2 ** 96"，
    # 使得 "exp(x) = exp(x') * 2 ** k"，其中 `k` 是有符号整数。求解可得
    # "k = round(x / log(2))" 以及 "x' = x - k * log(2)"。因此，`k` 的范围是 "[-61, 195]"。
    k: int256 = unsafe_add(unsafe_div(value << 96, 54916777467707473351141471128), 2 ** 95) >> 96
    value = unsafe_sub(value, unsafe_mul(k, 54916777467707473351141471128))

    # 使用 "(6, 7)" 项有理函数逼近进行求值。由于 `p` 是首一多项式，
    # 稍后我们会再乘以一个缩放因子。
    y: int256 = unsafe_add(unsafe_mul(unsafe_add(value, 1346386616545796478920950773328), value) >> 96, 57155421227552351082224309758442)
    p: int256 = unsafe_add(unsafe_mul(unsafe_add(unsafe_mul(unsafe_sub(unsafe_add(y, value), 94201549194550492254356042504812), y) >> 96,\
                           28719021644029726153956944680412240), value), 4385272521454847904659076985693276 << 96)

    # 我们让 `p` 保持在 "2 ** 192" 基数下，这样做除法时
    # 就不必再次放大它。
    q: int256 = unsafe_add(unsafe_mul(unsafe_sub(value, 2855989394907223263936484059900), value) >> 96, 50020603652535783019961831881945)
    q = unsafe_sub(unsafe_mul(q, value) >> 96, 533845033583426703283633433725380)
    q = unsafe_add(unsafe_mul(q, value) >> 96, 3604857256930695427073651918091429)
    q = unsafe_sub(unsafe_mul(q, value) >> 96, 14423608567350463180887372962807573)
    q = unsafe_add(unsafe_mul(q, value) >> 96, 26449188498355588339934803723976023)

    # 多项式 `q` 在该范围内没有零点，因为它的所有根都是复数。
    # 无需缩放，因为 `p` 已经大了 "2 ** 96" 倍。此外，
    # 除法之后 `r` 处于 "(0.09, 0.25) * 2**96" 范围内。
    r: int256 = unsafe_div(p, q)

    # 为完成计算，我们需要将 `r` 乘以：
    #   - 缩放因子 "s = ~6.031367120"，
    #   - 范围缩减带来的因子 "2 ** k"，以及
    #   - 基数转换所需的因子 "1e18 / 2 ** 96"。
    # 我们一次性完成这些乘法，中间结果采用 "2**213" 基数，
    # 这样最后的右移总能得到正值。

    # 注意，为了绕过 Vyper 对可能为负的参数值 `r` 的 safecast（安全类型转换）
    # 检查，我们先将 `r` 转换为 `bytes32`，
    # 再转换为 `uint256`。请记住，EVM 的默认行为是
    # 使用二进制补码表示来处理有符号整数。
    return unsafe_mul(convert(convert(r, bytes32), uint256), 3822833074963236453042738258902158003155416615667) >> convert(unsafe_sub(195, k), uint256)


@internal
@pure
def _snekmate_log_2(x: uint256, roundup: bool) -> uint256:
    """
    @notice 一个 `internal` 辅助函数，按所选的取整方向
         返回 `x` 以 2 为底的对数。
    @dev 本实现源自 Snekmate，其作者为
         pcaversaccio (Snekmate)，以 AGPL-3.0 许可证发布。
         https://github.com/pcaversaccio/snekmate
    @dev 注意，输入为 0 时返回 0。其实现
         参考了 OpenZeppelin 的实现，见：
         https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/Math.sol.
    @param x 32 字节的变量。
    @param roundup 布尔变量，用于指定是否
           向上取整。默认值 `False` 表示向下取整。
    @return uint256 32 字节的计算结果。
    """
    value: uint256 = x
    result: uint256 = empty(uint256)

    # 下面几行不会上溢，因为存在众所周知的
    # 衰减性质：`log_2(max_value(uint256)) < max_value(uint256)`。
    if x >> 128 != empty(uint256):
        value = x >> 128
        result = 128
    if value >> 64 != empty(uint256):
        value = value >> 64
        result = unsafe_add(result, 64)
    if value >> 32 != empty(uint256):
        value = value >> 32
        result = unsafe_add(result, 32)
    if value >> 16 != empty(uint256):
        value = value >> 16
        result = unsafe_add(result, 16)
    if value >> 8 != empty(uint256):
        value = value >> 8
        result = unsafe_add(result, 8)
    if value >> 4 != empty(uint256):
        value = value >> 4
        result = unsafe_add(result, 4)
    if value >> 2 != empty(uint256):
        value = value >> 2
        result = unsafe_add(result, 2)
    if value >> 1 != empty(uint256):
        result = unsafe_add(result, 1)

    if (roundup and (1 << result) < x):
        result = unsafe_add(result, 1)

    return result


@internal
@pure
def _cbrt(x: uint256) -> uint256:

    xx: uint256 = 0
    if x >= 115792089237316195423570985008687907853269 * 10**18:
        xx = x
    elif x >= 115792089237316195423570985008687907853269:
        xx = unsafe_mul(x, 10**18)
    else:
        xx = unsafe_mul(x, 10**36)

    log2x: int256 = convert(self._snekmate_log_2(xx, False), int256)

    # 将 log2x 除以 3 时，余数为 (log2x % 3)。
    # 因此，如果我们只乘以 2**(log2x/3) 而丢弃余数来计算初始
    # 猜测值，那么牛顿法需要更多次迭代才能收敛到解，
    # 因为缺少了这部分精度。现在多做几步计算，可以换来之后更少的
    # 计算量：
    # pow = log2(x) // 3
    # remainder = log2(x) % 3
    # initial_guess = 2 ** pow * cbrt(2) ** remainder
    # 代入 -> 2 = 1.26 ≈ 1260 / 1000，可得：
    #
    # initial_guess = 2 ** pow * 1260 ** remainder // 1000 ** remainder

    remainder: uint256 = convert(log2x, uint256) % 3
    a: uint256 = unsafe_div(
        unsafe_mul(
            pow_mod256(2, unsafe_div(convert(log2x, uint256), 3)),  # <- pow
            pow_mod256(1260, remainder),
        ),
        pow_mod256(1000, remainder),
    )

    # 由于我们为立方根选取了良好的初始值，7 次牛顿-拉弗森（Newton-Raphson）迭代
    # 刚好足够。6 次迭代会导致不收敛，而 8 次
    # 则多了一次。如果没有好的初始值，迭代次数
    # 可能达到 20 次甚至更多。这些迭代已被展开，这样可以降低 gas 成本，
    # 但会占用更多字节码：
    a = unsafe_div(unsafe_add(unsafe_mul(2, a), unsafe_div(xx, unsafe_mul(a, a))), 3)
    a = unsafe_div(unsafe_add(unsafe_mul(2, a), unsafe_div(xx, unsafe_mul(a, a))), 3)
    a = unsafe_div(unsafe_add(unsafe_mul(2, a), unsafe_div(xx, unsafe_mul(a, a))), 3)
    a = unsafe_div(unsafe_add(unsafe_mul(2, a), unsafe_div(xx, unsafe_mul(a, a))), 3)
    a = unsafe_div(unsafe_add(unsafe_mul(2, a), unsafe_div(xx, unsafe_mul(a, a))), 3)
    a = unsafe_div(unsafe_add(unsafe_mul(2, a), unsafe_div(xx, unsafe_mul(a, a))), 3)
    a = unsafe_div(unsafe_add(unsafe_mul(2, a), unsafe_div(xx, unsafe_mul(a, a))), 3)

    if x >= 115792089237316195423570985008687907853269 * 10**18:
        a = unsafe_mul(a, 10**12)
    elif x >= 115792089237316195423570985008687907853269:
        a = unsafe_mul(a, 10**6)

    return a


@internal
@pure
def _sort(unsorted_x: uint256[3]) -> uint256[3]:

    # 将包含三个数的数组按降序排序：

    x: uint256[N_COINS] = unsorted_x
    temp_var: uint256 = x[0]
    if x[0] < x[1]:
        x[0] = x[1]
        x[1] = temp_var
    if x[0] < x[2]:
        temp_var = x[0]
        x[0] = x[2]
        x[2] = temp_var
    if x[1] < x[2]:
        temp_var = x[1]
        x[1] = x[2]
        x[2] = temp_var

    return x


@internal
@view
def _geometric_mean(_x: uint256[3]) -> uint256:

    # 计算三个数的几何平均值。

    prod: uint256 = unsafe_div(
        unsafe_div(_x[0] * _x[1], 10**18) * _x[2],
        10**18
    )

    if prod == 0:
        return 0

    return self._cbrt(prod)
