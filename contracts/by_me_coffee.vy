# Get funds from users
# Withdraw funds
# Set a minimum funding value in USD

# pragma version 0.4.0
# @ license: MIT
# @ auther: Oscar Burgos ;-)

interface AggregatorV3Interface:
    def decimals() -> uint8: view
    def description() -> String[1000]: view
    def version() -> uint256: view
    def getRoundData(_roundId: uint80) -> (uint80, int256, uint256, uint256, uint80): view
    def latestRoundData() -> (uint80, int256, uint256, uint256, uint80): view

minimum_usd: uint256
price_feed: AggregatorV3Interface

@deploy
def __init__(price_feed_address: address):
    self.minimum_usd = 5
    self.price_feed = AggregatorV3Interface(price_feed_address)


@external
@payable
def fund():
    """
    Allows users to send $ to this contract.
    Have a minimum $ amount send

    How do we convert the ETH amount to dollars amount?
    """

    pass

@external
def withdraw():
    pass

@internal
def _get_eth_to_usd_rate():
    # We need the address of Sepolia Tesnet 0x694AA1769357215DE4FAC081bf1f309aDC325306
    # We need the ABI (It tell us how to interact with the contract)
    pass

@external
@view
def get_price(eth_amount:uint256)-> int256:

    a: uint80 = 0
    price: int256 = 0
    b: uint256 = 0
    c: uint256 = 0
    d: uint80 = 0
    (a, price, b, c, d) = staticcall self.price_feed.latestRoundData()

    eth_price : uint256 = convert(price,uint256) * (10**10)

    return price