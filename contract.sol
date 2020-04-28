pragma solidity ^0.5.1;

import "./ownable.sol";


contract Contrat is Ownable {

    enum Disponibility{Available, Canceled, Wait_for_deliverer, Wait_for_delivering, On_delivering, Wait_for_rating, Delivered}
    enum Type{atom,poly,master}

    Disponibility internal dispo;
    Type internal typee;

    event dispoChanged();
    event contratUpdate();

    bytes32 internal hash_desc;
    
    uint internal dell_price;

    /**
     * create a smart contract, initialize his value and put his disponibility to Available
     */
    constructor(string memory _title,string memory _localisation, string memory _description, uint _dell_price) public Ownable(){
        hash_desc = sha256(abi.encode(_title,_description,_localisation));
        dispo = Disponibility.Available;
        dell_price = _dell_price *(1 ether);
    }

    /**
     * a modifier which allow modification only if the contract is cancel
     */
    modifier onlyDispo(){
        require(dispo == Disponibility.Canceled);
        _;
    }

    /**
     * change the disponibility from available to cancel, or from cancel to available
     * an event is send
     */
    function avalaibleToCancel() external onlyOwner{
        require(dispo==Disponibility.Available || dispo==Disponibility.Canceled);
        if(dispo == Disponibility.Available){
            dispo = Disponibility.Canceled;
        }else{
            dispo = Disponibility.Available;
        }
        emit dispoChanged();
    }


    function getHash_desc()external view returns(bytes32){
        return hash_desc;
    }


    function getDispo() external view returns(Disponibility){
        return dispo;
    }

    function getTypee() external view returns(Type){
        return typee;
    }

    /**
     * various intermediate functions used in listContracts
     * if the condition are not met, an error occurred
     * they are define in order to avoid the use of function costing infinite gas
     */

    function isAvailible(address _someone) external view returns(bool){
        require((dispo == Disponibility.Available) && (owner!=_someone));
        return(true);
    }

    function isMaster()external view returns(bool){
        require(typee==Type.master);
        return true;
    }

}