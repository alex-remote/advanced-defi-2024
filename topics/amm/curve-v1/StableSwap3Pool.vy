# @version 0.2.4
# (c) Curve.Fi, 2020
# DAI/USDC/USDT 资金池

from vyper.interfaces import ERC20

interface CurveToken:
    def totalSupply() -> uint256: view
    def mint(_to: address, _value: uint256) -> bool: nonpayable
    def burnFrom(_to: address, _value: uint256) -> bool: nonpayable


# 事件
event TokenExchange:
    buyer: indexed(address)
    sold_id: int128
    tokens_sold: uint256
    bought_id: int128
    tokens_bought: uint256


event AddLiquidity:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    fees: uint256[N_COINS]
    invariant: uint256
    token_supply: uint256

event RemoveLiquidity:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    fees: uint256[N_COINS]
    token_supply: uint256

event RemoveLiquidityOne:
    provider: indexed(address)
    token_amount: uint256
    coin_amount: uint256

event RemoveLiquidityImbalance:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    fees: uint256[N_COINS]
    invariant: uint256
    token_supply: uint256

event CommitNewAdmin:
    deadline: indexed(uint256)
    admin: indexed(address)

event NewAdmin:
    admin: indexed(address)


event CommitNewFee:
    deadline: indexed(uint256)
    fee: uint256
    admin_fee: uint256

event NewFee:
    fee: uint256
    admin_fee: uint256

event RampA:
    old_A: uint256
    new_A: uint256
    initial_time: uint256
    future_time: uint256

event StopRampA:
    A: uint256
    t: uint256


# 这个值可以（也需要）在编译时修改
N_COINS: constant(int128) = 3  # <- 修改这里

FEE_DENOMINATOR: constant(uint256) = 10 ** 10
LENDING_PRECISION: constant(uint256) = 10 ** 18
PRECISION: constant(uint256) = 10 ** 18  # 要转换到的目标精度
PRECISION_MUL: constant(uint256[N_COINS]) = [1, 1000000000000, 1000000000000]

# 1e18, 1e30, 1e30
RATES: constant(uint256[N_COINS]) = [1000000000000000000, 1000000000000000000000000000000, 1000000000000000000000000000000]
FEE_INDEX: constant(int128) = 2  # 可能收取转账手续费的币种（USDT）

MAX_ADMIN_FEE: constant(uint256) = 10 * 10 ** 9
MAX_FEE: constant(uint256) = 5 * 10 ** 9
MAX_A: constant(uint256) = 10 ** 6
MAX_A_CHANGE: constant(uint256) = 10

ADMIN_ACTIONS_DELAY: constant(uint256) = 3 * 86400
MIN_RAMP_TIME: constant(uint256) = 86400

# 依次为 DAI、USDC、USDT
coins: public(address[N_COINS])
balances: public(uint256[N_COINS])
fee: public(uint256)  # 存储值为 fee * 1e10
admin_fee: public(uint256)  # 存储值为 admin_fee * 1e10

owner: public(address)
token: CurveToken

initial_A: public(uint256)
future_A: public(uint256)
initial_A_time: public(uint256)
future_A_time: public(uint256)

admin_actions_deadline: public(uint256)
transfer_ownership_deadline: public(uint256)
future_fee: public(uint256)
future_admin_fee: public(uint256)
future_owner: public(address)

is_killed: bool
kill_deadline: uint256
KILL_DEADLINE_DT: constant(uint256) = 2 * 30 * 86400


@external
def __init__(
    _owner: address,
    _coins: address[N_COINS],
    _pool_token: address,
    _A: uint256,
    _fee: uint256,
    _admin_fee: uint256
):
    """
    @notice 合约构造函数
    @param _owner 合约所有者地址
    @param _coins 各币种的 ERC20 合约地址
    @param _pool_token 代表 LP 份额的代币地址
    @param _A 放大系数乘以 n * (n - 1)
    @param _fee 兑换时收取的手续费
    @param _admin_fee 管理费
    """
    for i in range(N_COINS):
        assert _coins[i] != ZERO_ADDRESS
    self.coins = _coins
    self.initial_A = _A
    self.future_A = _A
    self.fee = _fee
    self.admin_fee = _admin_fee
    self.owner = _owner
    self.kill_deadline = block.timestamp + KILL_DEADLINE_DT
    self.token = CurveToken(_pool_token)


@view
@internal
def _A() -> uint256:
    """
    处理 A 向上或向下的渐变调整
    """
    t1: uint256 = self.future_A_time
    A1: uint256 = self.future_A

    """
    A1 |           ......
       |         . |
       |       .   |
       |     .     |
       |   .       |
    A0 | .         | 
       |-|----|----|------
         t0   b    t1
    """

    if block.timestamp < t1:
        A0: uint256 = self.initial_A
        t0: uint256 = self.initial_A_time
        # uint256 表达式中不能出现负数，因此用 "if" 分情况处理
        if A1 > A0:
            return A0 + (A1 - A0) * (block.timestamp - t0) / (t1 - t0)
        else:
            return A0 - (A0 - A1) * (block.timestamp - t0) / (t1 - t0)

    else:  # 当 t1 == 0 或 block.timestamp >= t1 时
        return A1


@view
@external
def A() -> uint256:
    return self._A()


@view
@internal
def _xp() -> uint256[N_COINS]:
    result: uint256[N_COINS] = RATES
    for i in range(N_COINS):
        # DAI  = 1e18 * dai 余额  / 1e18 = 18 位小数
        # USDC = 1e30 * usdc 余额 / 1e18 = 18 位小数  
        # USDT = 1e30 * usdc 余额 / 1e18 = 18 位小数 
        result[i] = result[i] * self.balances[i] / LENDING_PRECISION
    return result


@pure
@internal
def _xp_mem(_balances: uint256[N_COINS]) -> uint256[N_COINS]:
    result: uint256[N_COINS] = RATES
    for i in range(N_COINS):
        result[i] = result[i] * _balances[i] / PRECISION
    return result


# D 是什么？
# 当池子完全平衡时，每种代币的余额都是 D / N
@pure
@internal
def get_D(xp: uint256[N_COINS], amp: uint256) -> uint256:
    # sum(x_i)
    S: uint256 = 0
    for _x in xp:
        S += _x
    if S == 0:
        return 0

    Dprev: uint256 = 0
    D: uint256 = S
    # A * (N ** N)
    Ann: uint256 = amp * N_COINS
    for _i in range(255):
        # D ** (N + 1) / (N ** N * prod(x_i))
        D_P: uint256 = D
        for _x in xp:
            D_P = D_P * D / (_x * N_COINS)  # 如果出现除以 0，这里会失败：此时只有取出操作还能进行。这正是我们想要的
        Dprev = D
        # 等价于 D - f(D) / (df/dD)(D)
        D = (Ann * S + D_P * N_COINS) * D / ((Ann - 1) * D + (N_COINS + 1) * D_P)
        # 在精度 1 以内视为相等
        if D > Dprev:
            if D - Dprev <= 1:
                break
        else:
            if Dprev - D <= 1:
                break
    return D


@view
@internal
def get_D_mem(_balances: uint256[N_COINS], amp: uint256) -> uint256:
    return self.get_D(self._xp_mem(_balances), amp)


@view
@external
def get_virtual_price() -> uint256:
    """
    返回资产组合的虚拟价格（用于计算利润）
    放大了 1e18 倍
    """
    D: uint256 = self.get_D(self._xp(), self._A())
    # D 的单位与 DAI 类似（即已转换为 1e18 精度）
    # 平衡时 D = n * x_u，即资产组合的总虚拟价值
    token_supply: uint256 = self.token.totalSupply()
    return D * PRECISION / token_supply


@view
@external
def calc_token_amount(amounts: uint256[N_COINS], deposit: bool) -> uint256:
    """
    简化方法：计算存入或取出时代币供应量的增加或减少量，
    不考虑手续费（但考虑了
    滑点）。
    用于防止抢跑，而不是用于精确计算！
    """
    _balances: uint256[N_COINS] = self.balances
    amp: uint256 = self._A()
    D0: uint256 = self.get_D_mem(_balances, amp)
    for i in range(N_COINS):
        if deposit:
            _balances[i] += amounts[i]
        else:
            _balances[i] -= amounts[i]
    D1: uint256 = self.get_D_mem(_balances, amp)
    token_amount: uint256 = self.token.totalSupply()
    diff: uint256 = 0
    if deposit:
        diff = D1 - D0
    else:
        diff = D0 - D1
    return diff * token_amount / D0


@external
@nonreentrant('lock')
def add_liquidity(amounts: uint256[N_COINS], min_mint_amount: uint256):
    assert not self.is_killed  # dev: 已被停用

    fees: uint256[N_COINS] = empty(uint256[N_COINS])
    _fee: uint256 = self.fee * N_COINS / (4 * (N_COINS - 1))
    _admin_fee: uint256 = self.admin_fee
    amp: uint256 = self._A()

    token_supply: uint256 = self.token.totalSupply()
    # 初始不变量
    D0: uint256 = 0
    old_balances: uint256[N_COINS] = self.balances
    if token_supply > 0:
        D0 = self.get_D_mem(old_balances, amp)
    new_balances: uint256[N_COINS] = old_balances

    for i in range(N_COINS):
        in_amount: uint256 = amounts[i]
        if token_supply == 0:
            assert in_amount > 0  # dev: 首次存入需要提供所有币种
        in_coin: address = self.coins[i]

        # 从发送者处转入代币
        if in_amount > 0:
            if i == FEE_INDEX:
                in_amount = ERC20(in_coin).balanceOf(self)

            # "safeTransferFrom"：无论 ERC20 是否返回 bool 都能正常工作
            _response: Bytes[32] = raw_call(
                in_coin,
                concat(
                    method_id("transferFrom(address,address,uint256)"),
                    convert(msg.sender, bytes32),
                    convert(self, bytes32),
                    convert(amounts[i], bytes32),
                ),
                max_outsize=32,
            )  # dev: 转账失败
            if len(_response) > 0:
                assert convert(_response, bool)  # dev: 转账失败

            if i == FEE_INDEX:
                in_amount = ERC20(in_coin).balanceOf(self) - in_amount

        new_balances[i] = old_balances[i] + in_amount

    # 变化后的不变量
    D1: uint256 = self.get_D_mem(new_balances, amp)
    assert D1 > D0

    # 我们需要在计入手续费后重新计算不变量
    # 以计算用户应得的公平份额
    D2: uint256 = D1
    if token_supply > 0:
        # 仅当不是首次存入时才计入手续费
        for i in range(N_COINS):
            ideal_balance: uint256 = D1 * old_balances[i] / D0
            difference: uint256 = 0
            if ideal_balance > new_balances[i]:
                difference = ideal_balance - new_balances[i]
            else:
                difference = new_balances[i] - ideal_balance
            fees[i] = _fee * difference / FEE_DENOMINATOR
            self.balances[i] = new_balances[i] - (fees[i] * _admin_fee / FEE_DENOMINATOR)
            new_balances[i] -= fees[i]
        D2 = self.get_D_mem(new_balances, amp)
    else:
        self.balances = new_balances

    # 计算要铸造多少池子代币
    mint_amount: uint256 = 0
    if token_supply == 0:
        mint_amount = D1  # 如果有零头（dust），一并计入
    else:
        mint_amount = token_supply * (D2 - D0) / D0

    assert mint_amount >= min_mint_amount, "Slippage screwed you"

    # 铸造池子代币
    self.token.mint(msg.sender, mint_amount)

    log AddLiquidity(msg.sender, amounts, fees, D1, token_supply + mint_amount)


@view
@internal
def get_y(i: int128, j: int128, x: uint256, xp_: uint256[N_COINS]) -> uint256:
    # 输入中的 x 已转换为统一的价格/精度

    assert i != j       # dev: 币种相同
    assert j >= 0       # dev: j 小于零
    assert j < N_COINS  # dev: j 超过 N_COINS

    # 理论上不会触发，但为了安全起见保留
    assert i >= 0
    assert i < N_COINS

    amp: uint256 = self._A()
    D: uint256 = self.get_D(xp_, amp)
    # p = prod(x_i)，其中 i != j
    # D ** (N + 1) / (N ** N * p * A * (N ** N))
    c: uint256 = D
    # sum(x_i)，其中 i != j
    S_: uint256 = 0
    # A * (N ** N)
    Ann: uint256 = amp * N_COINS

    _x: uint256 = 0
    for _i in range(N_COINS):
        if _i == i:
            _x = x
        elif _i != j:
            _x = xp_[_i]
        else:
            # i = j
            continue
        S_ += _x
        c = c * D / (_x * N_COINS)
    c = c * D / (Ann * N_COINS)
    b: uint256 = S_ + D / Ann  # - D
    y_prev: uint256 = 0
    y: uint256 = D
    for _i in range(255):
        y_prev = y
        # 等价于 y - f(y) / (df/dy)(y)
        y = (y*y + c) / (2 * y + b - D)
        # 在精度 1 以内视为相等
        if y > y_prev:
            if y - y_prev <= 1:
                break
        else:
            if y_prev - y <= 1:
                break
    return y


@view
@external
def get_dy(i: int128, j: int128, dx: uint256) -> uint256:
    # dx 和 dy 以 c 单位（c-units）计
    rates: uint256[N_COINS] = RATES
    xp: uint256[N_COINS] = self._xp()

    x: uint256 = xp[i] + (dx * rates[i] / PRECISION)
    y: uint256 = self.get_y(i, j, x, xp)
    dy: uint256 = (xp[j] - y - 1) * PRECISION / rates[j]
    _fee: uint256 = self.fee * dy / FEE_DENOMINATOR
    return dy - _fee


@view
@external
def get_dy_underlying(i: int128, j: int128, dx: uint256) -> uint256:
    # dx 和 dy 以底层代币单位计
    xp: uint256[N_COINS] = self._xp()
    precisions: uint256[N_COINS] = PRECISION_MUL

    x: uint256 = xp[i] + dx * precisions[i]
    y: uint256 = self.get_y(i, j, x, xp)
    dy: uint256 = (xp[j] - y - 1) / precisions[j]
    _fee: uint256 = self.fee * dy / FEE_DENOMINATOR
    return dy - _fee



@external
@nonreentrant('lock')
def exchange(i: int128, j: int128, dx: uint256, min_dy: uint256):
    assert not self.is_killed  # dev: 已被停用
    # 1e18, 1e30, 1e30
    rates: uint256[N_COINS] = RATES

    old_balances: uint256[N_COINS] = self.balances
    xp: uint256[N_COINS] = self._xp_mem(old_balances)

    # 处理转账时意外被收取手续费的情况（USDT、PAXG）
    dx_w_fee: uint256 = dx
    input_coin: address = self.coins[i]

    if i == FEE_INDEX:
        dx_w_fee = ERC20(input_coin).balanceOf(self)

    # "safeTransferFrom"：无论 ERC20 是否返回 bool 都能正常工作
    _response: Bytes[32] = raw_call(
        input_coin,
        concat(
            method_id("transferFrom(address,address,uint256)"),
            convert(msg.sender, bytes32),
            convert(self, bytes32),
            convert(dx, bytes32),
        ),
        max_outsize=32,
    )  # dev: 转账失败
    if len(_response) > 0:
        assert convert(_response, bool)  # dev: 转账失败

    if i == FEE_INDEX:
        dx_w_fee = ERC20(input_coin).balanceOf(self) - dx_w_fee

    x: uint256 = xp[i] + dx_w_fee * rates[i] / PRECISION
    y: uint256 = self.get_y(i, j, x, xp)

    dy: uint256 = xp[j] - y - 1  # -1 是为了以防出现取整误差
    dy_fee: uint256 = dy * self.fee / FEE_DENOMINATOR

    # 全部转换为实际单位
    dy = (dy - dy_fee) * PRECISION / rates[j]
    assert dy >= min_dy, "Exchange resulted in fewer coins than expected"

    dy_admin_fee: uint256 = dy_fee * self.admin_fee / FEE_DENOMINATOR
    dy_admin_fee = dy_admin_fee * PRECISION / rates[j]

    # 以与实际 ERC20 代币数量变化完全相同的方式修改 balances
    self.balances[i] = old_balances[i] + dx_w_fee
    # 出现取整误差时，我们少收管理费，让利给 LP
    #                                  - (dy - dy_fee) - dy_admin_fee 
    #                                  -  dy + dy_fee  - dy_admin_fee
    self.balances[j] = old_balances[j] - dy - dy_admin_fee

    # "safeTransfer"：无论 ERC20 是否返回 bool 都能正常工作
    _response = raw_call(
        self.coins[j],
        concat(
            method_id("transfer(address,uint256)"),
            convert(msg.sender, bytes32),
            convert(dy, bytes32),
        ),
        max_outsize=32,
    )  # dev: 转账失败
    if len(_response) > 0:
        assert convert(_response, bool)  # dev: 转账失败

    log TokenExchange(msg.sender, i, dx, j, dy)


@external
@nonreentrant('lock')
def remove_liquidity(_amount: uint256, min_amounts: uint256[N_COINS]):
    total_supply: uint256 = self.token.totalSupply()
    amounts: uint256[N_COINS] = empty(uint256[N_COINS])
    fees: uint256[N_COINS] = empty(uint256[N_COINS])  # fees 并未使用，但由于历史原因保留在事件中

    for i in range(N_COINS):
        value: uint256 = self.balances[i] * _amount / total_supply
        assert value >= min_amounts[i], "Withdrawal resulted in fewer coins than expected"
        self.balances[i] -= value
        amounts[i] = value

        # "safeTransfer"：无论 ERC20 是否返回 bool 都能正常工作
        _response: Bytes[32] = raw_call(
            self.coins[i],
            concat(
                method_id("transfer(address,uint256)"),
                convert(msg.sender, bytes32),
                convert(value, bytes32),
            ),
            max_outsize=32,
        )  # dev: 转账失败
        if len(_response) > 0:
            assert convert(_response, bool)  # dev: 转账失败

    self.token.burnFrom(msg.sender, _amount)  # dev: 余额不足

    log RemoveLiquidity(msg.sender, amounts, fees, total_supply - _amount)


@external
@nonreentrant('lock')
def remove_liquidity_imbalance(amounts: uint256[N_COINS], max_burn_amount: uint256):
    assert not self.is_killed  # dev: 已被停用

    token_supply: uint256 = self.token.totalSupply()
    assert token_supply != 0  # dev: 总供应量为零
    _fee: uint256 = self.fee * N_COINS / (4 * (N_COINS - 1))
    _admin_fee: uint256 = self.admin_fee
    amp: uint256 = self._A()

    old_balances: uint256[N_COINS] = self.balances
    new_balances: uint256[N_COINS] = old_balances
    D0: uint256 = self.get_D_mem(old_balances, amp)
    for i in range(N_COINS):
        new_balances[i] -= amounts[i]
    D1: uint256 = self.get_D_mem(new_balances, amp)
    fees: uint256[N_COINS] = empty(uint256[N_COINS])
    for i in range(N_COINS):
        ideal_balance: uint256 = D1 * old_balances[i] / D0
        difference: uint256 = 0
        if ideal_balance > new_balances[i]:
            difference = ideal_balance - new_balances[i]
        else:
            difference = new_balances[i] - ideal_balance
        fees[i] = _fee * difference / FEE_DENOMINATOR
        self.balances[i] = new_balances[i] - (fees[i] * _admin_fee / FEE_DENOMINATOR)
        new_balances[i] -= fees[i]
    D2: uint256 = self.get_D_mem(new_balances, amp)

    token_amount: uint256 = (D0 - D2) * token_supply / D0
    assert token_amount != 0  # dev: 销毁的代币数量为零
    token_amount += 1  # 以防出现取整误差——让结果对 "攻击者" 不利
    assert token_amount <= max_burn_amount, "Slippage screwed you"

    self.token.burnFrom(msg.sender, token_amount)  # dev: 余额不足
    for i in range(N_COINS):
        if amounts[i] != 0:

            # "safeTransfer"：无论 ERC20 是否返回 bool 都能正常工作
            _response: Bytes[32] = raw_call(
                self.coins[i],
                concat(
                    method_id("transfer(address,uint256)"),
                    convert(msg.sender, bytes32),
                    convert(amounts[i], bytes32),
                ),
                max_outsize=32,
            )  # dev: 转账失败
            if len(_response) > 0:
                assert convert(_response, bool)  # dev: 转账失败

    log RemoveLiquidityImbalance(msg.sender, amounts, fees, D1, token_supply - token_amount)


@view
@internal
def get_y_D(A_: uint256, i: int128, xp: uint256[N_COINS], D: uint256) -> uint256:
    """
    计算当 D 从基于 xp 算出的值减少到给定的 D 时 x[i] 的值

    通过迭代求解二次方程来实现。
    x_1**2 + x1 * (sum' - (A*n**n - 1) * D / (A * n**n)) = D ** (n + 1) / (n ** (2 * n) * prod' * A)
    x_1**2 + b*x_1 = c

    x_1 = (x_1**2 + c) / (2*x_1 + b)
    """
    # 输入中的 x 已转换为统一的价格/精度

    assert i >= 0  # dev: i 小于零
    assert i < N_COINS  # dev: i 超过 N_COINS

    c: uint256 = D
    S_: uint256 = 0
    Ann: uint256 = A_ * N_COINS

    _x: uint256 = 0
    for _i in range(N_COINS):
        if _i != i:
            _x = xp[_i]
        else:
            continue
        S_ += _x
        c = c * D / (_x * N_COINS)
    c = c * D / (Ann * N_COINS)
    b: uint256 = S_ + D / Ann
    y_prev: uint256 = 0
    y: uint256 = D
    for _i in range(255):
        y_prev = y
        y = (y*y + c) / (2 * y + b - D)
        # 在精度 1 以内视为相等
        if y > y_prev:
            if y - y_prev <= 1:
                break
        else:
            if y_prev - y <= 1:
                break
    return y


@view
@internal
def _calc_withdraw_one_coin(_token_amount: uint256, i: int128) -> (uint256, uint256):
    # 首先需要计算：
    # * 获取当前的 D
    # * 针对 D - _token_amount 求解关于 y_i 的方程
    amp: uint256 = self._A()
    _fee: uint256 = self.fee * N_COINS / (4 * (N_COINS - 1))
    precisions: uint256[N_COINS] = PRECISION_MUL
    total_supply: uint256 = self.token.totalSupply()

    xp: uint256[N_COINS] = self._xp()

    D0: uint256 = self.get_D(xp, amp)
    D1: uint256 = D0 - _token_amount * D0 / total_supply
    xp_reduced: uint256[N_COINS] = xp


    """
    从 D0 减少到 D1 的示例
    y = x1
    x0 和 x2 的代币余额固定不变，因此 x1 必须减少

     100  100  100
     _______________ D0 / 3
    |  | |  | |  |
    |--|-|--|-|--|-- D1 / 3
    |  | |  | |  |
    |  | |--|-|--|-- new_y
    |  | |  | |  |
    |__|_|__|_|__|
     x0   x1   x2

    """
    new_y: uint256 = self.get_y_D(amp, i, xp, D1)
    dy_0: uint256 = (xp[i] - new_y) / precisions[i]  # 不含手续费

    for j in range(N_COINS):
        dx_expected: uint256 = 0
        if j == i:
            dx_expected = xp[j] * D1 / D0 - new_y
        else:
            dx_expected = xp[j] - xp[j] * D1 / D0
        xp_reduced[j] -= _fee * dx_expected / FEE_DENOMINATOR

    # dy <= dy_0
    dy: uint256 = xp_reduced[i] - self.get_y_D(amp, i, xp_reduced, D1)
    dy = (dy - 1) / precisions[i]  # 少取出一点以应对取整误差

    return dy, dy_0 - dy


@view
@external
def calc_withdraw_one_coin(_token_amount: uint256, i: int128) -> uint256:
    return self._calc_withdraw_one_coin(_token_amount, i)[0]


@external
@nonreentrant('lock')
def remove_liquidity_one_coin(_token_amount: uint256, i: int128, min_amount: uint256):
    """
    移除 _amount 数量的流动性，全部以币种 i 的形式取出
    """
    assert not self.is_killed  # dev: 已被停用

    dy: uint256 = 0
    dy_fee: uint256 = 0
    dy, dy_fee = self._calc_withdraw_one_coin(_token_amount, i)
    assert dy >= min_amount, "Not enough coins removed"

    self.balances[i] -= (dy + dy_fee * self.admin_fee / FEE_DENOMINATOR)
    self.token.burnFrom(msg.sender, _token_amount)  # dev: 余额不足

    # "safeTransfer"：无论 ERC20 是否返回 bool 都能正常工作
    _response: Bytes[32] = raw_call(
        self.coins[i],
        concat(
            method_id("transfer(address,uint256)"),
            convert(msg.sender, bytes32),
            convert(dy, bytes32),
        ),
        max_outsize=32,
    )  # dev: 转账失败
    if len(_response) > 0:
        assert convert(_response, bool)  # dev: 转账失败

    log RemoveLiquidityOne(msg.sender, _token_amount, dy)


### 管理员函数 ###
@external
def ramp_A(_future_A: uint256, _future_time: uint256):
    assert msg.sender == self.owner  # dev: 仅限 owner
    assert block.timestamp >= self.initial_A_time + MIN_RAMP_TIME
    assert _future_time >= block.timestamp + MIN_RAMP_TIME  # dev: 时间不足

    _initial_A: uint256 = self._A()
    assert (_future_A > 0) and (_future_A < MAX_A)
    assert ((_future_A >= _initial_A) and (_future_A <= _initial_A * MAX_A_CHANGE)) or\
           ((_future_A < _initial_A) and (_future_A * MAX_A_CHANGE >= _initial_A))
    self.initial_A = _initial_A
    self.future_A = _future_A
    self.initial_A_time = block.timestamp
    self.future_A_time = _future_time

    log RampA(_initial_A, _future_A, block.timestamp, _future_time)


@external
def stop_ramp_A():
    assert msg.sender == self.owner  # dev: 仅限 owner

    current_A: uint256 = self._A()
    self.initial_A = current_A
    self.future_A = current_A
    self.initial_A_time = block.timestamp
    self.future_A_time = block.timestamp
    # 此后 (block.timestamp < t1) 恒为 False，因此会返回保存的 A

    log StopRampA(current_A, block.timestamp)


@external
def commit_new_fee(new_fee: uint256, new_admin_fee: uint256):
    assert msg.sender == self.owner  # dev: 仅限 owner
    assert self.admin_actions_deadline == 0  # dev: 已有进行中的操作
    assert new_fee <= MAX_FEE  # dev: 手续费超过上限
    assert new_admin_fee <= MAX_ADMIN_FEE  # dev: 管理费超过上限

    _deadline: uint256 = block.timestamp + ADMIN_ACTIONS_DELAY
    self.admin_actions_deadline = _deadline
    self.future_fee = new_fee
    self.future_admin_fee = new_admin_fee

    log CommitNewFee(_deadline, new_fee, new_admin_fee)


@external
def apply_new_fee():
    assert msg.sender == self.owner  # dev: 仅限 owner
    assert block.timestamp >= self.admin_actions_deadline  # dev: 时间不足
    assert self.admin_actions_deadline != 0  # dev: 没有进行中的操作

    self.admin_actions_deadline = 0
    _fee: uint256 = self.future_fee
    _admin_fee: uint256 = self.future_admin_fee
    self.fee = _fee
    self.admin_fee = _admin_fee

    log NewFee(_fee, _admin_fee)


@external
def revert_new_parameters():
    assert msg.sender == self.owner  # dev: 仅限 owner

    self.admin_actions_deadline = 0


@external
def commit_transfer_ownership(_owner: address):
    assert msg.sender == self.owner  # dev: 仅限 owner
    assert self.transfer_ownership_deadline == 0  # dev: 已有进行中的所有权转移

    _deadline: uint256 = block.timestamp + ADMIN_ACTIONS_DELAY
    self.transfer_ownership_deadline = _deadline
    self.future_owner = _owner

    log CommitNewAdmin(_deadline, _owner)


@external
def apply_transfer_ownership():
    assert msg.sender == self.owner  # dev: 仅限 owner
    assert block.timestamp >= self.transfer_ownership_deadline  # dev: 时间不足
    assert self.transfer_ownership_deadline != 0  # dev: 没有进行中的所有权转移

    self.transfer_ownership_deadline = 0
    _owner: address = self.future_owner
    self.owner = _owner

    log NewAdmin(_owner)


@external
def revert_transfer_ownership():
    assert msg.sender == self.owner  # dev: 仅限 owner

    self.transfer_ownership_deadline = 0


@view
@external
def admin_balances(i: uint256) -> uint256:
    return ERC20(self.coins[i]).balanceOf(self) - self.balances[i]


@external
def withdraw_admin_fees():
    assert msg.sender == self.owner  # dev: 仅限 owner

    for i in range(N_COINS):
        c: address = self.coins[i]
        value: uint256 = ERC20(c).balanceOf(self) - self.balances[i]
        if value > 0:
            # "safeTransfer"：无论 ERC20 是否返回 bool 都能正常工作
            _response: Bytes[32] = raw_call(
                c,
                concat(
                    method_id("transfer(address,uint256)"),
                    convert(msg.sender, bytes32),
                    convert(value, bytes32),
                ),
                max_outsize=32,
            )  # dev: 转账失败
            if len(_response) > 0:
                assert convert(_response, bool)  # dev: 转账失败


@external
def donate_admin_fees():
    assert msg.sender == self.owner  # dev: 仅限 owner
    for i in range(N_COINS):
        self.balances[i] = ERC20(self.coins[i]).balanceOf(self)


@external
def kill_me():
    assert msg.sender == self.owner  # dev: 仅限 owner
    assert self.kill_deadline > block.timestamp  # dev: 已过截止时间
    self.is_killed = True


@external
def unkill_me():
    assert msg.sender == self.owner  # dev: 仅限 owner
    self.is_killed = False
