#pragma version 0.4.0
"""
@license  MIT
@author  Oscar Burgos ;-)
@title Buy Me a Coffee
@notice This contract is for creating a sample funding contract
"""

interface AggregatorV3Interface:
    def decimals() -> uint8: view
    def description() -> String[1000]: view
    def version() -> uint256: view
    def getRoundData(_roundId: uint80) -> (uint80, int256, uint256, uint256, uint80): view
    def latestRoundData() -> (uint80, int256, uint256, uint256, uint80): view

MINIMUM_USD: constant(uint256) = as_wei_value(5,"ether")
PRECISION: constant(uint256) = (1 * (10**18))
OWNER: immutable(address)
PRICE_FEED: immutable(AggregatorV3Interface)

funders: DynArray[address,1000]
funder_to_amount_funded: HashMap[address,uint256]


@deploy
def __init__(price_feed_address: address):
    # address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
    PRICE_FEED = AggregatorV3Interface(price_feed_address)
    OWNER = msg.sender

@external
@payable
def fund():
    self._fund()

@internal
@payable
def _fund():
    """
    Allows users to send $ to this contract.
    Have a minimum $ amount send

    How do we convert the ETH amount to dollars amount?
    """

    usd_value_of_eth:uint256 = self.get_eth_to_usd_rate(msg.value)

    assert usd_value_of_eth >= MINIMUM_USD , "You must send more ETH!!"

    self.funders.append(msg.sender)

    self.funder_to_amount_funded[msg.sender] += msg.value

@external
def withdraw():

    """
    Take the money out of this contract, that people sent via fund function
    How do we make sure only we can pull the money out?
    """
    assert msg.sender == OWNER , "You must be the owner to withdraw money from this contract"
    #send(OWNER, self.balance) # this line is not recommended
    raw_call(OWNER, b"", value = self.balance) #b""" means empty data. This line is safer than the line above

    for funder: address in self.funders:
        self.funder_to_amount_funded[funder] = 0  # It will cost a lot of gas

    self.funders = []

@internal
@view
def get_eth_to_usd_rate(eth_amount:uint256)-> uint256:

    a: uint80 = 0
    price: int256 = 0
    b: uint256 = 0
    c: uint256 = 0
    d: uint80 = 0
    (a, price, b, c, d) = staticcall PRICE_FEED.latestRoundData() #3365.51000000
    # 8 decimals
    # $3,021
    #eth amount in usd
    eth_price : uint256 = convert(price,uint256) * (10**10) # the end of this line is adding 10 zeros at the end of the number 336551000000 -> 3365510000000000000000

    #ETH: 11000000000000000
    # $ / ETH : 3365510000000000000000
    # integer division removes all decimals
    eth_amount_in_usd: uint256= (eth_amount * eth_price) // PRECISION # it represents 18 decimal places
    return eth_amount_in_usd

@external
@view
def get_eth_to_usd(eth_amount:uint256) -> uint256:
    return self.get_eth_to_usd_rate(eth_amount)


@external
@payable
def __default__():
    self._fund()
