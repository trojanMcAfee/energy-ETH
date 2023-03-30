// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


// import 'ds-test/test.sol';
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import "forge-std/Test.sol";
import "forge-std/console.sol";
import '../../contracts/facets/ozOracleFacet.sol';
import '../../contracts/facets/EnergyETHFacet.sol';
import '../../contracts/testing-files/WtiFeed.sol';
import '../../contracts/testing-files/EthFeed.sol';
import '../../contracts/testing-files/GoldFeed.sol';
// import '../../contracts/ozDiamond.sol';
import '../../contracts/InitUpgradeV2.sol';
import '../../interfaces/ozIDiamond.sol';


contract EnergyETHFacetTest is Test {

    uint256 arbFork;
    uint ethFork;
    
    ozOracleFacet private ozOracle;
    EnergyETHFacet private energyFacet;
    InitUpgradeV2 private initUpgrade;
    WtiFeed private wtiFeed;
    EthFeed private ethFeed;
    GoldFeed private goldFeed;
    ozIDiamond private OZL;

    address private deployer = 0xe738696676571D9b74C81716E4aE797c2440d306;
    address private volIndex = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;
    address private diamond = 0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2;

    address crvTricrypto = 0x8e0B8c8BB9db49a46697F3a5Bb8A308e744821D2;
    address yTricryptoPoolAddr = 0x239e14A19DFF93a17339DCC444f74406C17f8E67;
    address chainlinkAggregatorAddr = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

    address ozLoupe = 0xd986Ac35f3aD549794DBc70F33084F746b58b534;
    address revenueFacet = 0xD552211891bdBe3eA006343eF80d5aB283De601C;

    ERC20 USDC = ERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);

    address bob = makeAddr('bob');


    // struct FuzzSelector {
    //     address addr;
    //     bytes4[] selectors;
    // }


    function setUp() public {
        // string memory ARB_RPC = vm.envString('ARBITRUM');
        arbFork = vm.createSelectFork(vm.rpcUrl('arbitrum'), 69254399); //69254399

        (
            address[] memory facets,
            address[] memory feeds
        ) = _createContracts();

        initUpgrade = new InitUpgradeV2();

        OZL = ozIDiamond(diamond);

        bytes memory data = abi.encodeWithSelector(
            initUpgrade.init.selector,
            feeds,
            facets
        );

        //Creates FacetCut array
        ozIDiamond.FacetCut[] memory cuts = new ozIDiamond.FacetCut[](1);
        cuts[0] = _createCut(address(ozOracle), 0);

        vm.prank(deployer);
        OZL.diamondCut(cuts, address(initUpgrade), data);

        //--------
        energyFacet = new EnergyETHFacet();

        deal(address(USDC), bob, 5000 * 10 ** 6);

        _setLabels();

        //-----------------
        // targetContract(address(ozOracle));
        // bytes4[] memory selecs = new bytes4[](1);
        // selecs[0] = ozOracle.getLastPrice.selector;

        // FuzzSelector memory selectors = FuzzSelector({
        //     addr: address(ozOracle),
        //     selectors: selecs
        // });

        // targetSelector(selectors);

    }

    //---------

    function test_getPrice() public {
        uint price = energyFacet.getPrice();
        assertTrue(price > 0);
    }

    function testFuzz_issue(address user_, uint256 amount_) public {
        vm.assume(user_ != address(0));
        vm.assume(amount_ > 0);
        vm.assume(amount_ < 3);
        require((amount_ * energyFacet.getPrice()) < type(uint256).max);

        uint256 quote = (amount_ * energyFacet.getPrice()) / 10 ** 12;
        // require(quote <= USDC.balanceOf(bob), 'fff');
        console.log('qqqq: ', quote);

        vm.startPrank(bob);
        USDC.approve(address(energyFacet), type(uint).max);

        console.log(4);

        console.log('is - true: ', amount_ <= USDC.balanceOf(bob));
        console.log('bob: ', bob);

        energyFacet.issue(user_, amount_);

        vm.stopPrank();

        uint bal = USDC.balanceOf(address(energyFacet));
        assertTrue(bal > 0);
    }





    //------ Helpers -----

    function invariant_myTest() public {
        vm.selectFork(arbFork);
        assertTrue(true);
    }


    function _createCut(
        address contractAddr_, 
        uint8 id_
    ) private view returns(ozIDiamond.FacetCut memory cut) {
        bytes4[] memory selectors = new bytes4[](1);
        if (id_ == 0) selectors[0] = ozOracle.getEnergyPrice.selector;

        cut = ozIDiamond.FacetCut({
            facetAddress: contractAddr_,
            action: ozIDiamond.FacetCutAction.Add,
            functionSelectors: selectors
        });
    }


    function _createContracts() private returns(
        address[] memory,
        address[] memory
    ) {
        ethFeed = new EthFeed();
        goldFeed = new GoldFeed();
        wtiFeed = new WtiFeed();

        ozOracle = new ozOracleFacet(); 
        energyFacet = new EnergyETHFacet();

        address[] memory facets = new address[](2);
        facets[0] = address(ozOracle);
        facets[1] = address(energyFacet);

        address[] memory feeds = new address[](4);
        feeds[0] = address(wtiFeed);
        feeds[1] = volIndex;
        feeds[2] = address(ethFeed);
        feeds[3] = address(goldFeed); 

        return (facets, feeds);
    }


    function _setLabels() private {
        vm.label(address(ozOracle), 'ozOracle');
        vm.label(address(energyFacet), 'energyFacet');
        vm.label(address(initUpgrade), 'initUpgrade');
        vm.label(address(wtiFeed), 'wtiFeed');
        vm.label(address(ethFeed), 'ethFeed');
        vm.label(address(goldFeed), 'goldFeed');
        vm.label(address(OZL), 'OZL');
        vm.label(deployer, 'deployer2');
        vm.label(volIndex, 'volIndex');
        vm.label(crvTricrypto, 'crvTricrypto');
        vm.label(yTricryptoPoolAddr, 'yTricryptoPool');
        vm.label(chainlinkAggregatorAddr, 'chainlinkAggregator');
        vm.label(ozLoupe, 'ozLoupe');
        vm.label(revenueFacet, 'revenueFacet');
        vm.label(address(energyFacet), 'energyFacet');
        vm.label(address(USDC), 'USDC');
    }

}