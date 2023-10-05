// SPDX-License-Identifier: MIT
pragma solidity 0.8;


// Contract-address = 0x8BF17A1bBa32948ec73281d276C4C197a6F10F55 (Sepolia)
contract DaniroWallet {
    // Written by Danial Rahmani ^_^

    // GLOBAL-VALUES
    address public _OWNER_ ;
    uint collected_amount;
    bool public _Paused_ = false ;

    // STARTER-VALUES
    constructor () {
        _OWNER_ = msg.sender;
    }

    // STRUCTS
    struct ContractUser {
        address _author;
        uint _balance;
        string _name;
        uint _member_since;
        bool _exists;
    }

    struct Transaction {
        address _from;
        address _to;
        uint _amount;
    }


    // MAPS_AND_STORAGES
    mapping (address => ContractUser) Users ;
    Transaction[] All_Transactions ;

    
    // MODIFIERS
    modifier pause_check {
        require(_Paused_ == false , "Contract is Paused right-now");
        _;
    }
    modifier user_exists {
        require(Users[msg.sender]._exists, "user-not-exists");
        _;
    }
    modifier OnlyOwner {
        require(msg.sender == _OWNER_,"you are not the contract owner");
        _;
    }

    // EVENTS`
    event NEW_USER_REGISTERED(string _name , address _author,  uint _time );
    event REGISTER_USER_FAILED(string _name , address _author, uint _time );


    event Transfer_Done(address _from , address _to , uint _amount , uint _time );
    event Transfer_FAILED(address _from , address _to , uint _amount , uint _time );



    // METHODS_AND_FUNCTIONS
    
        // OWNER-ONLY-METHODS
    function change_owner (address _new_owner) public OnlyOwner {
        _OWNER_ = _new_owner;
    }

    function isPaused (bool _state) public OnlyOwner {
        _Paused_ = _state;
    }

    function Collected () public view  OnlyOwner returns (uint _collected_amount) {
        return  collected_amount;
    }

        // USERS-METHODS
    function RegisterUser ( string memory _name ) public pause_check {
        require(bytes(_name).length > 5,"_name is too short");

        if (Users[msg.sender]._exists) {
            ContractUser memory newUser = ContractUser({
                _author : msg.sender,
                _name : _name,
                _balance : 1000,
                _member_since : block.timestamp,
                _exists : true
            });

            Users[msg.sender] = newUser;

            emit NEW_USER_REGISTERED(newUser._name, msg.sender , newUser._member_since);
        }
        else {
            emit REGISTER_USER_FAILED(_name, msg.sender ,block.timestamp);
        }
    }

    function TransferToken ( uint _amount , address _to ) public pause_check {
        require(_amount <=  Users[msg.sender]._balance + 1 ,"amount is more that your balance");
        if (Users[_to]._exists) {
            Users[msg.sender]._balance -= _amount +1 ;
            Users[_to]._balance += _amount ;
            collected_amount += 1 ;
            Transaction memory newTransaction = Transaction({
                _from : msg.sender,
                _to : _to,
                _amount : _amount
            });

            All_Transactions.push(newTransaction);
            
            emit Transfer_Done(msg.sender, _to, _amount, block.timestamp);
        }   
        else {
            emit Transfer_FAILED(msg.sender, _to, _amount, block.timestamp);
        }
    }

    function MyBalance () public view pause_check returns (uint _amount) {
        return Users[msg.sender]._balance;
    }

    function MyData () public view pause_check returns (ContractUser memory _user) {
        return Users[msg.sender];
    }

    function All_Transaction_List () public view pause_check returns (Transaction[] memory _transactions) {
        return All_Transactions;
    }
}