pragma solidity 0.8.19;




interface ozIExecutorFacet {

    function calculateSlippage(
        uint amount_, 
        uint basisPoint_
    ) external view returns(uint minAmountOut);

}