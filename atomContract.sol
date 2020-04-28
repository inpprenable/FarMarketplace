pragma solidity ^0.5.1;

import "./contract.sol";
contract atomContract is Contrat {

    uint internal price;
    address payable internal buyer;
    address payable internal deliverer;
    uint8 internal ratingCD = 255;
    uint8 internal ratingFD = 255;
    uint8 internal ratingCF = 255;
    uint8 internal ratingDF = 255;
    uint8 internal ratingDC = 255;
    
    bytes32 internal hash_localisation_buyer;


    constructor(uint _price, string memory _title, string memory _localisation, string memory _description, uint _dell_price) public Contrat(_title,_localisation, _description, _dell_price){
        require(_price!=0 );
        price = _price * (1 ether);
        typee = Type.atom;
    }

    /**
     * a user buy the contract. the money is put on the balance, the buyer is set, the disponibility is set to delivering
     * an event is send
     */
    function buy(string calldata _localisation_buyer) external payable {
        require(msg.value == price + dell_price);
        require(dispo == Disponibility.Available);
        buyer = msg.sender;
        dispo = Disponibility.Wait_for_deliverer;
        hash_localisation_buyer = sha256(abi.encode(_localisation_buyer));
        emit dispoChanged();
    }
    
    function select_delivery() external {
        require(dispo == Disponibility.Wait_for_deliverer);
        deliverer = msg.sender;
        dispo = Disponibility.Wait_for_delivering;
        emit dispoChanged();
    }
    
    function receive_from_seller(uint8 _ratingDF ) external{
        require(msg.sender == deliverer);
        require(dispo == Disponibility.Wait_for_delivering);
        require(_ratingDF <= 10);
        dispo = Disponibility.On_delivering;
        ratingDF = _ratingDF;
        emit dispoChanged();
    }

    /**
     * the buyer receive the object of the contract, the seller receives the money, and the disponibility is set to validated
     * an event is send
     */
    function reception() external{
        require(msg.sender == buyer);
        require(dispo == Disponibility.On_delivering);
        owner.transfer(price);
        deliverer.transfer(dell_price);
        dispo = Disponibility.Wait_for_rating;
        emit dispoChanged();
    }
    
    function finish_contract() internal{
        require(msg.sender == owner || msg.sender == deliverer || msg.sender == buyer);
        if(dispo == Disponibility.Wait_for_rating && ratingFD != 255 && ratingDF != 255 && ratingDC != 255 && ratingCF !=255 && ratingCD != 255){
            dispo = Disponibility.Delivered;
            emit dispoChanged();
        }
    }
    
    function rate_seller(uint8 _ratingFD) external{
        require(msg.sender == owner);
        require(dispo == Disponibility.On_delivering || dispo == Disponibility.Wait_for_rating);
        require(_ratingFD <= 10);
        ratingFD = _ratingFD;
        finish_contract();
    }
    
    function rate_deliverer(uint8 _ratingDC) external {
        require(msg.sender == deliverer);
        require(dispo == Disponibility.Wait_for_rating);
        require(_ratingDC <= 10);
        ratingDC = _ratingDC;
        finish_contract();
    }
    
    function rate_buyer(uint8 _ratingCD, uint8 _ratingCF) external {
        require(msg.sender == buyer);
        require(dispo == Disponibility.Wait_for_rating);
        require(_ratingCD <= 10);
        require(_ratingCF <= 10);
        ratingCD = _ratingCD;
        ratingCF = _ratingCF;
        finish_contract();
    }
    
    
    function getPrice() external view returns(uint){
        return price;
    }
    
    function getBuyer() external view returns(address){
        return buyer;
    }
    
    function getDeliverer() external view returns(address){
        return deliverer;
    }

}