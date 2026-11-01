# @version 0.3.9

"""
@title CurveTricryptoOptimizedWETH
@author Curve.Fi
@license Copyright (c) Curve.Fi, 2020-2023 - all rights reserved
@notice 一个用于 3 种非锚定资产（例如 ETH、BTC、USD）的 Curve AMM 池子。
@dev AMM 中的所有价格都以池子中的第一个代币为计价基准。
"""

from vyper.interfaces import ERC20
implements: ERC20  # <----------------------------- AMM 合约本身也是 LP 代币。

# --------------------------------- 接口 -------------------------------------

interface Math:
    def geometric_mean(_x: uint256[N_COINS]) -> uint256: view
    def wad_exp(_power: int256) -> uint256: view
    def cbrt(x: uint256) -> uint256: view
    def reduction_coefficient(
        x: uint256[N_COINS], fee_gamma: uint256
    ) -> uint256: view
    def newton_D(
        ANN: uint256,
        gamma: uint256,
        x_unsorted: uint256[N_COINS],
        K0_prev: uint256
    ) -> uint256: view
    def get_y(
        ANN: uint256,
        gamma: uint256,
        x: uint256[N_COINS],
        D: uint256,
        i: uint256,
    ) -> uint256[2]: view
    def get_p(
        _xp: uint256[N_COINS], _D: uint256, _A_gamma: uint256[2],
    ) -> uint256[N_COINS-1]: view

interface WETH:
    def deposit(): payable
    def withdraw(_amount: uint256): nonpayable

interface Factory:
    def admin() -> address: view
    def fee_receiver() -> address: view
    def views_implementation() -> address: view

interface Views:
    def calc_token_amount(
        amounts: uint256[N_COINS], deposit: bool, swap: address
    ) -> uint256: view
    def get_dy(
        i: uint256, j: uint256, dx: uint256, swap: address
    ) -> uint256: view
    def get_dx(
        i: uint256, j: uint256, dy: uint256, swap: address
    ) -> uint256: view


# ------------------------------- 事件 ---------------------------------------

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    value: uint256

event Approvale
    owner: indexed(address)
    spender: indexed(address)
    value: uint256

event TokenExchange:
    buyer: indexed(address)
    sold_id: uint256
    tokens_sold: uint256
    bought_id: uint256
    tokens_bought: uint256
    fee: uint256
    packed_price_scale: uint256

event AddLiquidity:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    fee: uint256
    token_supply: uint256
    packed_price_scale: uint256

event RemoveLiquidity:
    provider: indexed(address)
    token_amounts: uint256[N_COINS]
    token_supply: uint256

event RemoveLiquidityOne:
    provider: indexed(address)
    token_amount: uint256
    coin_index: uint256
    coin_amount: uint256
    approx_fee: uint256
    packed_price_scale: uint256

event CommitNewParameters:
    deadline: indexed(uint256)
    mid_fee: uint256
    out_fee: uint256
    fee_gamma: uint256
    allowed_extra_profit: uint256
    adjustment_step: uint256
    ma_time: uint256

event NewParameters:
    mid_fee: uint256
    out_fee: uint256
    fee_gamma: uint256
    allowed_extra_profit: uint256
    adjustment_step: uint256
    ma_time: uint256

event RampAgamma:
    initial_A: uint256
    future_A: uint256
    initial_gamma: uint256
    future_gamma: uint256
    initial_time: uint256
    future_time: uint256

event StopRampA:
    current_A: uint256
    current_gamma: uint256
    time: uint256

event ClaimAdminFee:
    admin: indexed(address)
    tokens: uint256


# ----------------------- 存储/状态变量 --------------------------------------

WETH20: public(immutable(address))

N_COINS: constant(uint256) = 3
PRECISION: constant(uint256) = 10**18  # <--------------- 要转换到的目标精度。
A_MULTIPLIER: constant(uint256) = 10000
packed_precisions: uint256

MATH: public(immutable(Math))
coins: public(immutable(address[N_COINS]))
factory: public(address)

price_scale_packed: uint256  # <---------------- 内部价格尺度（price scale）。
price_oracle_packed: uint256  # <------------------ 由移动平均给出的目标价格。

last_prices_packed: uint256
last_prices_timestamp: public(uint256)

initial_A_gamma: public(uint256)
initial_A_gamma_time: public(uint256)

future_A_gamma: public(uint256)
future_A_gamma_time: public(uint256)  # <---------------- 渐变调整结束的时间。
#                                     池子首次部署时该值为 0（默认值），只有在
#                            `ramp_A_gamma` 中启动渐变调整流程时，才会被赋值为
#                                block.timestamp + future_time。渐变调整结束后
#          （即 self.future_A_gamma_time < block.timestamp），该变量保持原值，
#                                                             不会被重置为 0。

balances: public(uint256[N_COINS])
D: public(uint256)
xcp_profit: public(uint256)
xcp_profit_a: public(uint256)  # <------------- 上次领取管理费时的累计总利润。

virtual_price: public(uint256)  # <------------ 缓存的（读取快速的）虚拟价格。
#                                    缓存的 `virtual_price` 也在合约内部使用。

# -------------- 影响 price_scale 如何调整的参数 -----------------------------

packed_rebalancing_params: public(uint256)  # <-------------------- 包含再平衡
#                      参数 allowed_extra_profit、adjustment_step 和 ma_time。

future_packed_rebalancing_params: uint256

# ---------------- 决定动态手续费的手续费参数 --------------------------------

packed_fee_params: public(uint256)  # <-- 打包了 mid_fee、out_fee、fee_gamma。
future_packed_fee_params: uint256

ADMIN_FEE: public(constant(uint256)) = 5 * 10**9  # <---- 所赚取手续费的 50%。
MIN_FEE: constant(uint256) = 5 * 10**5  # <----------------- 0.5 BPS（基点）。
MAX_FEE: constant(uint256) = 10 * 10**9
NOISE_FEE: constant(uint256) = 10**5  # <------------------- 0.1 BPS（基点）。

# ----------------------- 管理员参数 -----------------------------------------

admin_actions_deadline: public(uint256)

ADMIN_ACTIONS_DELAY: constant(uint256) = 3 * 86400
MIN_RAMP_TIME: constant(uint256) = 86400

MIN_A: constant(uint256) = N_COINS**N_COINS * A_MULTIPLIER / 100
MAX_A: constant(uint256) = 1000 * A_MULTIPLIER * N_COINS**N_COINS
MAX_A_CHANGE: constant(uint256) = 10
MIN_GAMMA: constant(uint256) = 10**10
MAX_GAMMA: constant(uint256) = 5 * 10**16

PRICE_SIZE: constant(uint128) = 256 / (N_COINS - 1)
PRICE_MASK: constant(uint256) = 2**PRICE_SIZE - 1

# ----------------------- ERC20 专用变量 -------------------------------------

name: public(immutable(String[64]))
symbol: public(immutable(String[32]))
decimals: public(constant(uint8)) = 18
version: public(constant(String[8])) = "v2.0.0"

balanceOf: public(HashMap[address, uint256])
allowance: public(HashMap[address, HashMap[address, uint256]])
totalSupply: public(uint256)
nonces: public(HashMap[address, uint256])

EIP712_TYPEHASH: constant(bytes32) = keccak256(
    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"
)
EIP2612_TYPEHASH: constant(bytes32) = keccak256(
    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
)
VERSION_HASH: constant(bytes32) = keccak256(version)
NAME_HASH: immutable(bytes32)
CACHED_CHAIN_ID: immutable(uint256)
salt: public(immutable(bytes32))
CACHED_DOMAIN_SEPARATOR: immutable(bytes32)


# ----------------------- 合约 -----------------------------------------------

@external
def __init__(
    _name: String[64],
    _symbol: String[32],
    _coins: address[N_COINS],
    _math: address,
    _weth: address,
    _salt: bytes32,
    packed_precisions: uint256,
    packed_A_gamma: uint256,
    packed_fee_params: uint256,
    packed_rebalancing_params: uint256,
    packed_prices: uint256,
):

    WETH20 = _weth
    MATH = Math(_math)

    self.factory = msg.sender

    name = _name
    symbol = _symbol
    coins = _coins

    self.packed_precisions = packed_precisions  # <-------------- 各代币的精度
    #                                     按 10**(18 - coin.decimals()) 计算。

    self.initial_A_gamma = packed_A_gamma  # <------------------- A 和 gamma。
    self.future_A_gamma = packed_A_gamma

    self.packed_rebalancing_params = packed_rebalancing_params  # <------ 包含
    #                        再平衡参数：allowed_extra_profit、adjustment_step
    #                                                       以及 ma_exp_time。

    self.packed_fee_params = packed_fee_params  # <---------------- 包含手续费
    #                                    参数：mid_fee、out_fee 和 fee_gamma。

    self.price_scale_packed = packed_prices
    self.price_oracle_packed = packed_prices
    self.last_prices_packed = packed_prices
    self.last_prices_timestamp = block.timestamp
    self.xcp_profit_a = 10**18

    #            缓存 DOMAIN_SEPARATOR。如果 chain.id 不等于 CACHED_CHAIN_ID，
    #                  那么每次调用 `permit` 时都会重新计算 DOMAIN_SEPARATOR。
    #                                 否则将始终使用 CACHED_DOMAIN_SEPARATOR。
    #                                      具体实现见：`_domain_separator()`。
    NAME_HASH = keccak256(name)
    salt = _salt
    CACHED_CHAIN_ID = chain.id
    CACHED_DOMAIN_SEPARATOR = keccak256(
        _abi_encode(
            EIP712_TYPEHASH,
            NAME_HASH,
            VERSION_HASH,
            chain.id,
            self,
            salt,
        )
    )

    log Transfer(empty(address), self, 0)  # <--------------------- 触发一次从
    #                                     0x0 到 self 的空转账，供索引器捕获。


# ------------------- 代币转入与转出 AMM -------------------------------------


@payable
@external
def __default__():
    if msg.value > 0:
        assert WETH20 in coins


@internal
def _transfer_in(
    _coin: address,
    dx: uint256,
    dy: uint256,
    mvalue: uint256,
    callbacker: address,
    callback_sig: bytes32,
    sender: address,
    receiver: address,
    use_eth: bool
):
    """
    @notice 将 `_coin` 从 `sender` 转入 `self`，并在 `callback_sig`
            非空时调用它。
    @dev 回调签名必须具有以下参数：
         sender: address
         receiver: address
         coin: address
         dx: uint256
         dy: uint256
    @params _coin 要转入的代币地址。
    @params dx 转入池子的 `_coin` 数量。
    @params dy 转出池子的 `_coin` 数量。
    @params mvalue 若转账的是 ETH 则为 msg.value，否则为 0。
    @params callbacker 在其上调用 `callback_sig` 的地址。
    @params callback_sig 回调函数的签名。
    @params sender 转出 `_coin` 的来源地址。
    @params receiver 接收 `_coin` 的目标地址。
    @params use_eth 若转账的是 ETH 则为 True，否则为 False。
    """

    if use_eth and _coin == WETH20:
        assert mvalue == dx  # dev: ETH 数量不正确
    else:
        assert mvalue == 0  # dev: ETH 数量不为零

        if callback_sig == empty(bytes32):

            assert ERC20(_coin).transferFrom(
                sender, self, dx, default_return_value=True
            )

        else:

            # -------------------------------- _transfer_in 中的这部分逻辑只能
            #                                              由 _exchange 访问。

            #                                 先调用回调逻辑，然后检查池子是否
            #                 收到了 dx 数量的 _coins[i]，否则回滚（revert）。
            b: uint256 = ERC20(_coin).balanceOf(self)
            raw_call(
                callbacker,
                concat(
                    slice(callback_sig, 0, 4),
                    _abi_encode(sender, receiver, _coin, dx, dy)
                )
            )
            assert ERC20(_coin).balanceOf(self) - b == dx  # dev: 回调没有给我们代币
            #                                          ^------ 注意：dx 不能
            #                               为 0，因此合约必须收到一些 _coin。

        if _coin == WETH20:
            WETH(WETH20).withdraw(dx)  # <------------ 如果上一步转入的是 WETH
            #                         且 `not use_eth`，则将 WETH 提取为 ETH。


@internal
def _transfer_out(
    _coin: address, _amount: uint256, use_eth: bool, receiver: address
):
    """
    @notice 从池子向 receiver 转出单个代币。
    @dev 该函数由 `remove_liquidity`、
         `remove_liquidity_one` 和 `_exchange` 方法调用。
    @params _coin 要转出的代币地址
    @params _amount 要转出的代币数量
    @params use_eth 是否转出 ETH
    @params receiver 接收代币的地址
    """

    if use_eth and _coin == WETH20:
        raw_call(receiver, b"", value=_amount)
    else:
        if _coin == WETH20:
            WETH(WETH20).deposit(value=_amount)

        assert ERC20(_coin).transfer(
            receiver, _amount, default_return_value=True
        )


# -------------------------- AMM 主要函数 ------------------------------------


@payable
@external
@nonreentrant("lock")
def exchange(
    i: uint256,
    j: uint256,
    dx: uint256,
    min_dy: uint256,
    use_eth: bool = False,
    receiver: address = msg.sender
) -> uint256:
    """
    @notice 执行兑换，默认使用包装后的原生代币
    @param i 输入代币的索引值
    @param j 输出代币的索引值
    @param dx 换入的输入代币数量
    @param min_dy 至少应收到的输出代币数量
    @param use_eth 若输入代币为原生代币则为 True，否则为 False
    @param receiver 接收输出代币的地址，默认为 msg.sender
    @return uint256 `receiver 收到的索引 j 对应代币的数量
    """
    return self._exchange(
        msg.sender,
        msg.value,
        i,
        j,
        dx,
        min_dy,
        use_eth,
        receiver,
        empty(address),
        empty(bytes32)
    )


@payable
@external
@nonreentrant('lock')
def exchange_underlying(
    i: uint256,
    j: uint256,
    dx: uint256,
    min_dy: uint256,
    receiver: address = msg.sender
) -> uint256:
    """
    @notice 使用原生代币转账进行兑换。
    @param i 输入代币的索引值
    @param j 输出代币的索引值
    @param dx 换入的输入代币数量
    @param min_dy 至少应收到的输出代币数量
    @param receiver 接收输出代币的地址，默认为 msg.sender
    @return uint256 `receiver 收到的索引 j 对应代币的数量
    """
    return self._exchange(
        msg.sender,
        msg.value,
        i,
        j,
        dx,
        min_dy,
        True,
        receiver,
        empty(address),
        empty(bytes32)
    )


@external
@nonreentrant('lock')
def exchange_extended(
    i: uint256,
    j: uint256,
    dx: uint256,
    min_dy: uint256,
    use_eth: bool,
    sender: address,
    receiver: address,
    cb: bytes32
) -> uint256:
    """
    @notice 带回调方法的兑换。
    @dev 该方法不允许换入原生代币，但允许
         从池子中转出原生代币的兑换。
    @dev 不允许闪电贷
    @dev 一个用例是减少 zap 中冗余的 ERC20 代币
         转账次数。
    @param i 输入代币的索引值
    @param j 输出代币的索引值
    @param dx 换入的输入代币数量
    @param min_dy 至少应收到的输出代币数量
    @param use_eth 若输出为原生代币则为 True，否则为 False
    @param sender 转出输入代币的来源地址
    @param receiver 接收输出代币的地址
    @param cb 回调签名
    @return uint256 `receiver` 收到的索引 j 对应代币的数量
    """

    assert cb != empty(bytes32)  # dev: 未指定回调
    return self._exchange(
        sender, 0, i, j, dx, min_dy, use_eth, receiver, msg.sender, cb
    )  # callbacker 绝不应是 self -------------------------^


@payable
@external
@nonreentrant("lock")
def add_liquidity(
    amounts: uint256[N_COINS],
    min_mint_amount: uint256,
    use_eth: bool = False,
    receiver: address = msg.sender
) -> uint256:
    """
    @notice 向池子添加流动性。
    @param amounts 要添加的各代币数量。
    @param min_mint_amount 至少应铸造的 LP 数量。
    @param use_eth 若向池子添加的是原生代币则为 True。
    @param receiver 接收 LP 代币的地址，默认为 msg.sender
    @return uint256 `receiver 收到的 LP 代币数量
    """

    A_gamma: uint256[2] = self._A_gamma()
    # 变换后的余额
    xp: uint256[N_COINS] = self.balances
    # amountsp = xp - xp_old
    amountsp: uint256[N_COINS] = empty(uint256[N_COINS])
    xx: uint256[N_COINS] = empty(uint256[N_COINS])
    d_token: uint256 = 0
    d_token_fee: uint256 = 0
    old_D: uint256 = 0

    assert amounts[0] + amounts[1] + amounts[2] > 0  # dev: 没有要添加的代币

    # --------------------- 获取价格、余额 -----------------------------------

    precisions: uint256[N_COINS] = self._unpack(self.packed_precisions)
    packed_price_scale: uint256 = self.price_scale_packed
    price_scale: uint256[N_COINS-1] = self._unpack_prices(packed_price_scale)

    # ---------------------------------------------------- 更新余额并计算 xp。
    xp_old: uint256[N_COINS] = xp
    for i in range(N_COINS):
        bal: uint256 = xp[i] + amounts[i]
        xp[i] = bal
        self.balances[i] = bal
    xx = xp

    # xp[i] = (balances[i] + amounts[i]) * price[i] * precision / PRECISION
    xp[0] *= precisions[0]
    xp_old[0] *= precisions[0]
    for i in range(1, N_COINS):
        xp[i] = unsafe_div(xp[i] * price_scale[i-1] * precisions[i], PRECISION)
        xp_old[i] = unsafe_div(
            xp_old[i] * unsafe_mul(price_scale[i-1], precisions[i]),
            PRECISION
        )

    # ---------------- 将代币 transferFrom 转入池子 --------------------------

    for i in range(N_COINS):
        if amounts[i] > 0:
            if coins[i] == WETH20:
                self._transfer_in(
                    coins[i],
                    amounts[i],
                    0,  # <-----------------------------------
                    msg.value,  #                             | add_liquidity
                    empty(address),  # <----------------------| 不使用
                    empty(bytes32),  # <----------------------| 回调。
                    msg.sender,  #                            |
                    empty(address),  # <-----------------------
                    use_eth
                )
            else:
                self._transfer_in(
                    coins[i],
                    amounts[i],
                    0,
                    0,  # <---------------- 若代币不是 WETH20，则 mvalue = 0。
                    empty(address),
                    empty(bytes32),
                    msg.sender,
                    empty(address),
                    False  # <------- 若代币不是 WETH20，则 use_eth 为 False。
                )
            amountsp[i] = xp[i] - xp_old[i]

    # -------------------- 计算要铸造的 LP 代币 ------------------------------
    if self.future_A_gamma_time > block.timestamp:  # <-- A_gamma 正在渐变调整中。
        # ------------------- 如果 A 或 gamma 正在渐变调整，则重新计算不变量。
        old_D = MATH.newton_D(A_gamma[0], A_gamma[1], xp_old, 0)
    else:
        old_D = self.D

    # 代币余额更新后的新 D
    D: uint256 = MATH.newton_D(A_gamma[0], A_gamma[1], xp, 0)

    token_supply: uint256 = self.totalSupply
    if old_D > 0:
        d_token = token_supply * D / old_D - token_supply
    else:
        # (D/(N*p0) * D/(N*p1) ... * D/(N*p(N-1))) ** (1/N)
        d_token = self.get_xcp(D)  # <--------------------------------- 使初始
        #                                                     虚拟价格等于 1。

    assert d_token > 0  # dev: 未铸造任何代币

    if old_D > 0:
        d_token_fee = (
            self._calc_token_fee(amountsp, xp) * d_token / 10**10 + 1
        )
        d_token -= d_token_fee
        token_supply += d_token
        self.mint(receiver, d_token)
        packed_price_scale = self.tweak_price(A_gamma, xp, D, 0)
    else:
        self.D = D
        self.virtual_price = 10**18
        self.xcp_profit = 10**18
        self.xcp_profit_a = 10**18
        self.mint(receiver, d_token)

    assert d_token >= min_mint_amount, "Slippage"

    log AddLiquidity(
        receiver, amounts, d_token_fee, token_supply, packed_price_scale
    )

    self._claim_admin_fees()  # <-------------------------------- 领取管理费。

    return d_token


@external
@nonreentrant("lock")
def remove_liquidity(
    _amount: uint256,
    min_amounts: uint256[N_COINS],
    use_eth: bool = False,
    receiver: address = msg.sender,
    claim_admin_fees: bool = True,
) -> uint256[N_COINS]:
    """
    @notice 这种取出方式非常安全，不涉及复杂的数学运算，因为
            代币是按均衡比例取出的。不收取手续费。
    @param _amount 要销毁的 LP 代币数量
    @param min_amounts 至少应取出的各代币数量
    @param use_eth 是否取出 ETH
    @param receiver 接收所取出代币的地址
    @param claim_admin_fees 若为 True，则调用 self._claim_admin_fees()。默认为 True。
    @return uint256[3] `receiver` 收到的池中代币数量
    """
    amount: uint256 = _amount
    balances: uint256[N_COINS] = self.balances
    d_balances: uint256[N_COINS] = empty(uint256[N_COINS])

    if claim_admin_fees:
        self._claim_admin_fees()  # <----------- 我们先领取手续费，以便 DAO 在
        #                       取出之前拿到收益。紧急情况下可将其设为 False。

    # --------------------------------------------------------- 销毁 LP 代币。

    total_supply: uint256 = self.totalSupply  # <-------- 先获取 totalSupply，
    self.burnFrom(msg.sender, _amount)  # ---- 再用 self.burnFrom 减少它。

    # 从池子取出代币有两种情况。
    #   情况 1：取出后池子未被清空。
    #           这种情况下，D 按销毁的 LP 代币数量
    #           按比例调整。转出的 ERC20 代币数量与
    #           (AMM 余额 * 转入的 LP 代币) / LP 代币总供应量 成正比
    #   情况 2：取出后池子被清空。
    #           这种情况下，所有代币都会被取出，并且不变量
    #           会被重置。

    if amount == total_supply:  # <---------------------------------- 情况 2。
        for i in range(N_COINS):
            d_balances[i] = balances[i]
            self.balances[i] = 0  # <------------------------------ 清空池子。
    else:  # <------------------------------------------------------- 情况 1。
        amount -= 1  # <------------------- 为防止取整误差，稍微偏向 LP 一点。
        for i in range(N_COINS):
            d_balances[i] = balances[i] * amount / total_supply
            assert d_balances[i] >= min_amounts[i]
            self.balances[i] = balances[i] - d_balances[i]
            balances[i] = d_balances[i]  # <--------- 现在它表示要转出的数量。

    D: uint256 = self.D
    # D1 / D0 = (total_supply - amount) / total_supply
    self.D = D - unsafe_div(D * amount, total_supply)  # <----------- 减少 D，
    #                         减少量与离开的代币数量成正比。由于取出是均衡的，
    #                            这只是简单的减法。若 amount == total_supply，
    #                                                             D 将变为 0。

    # ---------------------------------- 转账 --------------------------------

    for i in range(N_COINS):
        self._transfer_out(coins[i], d_balances[i], use_eth, receiver)

    log RemoveLiquidity(msg.sender, balances, total_supply - _amount)

    return d_balances


@external
@nonreentrant("lock")
def remove_liquidity_one_coin(
    token_amount: uint256,
    i: uint256,
    min_amount: uint256,
    use_eth: bool = False,
    receiver: address = msg.sender
) -> uint256:
    """
    @notice 以单一代币取出流动性。
            会收取手续费（低于兑换手续费）。
    @dev 该操作同时会领取管理费。
    @param token_amount 要销毁的 LP 代币数量
    @param i 要取出的代币索引
    @param min_amount 至少应取出的代币数量。
    @param use_eth 是否取出 ETH
    @param receiver 接收所取出代币的地址
    @return `receiver` 收到的索引 i 对应代币的数量
    """

    A_gamma: uint256[2] = self._A_gamma()

    dy: uint256 = 0
    D: uint256 = 0
    p: uint256 = 0
    xp: uint256[N_COINS] = empty(uint256[N_COINS])
    approx_fee: uint256 = 0

    # ------------------------------------------- 移除流动性之前先领取管理费。
    self._claim_admin_fees()

    # ------------------------------------------------------------------------

    dy, D, xp, approx_fee = self._calc_withdraw_one_coin(
        A_gamma,
        token_amount,
        i,
        (self.future_A_gamma_time > block.timestamp),  # <----- 在渐变调整期间
    )  #                                                      我们需要更新 D。

    assert dy >= min_amount, "Slippage"

    # ------------------------- 转账 -----------------------------------------

    self.balances[i] -= dy
    self.burnFrom(msg.sender, token_amount)
    self._transfer_out(coins[i], dy, use_eth, receiver)

    packed_price_scale: uint256 = self.tweak_price(A_gamma, xp, D, 0)
    #        此处可以安全使用来自 _calc_withdraw_one_coin 的 D --^

    log RemoveLiquidityOne(
        msg.sender, token_amount, i, dy, approx_fee, packed_price_scale
    )

    return dy


@external
@nonreentrant("lock")
def claim_admin_fees():
    """
    @notice 领取管理费。任何人都可以调用。
    """
    self._claim_admin_fees()


# -------------------------- 打包函数 ----------------------------------------


@internal
@view
def _pack(x: uint256[3]) -> uint256:
    """
    @notice 将 3 个值 <= 10**18 的整数打包进一个 uint256
    @param x 要打包的 uint256[3]
    @return uint256 打包后的整数
    """
    #      | 128 位   | 64 位   | 64 位   |
    #          x[0]      x[1]      x[2]
    return (x[0] << 128) | (x[1] << 64) | x[2]


@internal
@view
def _unpack(_packed: uint256) -> uint256[3]:
    """
    @notice 将一个 uint256 解包为 3 个整数（值必须 <= 10**18）
    @param val 要解包的 uint256
    @return uint256[3] 由解包所得整数组成的长度为 3 的列表
    """
    return [
        #                  2**64 - 1
        (_packed >> 128) & 18446744073709551615,
        (_packed >> 64) & 18446744073709551615,
        _packed & 18446744073709551615,
    ]


@internal
@view
def _pack_prices(prices_to_pack: uint256[N_COINS-1]) -> uint256:
    """
    @notice 将 N_COINS-1 个价格打包进一个 uint256。
    @param prices_to_pack 要打包的价格
    @return uint256 打包了价格的整数
    """
    packed_prices: uint256 = 0
    p: uint256 = 0

    # PRICE_SIZE: constant(uint128) = 256 / (N_COINS - 1)
    # PRICE_MASK: constant(uint256) = 2**PRICE_SIZE - 1

    for k in range(N_COINS - 1):
        # 左移 128 位
        packed_prices = packed_prices << PRICE_SIZE
        #                  k | 3 - 2 - k | prices
        #                  0 | 1         | prices[1]
        #                  1 | 0         | prices[0]
        p = prices_to_pack[N_COINS - 2 - k]
        assert p < PRICE_MASK
        packed_prices = p | packed_prices
    # prices[1] | prices[0]
    return packed_prices


@internal
@view
def _unpack_prices(_packed_prices: uint256) -> uint256[2]:
    # 返回 uint256[2]，coin[0] 的价格尺度为 1，因此无需存储
    """
    @notice 从一个 uint256 中解包出 N_COINS-1 个价格。
    @param _packed_prices 打包后的价格
    @return uint256[2] 解包后的价格
    """
    unpacked_prices: uint256[N_COINS-1] = empty(uint256[N_COINS-1])
    packed_prices: uint256 = _packed_prices
    for k in range(N_COINS - 1):
        # PRICE_SIZE: constant(uint128) = 256 / (N_COINS - 1)
        # PRICE_MASK: constant(uint256) = 2**PRICE_SIZE - 1
        #                                       128 位掩码
        # packed_prices = 128 位 | 128 位
        unpacked_prices[k] = packed_prices & PRICE_MASK
        #                                    将打包的价格右移 128 位
        packed_prices = packed_prices >> PRICE_SIZE
    # 解包后的价格    = 128 位   |  128 位
    #                  prices[1] | prices[0]
    return unpacked_prices


# ---------------------- AMM 内部函数 -------------------------------


@internal
def _exchange(
    sender: address,
    # msg.value
    mvalue: uint256,
    # 输入代币
    i: uint256,
    # 输出代币
    j: uint256,
    dx: uint256,
    min_dy: uint256,
    use_eth: bool,
    receiver: address,
    callbacker: address,
    callback_sig: bytes32
) -> uint256:

    assert i != j  # dev: 币种索引越界
    assert dx > 0  # dev: 不能兑换 0 个币

    A_gamma: uint256[2] = self._A_gamma()
    xp: uint256[N_COINS] = self.balances
    precisions: uint256[N_COINS] = self._unpack(self.packed_precisions)
    dy: uint256 = 0

    y: uint256 = xp[j]  # <----------------- 若 j > N_COINS，这里会回滚（revert）。
    x0: uint256 = xp[i]  # <--------------- 若 i > N_COINS，这里会回滚（revert）。
    xp[i] = x0 + dx
    self.balances[i] = xp[i]

    packed_price_scale: uint256 = self.price_scale_packed
    price_scale: uint256[N_COINS - 1] = self._unpack_prices(
        packed_price_scale
    )

    """
    变换后的余额 = 代币余额 * 价格尺度 * 精度 / PRECISION
    """
    xp[0] *= precisions[0]
    for k in range(1, N_COINS):
        xp[k] = unsafe_div(
            xp[k] * price_scale[k - 1] * precisions[k],
            PRECISION
        )  # <-------- 由于 PRECISION 不为零，这里使用 unsafe_div 是安全的。

    prec_i: uint256 = precisions[i]

    # ----------- 若 A、gamma 正在渐变调整，则更新不变量 ---------

    t: uint256 = self.future_A_gamma_time
    if t > block.timestamp:
        x0 *= prec_i

        if i > 0:
            x0 = unsafe_div(x0 * price_scale[i - 1], PRECISION)

        x1: uint256 = xp[i]  # <------------------ 备份 xp 中的旧值 ...
        xp[i] = x0                                                         # |
        self.D = MATH.newton_D(A_gamma[0], A_gamma[1], xp, 0)              # |
        xp[i] = x1  # <-------------------------------------- ... 然后恢复。

    # ----------------------- 计算 dy 和手续费 --------------------------

    D: uint256 = self.D
    prec_j: uint256 = precisions[j]
    y_out: uint256[2] = MATH.get_y(A_gamma[0], A_gamma[1], xp, D, j)
    dy = xp[j] - y_out[0]
    xp[j] -= dy
    dy -= 1

    if j > 0:
        dy = dy * PRECISION / price_scale[j - 1]
    dy /= prec_j

    fee: uint256 = unsafe_div(self._fee(xp) * dy, 10**10)

    dy -= fee  # <--------------------- 从转出数量中扣除手续费。
    assert dy >= min_dy, "Slippage"

    # y = y - (dy - fee)
    y -= dy
    self.balances[j] = y  # <----------- 更新转出币种在池子中的余额。

    y *= prec_j
    if j > 0:
        y = unsafe_div(y * price_scale[j - 1], PRECISION)
    xp[j] = y  # <------------------------------------------------- 更新 xp。

    # ---------------------- 执行转入和转出 -------------------------

    ########################## 转入 <-------
    self._transfer_in(
        coins[i], dx, dy, mvalue,
        callbacker, callback_sig,  # <-------- 回调方法在这里被调用。
        sender, receiver, use_eth,
    )

    ########################## -------> 转出
    self._transfer_out(coins[j], dy, use_eth, receiver)

    # ------ 微调 price_scale（并为 newton_D 提供良好的初始猜测值） ----------

    packed_price_scale = self.tweak_price(A_gamma, xp, 0, y_out[1])

    log TokenExchange(sender, i, dx, j, dy, fee, packed_price_scale)

    return dy


@internal
def tweak_price(
    A_gamma: uint256[2],
    _xp: uint256[N_COINS],
    new_D: uint256,
    K0_prev: uint256 = 0,
) -> uint256:
    """
    @notice 微调 price_oracle、last_price，并在满足条件时调整
            price_scale。每当发生非平衡的流动性操作时都会调用它：
            _exchange、add_liquidity 或
            remove_liquidity_one_coin。
    @dev 包含主要的流动性再平衡逻辑，通过微调 `price_scale` 实现。
    @param A_gamma 由 A 和 gamma 参数组成的数组。
    @param _xp 当前余额数组。
    @param new_D 新的 D 值。
    @param K0_prev `newton_D` 的初始猜测值。
    """

    # ---------------------------- 读取 storage ------------------------------

    rebalancing_params: uint256[3] = self._unpack(
        self.packed_rebalancing_params
    )  # <---------- 包含：allowed_extra_profit、adjustment_step、ma_time。
    price_oracle: uint256[N_COINS - 1] = self._unpack_prices(
        self.price_oracle_packed
    )
    last_prices: uint256[N_COINS - 1] = self._unpack_prices(
        self.last_prices_packed
    )
    packed_price_scale: uint256 = self.price_scale_packed
    price_scale: uint256[N_COINS - 1] = self._unpack_prices(
        packed_price_scale
    )

    total_supply: uint256 = self.totalSupply
    old_xcp_profit: uint256 = self.xcp_profit
    old_virtual_price: uint256 = self.virtual_price
    last_prices_timestamp: uint256 = self.last_prices_timestamp

    # ----------------------- 如有需要，更新移动平均（MA） ----------------------------

    if last_prices_timestamp < block.timestamp:

        #   移动平均价格预言机的计算使用上一个区块中交易的 last_price，
        #      以及在该交易之前记录的价格预言机值。
        #              每个区块只会发生一次。

        # ------------------ 计算移动平均参数 -----------------

        alpha: uint256 = MATH.wad_exp(
            -convert(
                unsafe_div(
                    (block.timestamp - last_prices_timestamp) * 10**18,
                    rebalancing_params[2]  # <----------------------- ma_time.
                ),
                int256,
            )
        )

        for k in range(N_COINS - 1):

            # ----------------- 进入 EMA 的状态价格被限制为不超过
            #                                                 2 x price_scale。
            # 新 EMA = min(最新价格, 2 * 价格尺度) * (1 - alpha) + 旧 EMA * alpha
            price_oracle[k] = unsafe_div(
                min(last_prices[k], 2 * price_scale[k]) * (10**18 - alpha) +
                price_oracle[k] * alpha,  # ^-------- 限制进入 EMA 的现货价格。
                10**18
            )

        self.price_oracle_packed = self._pack_prices(price_oracle)
        self.last_prices_timestamp = block.timestamp  # <---- 存储时间戳。

    #                  price_oracle 在后面用于计算它与 price_scale 之间的
    #            向量距离。该距离用于计算
    #                  需要对 price_scale 进行的调整量。

    # ------------------ 若 new_D 被设为 0，则计算它 ------------------
    # 调整价格之前的 D
    # 兑换期间 new_D = 0
    D_unadjusted: uint256 = new_D
    if new_D == 0:  #  <--------------------------- _exchange 会将 new_D 设为 0。
        D_unadjusted = MATH.newton_D(A_gamma[0], A_gamma[1], _xp, K0_prev)

    # ----------------------- 计算 last_prices（最新价格） --------------------------

    last_prices = MATH.get_p(_xp, D_unadjusted, A_gamma)
    for k in range(N_COINS - 1):
        last_prices[k] = unsafe_div(last_prices[k] * price_scale[k], 10**18)
    self.last_prices_packed = self._pack_prices(last_prices)

    # ---------- 先在不调整价格的情况下更新利润数据 --------

    """
    xp = [D/(N*p0), D/(N*p1), D/(N*p2)]
    """
    xp: uint256[N_COINS] = empty(uint256[N_COINS])
    xp[0] = unsafe_div(D_unadjusted, N_COINS)
    for k in range(N_COINS - 1):
        xp[k + 1] = D_unadjusted * 10**18 / (N_COINS * price_scale[k])

    # ------------------------- 更新 xcp_profit ----------------------------

    xcp_profit: uint256 = 10**18
    virtual_price: uint256 = 10**18

    if old_virtual_price > 0:

        xcp: uint256 = MATH.geometric_mean(xp)
        virtual_price = 10**18 * xcp / total_supply

        """"
        xcp_profit = 初始虚拟价格 * (repeg 之前虚拟价格累计的盈利 / 亏损比率)
                     初始虚拟价格 = 1

        v_old[i] = 时刻 i 存储在状态变量中的虚拟价格
        v_new[i] = 时刻 i 计算得到的虚拟价格
        v_old[0] = 1

        xcp_profit = 1 * (v_new[0] / v_old[0]) * (v_new[1] / v_old[1]) * (v_new[2] / v_old[2]) * .. * (v_new[n] / v_old[n])

        虚拟价格在以下位置更新
        - 此处（代码更下方）
        - claim_admin_fees

        (1) 不考虑 claim_admin_fees 更新的简单示例
        假设 self.virtual_price 在两次调用 tweak_price 之间不发生变化
        v_new[i] = v_old[i + 1]

        xcp_profit = v_new[n] / v_old[0]
                   = v_new[n]

        (2) 考虑 claim_admin_fees 更新的示例
        self.virtual_price 可能在两次调用 tweak_price 之间发生变化

        xcp_profit = 1 * (v_new[0] / v_old[0]) * (v_new[1] / v_old[1]) * (v_new[2] / v_old[2]) * .. * (v_new[n] / v_old[n])
        """
        xcp_profit = unsafe_div(
            old_xcp_profit * virtual_price,
            old_virtual_price
        )  # <---------------- 由于 old_virtual_price > 0，使用 unsafe_div 是安全的。

        #       若 A 和 gamma 没有在渐变调整（t < block.timestamp），
        #         则确保新的 virtual_price 不低于旧的 virtual_price，
        #                                        否则池子就遭受了损失。
        if self.future_A_gamma_time < block.timestamp:
            assert virtual_price > old_virtual_price, "Loss"

    self.xcp_profit = xcp_profit

    # ------------ 若利润足以支撑调整，则对流动性进行再平衡：
    """
    当 allowed_extra_profit = 0 时

    virtual_price > (1 + xcp_profit) / 2

    |----------------- xcp_profit
    |
    |----------------- virtual_price
    |----------------- (1 + xcp_profit) / 2
    |
    |
    |----------------- 1
    """
    if virtual_price * 2 - 10**18 > xcp_profit + 2 * rebalancing_params[0]:
        #                          allowed_extra_profit --------^

        # ------------------- 获取调整步长 ----------------------------

        #                计算 price_scale 与 price_oracle 之间的
        #                                                        向量距离。
        norm: uint256 = 0
        ratio: uint256 = 0
        for k in range(N_COINS - 1):

            ratio = unsafe_div(price_oracle[k] * 10**18, price_scale[k])
            # 可用 unsafe_div，因为之前已做过安全除法 ----^

            if ratio > 10**18:
                ratio = unsafe_sub(ratio, 10**18)
            else:
                ratio = unsafe_sub(10**18, ratio)
            norm = unsafe_add(norm, ratio**2)

        # norm = sqrt(sum(|1 - r|)), r = 价格预言机 / 价格尺度
        norm = isqrt(norm)  # <-------------------- isqrt 的结果不以 1e18 为基数。
        adjustment_step: uint256 = max(
            rebalancing_params[1], unsafe_div(norm, 5)
        )  #           ^------------------------------------- adjustment_step.

        if norm > adjustment_step:  # <---------- 只有当 price_oracle 与 price_scale 之间的
            #          向量距离足够大时，我们才调整价格。
            #             此检查确保在距离较小，即池子价格
            #           已锚定于预言机价格时，
            #                                     不会发生再平衡。

            # ------------------------------------- 计算新的价格尺度。

            p_new: uint256[N_COINS - 1] = empty(uint256[N_COINS - 1])
            for k in range(N_COINS - 1):
                # p_new = (price_scale * (norm - adj_step) + adj_step * EMA)) / norm
                #       =  price_scale * (1 - adj_step / norm) + adj_step / norm * EMA
                p_new[k] = unsafe_div(
                    price_scale[k] * unsafe_sub(norm, adjustment_step)
                    + adjustment_step * price_oracle[k],
                    norm
                )  # <- norm 非零且大于 adjustment_step；此处 unsafe 也是安全的

            # ---------------- 用 p_new 更新过时的 xp（基于 price_scale 计算）。
            xp = _xp
            for k in range(N_COINS - 1):
                # _xp = 代币余额 * 旧的 price_scale
                xp[k + 1] = unsafe_div(_xp[k + 1] * p_new[k], price_scale[k])
                # 可用 unsafe_div，因为之前已做过安全除法 ----^

            # ------------------------------------------ 用新的 xp 更新 D。
            D: uint256 = MATH.newton_D(A_gamma[0], A_gamma[1], xp, 0)

            for k in range(N_COINS):
                frac: uint256 = xp[k] * 10**18 / D  # <----- 检查
                assert (frac > 10**16 - 1) and (frac < 10**20 + 1)  #   p_new 的有效性。

            xp[0] = D / N_COINS
            for k in range(N_COINS - 1):
                xp[k + 1] = D * 10**18 / (N_COINS * p_new[k])  # <---- 将
                #                                           xp 转换为真实价格。

            # ---------- 用新的 xp 和 D 计算新的 virtual_price。复用
            #              `old_virtual_price`（但其中存放的是新的 virtual_price）。
            old_virtual_price = unsafe_div(
                10**18 * MATH.geometric_mean(xp), total_supply
            )  # <----- 可用 unsafe_div，因为之前已做过安全除法（若 vp>1e18）

            # ---------------------------- 若利润足够则继续。
            # 若新的 virtual_price > (1 + xcp_profit) / 2
            if (
                old_virtual_price > 10**18 and
                2 * old_virtual_price - 10**18 > xcp_profit
            ):

                packed_price_scale = self._pack_prices(p_new)

                self.D = D
                # virtual_price = xcp / total_supply，其中 xcp 用新的价格尺度计算
                self.virtual_price = old_virtual_price
                self.price_scale_packed = packed_price_scale

                return packed_price_scale

    # --------- price_scale 未被调整。更新利润计数器和 D。
    self.D = D_unadjusted
    # virtual_price = xcp / total_supply
    self.virtual_price = virtual_price

    return packed_price_scale


@internal
def _claim_admin_fees():
    """
    @notice 领取管理费，并将其发送给工厂合约（Factory）中设置的 fee_receiver。
    """
    A_gamma: uint256[2] = self._A_gamma()

    xcp_profit: uint256 = self.xcp_profit  # <---------- 池子当前的利润。
    xcp_profit_a: uint256 = self.xcp_profit_a  # <- 上次领取时的利润。
    total_supply: uint256 = self.totalSupply

    # 以下情况不领取管理费：
    # 1. 自上次领取以来累积的利润不足；
    # 2. LP 代币少于 10**18（即 1 个单位），否则可能导致
    #    虚拟价格被操纵。
    if xcp_profit <= xcp_profit_a or total_supply < 10**18:
        return

    #      在这里领取属于管理员的代币。做法是“吞入”（gulp）那些作为手续费
    #       累积下来、但尚未计入池子
    #         `self.balances` 的池中代币：池子余额只记录转入和
    #                  转出的代币，不包括手续费。下面的代码负责“吞入”手续费：

    for i in range(N_COINS):
        if coins[i] == WETH20:
            self.balances[i] = self.balance
        else:
            self.balances[i] = ERC20(coins[i]).balanceOf(self)

    #            若池子没有产生利润，则 `xcp_profit == xcp_profit_a`，
    #                         且池子在上一步中不会吞入任何代币。

    vprice: uint256 = self.virtual_price

    #  管理费按如下方式计算。
    #      1. 计算自上次领取以来累积的利润。`xcp_profit`
    #         是当前利润，`xcp_profit_a` 是
    #         上次领取时的利润。
    #      2. 取出管理员的份额，该份额硬编码为 5 * 10**9。
    #         （50% => 100% 的一半 => 10**10 / 2 => 5 * 10**9）。
    #      3. 由于一半的利润用于池子的再平衡，我们
    #         只剩下一半；所以再除以 2。

    # ------- xcp_profit -------
    #                          |
    # --------------------------
    #                          |
    # --------------------------- 利润的 50%
    #                          |
    # --------------------------- 50% 利润的 1/2 = 管理员可领取的部分
    #                          |
    # ------- xcp_profit_a -----
    #
    #   (xcp_profit - xcp_profit_a) * (5 * 1e9)  / (2 * 1e10)
    # = (xcp_profit - xcp_profit_a) * 5 / (2 * 10)
    # = (xcp_profit - xcp_profit_a) * 1 / 4
    fees: uint256 = unsafe_div(
        unsafe_sub(xcp_profit, xcp_profit_a) * ADMIN_FEE, 2 * 10**10
    )

    # ------------------------------ 通过以 LP 代币形式铸造管理员在池子中的
    #                                                份额来领取管理费。
    receiver: address = Factory(self.factory).fee_receiver()
    if receiver != empty(address) and fees > 0:
        # v = vprice
        # f = fees
        # T = 总供应量
        # q = frac = vprice 从 v - f 增长到 v 的百分比
        # 类似于 LP 提供者把流动性从 v - f 增加到 v。
        # 按 v / (v - f) 的比例增加总供应量
        # T * (1 + q) / T = v / (v - f)
        # q = v / (v - f) - 1
        frac: uint256 = vprice * 10**18 / (vprice - fees) - 10**18
        claimed: uint256 = self.mint_relative(receiver, frac)

        # fees * 2 = (xcp_profit - xcp_profit_a) / 2
        # TODO: 为什么要 -= profit / 2？
        xcp_profit -= fees * 2

        self.xcp_profit = xcp_profit

        log ClaimAdminFee(receiver, claimed)

    # ------------------------------------------- 由于执行了吞入，重新计算 D。
    D: uint256 = MATH.newton_D(A_gamma[0], A_gamma[1], self.xp(), 0)
    self.D = D

    # ------------------- 领取管理费后重新计算 virtual_price。
    #     此处我们不检查当前虚拟价格是否大于
    #               旧的虚拟价格，因为领取过程可能导致
    #                                     池子价值略微下降。

    self.virtual_price = 10**18 * self.get_xcp(D) / self.totalSupply
    self.xcp_profit_a = xcp_profit  # <------------ 缓存上次领取时的利润。


@internal
@view
def xp() -> uint256[N_COINS]:

    result: uint256[N_COINS] = self.balances
    packed_prices: uint256 = self.price_scale_packed
    precisions: uint256[N_COINS] = self._unpack(self.packed_precisions)

    """
    变换后的余额 = 代币余额 * 精度 * 价格尺度
    """

    result[0] *= precisions[0]
    for i in range(1, N_COINS):
        p: uint256 = (packed_prices & PRICE_MASK) * precisions[i]
        result[i] = result[i] * p / PRECISION
        packed_prices = packed_prices >> PRICE_SIZE

    return result


@view
@internal
def _A_gamma() -> uint256[2]:
    t1: uint256 = self.future_A_gamma_time

    A_gamma_1: uint256 = self.future_A_gamma
    # 128 位   | 128 位
    #    A     | gamma
    gamma1: uint256 = A_gamma_1 & 2**128 - 1
    A1: uint256 = A_gamma_1 >> 128

    if block.timestamp < t1:

        # --------------- 处理 A 的渐变上调与下调 --------------------

        """
           |      _______ A1
           |     /|
           |    / |
           |   x  |
           |  /|  |
           | / |  |
        A0_|/__|__|_______
           t0  b  t1
        """
        A_gamma_0: uint256 = self.initial_A_gamma
        t0: uint256 = self.initial_A_gamma_time

        # 将 t0 和 t1 都平移 - t0
        t1 -= t0
        t0 = block.timestamp - t0
        t2: uint256 = t1 - t0

        # t1 = t1 - t0
        # t0 = b - t0
        # t2 = (t1 - t0) - (b - t0) = t1 - b

        # A = A0（当 b = t0 时）
        #   = A1（当 b = t1 时）
        #    (A0 * (t1 - b) + A1 * (b - t0)) / (t1 - t0)
        A1 = ((A_gamma_0 >> 128) * t2 + A1 * t0) / t1
        gamma1 = ((A_gamma_0 & 2**128 - 1) * t2 + gamma1 * t0) / t1

    return [A1, gamma1]


@internal
@view
def _fee(xp: uint256[N_COINS]) -> uint256:
    fee_params: uint256[3] = self._unpack(self.packed_fee_params)
    # fee_params[0], fee_params[1], fee_params[2]
    #       mid_fee,       out_fee,     fee_gamma
    # mid_fee = 最小手续费乘数
    # out_fee = 最大手续费乘数
    # fee_gamma = 设定 mid_fee 增长到 out_fee 的快慢

    f: uint256 = MATH.reduction_coefficient(xp, fee_params[2])
    # f = fee_gamma / (fee_gamma + 1 - K)
    # K = x[0] ... x[N-1] / ((x[0] + ... + x[N-1]) / N)**N
    # 0 <= K <= 1
    # fee_gamma / (fee_gamma + 1) <= f <= 1

    # mid_fee * f + out_fee * (1 - f)
    # 平衡的池子      -> K = 1  -> f = 1  -> mid_fee
    # 不平衡的池子    -> K -> 0 -> f -> 0 -> out_fee
    return unsafe_div(
        fee_params[0] * f + fee_params[1] * (10**18 - f),
        10**18
    )


"""
xcp = 恒定乘积中的 x
    = 恒定乘积的流动性 L

恒定乘积
x0*x1*x2*...x(N-1) = L**N = xcp**N
"""
@internal
@view
def get_xcp(D: uint256) -> uint256:

    """
    x[0] = D / (N * p0) = D / N
    x[1] = D / (N * p1)
    x[2] = D / (N * p2)
    """
    x: uint256[N_COINS] = empty(uint256[N_COINS])
    x[0] = D / N_COINS
    packed_prices: uint256 = self.price_scale_packed  # <-- 这里不乘精度（precisions），
    #                                 因为我们不切换到“真实”单位。

    # PRICE_SIZE: constant(uint128) = 256 / (N_COINS - 1)
    # PRICE_MASK: constant(uint256) = 2**PRICE_SIZE - 1

    for i in range(1, N_COINS):
        x[i] = D * 10**18 / (N_COINS * (packed_prices & PRICE_MASK))
        packed_prices = packed_prices >> PRICE_SIZE

    """
    (D/(N*p0) * D/(N*p1) ... * D/(N*p(N-1))) ** (1/N)

    示例
    N = 3
    p0 = 1
    xcp = (D/3 * D/(3*p1) * D/(3*p2)) ** (1 / 3)
    """
    return MATH.geometric_mean(x)


@view
@internal
#                   amounts[i] = dx[i] * price_scale[i]
def _calc_token_fee(amounts: uint256[N_COINS], xp: uint256[N_COINS]) -> uint256:
    # fee = _fee * N / (4 * (N - 1))
    fee: uint256 = unsafe_div(
        unsafe_mul(self._fee(xp), N_COINS),
        unsafe_mul(4, unsafe_sub(N_COINS, 1))
    )

    S: uint256 = 0
    for _x in amounts:
        S += _x

    avg: uint256 = unsafe_div(S, N_COINS)
    Sdiff: uint256 = 0

    for _x in amounts:
        if _x > avg:
            Sdiff += unsafe_sub(_x, avg)
        else:
            Sdiff += unsafe_sub(avg, _x)

    # fee = sum(|amounts[i] - avg(amounts)|) * fee / sum(amounts)
    #     = 0（当 amounts[0] = amounts[1] = amounts[2] 时）
    return fee * Sdiff / S + NOISE_FEE


@internal
@view
def _calc_withdraw_one_coin(
    A_gamma: uint256[2],
    token_amount: uint256,
    i: uint256,
    update_D: bool,
) -> (uint256, uint256, uint256[N_COINS], uint256):

    token_supply: uint256 = self.totalSupply
    assert token_amount <= token_supply  # dev: 代币数量超过总供应量
    assert i < N_COINS  # dev: 币种索引越界

    xx: uint256[N_COINS] = self.balances
    precisions: uint256[N_COINS] = self._unpack(self.packed_precisions)
    xp: uint256[N_COINS] = precisions
    D0: uint256 = 0

    # -------------------------- 计算 D0 和 xp -------------------------

    price_scale_i: uint256 = PRECISION * precisions[0]
    packed_prices: uint256 = self.price_scale_packed
    xp[0] *= xx[0]
    for k in range(1, N_COINS):
        p: uint256 = (packed_prices & PRICE_MASK)
        if i == k:
            #               价格尺度 * 精度
            price_scale_i = p * xp[i]
        #       precision[k] * balances[k] * price_scale[k] / PRECISION
        xp[k] = unsafe_div(xp[k] * xx[k] * p, PRECISION)
        packed_prices = packed_prices >> PRICE_SIZE

    if update_D:  # <-------------- 若池子正在渐变调整，则更新 D。
        D0 = MATH.newton_D(A_gamma[0], A_gamma[1], xp, 0)
    else:
        D0 = self.D

    D: uint256 = D0

    # -------------------------------- 手续费计算 ------------------------------

    # 对 D 收取手续费。粗略计算取出后的 xp[i]，并用它
    # 来计算手续费。这里精度并不是最重要的：我们只希望
    # 实现这样的行为：造成的不平衡越大，AMM 收取的
    # 手续费就越多。

    # 调整 xp 时假设 xp[0] ~= xp[1] ~= x[2]，但通常并非
    #  如此。我们收取 self._fee(xp)，其中 xp 是单币取出后
    #  的不精确调整值。如果取出数量过大：默认收取最高手续费。
    #   这是因为否则手续费计算会发生下溢。

    xp_imprecise: uint256[N_COINS] = xp
    # 平衡取出 = 从 xp[0] 取 -> xp[0] * token_amount / token_supply
    #            从 xp[1] 取 -> xp[1] * token_amount / token_supply
    #            从 xp[2] 取 -> xp[2] * token_amount / token_supply
    # 非平衡取出
    # 假设 xp[0] ~= xp[1] ~= xp[2]  -> xp[i] * N * token_amount / token_supply
    xp_correction: uint256 = xp[i] * N_COINS * token_amount / token_supply
    fee: uint256 = self._unpack(self.packed_fee_params)[1]  # <- self.out_fee.

    # 从 xp[i] 中扣除 xp[i] * N * token_amount / token_supply
    # 并计算手续费
    if xp_correction < xp_imprecise[i]:
        xp_imprecise[i] -= xp_correction
        fee = self._fee(xp_imprecise)

    dD: uint256 = unsafe_div(token_amount * D, token_supply)
    D_fee: uint256 = fee * dD / (2 * 10**10) + 1  # <------- 对 D 收取的实际手续费。

    # --------- 以第 i 个代币计算 `approx_fee`（假设处于平衡状态）。
    # -------------------------------- 只有事件中的手续费需要用到它。
    approx_fee: uint256 = N_COINS * D_fee * xx[i] / D

    # ------------------------------------------------------------------------
    D -= (dD - D_fee)  # <----------------------------------- 对 D 收取手续费。
    # --------------------------------- 用 `(D - D_fee)` 计算 `y_out`。
    # D0 = 减去 dD 之前的 D
    # y0 = xp[i]
    # y1 = MATH.get_y(A_gamma[0], A_gamma[1], xp, D0 - dD, i)[0]
    #
    # D0 >= D0 - dD + D_fee >= D0 - dD
    # y0 >= y >= y1
    # y0 - y1 >= y0 - y = dy
    y: uint256 = MATH.get_y(A_gamma[0], A_gamma[1], xp, D, i)[0]
    dy: uint256 = (xp[i] - y) * PRECISION / price_scale_i
    xp[i] = y

    return dy, D, xp, approx_fee


# ------------------------ ERC20 函数 -----------------------------------


@internal
def _approve(_owner: address, _spender: address, _value: uint256):
    self.allowance[_owner][_spender] = _value

    log Approval(_owner, _spender, _value)


@internal
def _transfer(_from: address, _to: address, _value: uint256):
    assert _to not in [self, empty(address)]

    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value

    log Transfer(_from, _to, _value)


@view
@internal
def _domain_separator() -> bytes32:
    if chain.id != CACHED_CHAIN_ID:
        return keccak256(
            _abi_encode(
                EIP712_TYPEHASH,
                NAME_HASH,
                VERSION_HASH,
                chain.id,
                self,
                salt,
            )
        )
    return CACHED_DOMAIN_SEPARATOR


@external
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
    """
    @dev 将代币从一个地址转移到另一个地址。
    @param _from address 代币转出的地址
    @param _to address 代币转入的地址
    @param _value uint256 要转移的代币数量
    @return bool 转账成功时返回 True，否则回滚（revert）。
    """
    _allowance: uint256 = self.allowance[_from][msg.sender]
    if _allowance != max_value(uint256):
        self._approve(_from, msg.sender, _allowance - _value)

    self._transfer(_from, _to, _value)
    return True


@external
def transfer(_to: address, _value: uint256) -> bool:
    """
    @dev 向指定地址转移代币
    @param _to 转入的地址。
    @param _value 要转移的数量。
    @return bool 转账成功时返回 True，否则回滚（revert）。
    """
    self._transfer(msg.sender, _to, _value)
    return True


@external
def approve(_spender: address, _value: uint256) -> bool:
    """
    @notice 允许 `_spender` 从调用者账户中转移最多 `_value` 数量
            的代币。
    @dev 允许把非零授权额度直接改为另一个非零值，但应
         谨慎使用。可以使用 increaseAllowance + decreaseAllowance 方法
         来防止可能发生的抢跑。
    @param _spender 被允许花费最多 `_value` 数量的
                    调用者资金的账户。
    @param _value 允许 `_spender` 花费的代币数量。
    @return bool 是否成功
    """
    self._approve(msg.sender, _spender, _value)
    return True


@external
def increaseAllowance(_spender: address, _add_value: uint256) -> bool:
    """
    @notice 增加授予 `_spender` 的授权额度（allowance）。
    @dev 此函数永远不会上溢，而是会将
         授权额度限制在 max_value(uint256)。这有可能授予
         无限授权。
    @param _spender 要增加授权额度的账户。
    @param _add_value 授权额度的增加量。
    @return bool 是否成功
    """
    cached_allowance: uint256 = self.allowance[msg.sender][_spender]
    allowance: uint256 = unsafe_add(cached_allowance, _add_value)

    if allowance < cached_allowance:  # <-------------- 检查是否上溢。
        allowance = max_value(uint256)

    if allowance != cached_allowance:
        self._approve(msg.sender, _spender, allowance)

    return True


@external
def decreaseAllowance(_spender: address, _sub_value: uint256) -> bool:
    """
    @notice 减少授予 `_spender` 的授权额度（allowance）。
    @dev 此函数永远不会下溢，而是会将
        授权额度限制为 0。
    @param _spender 要减少授权额度的账户。
    @param _sub_value 授权额度的减少量。
    @return bool 是否成功。
    """
    cached_allowance: uint256 = self.allowance[msg.sender][_spender]
    allowance: uint256 = unsafe_sub(cached_allowance, _sub_value)

    if cached_allowance < allowance:  # <------------- 检查是否下溢。
        allowance = 0

    if allowance != cached_allowance:
        self._approve(msg.sender, _spender, allowance)

    return True


@external
def permit(
    _owner: address,
    _spender: address,
    _value: uint256,
    _deadline: uint256,
    _v: uint8,
    _r: bytes32,
    _s: bytes32,
) -> bool:
    """
    @notice 通过签名（permit，EIP-2612 签名授权）允许 `_spender` 花费
            `_owner` 最多 `_value` 数量的代币。
    @dev 发生链分叉（fork）时，由于 domain separator（域分隔符）会被重新计算，
         重放攻击可以被防止。但前提是分叉后
         产生的各条链都更新了自己的 chainId。
    @param _owner 生成签名并授予
                  授权额度的账户。
    @param _spender 将被授予授权额度的账户。
    @param _value 授权数量。
    @param _deadline 签名必须提交的截止时间。
    @param _v ECDSA 签名的最后一个字节。
    @param _r ECDSA 签名的前 32 字节。
    @param _s ECDSA 签名的第二个 32 字节。
    @return bool 是否成功。
    """
    assert _owner != empty(address)  # dev: owner 无效
    assert block.timestamp <= _deadline  # dev: permit 已过期

    nonce: uint256 = self.nonces[_owner]
    digest: bytes32 = keccak256(
        concat(
            b"\x19\x01",
            self._domain_separator(),
            keccak256(
                _abi_encode(
                    EIP2612_TYPEHASH, _owner, _spender, _value, nonce, _deadline
                )
            ),
        )
    )
    assert ecrecover(digest, _v, _r, _s) == _owner  # dev: 签名无效

    self.nonces[_owner] = unsafe_add(nonce, 1)  # <-- 此处使用 unsafe_add 是安全的。
    self._approve(_owner, _spender, _value)
    return True


@internal
def mint(_to: address, _value: uint256) -> bool:
    """
    @dev 铸造一定数量的代币并分配给某个账户。
         这里封装了对余额的修改，以确保
         触发正确的事件。
    @param _to 接收新铸造代币的账户。
    @param _value 将要铸造的数量。
    @return bool 是否成功。
    """
    self.totalSupply += _value
    self.balanceOf[_to] += _value

    log Transfer(empty(address), _to, _value)
    return True


@internal
def mint_relative(_to: address, frac: uint256) -> uint256:
    """
    @dev 将供应量按 (1 + frac/1e18) 倍增加，并把新增部分铸造给 _to
    @param _to 接收新铸造代币的账户。
    @param frac 要铸造的数量占当前供应量的比例。
    @return uint256 铸造的代币数量。
    """
    supply: uint256 = self.totalSupply
    d_supply: uint256 = supply * frac / 10**18
    if d_supply > 0:
        self.totalSupply = supply + d_supply
        self.balanceOf[_to] += d_supply
        log Transfer(empty(address), _to, d_supply)

    return d_supply


@internal
def burnFrom(_to: address, _value: uint256) -> bool:
    """
    @dev 从指定账户销毁一定数量的代币。
    @param _to 其代币将被销毁的账户。
    @param _value 将要销毁的数量。
    @return bool 是否成功。
    """
    self.totalSupply -= _value
    self.balanceOf[_to] -= _value

    log Transfer(_to, empty(address), _value)
    return True


# ------------------------- AMM 视图函数 -------------------------------


@external
@view
def fee_receiver() -> address:
    """
    @notice 返回管理费（admin fee）接收者的地址。
    @return address 手续费接收者。
    """
    return Factory(self.factory).fee_receiver()


@external
@view
def calc_token_amount(amounts: uint256[N_COINS], deposit: bool) -> uint256:
    """
    @notice 计算存入或取出 `amounts` 数量的币时
            将铸造或需销毁的 LP 代币数量
    @dev 已包含手续费。
    @param amounts 存入或取出的各代币数量
    @param deposit 存入操作为 True，取出操作为 False。
    @return uint256 存入或取出所对应的 LP 代币数量。
    """
    view_contract: address = Factory(self.factory).views_implementation()
    return Views(view_contract).calc_token_amount(amounts, deposit, self)


@external
@view
def get_dy(i: uint256, j: uint256, dx: uint256) -> uint256:
    """
    @notice 获取用 dx 数量的 coin[i] 兑换可得到的 coin[j] 代币数量
    @dev 已包含手续费。
    @param i 输入代币的索引。可通过 pool.coins(i) 查询第 i 个索引处的币地址
    @param j 输出代币的索引
    @param dx 输入的 coin[i] 代币数量
    @return uint256 输入 dx 数量的 i 代币可得到的输出 j 代币的精确数量。
    """
    view_contract: address = Factory(self.factory).views_implementation()
    return Views(view_contract).get_dy(i, j, dx, self)


@external
@view
def get_dx(i: uint256, j: uint256, dy: uint256) -> uint256:
    """
    @notice 获取要兑换出 dy 数量的 coin[j] 时
            需要输入的 coin[i] 代币数量
    @dev 这是一个近似方法，返回接近实际输入
         数量的估计值。在链上调用开销较大。
    @param i 输入代币的索引。可通过 pool.coins(i) 查询
           第 i 个索引处的币地址
    @param j 输出代币的索引
    @param dy 收到的 coin[j] 代币数量
    @return uint256 获得 dy 数量的 j 代币所需输入的 i 代币的近似数量。
    """
    view_contract: address = Factory(self.factory).views_implementation()
    return Views(view_contract).get_dx(i, j, dy, self)


@external
@view
@nonreentrant("lock")
def lp_price() -> uint256:
    """
    @notice 计算 LP 代币相对于第 0 个索引处的币的
            当前价格
    @return uint256 LP 价格。
    """

    price_oracle: uint256[N_COINS-1] = self._unpack_prices(
        self.price_oracle_packed
    )
    return (
        3 * self.virtual_price * MATH.cbrt(price_oracle[0] * price_oracle[1])
    ) / 10**24


@external
@view
@nonreentrant("lock")
def get_virtual_price() -> uint256:
    """
    @notice 计算池子 LP 代币当前的虚拟价格（virtual price）。
    @dev 不要与 `self.virtual_price` 混淆，后者是缓存的
         虚拟价格。
    @return uint256 虚拟价格。
    """

    """
    get_xcp = 恒定乘积流动性 L
    xy = L^2
    x0 * ... * x(n-1) = L^N

    x'i = D / N
    xi * pi = D / N
    xi = D / (N * pi)
    x0 * ... * x(n-1) = D/N
                        * D / (N * p1)
                        * D / (N * p2)
                        * ...
                        * D / (N * p(n-1))

    虚拟价格（virtual price）= L / LP 总供应量
    """
    return 10**18 * self.get_xcp(self.D) / self.totalSupply


@external
@view
@nonreentrant("lock")
def price_oracle(k: uint256) -> uint256:
    """
    @notice 返回索引 `k` 处的币相对于索引 0 处的币的
            预言机价格。
    @dev 该预言机是一个指数移动平均（EMA），其周期
         由 `self.ma_time` 决定。被聚合的价格是在最近一笔交易之后（AFTER）
         计算并缓存的状态价格 (dy/dx)。
    @param k 币的索引。
    @return uint256 第 k 个币的价格预言机值。
    """
    price_oracle: uint256 = self._unpack_prices(self.price_oracle_packed)[k]
    price_scale: uint256 = self._unpack_prices(self.price_scale_packed)[k]
    last_prices_timestamp: uint256 = self.last_prices_timestamp

    if last_prices_timestamp < block.timestamp:  # <------------ 如有需要，
        #                                                   更新移动平均值。

        last_prices: uint256 = self._unpack_prices(self.last_prices_packed)[k]
        ma_time: uint256 = self._unpack(self.packed_rebalancing_params)[2]
        # ma_time = 半衰期（half life）/ ln(2)
        # alpha = e**(ln(0.5) * dt / H)
        #
        # ln(0.5) = ln(1/2) = -ln(2)
        #
        # e**(-dt / ma_time) = e**(-ln(2) * dt / 半衰期)
        alpha: uint256 = MATH.wad_exp(
            -convert(
                (block.timestamp - last_prices_timestamp) * 10**18 / ma_time,
                int256,
            )
        )

        # ---- 将进入 EMA 的状态价格上限限制为 2 x price_scale。
        """
        min(last_price, 2 * price_scale) * (1 - a) + a * ma
        last_price != 最后成交价
        """
        return (
            min(last_prices, 2 * price_scale) * (10**18 - alpha) +
            price_oracle * alpha
        ) / 10**18

    return price_oracle


@external
@view
def last_prices(k: uint256) -> uint256:
    """
    @notice 返回索引 `k` 处的币相对于索引 0 处的币的
            最新价格。
    @dev last_prices 返回的是在最近一笔交易之后，AMM 对一笔无穷小兑换
         给出的报价。它并不等同于最后成交价，而是
         通过求 `x` 对 `y` 的偏导数计算得到。该
         导数在 `get_p` 中计算，然后乘以 price_scale（价格尺度）
         得到 last_prices。
    @param k 币的索引。
    @return uint256 最近记录的币价格。
    """
    return self._unpack_prices(self.last_prices_packed)[k]


@external
@view
def price_scale(k: uint256) -> uint256:
    """
    @notice 返回索引 `k` 处的币相对于索引 0 处的币的
            price scale（价格尺度）。
    @dev 价格尺度决定了流动性集中
         所围绕的价格区间。
    @param k 币的索引。
    @return uint256 币的价格尺度。
    """
    return self._unpack_prices(self.price_scale_packed)[k]


@external
@view
def fee() -> uint256:
    """
    @notice 返回池子在当前状态下收取的手续费。
    @dev 不要与流动性操作时收取的手续费混淆，因为
         那里的手续费是在添加或移除流动性之后（AFTER）
         基于 `xp` 计算的。
    @return uint256 手续费（bps）。
    """
    return self._fee(self.xp())


@view
@external
def calc_withdraw_one_coin(token_amount: uint256, i: uint256) -> uint256:
    """
    @notice 计算扣除手续费后的输出代币数量
    @param token_amount 要销毁的 LP 代币数量
    @param i 取出流动性时所用代币的索引
    @return uint256 销毁 token_amount 个 LP 代币可收到的第 i 个代币的数量。
    """

    return self._calc_withdraw_one_coin(
        self._A_gamma(),
        token_amount,
        i,
        (self.future_A_gamma_time > block.timestamp)
    )[0]


@external
@view
def calc_token_fee(
    amounts: uint256[N_COINS], xp: uint256[N_COINS]
) -> uint256:
    """
    @notice 返回 add_liquidity 时对给定数量收取的手续费。
    @param amounts 添加到池子中的各币数量。
    @param xp 池子当前余额乘以各币精度后的值。
    @return uint256 收取的手续费。
    """
    return self._calc_token_fee(amounts, xp)


@view
@external
def A() -> uint256:
    """
    @notice 返回池子当前的放大系数 A。
    @return uint256 A 参数。
    """
    return self._A_gamma()[0]


@view
@external
def gamma() -> uint256:
    """
    @notice 返回池子当前的 gamma 参数。
    @return uint256 gamma 参数。
    """
    return self._A_gamma()[1]


@view
@external
def mid_fee() -> uint256:
    """
    @notice 返回当前的 mid fee（中间手续费）
    @return uint256 mid_fee 的值。
    """
    return self._unpack(self.packed_fee_params)[0]


@view
@external
def out_fee() -> uint256:
    """
    @notice 返回当前的 out fee（外围手续费）
    @return uint256 out_fee 的值。
    """
    return self._unpack(self.packed_fee_params)[1]


@view
@external
def fee_gamma() -> uint256:
    """
    @notice 返回当前的 fee gamma
    @return uint256 fee_gamma 的值。
    """
    return self._unpack(self.packed_fee_params)[2]


@view
@external
def allowed_extra_profit() -> uint256:
    """
    @notice 返回当前允许的额外利润（allowed extra profit）
    @return uint256 allowed_extra_profit 的值。
    """
    return self._unpack(self.packed_rebalancing_params)[0]


@view
@external
def adjustment_step() -> uint256:
    """
    @notice 返回当前的调整步长（adjustment step）
    @return uint256 adjustment_step 的值。
    """
    return self._unpack(self.packed_rebalancing_params)[1]


@view
@external
def ma_time() -> uint256:
    """
    @notice 返回当前的移动平均时间（单位：秒）
    @dev 为得到以秒为单位的时间，参数会乘以 ln(2)
         此处可能存在差一（off-by-one）误差。
    @return uint256 ma_time 的值。
    """
    return self._unpack(self.packed_rebalancing_params)[2] * 694 / 1000


@view
@external
def precisions() -> uint256[N_COINS]:  # <-------------- 供视图合约（view contract）使用。
    """
    @notice 返回池子中每种币的精度。
    @return uint256[3] 各币的精度。
    """
    return self._unpack(self.packed_precisions)


@external
@view
def fee_calc(xp: uint256[N_COINS]) -> uint256:  # <----- 供视图合约使用。
    """
    @notice 返回池子在当前状态下收取的手续费。
    @param xp 池子当前余额乘以各币精度后的值。
    @return uint256 手续费值。
    """
    return self._fee(xp)


@view
@external
def DOMAIN_SEPARATOR() -> bytes32:
    """
    @notice EIP712 域分隔符（domain separator）。
    @return bytes32 为当前链设置的域分隔符。
    """
    return self._domain_separator()


# ------------------------- AMM 管理函数 ------------------------------


@external
def ramp_A_gamma(
    future_A: uint256, future_gamma: uint256, future_time: uint256
):
    """
    @notice 开始对 A 和 gamma 参数值进行线性渐变调整（ramp）。
    @dev 仅工厂合约（Factory）管理员可调用，并且仅
    @param future_A 未来的 A 值。
    @param future_gamma 未来的 gamma 值。
    @param future_time 渐变调整结束时的时间戳。
    """
    assert msg.sender == Factory(self.factory).admin()  # dev: 仅限 owner
    assert block.timestamp > self.initial_A_gamma_time + (MIN_RAMP_TIME - 1)  # dev: 渐变调整正在进行中
    assert future_time > block.timestamp + MIN_RAMP_TIME - 1  # dev: 时间不足

    A_gamma: uint256[2] = self._A_gamma()
    initial_A_gamma: uint256 = A_gamma[0] << 128
    initial_A_gamma = initial_A_gamma | A_gamma[1]

    assert future_A > MIN_A - 1
    assert future_A < MAX_A + 1
    assert future_gamma > MIN_GAMMA - 1
    assert future_gamma < MAX_GAMMA + 1

    ratio: uint256 = 10**18 * future_A / A_gamma[0]
    assert ratio < 10**18 * MAX_A_CHANGE + 1
    assert ratio > 10**18 / MAX_A_CHANGE - 1

    ratio = 10**18 * future_gamma / A_gamma[1]
    assert ratio < 10**18 * MAX_A_CHANGE + 1
    assert ratio > 10**18 / MAX_A_CHANGE - 1

    self.initial_A_gamma = initial_A_gamma
    self.initial_A_gamma_time = block.timestamp

    future_A_gamma: uint256 = future_A << 128
    future_A_gamma = future_A_gamma | future_gamma
    self.future_A_gamma_time = future_time
    self.future_A_gamma = future_A_gamma

    log RampAgamma(
        A_gamma[0],
        future_A,
        A_gamma[1],
        future_gamma,
        block.timestamp,
        future_time,
    )


@external
def stop_ramp_A_gamma():
    """
    @notice 立即停止 A 和 gamma 参数的渐变调整。
    @dev 仅工厂合约管理员可调用。
    """
    assert msg.sender == Factory(self.factory).admin()  # dev: 仅限 owner

    A_gamma: uint256[2] = self._A_gamma()
    current_A_gamma: uint256 = A_gamma[0] << 128
    current_A_gamma = current_A_gamma | A_gamma[1]
    self.initial_A_gamma = current_A_gamma
    self.future_A_gamma = current_A_gamma
    self.initial_A_gamma_time = block.timestamp
    self.future_A_gamma_time = block.timestamp

    # ------ 现在 (block.timestamp < t1) 恒为 False，因此会返回已保存的 A。

    log StopRampA(A_gamma[0], A_gamma[1], block.timestamp)


@external
def commit_new_parameters(
    _new_mid_fee: uint256,
    _new_out_fee: uint256,
    _new_fee_gamma: uint256,
    _new_allowed_extra_profit: uint256,
    _new_adjustment_step: uint256,
    _new_ma_time: uint256,
):
    """
    @notice 提交新参数。
    @dev 仅工厂合约管理员可调用。
    @param _new_mid_fee 新的 mid fee。
    @param _new_out_fee 新的 out fee。
    @param _new_fee_gamma 新的 fee gamma。
    @param _new_allowed_extra_profit 新的允许额外利润（allowed extra profit）。
    @param _new_adjustment_step 新的调整步长（adjustment step）。
    @param _new_ma_time 新的 ma time。ma_time 等于 time_in_seconds/ln(2)。
    """
    assert msg.sender == Factory(self.factory).admin()  # dev: 仅限 owner
    assert self.admin_actions_deadline == 0  # dev: 已有进行中的操作

    _deadline: uint256 = block.timestamp + ADMIN_ACTIONS_DELAY
    self.admin_actions_deadline = _deadline

    # ----------------------------- 设置手续费参数 ---------------------------

    new_mid_fee: uint256 = _new_mid_fee
    new_out_fee: uint256 = _new_out_fee
    new_fee_gamma: uint256 = _new_fee_gamma

    current_fee_params: uint256[3] = self._unpack(self.packed_fee_params)

    if new_out_fee < MAX_FEE + 1:
        assert new_out_fee > MIN_FEE - 1  # dev: 手续费超出范围
    else:
        new_out_fee = current_fee_params[1]

    if new_mid_fee > MAX_FEE:
        new_mid_fee = current_fee_params[0]
    assert new_mid_fee <= new_out_fee  # dev: mid-fee 过高

    if new_fee_gamma < 10**18:
        assert new_fee_gamma > 0  # dev: fee_gamma 超出范围 [1 .. 10**18]
    else:
        new_fee_gamma = current_fee_params[2]

    self.future_packed_fee_params = self._pack(
        [new_mid_fee, new_out_fee, new_fee_gamma]
    )

    # ----------------- 设置流动性再平衡参数 -----------------

    new_allowed_extra_profit: uint256 = _new_allowed_extra_profit
    new_adjustment_step: uint256 = _new_adjustment_step
    new_ma_time: uint256 = _new_ma_time

    current_rebalancing_params: uint256[3] = self._unpack(self.packed_rebalancing_params)

    if new_allowed_extra_profit > 10**18:
        new_allowed_extra_profit = current_rebalancing_params[0]

    if new_adjustment_step > 10**18:
        new_adjustment_step = current_rebalancing_params[1]

    if new_ma_time < 872542:  # <----- 计算方式：7 * 24 * 60 * 60 / ln(2)
        assert new_ma_time > 86  # dev: MA 时间应大于 60/ln(2)
    else:
        new_ma_time = current_rebalancing_params[2]

    self.future_packed_rebalancing_params = self._pack(
        [new_allowed_extra_profit, new_adjustment_step, new_ma_time]
    )

    # ---------------------------------- 日志 ---------------------------------

    log CommitNewParameters(
        _deadline,
        new_mid_fee,
        new_out_fee,
        new_fee_gamma,
        new_allowed_extra_profit,
        new_adjustment_step,
        new_ma_time,
    )


@external
@nonreentrant("lock")
def apply_new_parameters():
    """
    @notice 应用已提交的参数。
    @dev 仅可在 admin_actions_deadline 之后调用。
    """
    assert block.timestamp >= self.admin_actions_deadline  # dev: 时间不足
    assert self.admin_actions_deadline != 0  # dev: 没有进行中的操作

    self.admin_actions_deadline = 0

    packed_fee_params: uint256 = self.future_packed_fee_params
    self.packed_fee_params = packed_fee_params

    packed_rebalancing_params: uint256 = self.future_packed_rebalancing_params
    self.packed_rebalancing_params = packed_rebalancing_params

    rebalancing_params: uint256[3] = self._unpack(packed_rebalancing_params)
    fee_params: uint256[3] = self._unpack(packed_fee_params)

    log NewParameters(
        fee_params[0],
        fee_params[1],
        fee_params[2],
        rebalancing_params[0],
        rebalancing_params[1],
        rebalancing_params[2],
    )


@external
def revert_new_parameters():
    """
    @notice 撤销已提交的参数
    @dev 仅工厂合约管理员可调用。将 admin_actions_deadline 设为 0
         可确保 apply_new_parameters 会回滚（revert）。
    """
    assert msg.sender == Factory(self.factory).admin()  # dev: 仅限 owner
    self.admin_actions_deadline = 0
