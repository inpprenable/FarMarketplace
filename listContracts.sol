pragma solidity ^0.5.1;

//import "./polyContract.sol";
//import "./masterContrat.sol";
import "./atomContract.sol";

contract listContracts is Ownable {
    Contrat[] public list; //TODO rendre internal


    event newContract(address indexed _owner,address _contrat);

    mapping (address => uint) internal numberOfContrat;
    uint public nbContr;

    constructor() public Ownable(){}

    /**
     * create a contract and put its address in the list
     * emit an event with the address of the new contract
     */
    function createAtomContract(uint _price, string memory _title, string memory _localisation, string memory _description, uint _dell_price) public {
        Contrat myContrat = new atomContract(_price, _title, _localisation, _description, _dell_price);
        myContrat.transferOwnership(msg.sender);
        endOfCreation(myContrat);
    }

    /**
     * create a master contract and put its address in the list
     * emit an event with the address of the new contract
     */
    /*
    function createMasterContract(uint _priceByUnit,uint _Qinit, string _title,string _localisation) public{
        Contrat myContrat = new masterContract(_priceByUnit, _Qinit, _title, _localisation);
        myContrat.transferOwnership(msg.sender);
        endOfCreation(myContrat);
    }
    */

    /**
     * create a poly contract and put its address in the list
     * only a master contract can use this function
     * emit an event with the address of the new contract
     */
    /*
    function createPolyContract(uint _price,uint _Q,string _title,string _localisation,address _buyer, address _owner)public payable returns(address){
        //require(Contrat(msg.sender).getType()==Contrat.Type.master);//TODO risque d'erreur
        assert(msg.sender.call(bytes4(keccak256("isMaster()"))));
        uint pInt = _price/(1 ether);
        Contrat myContrat = new polyContract(pInt, _Q, _title, _localisation,_buyer);
        myContrat.transferOwnership(_owner);
        endOfCreation(myContrat);
        return(address(myContrat));
    }
    */

    function endOfCreation(Contrat myContrat)private{
        list.push(myContrat);
        numberOfContrat[msg.sender]++;
        nbContr++;
        emit newContract(msg.sender,address(myContrat));
    }

    /**
     * return the list of all contract sold by the user
     * the function return this list by pack of 20
     *
     *
     * Comment l'utiliser :
     *  faire appel à getNbC pour connaitre _contratRestant
     *  initialiser sorti
     *  lancer a,b,c = giveContratByAuthor(_owner,getNbC(_owner),0)
     *  tant que a> 20 :
     *      sorti.extend C
     *      lancer a,b,c = giveContratByAuthor(_owner,a-20,b)
     *  sorti.extend(c[:a])
     **/
    function giveContratByAuthor(address _owner,uint _contratRestant,uint _i) external view returns(uint, Contrat[20] memory){
        Contrat[20] memory contratOfOwner;
        uint CR = _contratRestant;
        uint j=0;
        uint i;
        for(i =_i;i<nbContr && CR>0 && j<20;i++){
            //if(list[i].call(abi.encodeWithSignature("getOwner(address)", _owner))){
            //if(Contrat(list[i]).owner()==_owner){
            //if(list[i].call(abi.encodeWithSignature("isOwner(address)", _owner))){
            if(list[i].isOwner(_owner)){
                contratOfOwner[j]=list[i];
                j++;
                CR--;
            }
        }
        return (i,contratOfOwner);
    }


    /**
     * return the list of all contract which the user can buy
     * these contract are available and not belong to him
     * the function return this list by pack of 20
     */
    function givaAvailibleContracts(uint _i) external view returns(uint,uint,Contrat[20] memory){
        Contrat[20] memory contratBuyed;
        uint j=0;
        uint i;
        for(i=_i;i<list.length && j<20;i++){
            if(list[i].isAvailible(msg.sender)){
                contratBuyed[j] = list[i];
                j++;
            }
        }
        return(i,j,contratBuyed);
    }


    /**
     * give the total number of contracts
     */
    function getNbC(address _owner) external view returns(uint){
        return numberOfContrat[_owner];
    }
}