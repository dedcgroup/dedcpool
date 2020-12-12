pragma solidity ^0.4.24;

contract owned {
    address public owner;
    
    constructor () public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}
  
/******************************************/
/*       node pool manager       */
/******************************************/

contract DEDCPool is owned {
    
   struct nodepool {
        uint256 quota;
        uint256 release;
        uint256 balance;
    }
    
    mapping (address => nodepool) public nodepools;
    uint256 private quota=500000000; //10000 multiple ,Node total  quota  50000
    uint256 private release_quota=500000;//10000 multiple ,Each release  50
    uint16 private max=420;

    /* Initializes contract with initial  the creator of the contract */
    constructor () owned() public { }
 
 
    function ReleaseToNode(address nodeadd,uint256 release) onlyOwner  public  returns(bool)  {
        require(max != 0);
        if(nodepools[nodeadd].quota==0){
            nodepools[nodeadd].quota=quota;
            nodepools[nodeadd].release=0;
            nodepools[nodeadd].balance=quota;
            max--;
       }
       if(nodepools[nodeadd].quota>0){
           if(nodepools[nodeadd].balance==0) return false;
            if(release>=nodepools[nodeadd].quota){
                nodepools[nodeadd].release=nodepools[nodeadd].quota;
                nodepools[nodeadd].balance=0;
            }else{
                nodepools[nodeadd].release =release;
                nodepools[nodeadd].balance=nodepools[nodeadd].quota-nodepools[nodeadd].release;
            }
            return true;
       }
       return false;
    }
  
    function GetPreRelease(address nodeadd)  public  returns(uint256)  {
        if(nodepools[nodeadd].quota>0 && nodepools[nodeadd].balance>0){
            if((nodepools[nodeadd].release+release_quota)>nodepools[nodeadd].quota){
                return nodepools[nodeadd].quota-nodepools[nodeadd].release;
            }else{
                return release_quota;
            }
        }
        return 0;
    }
    
    function ModifyAddress(address oldAdd, address newAdd) onlyOwner  public  returns(bool)  {
        require(oldAdd!=newAdd && nodepools[oldAdd].quota>0 && nodepools[newAdd].quota==0);
        nodepools[newAdd].quota=nodepools[oldAdd].quota;
        nodepools[newAdd].release=nodepools[oldAdd].release;
        nodepools[newAdd].balance=nodepools[oldAdd].balance;
        nodepools[oldAdd].quota=0;
        nodepools[oldAdd].release=0;
        nodepools[oldAdd].balance=0;
        return true;
    }
    
  function ModifyRelease(uint256 release) onlyOwner  public  returns(bool)  {
       release_quota=release*10000;
        return true;
  }
    function GetInfo(address add)  public  returns(uint256,uint256,uint256)  {
        return (nodepools[add].quota,nodepools[add].release,nodepools[add].balance);
    }
  
}
